import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/sidebar.dart';
import '../../models/product.dart';
import '../../services/favorites_service.dart';
import '../../services/order_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/cart/cart_cubit.dart';
import '../../blocs/favorites/favorites_cubit.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final int _navIndex = 2;
  List<Product> _favorites = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.id : null;
  }

  Future<void> _loadFavorites() async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final favService = context.read<FavoritesService>();
      final items = await favService.getFavoriteProducts(userId);
      if (mounted) setState(() { _favorites = items; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleFavoriteToggle(Product product) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final favService = context.read<FavoritesService>();
      final isNowFavorited = await favService.toggleFavorite(userId, product.id);
      if (mounted) {
        context.read<FavoritesCubit>().toggle(product.id);
        setState(() {
          if (!isNowFavorited) {
            _favorites.removeWhere((p) => p.id == product.id);
          } else {
            product.isFavorite = true;
          }
        });
      }
    } catch (_) {}
  }

  Future<void> _handleAddToCart(Product product) async {
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
    return BlocListener<FavoritesCubit, FavoritesState>(
      listener: (context, state) {
        // Reload favorites list from backend whenever cubit changes
        _loadFavorites();
      },
      child: _isLoading
          ? Scaffold(
              backgroundColor: HColors.background,
              appBar: const HeritageAppBar(),
              body: const Center(child: CircularProgressIndicator(color: HColors.primary)),
            )
          : Scaffold(
              backgroundColor: HColors.background,
              appBar: const HeritageAppBar(),
              endDrawer: const AppSidebar(currentIndex: -1),
              bottomNavigationBar: HeritageBottomNav(
                currentIndex: _navIndex,
                onTap: (i) {
                  if (i == _navIndex) return;
                  if (i == 0) context.go('/home');
                  if (i == 1) context.go('/shop');
                  if (i == 3) context.go('/cart');
                  if (i == 4) context.go('/nearby');
                },
              ),
              body: _favorites.isEmpty
                  ? const _EmptyFavorites()
                  : CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Saved Crafts', style: HText.headlineLg.copyWith(color: HColors.onSurface)),
                                const SizedBox(height: 6),
                                Text(
                                  '${_favorites.length} artisan pieces saved',
                                  style: HText.bodyMd.copyWith(color: HColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          sliver: SliverGrid(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final product = _favorites[index];
                                return ProductCard(
                                  id: product.id,
                                  name: product.name,
                                  subtitle: product.subtitle,
                                  imageUrl: product.imageUrl,
                                  price: product.price,
                                  badge: product.badge,
                                  isFavorite: true,
                                  category: product.category,
                                  onFavoriteToggle: () => _handleFavoriteToggle(product),
                                  onAddToCart: () => _handleAddToCart(product),
                                  onTap: () => context.push('/product/${product.id}'),
                                );
                              },
                              childCount: _favorites.length,
                            ),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.72,
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
            ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90, height: 90,
              decoration: BoxDecoration(
                color: HColors.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.favorite_border, size: 42, color: HColors.secondary),
            ),
            const SizedBox(height: 20),
            Text('No Saved Crafts Yet', style: HText.headlineMd.copyWith(color: HColors.onSurface)),
            const SizedBox(height: 8),
            Text(
              'Save handcrafted items you love and revisit them anytime.',
              textAlign: TextAlign.center,
              style: HText.bodyMd.copyWith(color: HColors.onSurfaceVariant),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/shop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('EXPLORE COLLECTION'),
            ),
          ],
        ),
      ),
    );
  }
}
