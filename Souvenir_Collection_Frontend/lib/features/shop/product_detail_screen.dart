import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/cart/cart_cubit.dart';
import '../../blocs/favorites/favorites_cubit.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/favorites_service.dart';
import '../../services/order_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Product? _product;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() { _isLoading = true; _error = null; });
    try {
      final svc = context.read<ProductService>();
      final product = await svc.getProductById(widget.productId);
      if (mounted) {
        final favIds = context.read<FavoritesCubit>().state.favoriteIds;
        setState(() {
          _product = product;
          _isFavorite = favIds.contains(product.id);
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

  Future<void> _toggleFavorite() async {
    final userId = _currentUserId;
    if (userId == null || _product == null) return;
    try {
      final favService = context.read<FavoritesService>();
      await favService.toggleFavorite(userId, _product!.id);
      if (mounted) {
        context.read<FavoritesCubit>().toggle(_product!.id);
        setState(() => _isFavorite = !_isFavorite);
      }
    } catch (_) {}
  }

  Future<void> _addToCart() async {
    final userId = _currentUserId;
    if (userId == null || _product == null) return;
    try {
      final orderService = context.read<OrderService>();
      await orderService.addToCart(userId, _product!.id);
      if (mounted) {
        context.read<CartCubit>().increment();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_product!.name} added to cart'),
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
                      const Icon(Icons.error_outline, size: 48, color: HColors.error),
                      const SizedBox(height: 12),
                      Text('Failed to load', style: HText.headlineMd),
                      const SizedBox(height: 8),
                      Text(_error!, style: HText.bodyMd.copyWith(color: HColors.outline)),
                      const SizedBox(height: 16),
                      ElevatedButton(onPressed: _loadProduct, child: const Text('Retry')),
                    ],
                  ),
                )
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    final product = _product!;
    final meta = _categoryMeta[product.category] ??
        _fallbackIcons[product.id.hashCode % _fallbackIcons.length];

    return CustomScrollView(
      slivers: [
        // Hero image with back button
        SliverAppBar(
          expandedHeight: 300,
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
          actions: [
            IconButton(
              icon: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: HColors.surface.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_outline,
                  color: _isFavorite ? HColors.error : HColors.onSurfaceVariant,
                  size: 20,
                ),
              ),
              onPressed: _toggleFavorite,
            ),
            const SizedBox(width: 8),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildImagePlaceholder(meta),
                      )
                    : _buildImagePlaceholder(meta),
                // Gradient overlay for back button visibility
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.1),
                      ],
                    ),
                  ),
                ),
              ],
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
                // Category badge
                if (product.category.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: meta.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      product.category,
                      style: HText.labelSm.copyWith(color: meta.color, fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(height: 12),

                // Product name
                Text(product.name, style: HText.headlineLg.copyWith(color: HColors.onSurface)),
                const SizedBox(height: 8),

                // Price
                Row(
                  children: [
                    Text(
                      '\$${product.price.toStringAsFixed(0)}',
                      style: HText.headlineMd.copyWith(
                        color: HColors.primary,
                        fontWeight: FontWeight.w800,
                        fontSize: 26,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (product.stockQty > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: HColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${product.stockQty} in stock',
                          style: HText.labelSm.copyWith(color: HColors.success),
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: HColors.error.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Out of stock',
                          style: HText.labelSm.copyWith(color: HColors.error),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 20),

                // Description
                Text('Description', style: HText.headlineMd.copyWith(color: HColors.onSurface)),
                const SizedBox(height: 8),
                Text(
                  product.description.isNotEmpty ? product.description : 'No description available.',
                  style: HText.bodyLg.copyWith(color: HColors.outline, height: 1.6),
                ),
                const SizedBox(height: 24),

                // Quick links row
                Row(
                  children: [
                    if (product.artisanId.isNotEmpty)
                      Expanded(
                        child: _QuickLinkCard(
                          icon: Icons.person_outline,
                          label: 'View Artisan',
                          color: HColors.secondary,
                          onTap: () => context.push('/artisan/${product.artisanId}'),
                        ),
                      ),
                    if (product.artisanId.isNotEmpty) const SizedBox(width: 12),
                    Expanded(
                      child: _QuickLinkCard(
                        icon: Icons.star_outline,
                        label: 'Reviews',
                        color: HColors.primary,
                        onTap: () => context.push('/reviews/${product.id}'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // space for bottom button
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder(_Meta meta) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [meta.color.withValues(alpha: 0.7), meta.color.withValues(alpha: 0.3)],
        ),
      ),
      child: Center(
        child: Icon(meta.icon, size: 80, color: Colors.white.withValues(alpha: 0.7)),
      ),
    );
  }
}

// ─── quick link card ──────────────────────────────────────────────────
class _QuickLinkCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickLinkCard({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(label, style: HText.labelLg.copyWith(color: color)),
          ],
        ),
      ),
    );
  }
}

// ─── category color metadata ──────────────────────────────────────────
class _Meta {
  final Color color;
  final IconData icon;
  const _Meta(this.color, this.icon);
}

final _categoryMeta = {
  'Textile':  _Meta(const Color(0xFF8B3A2B), Icons.spa_outlined),
  'Silver':   _Meta(const Color(0xFFD4AF37), Icons.diamond_outlined),
  'Wood':     _Meta(const Color(0xFF5A2117), Icons.park_outlined),
  'Jewelry':  _Meta(const Color(0xFFB75D4E), Icons.stars_outlined),
  'Ceramics': _Meta(const Color(0xFF997A00), Icons.palette_outlined),
};

const _fallbackIcons = [
  _Meta(Color(0xFF8B3A2B), Icons.spa_outlined),
  _Meta(Color(0xFFD4AF37), Icons.auto_awesome),
  _Meta(Color(0xFF5A2117), Icons.category_outlined),
  _Meta(Color(0xFFB75D4E), Icons.workspaces_outlined),
  _Meta(Color(0xFF997A00), Icons.stars_outlined),
];
