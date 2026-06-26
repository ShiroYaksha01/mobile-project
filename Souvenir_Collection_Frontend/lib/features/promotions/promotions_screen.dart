import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gold_button.dart';
import '../../models/promotion.dart';
import '../../services/promotion_service.dart';

class PromotionsScreen extends StatefulWidget {
  const PromotionsScreen({super.key});

  @override
  State<PromotionsScreen> createState() => _PromotionsScreenState();
}

class _PromotionsScreenState extends State<PromotionsScreen> {
  List<Promotion>? _promotions;
  bool _isLoading = true;
  String? _error;

  // Validate
  final _codeCtrl = TextEditingController();
  double? _discountAmount;
  String? _validateError;

  @override
  void initState() {
    super.initState();
    _loadPromotions();
  }

  @override
  void dispose() {
    _codeCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadPromotions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final svc = context.read<PromotionService>();
      final promos = await svc.getActivePromotions();
      if (mounted) {
        setState(() {
          _promotions = promos;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _validateCode() async {
    final code = _codeCtrl.text.trim();
    if (code.isEmpty) return;

    setState(() {
      _discountAmount = null;
      _validateError = null;
    });
    try {
      final svc = context.read<PromotionService>();
      final discount = await svc.validatePromoCode(code);
      if (mounted) {
        setState(() => _discountAmount = discount);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _validateError = 'Invalid or expired code');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: AppBar(
        backgroundColor: HColors.surface,
        title: Text('Promotions',
            style: HText.headlineMd.copyWith(color: HColors.primary)),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: HColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Failed to load',
                          style: HText.headlineMd),
                      const SizedBox(height: 8),
                      Text(_error!, style: HText.bodyMd),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadPromotions,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Validate code section
                      Text('Validate a Code',
                          style: HText.headlineMd
                              .copyWith(color: HColors.onSurface)),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _codeCtrl,
                              decoration: InputDecoration(
                                hintText: 'Enter promo code',
                                hintStyle: HText.bodyMd.copyWith(
                                    color: HColors.outline),
                                filled: true,
                                fillColor: HColors.surfaceContainerLowest,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(14),
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 14),
                              ),
                              style: HText.bodyLg
                                  .copyWith(color: HColors.onSurface),
                            ),
                          ),
                          const SizedBox(width: 10),
                          GoldButton(
                            text: 'Validate',
                            onPressed: _validateCode,
                          ),
                        ],
                      ),
                      if (_discountAmount != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: HColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    HColors.success.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle,
                                  color: HColors.success),
                              const SizedBox(width: 10),
                              Text(
                                'Discount: \$${_discountAmount!.toStringAsFixed(2)}',
                                style: HText.labelLg.copyWith(
                                    color: HColors.success),
                              ),
                            ],
                          ),
                        ),
                      ],
                      if (_validateError != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: HColors.error.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color:
                                    HColors.error.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: HColors.error),
                              const SizedBox(width: 10),
                              Text(_validateError!,
                                  style: HText.labelLg.copyWith(
                                      color: HColors.error)),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),
                      Text('Active Promotions',
                          style: HText.headlineMd
                              .copyWith(color: HColors.onSurface)),
                      const SizedBox(height: 12),

                      if (_promotions != null && _promotions!.isNotEmpty)
                        ..._promotions!.map((p) => _promoCard(p))
                      else
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.all(30),
                            child: Text('No active promotions right now.',
                                style: HText.bodyMd
                                    .copyWith(color: HColors.outline)),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _promoCard(Promotion promo) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: HColors.secondary.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.local_offer,
                  color: HColors.secondary, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(promo.title,
                    style: HText.headlineMd
                        .copyWith(color: HColors.onSurface)),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: HColors.secondary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(promo.discountLabel,
                    style: HText.labelSm.copyWith(
                        color: AppColors.secondaryDark,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (promo.description.isNotEmpty)
            Text(promo.description,
                style: HText.bodyMd.copyWith(color: HColors.outline)),
          const SizedBox(height: 10),
          Row(
            children: [
              // Code with copy button
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: promo.code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Code "${promo.code}" copied!')),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: HColors.primaryContainer.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color:
                            HColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(promo.code,
                          style: HText.labelLg.copyWith(
                              color: HColors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5)),
                      const SizedBox(width: 8),
                      const Icon(Icons.copy,
                          size: 16, color: HColors.primary),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              if (promo.endDate != null)
                Text('Until ${_formatDate(promo.endDate!)}',
                    style:
                        HText.labelSm.copyWith(color: HColors.outline)),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
  }
}
