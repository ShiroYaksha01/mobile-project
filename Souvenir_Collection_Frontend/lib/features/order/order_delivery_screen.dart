import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';

class OrderDeliveryScreen extends StatefulWidget {
  const OrderDeliveryScreen({super.key});

  @override
  State<OrderDeliveryScreen> createState() => _OrderDeliveryScreenState();
}

class _OrderDeliveryScreenState extends State<OrderDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _postalCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _address1Ctrl.addListener(_updateState);
    _cityCtrl.addListener(_updateState);
    _postalCtrl.addListener(_updateState);
  }

  @override
  void dispose() {
    _address1Ctrl.removeListener(_updateState);
    _cityCtrl.removeListener(_updateState);
    _postalCtrl.removeListener(_updateState);
    _address1Ctrl.dispose();
    _address2Ctrl.dispose();
    _cityCtrl.dispose();
    _postalCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _updateState() {
    setState(() {}); // Rebuild to update button enabled state
  }

  bool get _isFormFilled {
    return _address1Ctrl.text.trim().isNotEmpty &&
           _cityCtrl.text.trim().isNotEmpty &&
           _postalCtrl.text.trim().isNotEmpty;
  }

  Widget _buildTextField(String label, {int maxLines = 1, TextEditingController? controller, String? Function(String?)? validator}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HColors.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: HColors.error, width: 2),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Where should we send your handcrafted items?',
                style: HText.headlineMd,
              ),
              const SizedBox(height: 32),
              _buildTextField(
                'Address Line 1',
                controller: _address1Ctrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'Address is required' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField('Address Line 2 (Optional)', controller: _address2Ctrl),
              const SizedBox(height: 24),
              _buildTextField(
                'City',
                controller: _cityCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'City is required' : null,
              ),
              const SizedBox(height: 24),
              _buildTextField(
                'Postal Code',
                controller: _postalCtrl,
                validator: (v) => v == null || v.trim().isEmpty ? 'Postal Code is required' : null,
              ),
              const SizedBox(height: 32),
              Text(
                'Add a Custom Gift Message',
                style: HText.headlineMd,
              ),
              const SizedBox(height: 16),
              _buildTextField('Personal Message (Optional)', controller: _messageCtrl, maxLines: 4),
              const SizedBox(height: 48),
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _isFormFilled ? () {
                    if (_formKey.currentState!.validate()) {
                      context.push('/order/review');
                    }
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HColors.primary,
                    disabledBackgroundColor: HColors.surfaceContainerHigh,
                    disabledForegroundColor: HColors.outline,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'CONTINUE TO REVIEW',
                    style: HText.labelLg.copyWith(
                      color: _isFormFilled ? Colors.white : HColors.outline,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
