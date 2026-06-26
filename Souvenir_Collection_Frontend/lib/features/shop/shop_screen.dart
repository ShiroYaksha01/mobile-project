import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/sidebar.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/favorites_service.dart';
import '../../services/order_service.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';

class ShopScreen extends StatefulWidget {
  final List<Product> products;
  final void Function(Product)? onFavoriteToggle;
  final void Function(Product)? onAddToCart;

  const ShopScreen({
    super.key,
    required this.products,
    this.onFavoriteToggle,
    this.onAddToCart,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategory = 0;
  int _navIndex = 1;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<String> _categories = ['All Crafts'];
  int _cartCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadCategories();
    _loadCartCount();
  }

  Future<void> _loadCategories() async {
    try {
      final productService = context.read<ProductService>();
      final cats = await productService.getCategories();
      if (mounted) {
        setState(() {
          _categories = ['All Crafts', ...cats.map((c) => c['name']?.toString() ?? '')];
        });
      }
    } catch (_) {}
  }

  Future<void> _loadCartCount() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final orderService = context.read<OrderService>();
        final count = await orderService.getCartCount(authState.user.id);
        if (mounted) setState(() => _cartCount = count);
      }
    } catch (_) {}
  }

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.id : null;
  }

  Future<void> _handleFavoriteToggle(Product product) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final favService = context.read<FavoritesService>();
      final isNowFavorited = await favService.toggleFavorite(userId, product.id);
      if (mounted) {
        setState(() {
          product.isFavorite = isNowFavorited;
        });
        widget.onFavoriteToggle?.call(product);
      }
    } catch (_) {}
  }

  Future<void> _handleAddToCart(Product product) async {
    final userId = _currentUserId;
    if (userId == null) return;
    try {
      final orderService = context.read<OrderService>();
      await orderService.addToCart(userId, product.id);
      if (mounted) {
        setState(() {
          product.cartQty++;
          _cartCount++;
        });
        widget.onAddToCart?.call(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _filteredProducts {
    var list = widget.products;
    if (_selectedCategory != 0 && _selectedCategory < _categories.length) {
      final cat = _categories[_selectedCategory];
      list = list.where((p) => p.category == cat).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: HColors.background,
        appBar: const HeritageAppBar(),
        endDrawer: const AppSidebar(currentIndex: -1),
        body: Column(
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search heritage pieces...',
                  hintStyle: HText.bodyMd.copyWith(
                    color: HColors.onSurfaceVariant,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: HColors.onSurfaceVariant,
                  ),
                  filled: true,
                  fillColor: HColors.surfaceContainerLowest,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: HColors.outlineVariant,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Products'),
                Tab(text: 'Collections'),
                Tab(text: 'Artisans'),
              ],
              labelStyle: HText.labelLg,
              unselectedLabelStyle: HText.labelLg.copyWith(
                color: HColors.onSurfaceVariant,
              ),
              labelColor: HColors.primary,
              unselectedLabelColor: HColors.onSurfaceVariant,
              indicatorColor: HColors.primary,
              dividerColor: HColors.surfaceContainerHigh,
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildProductsTab(),
                  _buildCollectionsTab(),
                  _buildArtisansTab(),
                ],
              ),
            ),
          ],
        ),
        bottomNavigationBar: HeritageBottomNav(
          currentIndex: _navIndex,
          cartCount: _cartCount,
          onTap: (i) {
            if (i == _navIndex) return;
            if (i == 0) context.go('/home');
            if (i == 1) context.go('/shop');
            if (i == 2) context.go('/saved');
            if (i == 3) context.go('/cart');
            if (i == 4) context.go('/nearby');
          },
        ),
        floatingActionButton: _buildFilterFAB(),
      ),
    );
  }

  Widget _buildProductsTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Category Chips
          SizedBox(
            height: 56,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final isSelected = _selectedCategory == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(
                      _categories[index],
                      style: HText.labelLg.copyWith(
                        color: isSelected
                            ? HColors.onSecondary
                            : HColors.onSurfaceVariant,
                      ),
                    ),
                    backgroundColor: isSelected
                        ? HColors.secondary
                        : HColors.surfaceContainerHighest,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),

          // Featured Products Scroll (Horizontal)
          SizedBox(
            height: 320,
            child: _filteredProducts.isEmpty
                ? Center(
                    child: Text(
                      'No products found',
                      style: HText.bodyMd,
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredProducts.take(3).length,
                    itemBuilder: (context, index) {
                      final product = _filteredProducts[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: SizedBox(
                          width: 200,
                          child: ProductCard(
                            id: product.id,
                            name: product.name,
                            subtitle: product.subtitle,
                            imageUrl: product.imageUrl,
                            price: product.price,
                            badge: product.badge,
                            isFavorite: product.isFavorite,
                            category: product.category,
                            onFavoriteToggle: () {
                              _handleFavoriteToggle(product);
                            },
                            onAddToCart: () {
                              _handleAddToCart(product);
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Grid Products
          Padding(
            padding: const EdgeInsets.all(20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.62,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return ProductCard(
                  id: product.id,
                  name: product.name,
                  subtitle: product.subtitle,
                  imageUrl: product.imageUrl,
                  price: product.price,
                  badge: product.badge,
                  isFavorite: product.isFavorite,
                  category: product.category,
                  onFavoriteToggle: () {
                    _handleFavoriteToggle(product);
                  },
                  onAddToCart: () {
                    _handleAddToCart(product);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildCollectionCard(
          title: 'Songkran Gift Set',
          subtitle: 'Celebrate the Khmer New Year',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDnDJ62hmjkoUypeXKmqSz5Oi18r7gNDWYEs6VBrdVKXYsf0md5E0gX00V9LtfdOs2tRn5Yc8Z4UBcxk4_ju79CaENhVaOftErjINGUVm4iLshfWgRRABwmOYZjs61O0EujZtJJA6p9MuEeMBMod1L6Bl2e2BnhMk8cviO4qMKZjFkf02Y9skMpTy5Jl6iIqs7Tt1lKnNo5lspnzvVYJlzG1xEGqiGRch9GWodkSoDSQS9_VI6sDon3rlch8MIipik2j8yer7kdhpo',
        ),
        const SizedBox(height: 16),
        _buildCollectionCard(
          title: 'Wedding Gifts',
          subtitle: 'Heritage pieces for eternal unions',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuBjiDGPRJpT-6iHqOLFC3hjs_EqZxVdnfa9Hp6qe44zeqduqTKCPON3jVBng2vnSfqI9UvUGCCEvQBweW2plKOXe2pLPI5-J9WUMY5XU0VOP9VRgeTFX7M8iCyxBXytiC91u37ulOjoDWDMkPw3OSw4GcEBcFcWl4DvL6N-tU-nC5XfINi_veI9lFVmq1IoBY2zg7BYDd97jSjHTcQSJwN8aUO6PKuHMXeJnkOJhcMgHRJOdExRQR0f-2Y5EOrPQxcL5JgsbQXOoNA',
        ),
      ],
    );
  }

  Widget _buildCollectionCard({
    required String title,
    required String subtitle,
    required String imageUrl,
  }) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: HColors.surfaceContainerLow,
                  child: const Icon(Icons.image_not_supported),
                );
              },
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: HText.headlineLg.copyWith(
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: HText.bodyMd.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtisansTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: 5,
      itemBuilder: (context, index) {
        return _buildArtisanCard(
          name: 'Vannak Som',
          specialty: 'Silk Weaver • Siem Reap',
          rating: 4.9,
          badge: 'MASTER',
          imageUrl:
              'https://lh3.googleusercontent.com/aida-public/AB6AXuDhv-CsxpxLLhNljZA1mjnE1PhMFm9yVDmjgrp_zSWVYXL4_9-CoLevgbk48ap5SWZyqcli0ko3RWGCFGi0bOjPaKZ_YuK07nOZAqgEhQn2JNuHJD6PL6sXgmmyrIJpiqziZusexf1Mk6sY6QXPxV7PGjK2EguEQJru8E5pNL7rFbCNxs0t9TbDCfu_dV5YxDtU7CvrAn1mUI_hotyhA97ROD4uzA1hUNfnhKsSCs5xYLW3JhI5VMfLim9PT7Vg4maWQlHhWAR01VI',
        );
      },
    );
  }

  Widget _buildArtisanCard({
    required String name,
    required String specialty,
    required double rating,
    required String badge,
    required String imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HColors.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: HColors.primaryContainer,
                    width: 2,
                  ),
                ),
                child: ClipOval(
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: HColors.surfaceContainerLow,
                        child: const Icon(Icons.person),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: HText.bodyLg,
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: HColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        badge,
                        style: HText.labelSm.copyWith(
                          color: HColors.onPrimaryContainer,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  specialty,
                  style: HText.labelLg.copyWith(
                    color: HColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      rating.toString(),
                      style: HText.labelLg.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterFAB() {
    return FloatingActionButton.extended(
      onPressed: () {},
      backgroundColor: HColors.primaryContainer,
      foregroundColor: HColors.onPrimaryContainer,
      icon: const Icon(Icons.tune),
      label: Text(
        'Filter',
        style: HText.labelLg.copyWith(
          color: HColors.onPrimaryContainer,
        ),
      ),
    );
  }
}
