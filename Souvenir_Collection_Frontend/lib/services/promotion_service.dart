import '../models/promotion.dart';
import 'api_client.dart';

class PromotionService {
  final ApiClient _apiClient;

  PromotionService(this._apiClient);

  /// GET /api/promotions/active
  Future<List<Promotion>> getActivePromotions() async {
    try {
      final response = await _apiClient.get('/promotions/active');
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>;
        return list
            .map((e) => Promotion.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load promotions');
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/promotions/validate?code=XXX&subTotal=100.00
  /// Returns the discount amount (decimal)
  Future<double> validatePromoCode(String code, {double subTotal = 0}) async {
    try {
      final response = await _apiClient.get(
        '/promotions/validate',
        queryParameters: {
          'code': code,
          'subTotal': subTotal.toString(),
        },
      );
      if (response.statusCode == 200) {
        final discount = response.data['data'];
        return (discount as num).toDouble();
      }
      throw Exception('Invalid or expired promo code');
    } catch (e) {
      rethrow;
    }
  }
}
