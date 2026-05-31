import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HeritageAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final VoidCallback? onMenu;
  final VoidCallback? onSearch;

  const HeritageAppBar({
    super.key,
    this.onMenu,
    this.onSearch,
  });

  @override
  Size get preferredSize => const Size.fromHeight(64);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: HColors.surface.withValues(alpha: 0.92),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      leading: const Padding(
        padding: EdgeInsets.only(left: 20),
        child: Icon(
          Icons.spa_outlined,
          color: HColors.primary,
          size: 24,
        ),
      ),
      title: Text(
        'Crafted in Cambodia',
        style: HText.headlineMd.copyWith(
          color: HColors.primary,
          fontSize: 18,
        ),
      ),
      actions: [
        if (onSearch != null)
          IconButton(
            onPressed: onSearch,
            icon: const Icon(Icons.search, color: HColors.primary),
          ),
        IconButton(
          onPressed: onMenu,
          icon: const Icon(
            Icons.menu,
            color: HColors.primary,
          ),
        ),
      ],
    );
  }
}