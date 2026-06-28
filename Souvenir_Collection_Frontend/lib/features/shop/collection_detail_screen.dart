import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../models/user_collection.dart';
import '../../services/user_collection_service.dart';

class CollectionDetailScreen extends StatefulWidget {
  final UserCollection collection;

  const CollectionDetailScreen({super.key, required this.collection});

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: HeritageAppBar(
        title: widget.collection.name,
        showBackButton: true,
      ),
      body: widget.collection.items.isEmpty
          ? Center(
              child: Text(
                'No products added yet.',
                style: HText.bodyLg.copyWith(color: HColors.onSurfaceVariant),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: widget.collection.items.length,
              itemBuilder: (context, index) {
                final item = widget.collection.items[index];
                final product = item.product;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: HColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: HColors.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          product.imageUrl,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 80,
                            height: 80,
                            color: HColors.surfaceContainerLow,
                            child: const Icon(Icons.image_not_supported),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: HText.headlineMd,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              product.subtitle,
                              style: HText.bodyMd.copyWith(color: HColors.onSurfaceVariant),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Text('Quantity: ', style: HText.labelLg),
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () async {
                                    final authState = context.read<AuthBloc>().state;
                                    if (authState is AuthAuthenticated) {
                                      final service = context.read<UserCollectionService>();
                                      if (item.quantity > 1) {
                                        await service.addOrUpdateItem(authState.user.id, widget.collection.id, product.id, item.quantity - 1);
                                        if (!mounted) return;
                                        setState(() {
                                          item.quantity--;
                                        });
                                      } else {
                                        await service.removeItem(authState.user.id, widget.collection.id, product.id);
                                        if (!mounted) return;
                                        setState(() {
                                          widget.collection.items.removeAt(index);
                                        });
                                      }
                                    }
                                  },
                                ),
                                Text('${item.quantity}', style: HText.bodyLg),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  onPressed: () async {
                                    final authState = context.read<AuthBloc>().state;
                                    if (authState is AuthAuthenticated) {
                                      final service = context.read<UserCollectionService>();
                                      await service.addOrUpdateItem(authState.user.id, widget.collection.id, product.id, item.quantity + 1);
                                      if (!mounted) return;
                                      setState(() {
                                        item.quantity++;
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pop(context);
        },
        backgroundColor: HColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Add Items', style: HText.labelLg.copyWith(color: Colors.white)),
      ),
    );
  }
}
