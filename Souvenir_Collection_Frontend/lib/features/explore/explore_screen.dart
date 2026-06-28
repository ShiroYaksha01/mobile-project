import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_bar.dart';
import '../../models/collection.dart';
import '../../services/collection_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  List<Collection>? _collections;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final svc = context.read<CollectionService>();
      final collections = await svc.getCollections();
      if (mounted) {
        setState(() {
          _collections = collections;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      appBar: const HeritageAppBar(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HColors.primary))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Oops!', style: HText.headlineMd),
                      const SizedBox(height: 8),
                      Text(_error!, style: HText.bodyMd),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Culture Gallery header
                        _sectionHeader(
                          'Culture Gallery',
                          'Discover Cambodian heritage through curated collections',
                          Icons.museum_outlined,
                        ),
                        const SizedBox(height: 16),

                        // Collections grid
                        if (_collections != null && _collections!.isNotEmpty)
                          GridView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 0.78,
                            ),
                            itemCount: _collections!.length,
                            itemBuilder: (context, index) =>
                                _collectionCard(_collections![index]),
                          )
                        else
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(40),
                              child: Text(
                                'No collections found.',
                                style: HText.bodyMd.copyWith(
                                    color: HColors.outline),
                              ),
                            ),
                          ),

                        const SizedBox(height: 28),

                        // Heritage Stories section
                        _sectionHeader(
                          'Heritage Stories',
                          'The artisans and traditions behind every piece',
                          Icons.auto_stories_outlined,
                        ),
                        const SizedBox(height: 16),
                        _storyCard(
                          'The Silk Weavers of Siem Reap',
                          'For centuries, Cambodian silk weaving has been passed down through generations. Each pattern tells a story of the land, its people, and their spiritual connection to nature.',
                          'https://images.unsplash.com/photo-1590736961830-e1a2b3c4d5e6?w=600',
                        ),
                        const SizedBox(height: 12),
                        _storyCard(
                          'Silver Craft in Koh Ker',
                          'Nestled near the ancient temple ruins, artisans continue the tradition of crafting intricate silver pieces using techniques dating back to the Khmer Empire.',
                          'https://images.unsplash.com/photo-1580870069867-74c5c1e4d9a7?w=600',
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _sectionHeader(String title, String subtitle, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: HColors.primary, size: 24),
            const SizedBox(width: 10),
            Text(title, style: HText.headlineMd.copyWith(color: HColors.onSurface)),
          ],
        ),
        const SizedBox(height: 6),
        Text(subtitle, style: HText.bodyMd.copyWith(color: HColors.outline)),
      ],
    );
  }

  Widget _collectionCard(Collection collection) {
    return GestureDetector(
      onTap: () => context.push('/collection/${collection.id}'),
      child: Container(
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
              child: Container(
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
                child: collection.image.isNotEmpty
                    ? Image.network(collection.image, fit: BoxFit.cover)
                    : Center(
                        child: Icon(Icons.museum_outlined,
                            size: 40,
                            color: HColors.surface.withValues(alpha: 0.8)),
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
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: HColors.primaryContainer.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          collection.type,
                          style: HText.labelSm.copyWith(color: HColors.primary),
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

  Widget _storyCard(String title, String body, String imageUrl) {
    return Container(
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2E2E2E).withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 140,
            decoration: BoxDecoration(
              color: HColors.primaryContainer.withValues(alpha: 0.2),
            ),
            child: Image.network(imageUrl, fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.auto_stories,
                          size: 40,
                          color: HColors.primary.withValues(alpha: 0.3)),
                    )),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: HText.headlineMd.copyWith(color: HColors.onSurface)),
                const SizedBox(height: 8),
                Text(body, style: HText.bodyMd.copyWith(color: HColors.outline)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
