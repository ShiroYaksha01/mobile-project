import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class LandingScreen extends StatefulWidget {
  final VoidCallback onBeginJourney;

  const LandingScreen({
    super.key,
    required this.onBeginJourney,
  });

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: HColors.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top App Bar
            Container(
              color: HColors.background,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Crafted in Cambodia',
                    style: HText.headlineMd.copyWith(
                      color: HColors.primary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    child: Text(
                      'Sign In',
                      style: HText.labelLg.copyWith(
                        color: HColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Hero Section
            SizedBox(
              height: isMobile ? screenHeight * 0.6 : screenHeight * 0.65,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background Image
                  Image.network(
                    'https://lh3.googleusercontent.com/aida-public/AB6AXuBmKDjtsaGVFh5Sa04-jZ9cNSl0INjZ5mBQIjEkLQRvvMnA20zRFBg-BhpRXe4TXtwD1dzMA9i8b2ejOGlZyOEKC63qFTQwm-gAO7aH3yU3ldkpzAItdWEPZSDqtY-g3GyBjbzWFT2Nna27nw267A-Wr824rK8xjQV7Lq0RpZCwqF7EZ7GUWCCnqirxZBzx-8OIiDRYPkV_suV3MrMhi95dEvCMZiC_bos0lcKCFWBv9RACOBmRpjmqlA1SQPJ0TwKzmCG3D5-X--8',
                    fit: BoxFit.cover,
                  ),

                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.1),
                          Colors.black.withOpacity(0.3),
                          Colors.black.withOpacity(0.8),
                        ],
                      ),
                    ),
                  ),

                  // Content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Discover the Soul of Khmer Artistry',
                          style: isMobile
                              ? HText.displayLg.copyWith(
                                  color: HColors.primaryFixed,
                                  fontSize: 36,
                                )
                              : HText.displayLg.copyWith(
                                  color: HColors.primaryFixed,
                                ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Ancient Khmer traditions, reimagined for modern elegance.',
                          style: HText.bodyLg.copyWith(
                            color: Colors.white.withOpacity(0.9),
                          ),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 32),
                        Row(
                          children: [
                            // Primary CTA Button
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: Text(
                                'Begin Your Journey',
                                style: HText.labelLg.copyWith(
                                  color: Colors.white,
                                  letterSpacing: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: HColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                elevation: 8,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Secondary Link
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(context, '/login');
                              },
                              child: Text(
                                'Already have an account? Sign In',
                                style: HText.labelLg.copyWith(
                                  color: HColors.primaryFixed,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Final CTA Section
            Container(
              padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: HColors.primary.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    padding: const EdgeInsets.only(top: 32),
                    child: Column(
                      children: [
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: HColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 48,
                              vertical: 20,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(50),
                            ),
                            elevation: 4,
                          ),
                          child: Text(
                            'Begin Your Journey',
                            style: HText.labelLg.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'By joining, you agree to our Terms of Heritage Preservation.',
                          style: HText.labelSm.copyWith(
                            color: HColors.outline,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: HColors.primary.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                color: HColors.surfaceContainerLow,
              ),
              child: Column(
                children: [
                  Text(
                    'Crafted in Cambodia',
                    style: HText.headlineMd.copyWith(
                      color: HColors.primary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2024 Crafted in Cambodia. Preserving Heritage Through Modern Connection.',
                    style: HText.labelSm.copyWith(
                      color: HColors.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _FooterLink(label: 'About Our Artisans'),
                      _FooterLink(label: 'Heritage Preservation'),
                      _FooterLink(label: 'Shipping & Returns'),
                      _FooterLink(label: 'Privacy Policy'),
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
}

class _FooterLink extends StatelessWidget {
  final String label;

  const _FooterLink({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Text(
        label,
        style: HText.labelSm.copyWith(
          color: HColors.onSurfaceVariant,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
