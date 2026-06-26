import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class HeritageBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int cartCount;

  const HeritageBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.cartCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: HColors.surface,
        border: const Border(
          top: BorderSide(
            color: HColors.outlineVariant,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Home',
                index: 0,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.storefront_outlined,
                activeIcon: Icons.storefront,
                label: 'Shop',
                index: 1,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.favorite_outline,
                activeIcon: Icons.favorite,
                label: 'Saved',
                index: 2,
                current: currentIndex,
                onTap: onTap,
              ),
              _CartNavItem(
                count: cartCount,
                index: 3,
                current: currentIndex,
                onTap: onTap,
              ),
              _NavItem(
                icon: Icons.location_on_outlined,
                activeIcon: Icons.location_on,
                label: 'Nearby',
                index: 4,
                current: currentIndex,
                onTap: onTap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              active ? activeIcon : icon,
              color: active
                  ? HColors.primary
                  : HColors.onSurfaceVariant,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: HText.labelSm.copyWith(
                color: active
                    ? HColors.primary
                    : HColors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  final int count;
  final int index;
  final int current;
  final ValueChanged<int> onTap;

  const _CartNavItem({
    required this.count,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final active = index == current;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Badge(
              label: Text('$count'),
              isLabelVisible: count > 0,
              child: Icon(
                active
                    ? Icons.shopping_bag
                    : Icons.shopping_bag_outlined,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Cart',
              style: HText.labelSm,
            ),
          ],
        ),
      ),
    );
  }
}