import '../models/artisan.dart';
import 'api_client.dart';

class ArtisanService {
  final ApiClient _apiClient;

  ArtisanService(this._apiClient);

  Future<List<Artisan>> getAllArtisans() async {
    try {
      final response = await _apiClient.get('/artisans');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Artisan.fromJson(json)).toList();
      }
      throw Exception('Failed to load artisans');
    } catch (e) {
      throw Exception('Failed to load artisans: $e');
    }
  }
}
