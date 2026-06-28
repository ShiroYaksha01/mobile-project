import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/cart/cart_cubit.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/gold_button.dart';
import '../../models/product.dart';
import '../../services/collection_service.dart';
import '../../services/product_service.dart';
import '../../services/quiz_service.dart';

class GiftFinderQuizScreen extends StatefulWidget {
  const GiftFinderQuizScreen({super.key});

  @override
  State<GiftFinderQuizScreen> createState() => _GiftFinderQuizScreenState();
}

class _GiftFinderQuizScreenState extends State<GiftFinderQuizScreen> {
  List<Map<String, dynamic>>? _questions;
  int _currentStep = 0;
  final Set<String> _selectedAnswerIds = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _error;

  // Results
  Map<String, dynamic>? _result;

  @override
  void initState() {
    super.initState();
    _loadQuiz();
  }

  Future<void> _loadQuiz() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final svc = context.read<QuizService>();
      final questions = await svc.getQuizQuestions();
      if (mounted) {
        setState(() {
          _questions = questions;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _findGifts() async {
    setState(() => _isSubmitting = true);

    // Collect all tags from selected answers
    final tags = <String>{};
    if (_questions != null) {
      for (final q in _questions!) {
        final answers = (q['quizAnswers'] as List<dynamic>?) ?? [];
        for (final a in answers) {
          final answer = a as Map<String, dynamic>;
          final answerId = answer['id'] as String? ?? '';
          if (_selectedAnswerIds.contains(answerId)) {
            final tagStr = (answer['tags'] as String?) ?? '';
            tags.addAll(tagStr.split(',')
                .map((t) => t.trim().toLowerCase())
                .where((t) => t.isNotEmpty));
          }
        }
      }
    }

    // Prioritize collection products with images
    final collectionService = context.read<CollectionService>();
    List<Product> pool = [];
    try {
      final collections = await collectionService.getCollections();
      if (collections.isNotEmpty) {
        // Pick a random collection
        collections.shuffle(Random(tags.hashCode));
        final col = collections.first;
        final id = col.id;
        if (id.isNotEmpty) {
          pool = await collectionService.getCollectionProducts(id);
        }
      }
    } catch (_) {}

    // Fallback: fetch all products
    if (pool.isEmpty) {
      try {
        pool = await context.read<ProductService>().getAllProducts();
      } catch (_) {}
    }

    // Only keep products with images
    final withImages = pool.where((p) => p.imageUrl.isNotEmpty).toList();
    if (withImages.isNotEmpty) pool = withImages;

    // Score each product against collected tags
    final scored = <_ScoredProduct>[];
    for (final p in pool) {
      int score = 0;
      final nameLow = p.name.toLowerCase();
      final descLow = p.description.toLowerCase();
      final catLow = p.category.toLowerCase();

      for (final tag in tags) {
        if (nameLow.contains(tag)) score += 3;
        if (descLow.contains(tag)) score += 2;
        if (catLow.contains(tag)) score += 1;
      }
      if (score > 0) scored.add(_ScoredProduct(p, score));
    }

    // If no matches, just use pool products with images
    if (scored.isEmpty && pool.isNotEmpty) {
      pool.shuffle();
      for (final p in pool.take(3)) {
        scored.add(_ScoredProduct(p, 1));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    final top = scored.take(6).toList();
    top.shuffle(Random(tags.hashCode));
    final matched = top.take(3).map((sp) => sp.product).toList();

    final result = <String, dynamic>{
      'feedback': matched.isNotEmpty
          ? 'We found ${matched.length} treasures from our collections!'
          : 'No exact matches found. Try different answers!',
      'matchedTags': tags.toList(),
      'recommendedProducts': matched,
    };

    if (mounted) {
      setState(() {
        _result = result;
        _isSubmitting = false;
      });
    }
  }

  void _toggleAnswer(String answerId) {
    setState(() {
      if (_selectedAnswerIds.contains(answerId)) {
        _selectedAnswerIds.remove(answerId);
      } else {
        _selectedAnswerIds.add(answerId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: AppBar(
        backgroundColor: HColors.surface,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HColors.primary),
          onPressed: () => context.go('/home'),
        ),
        title: Text('Gift Finder',
            style: HText.headlineMd.copyWith(color: HColors.primary)),
        centerTitle: true,
      ),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (ctx, cs) => HeritageBottomNav(
          currentIndex: -1,
          cartCount: cs.cartCount,
          onTap: (i) {
            if (i == 0) context.go('/home');
            if (i == 1) context.go('/shop');
            if (i == 2) context.go('/saved');
            if (i == 3) context.go('/cart');
            if (i == 4) context.go('/nearby');
          },
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: HColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Quiz unavailable',
                          style: HText.headlineMd),
                      const SizedBox(height: 8),
                      Text(_error!, style: HText.bodyMd),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadQuiz,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _result != null
                  ? _buildResults()
                  : _buildQuestion(),
    );
  }

  Widget _buildQuestion() {
    if (_questions == null || _questions!.isEmpty) {
      return Center(
        child: Text('No quiz questions available.',
            style: HText.bodyMd.copyWith(color: HColors.outline)),
      );
    }

    final question = _questions![_currentStep];
    final questionText =
        question['questionText'] as String? ?? 'Question ${_currentStep + 1}';
    final answers = (question['quizAnswers'] as List<dynamic>?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];
    final totalSteps = _questions!.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Progress
          Row(
            children: List.generate(totalSteps, (i) {
              return Expanded(
                child: Container(
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: i <= _currentStep
                        ? HColors.primary
                        : HColors.outlineVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text('Step ${_currentStep + 1} of $totalSteps',
              style: HText.labelSm.copyWith(color: HColors.outline),
              textAlign: TextAlign.center),
          const SizedBox(height: 32),

          // Question
          Text(questionText,
              style: HText.headlineMd.copyWith(color: HColors.onSurface)),
          const SizedBox(height: 24),

          // Answers
          ...answers.map((answer) {
            final answerId = answer['id'] as String? ?? '';
            final answerText = answer['answerText'] as String? ?? '';
            final isSelected = _selectedAnswerIds.contains(answerId);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: GestureDetector(
                onTap: () => _toggleAnswer(answerId),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? HColors.primaryContainer.withValues(alpha: 0.2)
                        : HColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? HColors.primary : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? HColors.primary
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? HColors.primary
                                : HColors.outline,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.check,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(answerText,
                            style: HText.bodyLg.copyWith(
                                color: HColors.onSurface)),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),

          // Navigation buttons
          Row(
            children: [
              if (_currentStep > 0)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        setState(() => _currentStep--),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Back'),
                  ),
                ),
              if (_currentStep > 0) const SizedBox(width: 12),
              Expanded(
                child: GoldButton(
                  text: _currentStep < totalSteps - 1 ? 'Next' : 'Find Gifts!',
                  onPressed: () {
                    if (_currentStep < totalSteps - 1) {
                      setState(() => _currentStep++);
                    } else {
                      _findGifts();
                    }
                  },
                  isLoading:
                      _currentStep == totalSteps - 1 && _isSubmitting,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResults() {
    final feedback =
        _result!['feedback'] as String? ?? 'Here are your recommendations!';
    final matchedTags =
        (_result!['matchedTags'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [];
    final rawProducts =
        _result!['recommendedProducts'] as List<dynamic>? ?? [];
    final products = rawProducts
        .whereType<Product>()
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.card_giftcard,
              size: 64, color: HColors.secondary),
          const SizedBox(height: 16),
          Text('Your Gift Matches!',
              style: HText.headlineLg.copyWith(color: HColors.onSurface),
              textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(feedback,
              style: HText.bodyLg.copyWith(color: HColors.outline),
              textAlign: TextAlign.center),
          if (matchedTags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 6,
              children: matchedTags
                  .map((tag) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              HColors.primaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(tag,
                            style: HText.labelSm
                                .copyWith(color: HColors.primary)),
                      ))
                  .toList(),
            ),
          ],
          const SizedBox(height: 24),

          // Recommended products
          if (products.isNotEmpty) ...[
            Text('Recommended for You',
                style: HText.headlineMd.copyWith(color: HColors.onSurface)),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];
                return _productResultCard(p);
              },
            ),
          ],

          const SizedBox(height: 24),
          GoldButton(
            text: 'Restart Quiz',
            onPressed: () {
              setState(() {
                _currentStep = 0;
                _selectedAnswerIds.clear();
                _result = null;
              });
            },
            isOutlined: true,
          ),
        ],
      ),
    );
  }

  Widget _productResultCard(Product product) {
    return Container(
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E2E2E).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  HColors.primary.withValues(alpha: 0.7),
                  HColors.primary.withValues(alpha: 0.25),
                ],
              ),
            ),
            child: product.imageUrl.isNotEmpty
                ? Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.card_giftcard,
                          size: 40,
                          color: HColors.surface.withValues(alpha: 0.6)),
                    ),
                  )
                : Center(
                    child: Icon(Icons.card_giftcard,
                        size: 40,
                        color: HColors.surface.withValues(alpha: 0.6)),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name,
                    style: HText.labelLg
                        .copyWith(color: HColors.onSurface),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text('\$${product.price.toStringAsFixed(2)}',
                    style: HText.labelLg.copyWith(
                        color: HColors.primary,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ScoredProduct {
  final Product product;
  final int score;
  _ScoredProduct(this.product, this.score);
}
