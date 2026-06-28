import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../services/order_service.dart';
import '../../services/promotion_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/cart/cart_cubit.dart';
import '../../models/product.dart';

class OrderConfirmScreen extends StatefulWidget {
  const OrderConfirmScreen({super.key});

  @override
  State<OrderConfirmScreen> createState() => _OrderConfirmScreenState();
}

class _OrderConfirmScreenState extends State<OrderConfirmScreen> {
  final TextEditingController _promoCtrl = TextEditingController();
  
  bool _isLoading = true;
  bool _isPlacingOrder = false;
  double _subtotal = 0.00;
  final double _shipping = 5.00;
  
  double _discount = 0.00;
  String _promoCode = '';
  String? _promotionId;

  @override
  void initState() {
    super.initState();
    _loadCartData();
  }

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.id : null;
  }

  Future<void> _loadCartData() async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    try {
      final items = await context.read<OrderService>().getCartItems(userId);
      double sum = 0.0;
      for (var item in items) {
        sum += item.price * item.cartQty;
      }
      
      if (mounted) {
        setState(() {
          _subtotal = sum;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _validatePromo() async {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty) return;
    
    setState(() { _promoCode = code; });
    
    try {
      final promoService = context.read<PromotionService>();
      final discount = await promoService.validatePromoCode(code, subTotal: _subtotal);
      
      if (mounted) {
        setState(() { 
          _discount = discount; 
          // Note: validatePromoCode from PromotionService doesn't return the ID right now, 
          // but we can pass the code or null for ID for now.
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Promo code applied successfully!'), backgroundColor: HColors.success),
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() { _discount = 0.00; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid or expired promo code'), backgroundColor: HColors.error),
        );
      }
    }
  }

  Future<void> _placeOrder() async {
    final userId = _currentUserId;
    if (userId == null) return;
    
    setState(() {
      _isPlacingOrder = true;
    });
    
    try {
      await context.read<OrderService>().createOrder(
        userId, 
        paymentMethod: "CreditCard", 
        deliveryAddress: "123 Heritage Ave" // Hardcoded for demo purposes as we didn't pass state from delivery screen
      );
      
      if (mounted) {
        context.read<CartCubit>().setCount(0); // Clear cart count badge
        
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (ctx) => AlertDialog(
            title: const Text('Order Placed!'),
            content: const Text('Your order has been successfully placed. Thank you for supporting artisan craftsmanship!'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  context.go('/orders'); // Navigate to Order History
                },
                child: const Text('View Order History', style: TextStyle(color: HColors.primary)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error placing order: $e'), backgroundColor: HColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPlacingOrder = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Confirm Order')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    
    double grandTotal = _subtotal - _discount + _shipping;
    if (grandTotal < 0) grandTotal = 0;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Order Summary', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const Divider(),
            ListTile(title: const Text('Subtotal'), trailing: Text('\$${_subtotal.toStringAsFixed(2)}')),
            if (_discount > 0)
              ListTile(title: Text('Discount ($_promoCode)'), trailing: Text('-\$${_discount.toStringAsFixed(2)}', style: const TextStyle(color: HColors.success))),
            ListTile(title: const Text('Shipping'), trailing: Text('\$${_shipping.toStringAsFixed(2)}')),
            ListTile(title: const Text('Grand Total'), trailing: Text('\$${grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _promoCtrl,
                    decoration: const InputDecoration(labelText: 'Promo Code', border: OutlineInputBorder()),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _validatePromo,
                  child: const Text('Apply'),
                ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isPlacingOrder ? null : _placeOrder,
                style: ElevatedButton.styleFrom(backgroundColor: HColors.primary),
                child: _isPlacingOrder 
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Place Order', style: TextStyle(fontSize: 18, color: Colors.white, letterSpacing: 1.2)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
