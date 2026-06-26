import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gold_button.dart';
import '../../models/review.dart';
import '../../services/review_service.dart';

class ReviewsScreen extends StatefulWidget {
  final String productId;

  const ReviewsScreen({super.key, required this.productId});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  List<Review>? _reviews;
  double _averageRating = 0;
  bool _isLoading = true;
  String? _error;

  // Submit form
  final _formKey = GlobalKey<FormState>();
  final _reviewTextCtrl = TextEditingController();
  int _selectedRating = 5;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _reviewTextCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final svc = context.read<ReviewService>();
      final results = await Future.wait([
        svc.getProductReviews(widget.productId),
        svc.getProductRating(widget.productId),
      ]);
      if (mounted) {
        setState(() {
          _reviews = results[0] as List<Review>;
          _averageRating = results[1] as double;
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

  Future<void> _submitReview() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      final authState = context.read<AuthBloc>().state;
      final userId = authState is AuthAuthenticated ? authState.user.id : '';
      if (userId.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to review.')),
          );
        }
        return;
      }

      final svc = context.read<ReviewService>();
      await svc.createReview(
        userId: userId,
        productId: widget.productId,
        reviewText: _reviewTextCtrl.text.trim(),
        rating: _selectedRating,
      );
      _reviewTextCtrl.clear();
      setState(() => _selectedRating = 5);
      await _loadData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Review submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: AppBar(
        backgroundColor: HColors.surface,
        title: Text('Reviews',
            style: HText.headlineMd.copyWith(color: HColors.primary)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: HColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Failed to load reviews',
                          style: HText.headlineMd),
                      const SizedBox(height: 8),
                      Text(_error!, style: HText.bodyMd),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Rating summary
                      _ratingSummary(),
                      const SizedBox(height: 24),

                      // Review list
                      Text('Reviews',
                          style: HText.headlineMd
                              .copyWith(color: HColors.onSurface)),
                      const SizedBox(height: 12),
                      if (_reviews != null && _reviews!.isNotEmpty)
                        ..._reviews!.map((r) => _reviewTile(r))
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Text('No reviews yet. Be the first!',
                                style: HText.bodyMd
                                    .copyWith(color: HColors.outline)),
                          ),
                        ),

                      const SizedBox(height: 32),

                      // Submit form
                      Text('Write a Review',
                          style: HText.headlineMd
                              .copyWith(color: HColors.onSurface)),
                      const SizedBox(height: 12),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Star rating selector
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(5, (i) {
                                return IconButton(
                                  onPressed: () =>
                                      setState(() => _selectedRating = i + 1),
                                  icon: Icon(
                                    i < _selectedRating
                                        ? Icons.star
                                        : Icons.star_outline,
                                    color: HColors.secondary,
                                    size: 32,
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 12),
                            TextFormField(
                              controller: _reviewTextCtrl,
                              maxLines: 3,
                              decoration: InputDecoration(
                                hintText: 'Share your thoughts...',
                                hintStyle: HText.bodyMd
                                    .copyWith(color: HColors.outline),
                                filled: true,
                                fillColor: HColors.surfaceContainerLowest,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              validator: (v) => v == null || v.trim().isEmpty
                                  ? 'Please write something'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            GoldButton(
                              text: _isSubmitting
                                  ? 'Submitting…'
                                  : 'Submit Review',
                              onPressed:
                                  _isSubmitting ? null : _submitReview,
                              isLoading: _isSubmitting,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _ratingSummary() {
    // Build distribution
    final dist = <int, int>{for (var i = 1; i <= 5; i++) i: 0};
    if (_reviews != null) {
      for (final r in _reviews!) {
        dist[r.rating] = (dist[r.rating] ?? 0) + 1;
      }
    }
    final maxCount =
        _reviews != null && _reviews!.isNotEmpty
            ? dist.values.reduce((a, b) => a > b ? a : b).toDouble()
            : 1.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Average rating
          SizedBox(
            width: 80,
            child: Column(
              children: [
                Text(
                  _averageRating.toStringAsFixed(1),
                  style: HText.displayLg.copyWith(
                      color: HColors.onSurface, fontSize: 40),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star, size: 16, color: HColors.secondary),
                    const SizedBox(width: 4),
                    Text(
                      '${_reviews?.length ?? 0} reviews',
                      style: HText.labelSm.copyWith(color: HColors.outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          // Distribution bars
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final count = dist[star] ?? 0;
                final fraction =
                    maxCount > 0 ? count / maxCount : 0.0;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 14,
                        child: Text('$star',
                            style: HText.labelSm
                                .copyWith(color: HColors.outline)),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: fraction,
                            backgroundColor:
                                HColors.outlineVariant.withValues(alpha: 0.3),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              fraction > 0
                                  ? HColors.secondary
                                  : Colors.transparent,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      SizedBox(
                        width: 20,
                        child: Text('$count',
                            style: HText.labelSm
                                .copyWith(color: HColors.outline)),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _reviewTile(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ...List.generate(5, (i) {
                return Icon(
                  i < review.rating ? Icons.star : Icons.star_outline,
                  size: 16,
                  color: HColors.secondary,
                );
              }),
              const Spacer(),
              if (review.createdAt != null)
                Text(
                  _formatDate(review.createdAt!),
                  style: HText.labelSm.copyWith(color: HColors.outline),
                ),
            ],
          ),
          if (review.reviewText != null && review.reviewText!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(review.reviewText!,
                style: HText.bodyMd.copyWith(color: HColors.onSurface)),
          ],
          if (review.image.isNotEmpty) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                review.image,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
