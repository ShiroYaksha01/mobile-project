import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/product_card.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/cart/cart_cubit.dart';
import '../../blocs/favorites/favorites_cubit.dart';
import '../../models/collection.dart';
import '../../models/product.dart';
import '../../services/collection_service.dart';
import '../../services/favorites_service.dart';
import '../../services/order_service.dart';

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
    setState(() { _isLoading = true; _error = null; });
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
        setState(() { _error = e.toString(); _isLoading = false; });
      }
    }
  }

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.id : null;
  }

  Future<void> _toggleFavorite(Product product) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final favService = context.read<FavoritesService>();
      await favService.toggleFavorite(userId, product.id);
      if (mounted) {
        context.read<FavoritesCubit>().toggle(product.id);
        setState(() {});
      }
    } catch (_) {}
  }

  Future<void> _addToCart(Product product) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final orderService = context.read<OrderService>();
      await orderService.addToCart(userId, product.id);
      if (mounted) {
        context.read<CartCubit>().increment();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            backgroundColor: HColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Failed to load', style: HText.headlineMd),
                      const SizedBox(height: 8),
                      Text(_error!, style: HText.bodyMd),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        return CustomScrollView(
          slivers: [
            // Hero header
            SliverAppBar(
              expandedHeight: 260,
              pinned: true,
              backgroundColor: HColors.surface,
              leading: IconButton(
                icon: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(
                    color: HColors.surface.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back, color: HColors.primary, size: 22),
                ),
                onPressed: () => context.pop(),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    _collection!.image.isNotEmpty
                        ? Image.network(_collection!.image, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _buildHeroPlaceholder())
                        : _buildHeroPlaceholder(),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.3),
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.6),
                          ],
                        ),
                      ),
                    ),
                    // Title overlay
                    Positioned(
                      bottom: 20, left: 20, right: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (_collection!.type.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: HColors.primary.withValues(alpha: 0.85),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                _collection!.type,
                                style: HText.labelSm.copyWith(color: Colors.white),
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            _collection?.title ?? '',
                            style: HText.headlineLg.copyWith(color: Colors.white, fontSize: 28),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Description
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Text(
                  _collection?.description ?? '',
                  style: HText.bodyLg.copyWith(color: HColors.outline, height: 1.6),
                ),
              ),
            ),

            // Products header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                child: Row(
                  children: [
                    Text(
                      'Products',
                      style: HText.headlineMd.copyWith(color: HColors.onSurface),
                    ),
                    const SizedBox(width: 8),
                    if (_products != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: HColors.primaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_products!.length}',
                          style: HText.labelSm.copyWith(color: HColors.primary),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Products grid
            if (_products != null && _products!.isNotEmpty)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = _products![index];
                      final isFav = favState.favoriteIds.contains(product.id);
                      return ProductCard(
                        id: product.id,
                        name: product.name,
                        subtitle: product.description,
                        imageUrl: product.imageUrl,
                        price: product.price,
                        category: product.category,
                        isFavorite: isFav,
                        onFavoriteToggle: () => _toggleFavorite(product),
                        onAddToCart: () => _addToCart(product),
                        onTap: () => context.push('/product/${product.id}'),
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
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined, size: 48, color: HColors.outline.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'No products in this collection yet.',
                          style: HText.bodyMd.copyWith(color: HColors.outline),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        );
      },
    );
  }

  Widget _buildHeroPlaceholder() {
    return Container(
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
        child: Icon(Icons.museum_outlined, size: 64, color: HColors.surface.withValues(alpha: 0.5)),
      ),
    );
  }
}
