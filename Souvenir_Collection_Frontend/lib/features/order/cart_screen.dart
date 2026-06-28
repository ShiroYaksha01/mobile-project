import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/widgets/sidebar.dart';
import '../../models/product.dart';
import '../../services/order_service.dart';
import '../../services/promotion_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final int _navIndex = 3;
  List<Product> _cartItems = [];
  bool _isLoading = true;
  final _promoCtrl = TextEditingController();
  double? _discount;
  String? _promoError;
  String? _appliedCode;

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
      if (mounted) setState(() { _cartItems = items; _isLoading = false; });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateQuantity(Product product, int delta) async {
    final userId = _currentUserId;
    if (userId == null) return;
    final newQty = product.cartQty + delta;
    try {
      final orderService = context.read<OrderService>();
      if (newQty <= 0) {
        await orderService.removeItem(userId, product.id);
        if (mounted) {
          setState(() {
            _cartItems.removeWhere((p) => p.id == product.id);
          });
        }
      } else {
        await orderService.updateQuantity(userId, product.id, newQty);
        if (mounted) {
          setState(() {
            product.cartQty = newQty;
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _validatePromo() async {
    final code = _promoCtrl.text.trim();
    if (code.isEmpty) return;
    setState(() { _promoError = null; _discount = null; });
    try {
      final promoService = context.read<PromotionService>();
      final subTotal = _cartItems.fold<double>(0, (s, i) => s + i.price * i.cartQty);
      final discount = await promoService.validatePromoCode(code, subTotal: subTotal);
      if (mounted) {
        setState(() { _discount = discount; _appliedCode = code; });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Promo applied! -\$${discount.toStringAsFixed(2)}'), backgroundColor: HColors.success),
        );
      }
    } catch (_) {
      if (mounted) setState(() => _promoError = 'Invalid or expired code');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: HColors.background,
        appBar: const HeritageAppBar(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final total = _cartItems.fold<double>(
      0,
      (sum, item) => sum + item.price * item.cartQty,
    );

    return Scaffold(
      backgroundColor: HColors.background,
      appBar: const HeritageAppBar(),
      endDrawer: const AppSidebar(currentIndex: -1),
      bottomNavigationBar: HeritageBottomNav(
        currentIndex: _navIndex,
        cartCount: _cartItems.length,
        onTap: (i) {
          if (i == _navIndex) return;
          if (i == 0) context.go('/home');
          if (i == 1) context.go('/shop');
          if (i == 2) context.go('/saved');
          if (i == 3) {
            // Already here
          }
          if (i == 4) context.go('/nearby');
        },
      ),
      body: _cartItems.isEmpty
          ? const _EmptyCart()
          : Column(
              children: [
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'My Cart',
                                style: HText.headlineLg,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${_cartItems.length} handcrafted pieces selected',
                                style: HText.bodyMd.copyWith(
                                  color: HColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        sliver: SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = _cartItems[index];
                              return _CartItemCard(
                                product: product,
                                onUpdate: () => setState(() {}),
                                onIncrement: () => _updateQuantity(product, 1),
                                onDecrement: () => _updateQuantity(product, -1),
                              );
                            },
                            childCount: _cartItems.length,
                          ),
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: _buildPromoSection(),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 24),
                      ),
                    ],
                  ),
                ),
                _buildSummary(total),
              ],
            ),
    );
  }

  Widget _buildPromoSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Promo Code', style: HText.labelLg.copyWith(color: HColors.onSurface)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _promoCtrl,
                  decoration: InputDecoration(
                    hintText: 'Enter code',
                    hintStyle: HText.bodyMd.copyWith(color: HColors.outline),
                    filled: true,
                    fillColor: HColors.surfaceContainerLowest,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  style: HText.bodyMd,
                ),
              ),
              const SizedBox(width: 10),
              GoldButton(text: 'Apply', onPressed: _validatePromo),
            ],
          ),
          if (_promoError != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(_promoError!, style: HText.labelSm.copyWith(color: HColors.error)),
            ),
          if (_appliedCode != null && _discount != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: HColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: HColors.success, size: 18),
                    const SizedBox(width: 8),
                    Text('$_appliedCode applied: -\$${_discount!.toStringAsFixed(2)}',
                        style: HText.labelSm.copyWith(color: HColors.success)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummary(double total) {
    final discount = _discount ?? 0;
    final grandTotal = (total - discount) < 0 ? 0 : total - discount;
    return Container(
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
            if (discount > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Discount', style: HText.bodyMd.copyWith(color: HColors.success)),
                    Text('-\$${discount.toStringAsFixed(2)}',
                        style: HText.bodyMd.copyWith(color: HColors.success, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Total', style: HText.bodyLg.copyWith(color: HColors.onSurfaceVariant)),
                Text('\$${grandTotal.toStringAsFixed(2)}',
                    style: HText.headlineMd.copyWith(color: HColors.primary, fontWeight: FontWeight.w700)),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (_cartItems.isEmpty) return;
                  context.push('/order/delivery');
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
                  'PROCEED TO CHECKOUT',
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

class _CartItemCard extends StatelessWidget {
  final Product product;
  final VoidCallback onUpdate;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const _CartItemCard({
    required this.product,
    required this.onUpdate,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: HColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          // Placeholder for product icon/pattern (matching ProductCard)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: HColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  HColors.primary.withValues(alpha: 0.2),
                  HColors.primary.withValues(alpha: 0.05),
                ],
              ),
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: HColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: HText.labelLg.copyWith(
                    color: HColors.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  product.subtitle,
                  style: HText.labelSm.copyWith(
                    color: HColors.secondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price}',
                  style: HText.bodyMd.copyWith(
                    color: HColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Column(
            children: [
              GestureDetector(
                onTap: () {
                  onIncrement();
                  onUpdate();
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: HColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.add, size: 16, color: HColors.primary),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text(
                  '${product.cartQty}',
                  style: HText.labelLg.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (product.cartQty > 0) {
                    onDecrement();
                    onUpdate();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: HColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.remove, size: 16, color: HColors.primary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  const _EmptyCart();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: HColors.surfaceContainer,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 48,
                color: HColors.primary.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Cart is Empty',
              style: HText.headlineMd,
            ),
            const SizedBox(height: 12),
            Text(
              'It seems you haven\'t added any artisan crafts to your collection yet.',
              textAlign: TextAlign.center,
              style: HText.bodyMd.copyWith(
                color: HColors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => context.go('/shop'),
              style: ElevatedButton.styleFrom(
                backgroundColor: HColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('START BROWSING'),
            ),
          ],
        ),
      ),
    );
  }
}
