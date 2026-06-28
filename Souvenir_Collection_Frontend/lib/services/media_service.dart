import 'package:dio/dio.dart';

import 'api_client.dart';

class MediaService {
  final ApiClient _apiClient;

  MediaService(this._apiClient);

  /// POST /api/media/upload — multipart form upload with IFormFile
  /// Returns { url: string }
  Future<String> uploadMedia(String filePath) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final response = await _apiClient.dioClient.post(
        '/media/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data['url'] as String? ?? '';
      }
      throw Exception('Failed to upload media');
    } catch (e) {
      rethrow;
    }
  }

  /// Upload media from bytes (in-memory)
  Future<String> uploadMediaBytes(
    List<int> bytes,
    String fileName,
  ) async {
    try {
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(
          bytes,
          filename: fileName,
        ),
      });

      final response = await _apiClient.dioClient.post(
        '/media/upload',
        data: formData,
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        return data['url'] as String? ?? '';
      }
      throw Exception('Failed to upload media');
    } catch (e) {
      rethrow;
    }
  }
}
