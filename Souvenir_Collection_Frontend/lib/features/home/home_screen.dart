import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../core/widgets/bottom_nav.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/product_card.dart';
import '../../core/widgets/sidebar.dart';
import '../../models/artisan.dart';
import '../../models/collection.dart';
import '../../models/nearby_shop.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/favorites_service.dart';
import '../../services/order_service.dart';
import '../../services/map_service.dart';
import '../../services/collection_service.dart';
import '../../blocs/artisans/artisan_bloc.dart';
import '../../blocs/artisans/artisan_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/cart/cart_cubit.dart';
import '../../blocs/favorites/favorites_cubit.dart';

class HomeScreen extends StatefulWidget {
  final List<Product> products;
  final void Function(Product)? onFavoriteToggle;
  final void Function(Product)? onAddToCart;

  const HomeScreen({
    super.key,
    required this.products,
    this.onFavoriteToggle,
    this.onAddToCart,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategory = 0;
  int _navIndex = 0;
  bool _showSearch = false;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Data from API
  List<String> _categories = ['All'];
  List<NearbyShop> _nearbyShops = [];
  List<Collection> _collections = [];
  bool _categoriesLoading = true;
  bool _nearbyLoading = true;
  bool _collectionsLoading = true;
  int _cartCount = 0;
  String _sortBy = 'default'; // 'default', 'price_asc', 'price_desc', 'name'

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadNearbyShops();
    _loadCollections();
    _loadCartCount();
    _loadFavorites();
  }

  Future<void> _loadCategories() async {
    try {
      final productService = context.read<ProductService>();
      final cats = await productService.getCategories();
      if (mounted) {
        setState(() {
          // Deduplicate categories
          final names = cats.map((c) => c['name']?.toString() ?? '').where((n) => n.isNotEmpty).toSet().toList();
          _categories = ['All', ...names];
          _categoriesLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _categoriesLoading = false);
      }
    }
  }

  Future<void> _loadNearbyShops() async {
    try {
      final mapService = context.read<MapService>();
      final shops = await mapService.getBranches();
      if (mounted) {
        setState(() {
          _nearbyShops = shops;
          _nearbyLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _nearbyLoading = false);
      }
    }
  }

  Future<void> _loadCollections() async {
    try {
      final collectionService = context.read<CollectionService>();
      final collections = await collectionService.getCollections();
      if (mounted) {
        setState(() {
          _collections = collections;
          _collectionsLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _collectionsLoading = false);
      }
    }
  }

  Future<void> _loadCartCount() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final orderService = context.read<OrderService>();
        final count = await orderService.getCartCount(authState.user.id);
        if (mounted) {
          context.read<CartCubit>().setCount(count);
          setState(() => _cartCount = count);
        }
      }
    } catch (_) {}
  }

  Future<void> _loadFavorites() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final favService = context.read<FavoritesService>();
        final items = await favService.getFavoriteProducts(authState.user.id);
        if (mounted) {
          final ids = items.map((p) => p.id).toSet();
          context.read<FavoritesCubit>().setFavorites(ids);
        }
      }
    } catch (_) {}
  }

  String? get _currentUserId {
    final state = context.read<AuthBloc>().state;
    return state is AuthAuthenticated ? state.user.id : null;
  }

  Future<void> _handleFavoriteToggle(Product product) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      _showLoginPrompt();
      return;
    }
    try {
      final favService = context.read<FavoritesService>();
      final isNowFavorited = await favService.toggleFavorite(userId, product.id);
      if (mounted) {
        context.read<FavoritesCubit>().toggle(product.id);
        setState(() => product.isFavorite = isNowFavorited);
        widget.onFavoriteToggle?.call(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isNowFavorited ? 'Added to favorites' : 'Removed from favorites'),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (_) {}
  }

  Future<void> _handleAddToCart(Product product) async {
    final userId = _currentUserId;
    if (userId == null || userId.isEmpty) {
      _showLoginPrompt();
      return;
    }
    try {
      final orderService = context.read<OrderService>();
      await orderService.addToCart(userId, product.id);
      if (mounted) {
        context.read<CartCubit>().increment();
        setState(() => product.cartQty++);
        widget.onAddToCart?.call(product);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} added to cart'),
            duration: const Duration(seconds: 2),
            backgroundColor: HColors.success,
          ),
        );
      }
    } catch (_) {}
  }

  void _showLoginPrompt() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign in required'),
        content: const Text('Please sign in to add items to cart or favorites.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () { Navigator.pop(ctx); context.go('/login'); },
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  List<Product> get _filteredProducts {
    var list = widget.products.toList();
    if (_selectedCategory != 0 && _selectedCategory < _categories.length) {
      final cat = _categories[_selectedCategory];
      list = list.where((p) => p.category == cat).toList();
    }
    if (_searchQuery.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
    // Sort
    switch (_sortBy) {
      case 'price_asc': list.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'price_desc': list.sort((a, b) => b.price.compareTo(a.price)); break;
      case 'name': list.sort((a, b) => a.name.compareTo(b.name)); break;
    }
    return list;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final featured = widget.products.take(4).toList();
    final showFiltered = _selectedCategory != 0 || _searchQuery.isNotEmpty;
    final displayProducts = showFiltered ? _filteredProducts : featured;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          _loadFavorites();
          _loadCartCount();
        }
      },
      child: Scaffold(
      appBar: HeritageAppBar(
        onSearch: () {
          setState(() {
            _showSearch = !_showSearch;
            if (!_showSearch) {
              _searchController.clear();
              _searchQuery = '';
            }
          });
        },
      ),
      endDrawer: const AppSidebar(currentIndex: -1),
      bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
        builder: (context, cartState) => HeritageBottomNav(
        currentIndex: _navIndex,
        cartCount: cartState.cartCount,
        onTap: (i) {
          if (i == _navIndex) return;
          if (i == 0) context.go('/home');
          if (i == 1) context.go('/shop');
          if (i == 2) context.go('/saved');
          if (i == 3) context.go('/cart');
          if (i == 4) context.go('/nearby');
        },
      ),
      ),
      body: CustomScrollView(
        slivers: [
          if (_showSearch) _buildSearchBar(),
          SliverToBoxAdapter(child: _HeroSection()),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildPromotionStrip()),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          SliverToBoxAdapter(child: _buildCategoryRow()),
          SliverToBoxAdapter(child: const SizedBox(height: 24)),
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              showFiltered ? 'Filtered Picks' : 'Featured Collections',
              showFiltered ? '${displayProducts.length} items' : null,
            ),
          ),
          SliverToBoxAdapter(child: const SizedBox(height: 14)),
          SliverToBoxAdapter(child: _buildProductRow(displayProducts)),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
          SliverToBoxAdapter(child: _buildCollectionsSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
          SliverToBoxAdapter(child: _buildArtisanSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
          SliverToBoxAdapter(child: _buildStoryCard()),
          const SliverToBoxAdapter(child: SizedBox(height: 36)),
          SliverToBoxAdapter(child: _buildSectionHeader('Nearby Shops', null)),
          SliverToBoxAdapter(child: const SizedBox(height: 14)),
          SliverToBoxAdapter(child: _buildNearbyShops()),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    ),
    ); // BlocListener
  }

  Widget _buildSearchBar() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: TextField(
          controller: _searchController,
          autofocus: true,
          onChanged: (v) => setState(() => _searchQuery = v),
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: HText.bodyMd.copyWith(color: HColors.outline),
            prefixIcon:
                const Icon(Icons.search, color: HColors.outline, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
                    onTap: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                    child: const Icon(Icons.close,
                        color: HColors.outline, size: 18))
                : null,
            filled: true,
            fillColor: HColors.surfaceContainerHigh,
            contentPadding: const EdgeInsets.symmetric(vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          style: HText.bodyMd,
        ),
      ),
    );
  }

  Widget _buildCategoryRow() {
    if (_categoriesLoading && _categories.length <= 1) {
      return const SizedBox(
        height: 42,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (ctx, i) => CategoryChip(
          label: _categories[i],
          selected: i == _selectedCategory,
          onTap: () => setState(() => _selectedCategory = i),
        ),
      ),
    );
  }

  Widget _buildPromotionStrip() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: HColors.secondaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: HColors.secondary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_offer_outlined, color: HColors.secondary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Festive Special', style: HText.labelLg.copyWith(color: HColors.onSecondaryContainer, fontWeight: FontWeight.bold)),
                const SizedBox(height: 2),
                Text('Use code KHMER20 for 20% off all silk items.', style: HText.labelSm.copyWith(color: HColors.onSecondaryContainer.withValues(alpha: 0.8))),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: HColors.secondary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('COPY', style: HText.labelSm.copyWith(color: HColors.onSecondary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: HText.headlineMd.copyWith(color: HColors.primary)),
              if (subtitle != null)
                Text(subtitle, style: HText.labelSm.copyWith(color: HColors.outline)),
            ],
          ),
          PopupMenuButton<String>(
            initialValue: _sortBy,
            onSelected: (v) => setState(() => _sortBy = v),
            itemBuilder: (_) => [
              const PopupMenuItem(value: 'default', child: Text('Default')),
              const PopupMenuItem(value: 'price_asc', child: Text('Price: Low→High')),
              const PopupMenuItem(value: 'price_desc', child: Text('Price: High→Low')),
              const PopupMenuItem(value: 'name', child: Text('Name A→Z')),
            ],
            child: const Icon(Icons.sort, color: HColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow(List<Product> products) {
    if (products.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Center(
          child: Column(
            children: [
              const Icon(Icons.inventory_2_outlined, size: 48, color: HColors.outline),
              const SizedBox(height: 12),
              Text('No items found', style: HText.bodyMd.copyWith(color: HColors.outline)),
            ],
          ),
        ),
      );
    }
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        return SizedBox(
          height: 320,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: products.length,
            separatorBuilder: (_, _) => const SizedBox(width: 16),
            itemBuilder: (ctx, i) {
              final p = products[i];
              final isFav = favState.favoriteIds.contains(p.id);
              return SizedBox(
                width: 200,
                child: ProductCard(
                  id: p.id, name: p.name, subtitle: p.subtitle,
                  imageUrl: p.imageUrl, price: p.price,
                  badge: p.badge, isFavorite: isFav, category: p.category,
                  onFavoriteToggle: () => _handleFavoriteToggle(p),
                  onAddToCart: () => _handleAddToCart(p),
                  onTap: () => context.push('/product/${p.id}'),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCollectionsSection() {
    if (_collectionsLoading && _collections.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_collections.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Curated Collections',
                      style: HText.headlineMd.copyWith(color: HColors.primary)),
                  const SizedBox(height: 2),
                  Text('Discover Cambodian heritage',
                      style: HText.labelSm.copyWith(color: HColors.outline)),
                ],
              ),
              GestureDetector(
                onTap: () => context.push('/explore'),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('View All',
                        style: HText.labelSm.copyWith(
                            color: HColors.primary,
                            fontWeight: FontWeight.w600)),
                    const Icon(Icons.arrow_forward_ios,
                        size: 12, color: HColors.primary),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 240,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _collections.length,
            separatorBuilder: (_, _) => const SizedBox(width: 14),
            itemBuilder: (ctx, i) {
              final c = _collections[i];
              return _CollectionCard(collection: c);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildArtisanSection() {
    return Container(
      color: HColors.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Text('Meet the Artisans',
              style: HText.headlineMd.copyWith(color: HColors.primary)),
          const SizedBox(height: 4),
          Text('The heartbeat of our heritage',
              style: HText.bodyMd.copyWith(
                  color: HColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic)),
          const SizedBox(height: 20),
          SizedBox(
            height: 120,
            child: BlocBuilder<ArtisanBloc, ArtisanState>(
              builder: (context, state) {
                if (state is ArtisanLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ArtisanError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is ArtisanLoaded) {
                  if (state.artisans.isEmpty) {
                    return const Center(child: Text('No artisans found'));
                  }
                  return ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: state.artisans.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 24),
                    itemBuilder: (ctx, i) =>
                        _ArtisanAvatar(artisan: state.artisans[i], index: i),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [HColors.primary, Color(0xFF3D3000)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: HColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.auto_stories_outlined,
              color: HColors.primaryFixedDim, size: 28),
          const SizedBox(height: 12),
          Text('Our Story',
              style: HText.headlineMd.copyWith(color: HColors.primaryFixed)),
          const SizedBox(height: 8),
          Text(
            'Connecting ancient Khmer artistry with the modern world. Every piece carries a story of mastery passed down through generations.',
            style:
                HText.bodyMd.copyWith(color: Colors.white.withValues(alpha: 0.8)),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: HColors.primaryFixed,
              side: const BorderSide(color: HColors.primaryFixed),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
            child: Text('LEARN MORE',
                style: HText.labelSm.copyWith(color: HColors.primaryFixed)),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyShops() {
    if (_nearbyLoading && _nearbyShops.isEmpty) {
      return const SizedBox(
        height: 170,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_nearbyShops.isEmpty) {
      return const SizedBox(
        height: 170,
        child: Center(
          child: Text('No nearby shops found',
              style: TextStyle(color: HColors.outline)),
        ),
      );
    }
    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _nearbyShops.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (ctx, i) =>
            _NearbyShopCard(shop: _nearbyShops[i]),
      ),
    );
  }
}

// ─── hero — rich gradient + decorative ornament (no image) ──────────
class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 360,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Rich layered background
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF1A1400),
                    Color(0xFF4A3C00),
                    Color(0xFF735C00),
                    Color(0xFF3D3000),
                  ],
                  stops: [0.0, 0.4, 0.75, 1.0],
                ),
              ),
              child: CustomPaint(
                painter: _HeroPatternPainter(),
              ),
            ),
          ),
          // Gradient overlay for text readability
          DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.65),
                ],
                stops: const [0.35, 1.0],
              ),
            ),
          ),
          // Content
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 2,
                        decoration: BoxDecoration(
                          color: HColors.primaryContainer,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'KHMER HERITAGE',
                        style: HText.labelSm.copyWith(
                          color: HColors.primaryContainer,
                          letterSpacing: 2.5,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Soul of Khmer\nArtistry',
                    style: HText.displayLg.copyWith(
                      color: Colors.white,
                      fontSize: 36,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Connecting ancient traditions with modern elegance.',
                    style: HText.bodyMd.copyWith(
                      color: Colors.white.withValues(alpha: 0.78),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/shop');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: HColors.primaryContainer,
                      foregroundColor: HColors.onPrimaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 13),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('EXPLORE THE HERITAGE',
                            style: HText.labelLg.copyWith(
                                color: HColors.onPrimaryContainer)),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward, size: 16),
                      ],
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

// ─── geometric pattern painter for hero background ─────────────────
class _HeroPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.03)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    const step = 32.0;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        canvas.drawCircle(Offset(x, y), step * 0.5, paint);
      }
    }

    final accentPaint = Paint()
      ..color = HColors.primaryContainer.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final rng = Random(42);
    for (int i = 0; i < 18; i++) {
      final cx = rng.nextDouble() * size.width;
      final cy = rng.nextDouble() * size.height;
      final r = 20 + rng.nextDouble() * 50;
      canvas.drawCircle(Offset(cx, cy), r, accentPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── artisan avatar — initials-based (no image) ─────────────────────
const _avatarColors = [
  Color(0xFFD4AF37),
  Color(0xFF9D4221),
  Color(0xFF735C00),
  Color(0xFF8F4B3A),
];

class _ArtisanAvatar extends StatelessWidget {
  final Artisan artisan;
  final int index;
  const _ArtisanAvatar({required this.artisan, required this.index});

  String get _initials {
    final parts = artisan.name.split(' ');
    if (parts.length >= 2) {
      return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
    }
    return artisan.name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final color = _avatarColors[index % _avatarColors.length];
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.12),
              border: Border.all(color: color.withValues(alpha: 0.5), width: 2),
            ),
            child: Center(
              child: Text(
                _initials,
                style: HText.headlineMd.copyWith(
                  color: color,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            artisan.name,
            style: HText.labelSm.copyWith(
                color: HColors.onSurface, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            artisan.craft.toUpperCase(),
            style: HText.labelSm.copyWith(
                color: HColors.secondary, fontSize: 9, letterSpacing: 0.5),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── collection card ────────────────────────────────────────────────
class _CollectionCard extends StatelessWidget {
  final Collection collection;
  const _CollectionCard({required this.collection});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/collection/${collection.id}'),
      child: Container(
        width: 180,
        decoration: BoxDecoration(
          color: HColors.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF2E2E2E).withValues(alpha: 0.06),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: collection.image.isNotEmpty
                  ? Image.network(collection.image, fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  HColors.primary.withValues(alpha: 0.6),
                                  HColors.primary.withValues(alpha: 0.25),
                                ],
                              ),
                            ),
                            child: const Center(
                              child: Icon(Icons.museum_outlined,
                                  size: 36, color: Colors.white70),
                            ),
                          ))
                  : Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            HColors.primary.withValues(alpha: 0.6),
                            HColors.primary.withValues(alpha: 0.25),
                          ],
                        ),
                      ),
                      child: const Center(
                        child: Icon(Icons.museum_outlined,
                            size: 36, color: Colors.white70),
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      collection.title,
                      style: HText.labelLg.copyWith(color: HColors.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      collection.description,
                      style: HText.labelSm.copyWith(color: HColors.outline),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (collection.type.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: HColors.primaryContainer
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          collection.type,
                          style: HText.labelSm.copyWith(
                              color: HColors.primary, fontSize: 10),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── nearby shop card ───────────────────────────────────────────────
class _NearbyShopCard extends StatelessWidget {
  final NearbyShop shop;
  const _NearbyShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border:
            Border.all(color: HColors.outlineVariant.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E2E2E).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: HColors.primaryContainer.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                ),
                child:
                    const Icon(Icons.store, color: HColors.primary, size: 20),
              ),
              const Spacer(),
              if (shop.rating > 0)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: HColors.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, size: 12, color: HColors.primary),
                      const SizedBox(width: 3),
                      Text(shop.rating.toString(),
                          style: HText.labelSm.copyWith(
                              color: HColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 11)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(shop.name,
              style: HText.labelLg.copyWith(color: HColors.onSurface),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          const SizedBox(height: 3),
          Text(shop.type,
              style: HText.labelSm.copyWith(color: HColors.outline)),
          const Spacer(),
          if (shop.distance.isNotEmpty)
            Row(
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 13, color: HColors.secondary),
                const SizedBox(width: 4),
                Text(shop.distance,
                    style: HText.labelSm.copyWith(
                        color: HColors.secondary, fontSize: 10)),
              ],
            ),
        ],
      ),
    );
  }
}
