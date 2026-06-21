import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class KhmerIcon extends StatelessWidget {
  final String assetPath;
  final double size;
  final Color? color;

  const KhmerIcon({
    super.key,
    required this.assetPath,
    this.size = 24.0,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Note: Once flutter_svg is added to pubspec.yaml, 
    // we will use SvgPicture.asset() here.
    // For now, this serves as a placeholder for our SVG icons
    // so we can build out the UI.
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        assetPath,
        color: color ?? AppColors.secondary, // Defaults to gold accent
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.image_not_supported,
            size: size,
            color: color ?? AppColors.secondary,
          );
        },
      ),
    );
  }
}
