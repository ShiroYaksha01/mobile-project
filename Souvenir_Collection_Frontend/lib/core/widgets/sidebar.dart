import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'phka_chan_painter.dart';

class AppSidebar extends StatelessWidget {
  final VoidCallback? onProfile;
  final VoidCallback? onSettings;
  final VoidCallback? onAbout;
  final VoidCallback? onHelp;
  final VoidCallback? onLogout;
  final int currentIndex;

  const AppSidebar({
    super.key,
    this.onProfile,
    this.onSettings,
    this.onAbout,
    this.onHelp,
    this.onLogout,
    this.currentIndex = -1,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: HColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          bottomLeft: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                _DrawerItem(
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  title: "Profile",
                  selected: currentIndex == 5,
                  onTap: onProfile ?? () {},
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  title: "Settings",
                  selected: currentIndex == 6,
                  onTap: onSettings ?? () {},
                ),
                _DrawerItem(
                  icon: Icons.info_outline,
                  selectedIcon: Icons.info,
                  title: "About Heritage",
                  selected: currentIndex == 7,
                  onTap: onAbout ?? () {},
                ),
                _DrawerItem(
                  icon: Icons.help_outline,
                  selectedIcon: Icons.help,
                  title: "Help & Support",
                  selected: currentIndex == 8,
                  onTap: onHelp ?? () {},
                ),
              ],
            ),
          ),
          _buildLogoutSection(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 220,
      child: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HColors.primary,
                  Color(0xFF3D3000),
                ],
              ),
            ),
          ),
          // Phka Chan Pattern
          const Positioned.fill(
            child: CustomPaint(
              painter: PhkaChanPainter(
                color: Colors.white,
                opacity: 0.08,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.spa_outlined,
                      color: HColors.primaryFixed,
                      size: 32,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    "Crafted in Cambodia",
                    style: HText.headlineMd.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: HColors.secondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Heritage Marketplace",
                        style: HText.bodyMd.copyWith(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogoutSection(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: InkWell(
          onTap: onLogout ?? () => Navigator.pushReplacementNamed(context, '/login'),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: HColors.outlineVariant),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.logout, color: HColors.primary, size: 20),
                const SizedBox(width: 12),
                Text(
                  "Sign Out",
                  style: HText.labelLg.copyWith(
                    color: HColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final IconData? selectedIcon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    this.selectedIcon,
    required this.title,
    this.selected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        selected: selected,
        selectedTileColor: HColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        leading: Icon(
          selected ? (selectedIcon ?? icon) : icon,
          color: selected ? HColors.primary : HColors.onSurfaceVariant,
          size: 24,
        ),
        title: Text(
          title,
          style: HText.bodyLg.copyWith(
            color: selected ? HColors.primary : HColors.onSurface,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
        trailing: selected
            ? Container(
                width: 4,
                height: 24,
                decoration: BoxDecoration(
                  color: HColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              )
            : null,
      ),
    );
  }
}
