import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/product_card.dart';
import '../../models/collection.dart';
import '../../models/product.dart';
import '../../services/collection_service.dart';

class CollectionDetailScreen extends StatefulWidget {
  final String collectionId;

  const CollectionDetailScreen({super.key, required this.collectionId});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  Collection? _collection;
  List<Product>? _products;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final svc = context.read<CollectionService>();
      final results = await Future.wait([
        svc.getCollectionById(widget.collectionId),
        svc.getCollectionProducts(widget.collectionId),
      ]);
      if (mounted) {
        setState(() {
          _collection = results[0] as Collection;
          _products = results[1] as List<Product>;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: HColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Failed to load', style: HText.headlineMd),
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
              : CustomScrollView(
                  slivers: [
                    // Hero image + title
                    SliverAppBar(
                      expandedHeight: 240,
                      pinned: true,
                      backgroundColor: HColors.surface,
                      leading: IconButton(
                        icon: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: HColors.surface.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.arrow_back,
                              color: HColors.primary, size: 22),
                        ),
                        onPressed: () => context.pop(),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        background: _collection!.image.isNotEmpty
                            ? Image.network(_collection!.image,
                                fit: BoxFit.cover)
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      HColors.primary.withValues(alpha: 0.8),
                                      HColors.primary.withValues(alpha: 0.1),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Icon(Icons.museum_outlined,
                                      size: 64,
                                      color: HColors.surface
                                          .withValues(alpha: 0.6)),
                                ),
                              ),
                      ),
                    ),

                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _collection?.title ?? '',
                              style: HText.headlineLg
                                  .copyWith(color: HColors.onSurface),
                            ),
                            const SizedBox(height: 8),
                            if (_collection!.type.isNotEmpty)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 4),
                                decoration: BoxDecoration(
                                  color: HColors.primaryContainer
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  _collection!.type,
                                  style: HText.labelSm
                                      .copyWith(color: HColors.primary),
                                ),
                              ),
                            const SizedBox(height: 12),
                            Text(
                              _collection?.description ?? '',
                              style: HText.bodyLg
                                  .copyWith(color: HColors.outline),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Products',
                              style: HText.headlineMd
                                  .copyWith(color: HColors.onSurface),
                            ),
                            const SizedBox(height: 12),
                          ],
                        ),
                      ),
                    ),

                    // Product grid
                    if (_products != null && _products!.isNotEmpty)
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.72,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = _products![index];
                              return ProductCard(
                                id: product.id,
                                name: product.name,
                                subtitle: product.description,
                                imageUrl: product.imageUrl,
                                price: product.price,
                                category: product.category,
                                onAddToCart: () {
                                  // Handled by parent / cart cubit
                                },
                              );
                            },
                            childCount: _products!.length,
                          ),
                        ),
                      )
                    else
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              'No products in this collection yet.',
                              style: HText.bodyMd
                                  .copyWith(color: HColors.outline),
                            ),
                          ),
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 40)),
                  ],
                ),
    );
  }
}
