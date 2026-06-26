import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: AppBar(
        backgroundColor: HColors.surface,
        title: Text('Help & Support',
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
            // FAQ Section
            Text('Frequently Asked Questions',
                style: HText.headlineLg.copyWith(color: HColors.primary)),
            const SizedBox(height: 16),
            _FaqTile(
              question: 'How do I place an order?',
              answer:
                  'Browse our shop, add items to your cart, and proceed to checkout. '
                  'You\'ll be guided through delivery details and payment.',
            ),
            _FaqTile(
              question: 'How long does delivery take?',
              answer:
                  'Orders within Cambodia typically arrive in 3–5 business days. '
                  'International shipping takes 10–14 business days depending on the destination.',
            ),
            _FaqTile(
              question: 'Can I return or exchange an item?',
              answer:
                  'Yes! You may return any unused item within 14 days of delivery. '
                  'Handmade items have natural variations — these are not considered defects but part of their unique character.',
            ),
            _FaqTile(
              question: 'How do I track my order?',
              answer:
                  'Once your order ships, you\'ll receive an email with a tracking number. '
                  'You can also check your order status in the app under your profile.',
            ),
            _FaqTile(
              question: 'Are the artisans verified?',
              answer:
                  'Yes. Every artisan on our platform undergoes a verification process '
                  'to ensure authenticity and fair trade practices.',
            ),
            const SizedBox(height: 32),

            // Contact Section
            Text('Contact Us',
                style: HText.headlineLg.copyWith(color: HColors.primary)),
            const SizedBox(height: 16),
            _ContactCard(
              icon: Icons.email_outlined,
              title: 'Email',
              detail: 'support@craftedincambodia.com',
            ),
            const SizedBox(height: 12),
            _ContactCard(
              icon: Icons.phone_outlined,
              title: 'Phone',
              detail: '+855 111111111',
            ),
            const SizedBox(height: 12),
            _ContactCard(
              icon: Icons.location_on_outlined,
              title: 'Office',
              detail: 'Sangkat Chey Chumneas, Khan Daun Penh\nPhnom Penh, Cambodia',
            ),
            const SizedBox(height: 32),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: HColors.outlineVariant.withValues(alpha: 0.4)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(widget.question,
                        style: HText.bodyLg.copyWith(
                            color: HColors.onSurface,
                            fontWeight: FontWeight.w600)),
                  ),
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: HColors.primary,
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding:
                  const EdgeInsets.only(left: 16, right: 16, bottom: 16),
              child: Text(widget.answer,
                  style: HText.bodyMd.copyWith(
                      color: HColors.onSurfaceVariant, height: 1.5)),
            ),
        ],
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.detail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border:
            Border.all(color: HColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: HColors.primary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: HText.labelSm.copyWith(color: HColors.outline)),
              const SizedBox(height: 2),
              Text(detail,
                  style: HText.bodyLg.copyWith(color: HColors.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}
