import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';

import 'package:messenger_client_flutter/models/models.dart';

class ApiService {
  final Dio _dio = Dio();

  void configure({required String baseUrl, required String token}) {
    _dio.options = BaseOptions(
      baseUrl: baseUrl,
      headers: {'Authorization': 'Bearer $token'},
    );
  }

  Future<AuthResponse> register(
      String userName, String password, String baseUrl) async {
    final response = await _dio.post(
      '$baseUrl/api/auth/register',
      data: {'userName': userName, 'password': password},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<AuthResponse> login(
      String userName, String password, String baseUrl) async {
    final response = await _dio.post(
      '$baseUrl/api/auth/login',
      data: {'userName': userName, 'password': password},
    );
    return AuthResponse.fromJson(response.data);
  }

  Future<ChannelModel> createChannel(String name) async {
    final response = await _dio.post('/api/channels', data: {'name': name});
    return ChannelModel.fromJson(response.data);
  }

  Future<List<MessageModel>> getMessages(String channelId) async {
    final response = await _dio.get('/api/channels/$channelId/messages');
    return (response.data as List)
        .map((e) => MessageModel.fromJson(e))
        .toList();
  }

  Future<void> sendMessage(String channelId, String text) async {
    await _dio.post('/api/channels/message',
        data: {'channelId': channelId, 'text': text});
  }

  Future<void> uploadFile(String channelId, PlatformFile file) async {
    final formData = FormData.fromMap({
      'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
    });
    await _dio.post('/api/channels/$channelId/files', data: formData);
  }
}
