import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class ArtisanCard extends StatelessWidget {
  final String id;
  final String name;
  final String craft;
  final String imageUrl;
  final String region;
  final bool isVerified;
  final double? rating;
  final VoidCallback? onTap;

  const ArtisanCard({
    super.key,
    required this.id,
    required this.name,
    required this.craft,
    this.imageUrl = '',
    this.region = '',
    this.isVerified = false,
    this.rating,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
          children: [
            // Avatar header
            Container(
              height: 120,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    HColors.primary.withValues(alpha: 0.7),
                    HColors.primary.withValues(alpha: 0.3),
                  ],
                ),
              ),
              child: Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HColors.surface,
                    border:
                        Border.all(color: HColors.secondary, width: 2),
                    image: imageUrl.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(imageUrl),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: imageUrl.isEmpty
                      ? Icon(
                          Icons.person,
                          size: 36,
                          color: HColors.primary.withValues(alpha: 0.5),
                        )
                      : null,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          name,
                          style: HText.labelLg.copyWith(
                            color: HColors.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified) ...[
                        const SizedBox(width: 6),
                        Icon(
                          Icons.verified,
                          size: 18,
                          color: HColors.secondary,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    craft,
                    style: HText.labelSm.copyWith(
                      color: HColors.primary,
                    ),
                  ),
                  if (region.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 14, color: HColors.outline),
                        const SizedBox(width: 4),
                        Text(
                          region,
                          style: HText.labelSm.copyWith(
                            color: HColors.outline,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (rating != null) ...[
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.star, size: 16, color: HColors.secondary),
                        const SizedBox(width: 4),
                        Text(
                          rating!.toStringAsFixed(1),
                          style: HText.labelSm.copyWith(
                            color: HColors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
