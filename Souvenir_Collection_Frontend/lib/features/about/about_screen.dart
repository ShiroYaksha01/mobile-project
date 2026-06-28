import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: AppBar(
        backgroundColor: HColors.surface,
        title: Text('About Heritage',
            style: HText.headlineMd.copyWith(color: HColors.primary)),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: HColors.primary),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero image placeholder
            Container(
              height: 180,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [HColors.primary, Color(0xFF3D3000)],
                ),
              ),
              child: const Center(
                child: Icon(Icons.spa_outlined,
                    color: HColors.primaryFixed, size: 64),
              ),
            ),
            const SizedBox(height: 24),

            Text('Our Mission',
                style: HText.headlineLg.copyWith(color: HColors.primary)),
            const SizedBox(height: 12),
            Text(
              'Crafted in Cambodia is a digital marketplace dedicated to preserving '
              'and celebrating the rich artistic traditions of the Khmer people. '
              'We connect master artisans from Siem Reap, Phnom Penh, Battambang, '
              'and rural provinces with the world — ensuring that centuries-old '
              'craftsmanship continues to thrive in the modern age.',
              style: HText.bodyLg.copyWith(
                  color: HColors.onSurface, height: 1.6),
            ),
            const SizedBox(height: 28),

            Text('The Artisans',
                style: HText.headlineLg.copyWith(color: HColors.primary)),
            const SizedBox(height: 12),
            Text(
              'Every product on our platform is handmade by a verified Khmer '
              'artisan. From silk weavers in Takeo to silver smiths in Kandal, '
              'our artisans are the heartbeat of Cambodia\'s cultural heritage. '
              'Each piece carries the story of its maker — their hands, their '
              'village, their lineage of craft passed down through generations.',
              style: HText.bodyLg.copyWith(
                  color: HColors.onSurface, height: 1.6),
            ),
            const SizedBox(height: 28),

            Text('Our Crafts',
                style: HText.headlineLg.copyWith(color: HColors.primary)),
            const SizedBox(height: 12),
            _craftItem('🧵', 'Silk Weaving',
                'Hand-loomed silk with intricate gold-thread patterns — a tradition dating back to the Angkorian empire.'),
            _craftItem('🏺', 'Pottery & Ceramics',
                'Wheel-thrown and kiln-fired ceramics using clay sourced from Kampong Chhnang province.'),
            _craftItem('🪡', 'Silverwork',
                'Hand-hammered silver jewelry and ornamental pieces crafted by artisans in Kandal.'),
            _craftItem('🪚', 'Wood Carving',
                'Intricate bas-relief carvings in tropical hardwoods, inspired by temple motifs.'),
            const SizedBox(height: 28),

            Text('Heritage Preservation',
                style: HText.headlineLg.copyWith(color: HColors.primary)),
            const SizedBox(height: 12),
            Text(
              'A portion of every purchase goes directly to heritage preservation '
              'efforts — restoring temple carvings, funding apprenticeship programs '
              'for young artisans, and documenting endangered craft techniques '
              'before they are lost to time.',
              style: HText.bodyLg.copyWith(
                  color: HColors.onSurface, height: 1.6),
            ),
            const SizedBox(height: 32),

            // Footer
            Center(
              child: Text(
                '© 2024 Crafted in Cambodia. Preserving Heritage Through Modern Connection.',
                style: HText.labelSm.copyWith(color: HColors.outline),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _craftItem(String emoji, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: HText.bodyLg.copyWith(
                        color: HColors.onSurface,
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(description,
                    style: HText.bodyMd.copyWith(
                        color: HColors.onSurfaceVariant, height: 1.4)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
