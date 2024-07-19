import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

//Auth token we will use to generate a meeting and connect to it

String getToken() {
  final token = dotenv.env['VIDEO_TOKEN'];

  if (token != null) {
    return token;
  }

  return '';
}

Dio dio = Dio(BaseOptions(
    baseUrl: 'https://api.videosdk.live/v2',
    contentType: 'application/json',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {
      'Authorization': getToken(),
    }
));

Future<String?> createMeeting() async {
  try {
    Response response = await dio.post('/rooms');

    return response.data['roomId'];
  } catch (error) {
    if (kDebugMode) {
      print('Error: $error');
    }
  }
  return null;
}