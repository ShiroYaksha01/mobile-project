import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/sidebar.dart';
import '../../data/static_data.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final int _navIndex = 4;

  @override
  Widget build(BuildContext context) {
    final shops = StaticData.nearbyShops;

    return Scaffold(
      backgroundColor: HColors.background,
      appBar: const HeritageAppBar(),
      endDrawer: const AppSidebar(currentIndex: -1),
      bottomNavigationBar: HeritageBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == _navIndex) return;
          if (i == 0) Navigator.pushReplacementNamed(context, '/home');
          if (i == 1) Navigator.pushReplacementNamed(context, '/shop');
          if (i == 2) Navigator.pushReplacementNamed(context, '/saved');
          if (i == 3) Navigator.pushReplacementNamed(context, '/cart');
          if (i == 4) {
            // Already here
          }
        },
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nearby Ateliers',
                    style: HText.headlineLg,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Discover master artisans in your vicinity',
                    style: HText.bodyMd.copyWith(
                      color: HColors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final shop = shops[index];

                  return _ShopCard(shop: shop);
                },
                childCount: shops.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 32),
          ),
        ],
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final dynamic shop; // NearbyShop model

  const _ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E2E2E).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: HColors.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.storefront_outlined,
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
                  shop.name,
                  style: HText.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                    color: HColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  shop.type,
                  style: HText.bodyMd.copyWith(
                    color: HColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: HColors.secondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      shop.distance,
                      style: HText.labelSm.copyWith(
                        color: HColors.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: HColors.primaryContainer.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star, size: 14, color: HColors.primary),
                    const SizedBox(width: 4),
                    Text(
                      shop.rating.toString(),
                      style: HText.labelSm.copyWith(
                        fontWeight: FontWeight.bold,
                        color: HColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: HColors.outline.withValues(alpha: 0.5),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
