import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/nearby_shop.dart';
import '../../services/map_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  List<NearbyShop>? _branches;
  NearbyShop? _selectedBranch;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBranches();
  }

  Future<void> _loadBranches() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final svc = context.read<MapService>();
      final branches = await svc.getBranches();
      if (mounted) {
        setState(() {
          _branches = branches;
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

  void _showBottomSheet(NearbyShop shop) {
    setState(() => _selectedBranch = shop);
    showModalBottomSheet(
      context: context,
      backgroundColor: HColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _branchSheet(shop),
    );
  }

  Widget _branchSheet(NearbyShop shop) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: HColors.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(shop.name,
              style: HText.headlineMd.copyWith(color: HColors.onSurface)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.store, size: 16, color: HColors.primary),
              const SizedBox(width: 6),
              Text(shop.type,
                  style: HText.bodyMd.copyWith(color: HColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.location_on_outlined,
                  size: 18, color: HColors.outline),
              const SizedBox(width: 6),
              Expanded(
                child: Text(shop.address,
                    style: HText.bodyMd.copyWith(color: HColors.outline)),
              ),
            ],
          ),
          if (shop.rating > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.star, size: 18, color: HColors.secondary),
                const SizedBox(width: 6),
                Text('${shop.rating.toStringAsFixed(1)} / 5.0',
                    style: HText.bodyMd.copyWith(color: HColors.onSurface)),
              ],
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: AppBar(
        backgroundColor: HColors.surface,
        title: Text('Our Locations',
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
                      Text('Map unavailable', style: HText.headlineMd),
                      const SizedBox(height: 8),
                      Text(_error!, style: HText.bodyMd),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadBranches,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _buildMapPlaceholder(),
    );
  }

  /// Placeholder map using a styled container.
  /// Replace with flutter_map + OpenStreetMap when the dependency is added.
  Widget _buildMapPlaceholder() {
    return Stack(
      children: [
        // Map background
        Container(
          color: const Color(0xFFE8E0D5),
          child: CustomPaint(
            painter: _MapPatternPainter(),
            size: Size.infinite,
          ),
        ),

        // Branch markers
        if (_branches != null)
          ..._branches!.map((branch) {
            // Position markers across the screen using lat/lng
            // Cambodia is roughly 10.5-14.5 lat, 102-108 lng
            final left = ((branch.lng - 102) / 6).clamp(0.05, 0.90);
            final top = ((14.5 - branch.lat) / 4).clamp(0.08, 0.85);

            return Positioned(
              left: MediaQuery.of(context).size.width * left - 20,
              top: MediaQuery.of(context).size.height * top - 30,
              child: GestureDetector(
                onTap: () => _showBottomSheet(branch),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _selectedBranch?.id == branch.id
                            ? HColors.secondary
                            : HColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: HColors.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.store,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: HColors.surface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Text(
                        branch.name,
                        style: HText.labelSm.copyWith(
                            color: HColors.onSurface, fontSize: 9),
                        maxLines: 1,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),

        // Legend
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: HColors.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Branches',
                    style: HText.labelLg.copyWith(color: HColors.onSurface)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                          color: HColors.primary, shape: BoxShape.circle),
                    ),
                    const SizedBox(width: 8),
                    Text('Verified Artisan Shop',
                        style: HText.labelSm
                            .copyWith(color: HColors.outline)),
                  ],
                ),
              ],
            ),
          ),
        ),

        // List drawer at bottom
        if (_branches != null && _branches!.isNotEmpty)
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _branches!.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final b = _branches![index];
                  return GestureDetector(
                    onTap: () => _showBottomSheet(b),
                    child: Container(
                      width: 180,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: HColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(b.name,
                              style: HText.labelLg
                                  .copyWith(color: HColors.onSurface),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.store,
                                  size: 14, color: HColors.primary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(b.type,
                                    style: HText.labelSm.copyWith(
                                        color: HColors.outline),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(b.address,
                              style: HText.labelSm.copyWith(
                                  color: HColors.outline, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD5CFC4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }

    // Draw some "road" curves
    final roadPaint = Paint()
      ..color = const Color(0xFFCCC5B8)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final path1 = Path()
      ..moveTo(0, size.height * 0.4)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.3,
          size.width, size.height * 0.5);
    canvas.drawPath(path1, roadPaint);

    final path2 = Path()
      ..moveTo(size.width * 0.2, 0)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.6,
          size.width * 0.8, size.height);
    canvas.drawPath(path2, roadPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
