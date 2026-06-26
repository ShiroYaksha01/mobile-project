import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/sidebar.dart';
import '../../services/product_service.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final int _navIndex = 2;

  @override
  Widget build(BuildContext context) {
    final favorites = ProductService.favorites;

    return Scaffold(
      appBar: const HeritageAppBar(),
      endDrawer: const AppSidebar(currentIndex: -1),
      bottomNavigationBar: HeritageBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == _navIndex) return;
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushReplacementNamed(context, '/shop');
          if (i == 2) {
            // Already here
          }
          if (i == 3) Navigator.pushReplacementNamed(context, '/cart');
          if (i == 4) Navigator.pushReplacementNamed(context, '/nearby');
        },
      ),
      body: favorites.isEmpty
          ? const _EmptyFavorites()
          : CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Saved Crafts',
                          style: HText.headlineLg,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${favorites.length} artisan pieces saved',
                          style: HText.bodyMd.copyWith(
                            color: HColors.onSurfaceVariant,
                          ),
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
                        final product = favorites[index];

                        return ProductCard(
                          id: product.id,
                          name: product.name,
                          subtitle: product.subtitle,
                          imageUrl: product.imageUrl,
                          price: product.price,
                          badge: product.badge,
                          isFavorite: product.isFavorite,
                          category: product.category,
                          onFavoriteToggle: () {
                            setState(() {
                              ProductService.toggleFavorite(product.id);
                            });
                          },
                          onAddToCart: () {
                            setState(() {
                              product.cartQty++;
                            });

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  '${product.name} added to cart',
                                ),
                              ),
                            );
                          },
                        );
                      },
                      childCount: favorites.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.62,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 24),
                ),
              ],
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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: HColors.surfaceContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.favorite_border,
                size: 42,
                color: HColors.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Saved Crafts Yet',
              style: HText.headlineMd,
            ),
            const SizedBox(height: 8),
            Text(
              'Save handcrafted items you love and revisit them anytime.',
              textAlign: TextAlign.center,
              style: HText.bodyMd.copyWith(
                color: HColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/shop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('EXPLORE COLLECTION'),
            ),
          ],
        ),
      ),
    );
  }
}
