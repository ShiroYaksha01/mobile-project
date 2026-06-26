import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/sidebar.dart';
import '../../models/nearby_shop.dart';
import '../../services/map_service.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  final int _navIndex = 4;
  List<NearbyShop> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    try {
      final mapService = context.read<MapService>();
      final shops = await mapService.getBranches();
      if (mounted) setState(() { _shops = shops; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: const HeritageAppBar(),
      endDrawer: const AppSidebar(currentIndex: -1),
      bottomNavigationBar: HeritageBottomNav(
        currentIndex: _navIndex,
        onTap: (i) {
          if (i == _navIndex) return;
          if (i == 0) context.go('/home');
          if (i == 1) context.go('/shop');
          if (i == 2) context.go('/saved');
          if (i == 3) context.go('/cart');
          if (i == 4) {
            // Already here
          }
        },
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Map section
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 260,
                    child: _MapSection(shops: _shops),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Nearby Ateliers', style: HText.headlineLg),
                        const SizedBox(height: 6),
                        Text('${_shops.length} artisan shops near you',
                            style: HText.bodyMd.copyWith(color: HColors.onSurfaceVariant)),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  sliver: _shops.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(child: Text('No nearby shops found',
                              style: TextStyle(color: HColors.outline))),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final shop = _shops[index];
                              return _ShopCard(shop: shop);
                            },
                            childCount: _shops.length,
                          ),
                        ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final NearbyShop shop;

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
                if (shop.address.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: HColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shop.address,
                          style: HText.labelSm.copyWith(
                            color: HColors.secondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (shop.rating > 0)
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

// ── Mini map for Nearby ──
class _MapSection extends StatelessWidget {
  final List<NearbyShop> shops;
  const _MapSection({required this.shops});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      height: 240,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          Container(color: const Color(0xFFE8E0D5), child: CustomPaint(painter: _MiniMapPainter(), size: Size.infinite)),
          ...shops.asMap().entries.map((e) {
            final shop = e.value; final i = e.key;
            final left = 0.08 + (i % 4) * 0.23 + (i * 7 % 10) * 0.005;
            final top = 0.15 + (i ~/ 4) * 0.35 + (i * 13 % 10) * 0.01;
            return Positioned(
              left: MediaQuery.of(context).size.width * left - 20,
              top: 240 * top - 18,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  width: 26, height: 26,
                  decoration: BoxDecoration(color: HColors.primary, shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: HColors.primary.withValues(alpha: 0.3), blurRadius: 6)]),
                  child: const Icon(Icons.store, color: Colors.white, size: 15),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: HColors.surface.withValues(alpha: 0.9), borderRadius: BorderRadius.circular(4)),
                  child: Text(shop.name, style: const TextStyle(fontSize: 8, color: Color(0xFF2C241E)), maxLines: 1),
                ),
              ]),
            );
          }),
        ],
      ),
    );
  }
}

class _MiniMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gp = Paint()..color = const Color(0xFFD5CFC4)..style = PaintingStyle.stroke..strokeWidth = 0.5;
    const s = 30.0;
    for (double x = 0; x < size.width; x += s) canvas.drawLine(Offset(x, 0), Offset(x, size.height), gp);
    for (double y = 0; y < size.height; y += s) canvas.drawLine(Offset(0, y), Offset(size.width, y), gp);
    final rp = Paint()..color = const Color(0xFFCCC5B8)..strokeWidth = 2.5..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(0, size.height * 0.45), Offset(size.width, size.height * 0.55), rp);
    canvas.drawLine(Offset(size.width * 0.25, 0), Offset(size.width * 0.2, size.height), rp);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
