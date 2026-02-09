import 'package:dio/dio.dart';

import '../../core/api_client.dart';
import 'topic_model.dart';

class TopicService {
  final Dio _dio = ApiClient().client;

  Future<List<Topic>> fetchTopics() async {
    final response = await _dio.get('/topics/');
    final data = response.data as List<dynamic>;
    return data.map((e) => Topic.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Topic> addTopic({required String title, String? notes}) async {
    final response = await _dio.post(
      '/topics/',
      data: {
        'title': title,
        'notes': notes,
      },
    );
    return Topic.fromJson(response.data as Map<String, dynamic>);
  }
}

