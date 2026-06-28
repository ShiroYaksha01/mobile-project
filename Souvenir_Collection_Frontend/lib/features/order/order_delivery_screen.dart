import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';

class OrderDeliveryScreen extends StatelessWidget {
  const OrderDeliveryScreen({super.key});

  Widget _buildTextField(String label, {int maxLines = 1}) {
    return TextField(
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: HText.bodyMd.copyWith(color: HColors.outline),
        filled: true,
        fillColor: HColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: HColors.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: HColors.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HColors.primary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),
      style: HText.bodyMd,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: const HeritageAppBar(
        title: 'Delivery Details',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Where should we send your handcrafted items?',
              style: HText.headlineMd,
            ),
            const SizedBox(height: 32),
            _buildTextField('Address Line 1'),
            const SizedBox(height: 24),
            _buildTextField('Address Line 2 (Optional)'),
            const SizedBox(height: 24),
            _buildTextField('City'),
            const SizedBox(height: 24),
            _buildTextField('Postal Code'),
            const SizedBox(height: 32),
            Text(
              'Add a Custom Gift Message',
              style: HText.headlineMd,
            ),
            const SizedBox(height: 16),
            _buildTextField('Personal Message (Optional)', maxLines: 4),
            const SizedBox(height: 48),
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  context.push('/order/review');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'CONTINUE TO REVIEW',
                  style: HText.labelLg.copyWith(
                    color: Colors.white,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
