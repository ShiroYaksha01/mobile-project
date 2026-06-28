import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../models/product.dart';
import '../../services/order_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  List<Product> _cartItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.id : null;
  }

  Future<void> _loadCart() async {
    final userId = _currentUserId;
    if (userId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }
    try {
      final orderService = context.read<OrderService>();
      final items = await orderService.getCartItems(userId);
      if (mounted) {
        setState(() {
          _cartItems = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            HColors.primary.withValues(alpha: 0.2),
            HColors.primary.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: const Icon(Icons.inventory_2_outlined, color: HColors.primary),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: HColors.background,
        appBar: const HeritageAppBar(
          title: 'Order Review',
          showBackButton: true,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final total = _cartItems.fold<double>(
      0,
      (sum, item) => sum + item.price * item.cartQty,
    );

    return Scaffold(
      backgroundColor: HColors.background,
      appBar: const HeritageAppBar(
        title: 'Order Review',
        showBackButton: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20.0),
              itemCount: _cartItems.length,
              itemBuilder: (context, index) {
                final product = _cartItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: HColors.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: HColors.outlineVariant.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          product.imageUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl: product.imageUrl,
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      width: 60,
                                      height: 60,
                                      color: HColors.surfaceContainerLow,
                                    ),
                                    errorWidget: (context, url, error) => _buildPlaceholderIcon(),
                                  ),
                                )
                              : _buildPlaceholderIcon(),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(product.name, style: HText.labelLg),
                                const SizedBox(height: 4),
                                Text('\$${product.price.toStringAsFixed(2)}', style: HText.bodyMd.copyWith(color: HColors.primary, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text('Quantity: ${product.cartQty}', style: HText.bodyMd),
                            ],
                          ),
                          Row(
                            children: [
                              Text('Gift Wrap', style: HText.bodyMd),
                              const SizedBox(width: 8),
                              Switch(
                                value: false,
                                onChanged: (val) {},
                                activeColor: HColors.primary,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            decoration: BoxDecoration(
              color: HColors.surfaceContainerLowest,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(32),
                topRight: Radius.circular(32),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total:', style: HText.bodyLg.copyWith(color: HColors.onSurfaceVariant)),
                      Text('\$${total.toStringAsFixed(2)}', style: HText.headlineMd.copyWith(color: HColors.primary, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push('/order/confirm');
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
                        'PLACE ORDER',
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
          ),
        ],
      ),
    );
  }
}
