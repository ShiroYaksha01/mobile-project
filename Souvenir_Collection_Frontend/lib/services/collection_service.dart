import '../models/collection.dart';
import '../models/product.dart';
import 'api_client.dart';

class CollectionService {
  final ApiClient _apiClient;

  CollectionService(this._apiClient);

  /// GET /api/collections?sortOrder=asc
  Future<List<Collection>> getCollections({String sortOrder = 'asc'}) async {
    try {
      final response = await _apiClient.get(
        '/collections',
        queryParameters: {'sortOrder': sortOrder},
      );
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>;
        return list
            .map((e) => Collection.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load collections');
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/collections/{id}
  Future<Collection> getCollectionById(String id) async {
    try {
      final response = await _apiClient.get('/collections/$id');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Collection.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to load collection');
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/collections/slug/{slug}
  Future<Collection> getCollectionBySlug(String slug) async {
    try {
      final response = await _apiClient.get('/collections/slug/$slug');
      if (response.statusCode == 200) {
        final data = response.data['data'];
        return Collection.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to load collection');
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/collections/type/{type}?sortOrder=asc
  Future<List<Collection>> getCollectionsByType(String type,
      {String sortOrder = 'asc'}) async {
    try {
      final response = await _apiClient.get(
        '/collections/type/$type',
        queryParameters: {'sortOrder': sortOrder},
      );
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>;
        return list
            .map((e) => Collection.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load collections by type');
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/collections/{id}/products?sortOrder=asc
  Future<List<Product>> getCollectionProducts(String collectionId,
      {String sortOrder = 'asc'}) async {
    try {
      final response = await _apiClient.get(
        '/collections/$collectionId/products',
        queryParameters: {'sortOrder': sortOrder},
      );
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>;
        return list
            .map((e) => Product.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load collection products');
    } catch (e) {
      rethrow;
    }
  }
}
