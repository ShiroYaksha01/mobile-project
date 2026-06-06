import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/sidebar.dart';
import '../../data/static_data.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final int _navIndex = 3;

  @override
  Widget build(BuildContext context) {
    final cartItems =
        StaticData.products.where((p) => p.cartQty > 0).toList();

    final total = cartItems.fold<double>(
      0,
      (sum, item) => sum + item.price * item.cartQty,
    );

    return Scaffold(
      backgroundColor: HColors.background,
      appBar: const HeritageAppBar(),
      endDrawer: const AppSidebar(currentIndex: -1),
      bottomNavigationBar: HeritageBottomNav(
        currentIndex: _navIndex,
        cartCount: cartItems.length,
        onTap: (i) {
          if (i == _navIndex) return;
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushReplacementNamed(context, '/shop');
          if (i == 2) Navigator.pushReplacementNamed(context, '/saved');
          if (i == 3) {
            // Already here
          }
          if (i == 4) Navigator.pushReplacementNamed(context, '/nearby');
        },
      ),
      body: cartItems.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Cart',
                                style: HText.headlineLg,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${cartItems.length} handcrafted pieces selected',
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
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = cartItems[index];

                              return _CartItemCard(
                                product: product,
                                onUpdate: () => setState(() {}),
                              );
                            },
                            childCount: cartItems.length,
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 32),
                      ),
                    ],
                  ),
                ),
                _buildSummary(total),
              ],
            ),
    );
  }

  Widget _buildSummary(double total) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: HText.bodyLg.copyWith(
                    color: HColors.onSurfaceVariant,
                  ),
                ),
                Text(
                  '\$${total.toStringAsFixed(0)}',
                  style: HText.headlineMd.copyWith(
                    color: HColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Proceed to checkout
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'PROCEED TO CHECKOUT',
                  style: HText.labelLg.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic product;
  final VoidCallback onUpdate;

  const _CartItemCard({
    required this.product,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Placeholder for product icon/pattern (matching ProductCard)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: HColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HColors.primary.withValues(alpha: 0.2),
                  HColors.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: HColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: HText.labelLg.copyWith(
                    color: HColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.subtitle,
                  style: HText.labelSm.copyWith(
                    color: HColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price}',
                  style: HText.bodyMd.copyWith(
                    color: HColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  product.cartQty++;
                  onUpdate();
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: HColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, size: 16, color: HColors.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${product.cartQty}',
                  style: HText.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (product.cartQty > 0) {
                    product.cartQty--;
                    onUpdate();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: HColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.remove, size: 16, color: HColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: HColors.surfaceContainer,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: HColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Cart is Empty',
              style: HText.headlineMd,
            ),
            const SizedBox(height: 12),
            Text(
              'It seems you haven\'t added any artisan crafts to your collection yet.',
              textAlign: TextAlign.center,
              style: HText.bodyMd.copyWith(
                color: HColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/shop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('START BROWSING'),
            ),
          ],
        ),
      ),
    );
  }
}
