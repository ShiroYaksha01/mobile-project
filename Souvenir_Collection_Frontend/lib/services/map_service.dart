import '../models/nearby_shop.dart';
import 'api_client.dart';

class MapService {
  final ApiClient _apiClient;

  MapService(this._apiClient);

  /// Fetch all branches (verified artisans) from GET /api/map/branches
  Future<List<NearbyShop>> getBranches() async {
    try {
      final response = await _apiClient.get('/map/branches');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => NearbyShop.fromJson(json)).toList();
      }
      throw Exception('Failed to load branches');
    } catch (e) {
      throw Exception('Failed to load branches: $e');
    }
  }
}
