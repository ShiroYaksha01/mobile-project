import '../models/review.dart';
import 'api_client.dart';

class ReviewService {
  final ApiClient _apiClient;

  ReviewService(this._apiClient);

  /// GET /api/reviews/product/{productId}
  Future<List<Review>> getProductReviews(String productId) async {
    try {
      final response = await _apiClient.get('/reviews/product/$productId');
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>;
        return list
            .map((e) => Review.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Failed to load reviews');
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/reviews — body: Review entity JSON
  Future<Review> createReview({
    required String userId,
    String? productId,
    String? reviewText,
    required int rating,
    String? image,
  }) async {
    try {
      final body = <String, dynamic>{
        'userId': userId,
        'rating': rating,
      };
      if (productId != null) body['productId'] = productId;
      if (reviewText != null) body['reviewText'] = reviewText;
      if (image != null) body['image'] = image;

      final response = await _apiClient.post('/reviews', data: body);
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = response.data['data'];
        return Review.fromJson(data as Map<String, dynamic>);
      }
      throw Exception('Failed to create review');
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/reviews/product/{productId}/rating
  Future<double> getProductRating(String productId) async {
    try {
      final response =
          await _apiClient.get('/reviews/product/$productId/rating');
      if (response.statusCode == 200) {
        final rating = response.data['data'];
        return (rating as num).toDouble();
      }
      throw Exception('Failed to load product rating');
    } catch (e) {
      return 0.0;
    }
  }
}
