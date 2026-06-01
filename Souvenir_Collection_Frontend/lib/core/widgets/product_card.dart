import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

final _categoryMeta = {
  'Textile':  _Meta(const Color(0xFF4A6FA5), Icons.texture),
  'Silver':   _Meta(const Color(0xFF6B7B8D), Icons.diamond_outlined),
  'Wood':     _Meta(const Color(0xFF8B6914), Icons.nature_outlined),
  'Jewelry':  _Meta(const Color(0xFF9D4221), Icons.favorite_border),
  'Ceramics': _Meta(const Color(0xFFB88746), Icons.palette_outlined),
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
  _Meta(HColors.primary, Icons.auto_awesome),
  _Meta(HColors.secondary, Icons.category_outlined),
  _Meta(HColors.tertiary, Icons.workspaces_outlined),
];

class ProductCard extends StatefulWidget {
  final String id, name, subtitle, imageUrl, category;
  final double price;
  final String badge;
  final bool isFavorite;
  final VoidCallback? onFavoriteToggle, onAddToCart;

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
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 120));
  late final Animation<double> _scale = Tween<double>(begin: 1, end: 0.95)
      .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final meta = _metaFor(widget.category, widget.id.hashCode);

    return ScaleTransition(
      scale: _scale,
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          widget.onAddToCart?.call();
        },
        onTapCancel: () => _ctrl.reverse(),
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
            children: [
              // Category-colored header with icon instead of image
              SizedBox(
                height: 160,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
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
                      child: CustomPaint(
                        painter: _CardPatternPainter(meta.color),
                      ),
                    ),
                    Center(
                      child: Icon(meta.icon, size: 44,
                          color: Colors.white.withValues(alpha: 0.85)),
                    ),
                    if (widget.badge.isNotEmpty)
                      Positioned(
                        top: 10,
                        left: 10,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: meta.color,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            widget.badge.toUpperCase(),
                            style: HText.labelSm.copyWith(
                                color: Colors.white, fontSize: 9),
                          ),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: widget.onFavoriteToggle,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.06),
                                  blurRadius: 4)
                            ],
                          ),
                          child: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_outline,
                            size: 16,
                            color: widget.isFavorite
                                ? HColors.secondary
                                : HColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name,
                        style: HText.labelLg.copyWith(
                            color: HColors.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(widget.subtitle,
                        style: HText.labelSm.copyWith(
                            color: HColors.secondary)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${widget.price.toStringAsFixed(0)}',
                            style: HText.bodyMd.copyWith(
                                color: HColors.primary,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: meta.color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child:
                              Icon(Icons.add, size: 18, color: meta.color),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardPatternPainter extends CustomPainter {
  final Color color;
  _CardPatternPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.06)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const step = 20.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x + step / 2, y + step / 2), step * 0.35, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
