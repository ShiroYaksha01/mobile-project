import 'api_client.dart';

class QuizService {
  final ApiClient _apiClient;

  QuizService(this._apiClient);

  /// GET /api/quiz — returns list of questions with nested answers
  Future<List<Map<String, dynamic>>> getQuizQuestions() async {
    try {
      final response = await _apiClient.get('/quiz');
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
      throw Exception('Failed to load quiz questions');
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/quiz/{id} — single question with nested answers
  Future<Map<String, dynamic>> getQuizQuestion(String questionId) async {
    try {
      final response = await _apiClient.get('/quiz/$questionId');
      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to load quiz question');
    } catch (e) {
      rethrow;
    }
  }

  /// GET /api/quiz/{questionId}/answer
  Future<List<Map<String, dynamic>>> getQuizAnswers(String questionId) async {
    try {
      final response = await _apiClient.get('/quiz/$questionId/answer');
      if (response.statusCode == 200) {
        final list = response.data['data'] as List<dynamic>;
        return list.map((e) => e as Map<String, dynamic>).toList();
      }
      throw Exception('Failed to load quiz answers');
    } catch (e) {
      rethrow;
    }
  }

  /// POST /api/quiz/answer — body: { selectedAnswerIds: [...] }
  /// Returns QuizResultDto: { recommendedProductIds, recommendedProducts, matchedTags, feedback }
  Future<Map<String, dynamic>> submitAnswers(List<String> selectedAnswerIds) async {
    try {
      final body = {
        'selectedAnswerIds': selectedAnswerIds,
      };
      final response = await _apiClient.post('/quiz/answer', data: body);
      if (response.statusCode == 200) {
        return response.data['data'] as Map<String, dynamic>;
      }
      throw Exception('Failed to submit quiz answers');
    } catch (e) {
      rethrow;
    }
  }
}
