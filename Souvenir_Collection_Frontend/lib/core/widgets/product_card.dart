import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

// Khmer-inspired category colors: terracotta, gold, earth, ruby, clay
final _categoryMeta = {
  'Textile':  _Meta(const Color(0xFF8B3A2B), Icons.spa_outlined),      // Angkor Red
  'Silver':   _Meta(const Color(0xFFD4AF37), Icons.diamond_outlined),  // Metallic Gold
  'Wood':     _Meta(const Color(0xFF5A2117), Icons.park_outlined),     // Deep Earth
  'Jewelry':  _Meta(const Color(0xFFB75D4E), Icons.stars_outlined),    // Ruby
  'Ceramics': _Meta(const Color(0xFF997A00), Icons.palette_outlined),  // Warm Clay
};

class _Meta {
  final Color color;
  final IconData icon;
  const _Meta(this.color, this.icon);
}

_Meta _metaFor(String category, int index) {
  return _categoryMeta[category] ?? _fallbackIcons[index % _fallbackIcons.length];
}

const _fallbackIcons = [
  _Meta(const Color(0xFF8B3A2B), Icons.spa_outlined),     // Terracotta lotus
  _Meta(const Color(0xFFD4AF37), Icons.auto_awesome),      // Gold sparkle
  _Meta(const Color(0xFF5A2117), Icons.category_outlined),  // Deep earth
  _Meta(const Color(0xFFB75D4E), Icons.workspaces_outlined), // Ruby
  _Meta(const Color(0xFF997A00), Icons.stars_outlined),     // Warm gold
];

class ProductCard extends StatelessWidget {
  final String id, name, subtitle, imageUrl, category;
  final double price;
  final String badge;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle, onAddToCart, onTap;

  const ProductCard({
    super.key,
    required this.id,
    required this.name,
    required this.subtitle,
    required this.imageUrl,
    required this.price,
    this.badge = '',
    this.isFavorite = false,
    this.category = '',
    this.onFavoriteToggle,
    this.onAddToCart,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(category, id.hashCode);
    final hasImage = imageUrl.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E2E2E).withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Image area
          AspectRatio(
            aspectRatio: 1.1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Background
                if (hasImage)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    loadingBuilder: (_, child, progress) {
                      if (progress == null) return child;
                      return _buildGradientBg(meta);
                    },
                    errorBuilder: (_, __, ___) => _buildGradientBg(meta),
                  )
                else
                  _buildGradientBg(meta),

                if (!hasImage)
                  Center(
                    child: Icon(meta.icon, size: 44,
                        color: Colors.white.withValues(alpha: 0.85)),
                  ),

                // Badge
                if (badge.isNotEmpty)
                  Positioned(
                    top: 10, left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: meta.color,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(badge.toUpperCase(),
                          style: HText.labelSm.copyWith(color: Colors.white, fontSize: 9)),
                    ),
                  ),

                // Favorite button — uses Material for reliable tap
                Positioned(
                  top: 8, right: 8,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: onFavoriteToggle,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 4)
                          ],
                        ),
                        child: Icon(
                          isFavorite ? Icons.favorite : Icons.favorite_outline,
                          size: 18,
                          color: isFavorite ? HColors.error : HColors.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Text content
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(name,
                    style: HText.labelLg.copyWith(color: HColors.onSurface),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: HText.labelSm.copyWith(color: HColors.outline),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text('\$${price.toStringAsFixed(0)}',
                            style: HText.bodyMd.copyWith(
                                color: HColors.primary, fontWeight: FontWeight.w700, fontSize: 15)),
                      ),
                    ),
                    // Add-to-cart button — Material for reliable tap
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: onAddToCart,
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: meta.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(Icons.add, size: 20, color: meta.color),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildGradientBg(_Meta meta) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            meta.color.withValues(alpha: 0.7),
            meta.color.withValues(alpha: 0.35),
          ],
        ),
      ),
      child: CustomPaint(painter: _CardPatternPainter(meta.color)),
    );
  }
}

// Khmer diamond-lattice pattern (common in Cambodian silk & silver)
class _CardPatternPainter extends CustomPainter {
  final Color color;
  _CardPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;
    final dotPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.09)
      ..style = PaintingStyle.fill;

    const s = 26.0;
    for (double x = 0; x < size.width + s; x += s) {
      for (double y = 0; y < size.height + s; y += s) {
        // Diamond lozenge — classic Khmer textile motif
        final path = Path()
          ..moveTo(x, y - s * 0.22)
          ..lineTo(x + s * 0.18, y)
          ..lineTo(x, y + s * 0.22)
          ..lineTo(x - s * 0.18, y)
          ..close();
        canvas.drawPath(path, linePaint);
      }
    }
    for (double x = s / 2; x < size.width; x += s) {
      for (double y = s / 2; y < size.height; y += s) {
        canvas.drawCircle(Offset(x, y), 2.0, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
