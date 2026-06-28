import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import '../../blocs/artisans/artisan_bloc.dart';
import '../../blocs/artisans/artisan_state.dart';
import '../../blocs/products/product_bloc.dart';
import '../../blocs/products/product_state.dart';
import '../../models/artisan.dart';
import '../../models/product.dart';

class ArtisanProfileScreen extends StatelessWidget {
  final String artisanId;
  const ArtisanProfileScreen({super.key, required this.artisanId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<ArtisanBloc, ArtisanState>(
        builder: (context, artisanState) {
          if (artisanState is ArtisanLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (artisanState is ArtisanLoaded) {
            final artisan = artisanState.artisans.firstWhere(
              (a) => a.id == artisanId,
              orElse: () => const Artisan(name: 'Unknown', craft: '', imageUrl: ''),
            );

            if (artisan.id.isEmpty) {
              return Scaffold(
                appBar: AppBar(title: const Text('Artisan Not Found')),
                body: const Center(child: Text('Could not load artisan details.')),
              );
            }

            return CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, artisan),
                _buildBiographicalScroll(artisan),
                _buildProductsHeader(),
                _buildProductsCatalog(artisan.id),
              ],
            );
          } else if (artisanState is ArtisanError) {
            return Center(child: Text('Error: ${artisanState.message}'));
          }
          return const Center(child: Text('No Data'));
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, Artisan artisan) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          artisan.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black87, blurRadius: 4)],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            CachedNetworkImage(
              imageUrl: artisan.imageUrl.isNotEmpty
                  ? artisan.imageUrl
                  : 'https://images.unsplash.com/photo-1544928147-79a2dbc1f389?w=800&q=80',
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: Colors.brown[200],
                child: const Icon(Icons.person, size: 100, color: Colors.white),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                ),
              ),
            ),
            Positioned(
              bottom: 60,
              left: 16,
              right: 16,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade700,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      artisan.craft.isNotEmpty ? artisan.craft : 'Master Artisan',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (artisan.region.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            artisan.region,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                  if (artisan.isVerified) ...[
                    const Spacer(),
                    const Icon(Icons.verified, color: Colors.blueAccent, size: 28),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBiographicalScroll(Artisan artisan) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.history_edu, color: Colors.brown),
                    SizedBox(width: 8),
                    Text(
                      'The Artisan\'s Story',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.brown),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  artisan.bio.isNotEmpty
                      ? artisan.bio
                      : 'A master craftsman dedicated to preserving traditional techniques and sharing their cultural heritage through exceptional handmade items.',
                  style: const TextStyle(fontSize: 15, height: 1.5, color: Colors.black87),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductsHeader() {
    return const SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Text(
          'Handmade Collection',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.brown),
        ),
      ),
    );
  }

  Widget _buildProductsCatalog(String artisanId) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const SliverToBoxAdapter(
            child: Center(child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            )),
          );
        } else if (state is ProductLoaded) {
          final artisanProducts = state.products.where((p) => p.artisanId == artisanId).toList();

          if (artisanProducts.isEmpty) {
            return const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Center(
                  child: Text('No products available from this artisan.'),
                ),
              ),
            );
          }

          return SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = artisanProducts[index];
                  return _buildProductCard(context, product);
                },
                childCount: artisanProducts.length,
              ),
            ),
          );
        }
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        context.push('/product/${product.id}');
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 3,
              child: CachedNetworkImage(
                imageUrl: product.imageUrl.isNotEmpty
                    ? product.imageUrl
                    : 'https://images.unsplash.com/photo-1574358602640-5fdf3cc8221b?w=400&q=80',
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[300],
                  child: const Icon(Icons.image, size: 50, color: Colors.grey),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.brown.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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
