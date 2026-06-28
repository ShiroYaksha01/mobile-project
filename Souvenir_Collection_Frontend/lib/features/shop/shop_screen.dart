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
import '../../blocs/artisans/artisan_bloc.dart';
import '../../blocs/artisans/artisan_state.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../blocs/cart/cart_cubit.dart';
import '../../blocs/favorites/favorites_cubit.dart';
import '../../models/user_collection.dart';
import '../../services/user_collection_service.dart';
import 'collection_detail_screen.dart';

class ShopScreen extends StatefulWidget {
  final List<Product> products;
  final String initialQuery;
  final void Function(Product)? onFavoriteToggle;
  final void Function(Product)? onAddToCart;

  const ShopScreen({
    super.key,
    required this.products,
    this.initialQuery = '',
    this.onFavoriteToggle,
    this.onAddToCart,
  });

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedCategory = 0;
  final int _navIndex = 1;
  String _searchQuery = '';
  final _searchController = TextEditingController();

  List<String> _categories = ['All Crafts'];

  String _sortBy = 'default';
  List<UserCollection> _userCollections = [];

  @override
  void initState() {
    super.initState();
    _searchQuery = widget.initialQuery;
    _searchController.text = widget.initialQuery;
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadUserCollections();
    _loadCategories();
    _loadCartCount();
    _loadFavorites();
  }

  Future<void> _loadUserCollections() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      try {
        final service = context.read<UserCollectionService>();
        final collections = await service.getUserCollections(authState.user.id);
        if (!mounted) return;
        setState(() {
          _userCollections = collections;
        });
      } catch (e) {
        // ignore
      }
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
  }

  Future<void> _loadCategories() async {
    try {
      final productService = context.read<ProductService>();
      final cats = await productService.getCategories();
      if (mounted) {
        setState(() {
          // Deduplicate categories
          final names = cats.map((c) => c['name']?.toString() ?? '').where((n) => n.isNotEmpty).toSet().toList();
          _categories = ['All Crafts', ...names];
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
        if (mounted) {
          context.read<CartCubit>().setCount(count);
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

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _sortedProducts {
    var list = widget.products.toList();
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
    switch (_sortBy) {
      case 'price_asc': list.sort((a, b) => a.price.compareTo(b.price)); break;
      case 'price_desc': list.sort((a, b) => b.price.compareTo(a.price)); break;
      case 'name': list.sort((a, b) => a.name.compareTo(b.name)); break;
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, authState) {
        if (authState is AuthAuthenticated) {
          _loadFavorites();
          _loadCartCount();
        }
      },
      child: DefaultTabController(
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
        floatingActionButton: _buildFilterFAB(),
      ),
    ),
    ); // BlocListener
  }

  Widget _buildProductsTab() {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) => SingleChildScrollView(
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

          // Featured Products Header
          if (_searchQuery.isEmpty && _selectedCategory == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text('Featured Items', style: HText.headlineMd.copyWith(color: HColors.primary)),
              ),
            ),

          // Featured Products Scroll (Horizontal)
          if (_searchQuery.isEmpty && _selectedCategory == 0)
            SizedBox(
              height: 320,
              child: _sortedProducts.isEmpty
                  ? Center(
                      child: Text(
                        'No products found',
                        style: HText.bodyMd,
                      ),
                    )
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _sortedProducts.take(3).length,
                      itemBuilder: (context, index) {
                        final product = _sortedProducts[index];
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
                              isFavorite: favState.favoriteIds.contains(product.id),
                              category: product.category,
                              onFavoriteToggle: () {
                                _handleFavoriteToggle(product);
                              },
                              onAddToCart: () {
                                _handleAddToCart(product);
                              },
                              onTap: () => context.push('/product/${product.id}'),
                            ),
                          ),
                        );
                      },
                    ),
            ),

          // Grid Products Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                (_searchQuery.isNotEmpty || _selectedCategory != 0)
                    ? 'Search Results'
                    : 'All Items',
                style: HText.headlineMd.copyWith(color: HColors.primary),
              ),
            ),
          ),

          // Grid Products
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.72,
              ),
              itemCount: _sortedProducts.length,
              itemBuilder: (context, index) {
                final product = _sortedProducts[index];
                return ProductCard(
                  id: product.id,
                  name: product.name,
                  subtitle: product.subtitle,
                  imageUrl: product.imageUrl,
                  price: product.price,
                  badge: product.badge,
                  isFavorite: favState.favoriteIds.contains(product.id),
                  category: product.category,
                  onFavoriteToggle: () {
                    _handleFavoriteToggle(product);
                  },
                  onAddToCart: () {
                    _handleAddToCart(product);
                  },
                  onTap: () => context.push('/product/${product.id}'),
                );
              },
            ),
          ),
        ],
      ),
    ),
    ); // BlocBuilder close
  }

  Widget _buildCollectionsTab() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        ElevatedButton.icon(
          onPressed: _showCreateCollectionDialog,
          icon: const Icon(Icons.create_new_folder),
          label: const Text('Create Custom Collection'),
          style: ElevatedButton.styleFrom(
            backgroundColor: HColors.primary,
            foregroundColor: HColors.primaryContainer,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        if (_userCollections.isNotEmpty) ...[
          Text('My Collections', style: HText.bodyLg),
          const SizedBox(height: 16),
          ..._userCollections.map((c) => _buildUserCollectionCard(c)),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  void _showCreateCollectionDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Collection'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Collection Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final authState = context.read<AuthBloc>().state;
                if (authState is AuthAuthenticated) {
                  try {
                    final service = context.read<UserCollectionService>();
                    final newCol = await service.createCollection(authState.user.id, controller.text.trim());
                    if (!mounted) return;
                    setState(() {
                      _userCollections.add(newCol);
                    });
                  } catch (e) {}
                }
                if (!ctx.mounted) return;
                Navigator.pop(ctx);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddProductDialog(UserCollection collection) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              minChildSize: 0.5,
              maxChildSize: 0.9,
              expand: false,
              builder: (_, controller) {
                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Add Purchased Products to ${collection.name}', style: HText.headlineMd),
                    ),
                    Expanded(
                      child: widget.products.isEmpty
                          ? const Center(child: Text('No purchased products available.'))
                          : ListView.builder(
                              controller: controller,
                              itemCount: widget.products.length,
                              itemBuilder: (context, index) {
                                final product = widget.products[index];
                                final isAdded = collection.items.any((item) => item.product.id == product.id);
                                return ListTile(
                                  leading: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      product.imageUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => Container(
                                        width: 50,
                                        height: 50,
                                        color: HColors.surfaceContainerLow,
                                        child: const Icon(Icons.image_not_supported),
                                      ),
                                    ),
                                  ),
                                  title: Text(product.name),
                                  trailing: isAdded
                                      ? const Icon(Icons.check_circle, color: Colors.green)
                                      : IconButton(
                                          icon: const Icon(Icons.add_circle_outline),
                                          onPressed: () async {
                                            final authState = context.read<AuthBloc>().state;
                                            if (authState is AuthAuthenticated) {
                                              try {
                                                final service = context.read<UserCollectionService>();
                                                await service.addOrUpdateItem(authState.user.id, collection.id, product.id, 1);
                                                if (!mounted) return;
                                                setState(() {
                                                  collection.items.add(CollectionItem(product: product));
                                                });
                                                setModalState(() {});
                                              } catch (e) {}
                                            }
                                          },
                                        ),
                                );
                              },
                            ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildUserCollectionCard(UserCollection collection) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (ctx) => CollectionDetailScreen(collection: collection),
          ),
        ).then((_) => setState(() {}));
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: HColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: HColors.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  collection.name,
                  style: HText.headlineMd,
                ),
                const SizedBox(height: 4),
                Text(
                  '${collection.items.length} products',
                  style: HText.bodyMd.copyWith(color: HColors.onSurfaceVariant),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showAddProductDialog(collection),
              tooltip: 'Add product',
            ),
          ],
        ),
      ),
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
    return BlocBuilder<ArtisanBloc, ArtisanState>(
      builder: (context, state) {
        if (state is ArtisanLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ArtisanLoaded) {
          if (state.artisans.isEmpty) {
            return const Center(child: Text('No artisans found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: state.artisans.length,
            itemBuilder: (context, index) {
              final artisan = state.artisans[index];
              return _buildArtisanCard(
                context: context,
                id: artisan.id,
                name: artisan.name,
                specialty: artisan.craft.isNotEmpty 
                    ? '${artisan.craft}${artisan.region.isNotEmpty ? ' • ${artisan.region}' : ''}' 
                    : artisan.region,
                rating: 4.9,
                badge: artisan.isVerified ? 'VERIFIED' : 'ARTISAN',
                imageUrl: artisan.imageUrl.isNotEmpty
                    ? artisan.imageUrl
                    : 'https://images.unsplash.com/photo-1544928147-79a2dbc1f389?w=800&q=80',
              );
            },
          );
        } else if (state is ArtisanError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('Please load artisans.'));
      },
    );
  }

  Widget _buildArtisanCard({
    required BuildContext context,
    required String id,
    required String name,
    required String specialty,
    required double rating,
    required String badge,
    required String imageUrl,
  }) {
    return GestureDetector(
      onTap: () => context.push('/artisan/$id'),
      child: Container(
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
    ),
    );
  }

  Widget _buildFilterFAB() {
    return FloatingActionButton.extended(
      onPressed: () {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sort & Filter', style: HText.headlineMd),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.attach_money),
                  title: const Text('Price: Low to High'),
                  onTap: () { setState(() => _sortBy = 'price_asc'); Navigator.pop(ctx); },
                ),
                ListTile(
                  leading: const Icon(Icons.money_off),
                  title: const Text('Price: High to Low'),
                  onTap: () { setState(() => _sortBy = 'price_desc'); Navigator.pop(ctx); },
                ),
                ListTile(
                  leading: const Icon(Icons.sort_by_alpha),
                  title: const Text('Name: A to Z'),
                  onTap: () { setState(() => _sortBy = 'name'); Navigator.pop(ctx); },
                ),
              ],
            ),
          ),
        );
      },
      backgroundColor: HColors.primaryContainer,
      foregroundColor: HColors.onPrimaryContainer,
      icon: const Icon(Icons.tune),
      label: Text('Sort', style: HText.labelLg.copyWith(color: HColors.onPrimaryContainer)),
    );
  }
}
