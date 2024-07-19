import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/auth_provider.dart';
import '../types/evisit.dart';

Future<List<Evisit>> fetchDataAndTransform() async {
  dio.options.headers['Cookie'] = await loadSavedCookies();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String? id = prefs.getString('auth_id');
  int? role = prefs.getInt('role');

  Response response = await dio.get('/evisits');

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = (response.data);
    List<Evisit> evisits = [];

    for (var item in jsonData) {
      bool isAvailablePatient = (role == 0 && item['patient'] != null && item['patient']['_id'] == id);
      bool isAvailableDoctor = (role == 1 && item['doctor'] != null && item['doctor']['_id'] == id);

      if (isAvailableDoctor || isAvailablePatient) {
        Evisit evisit = Evisit(
          diagnosis: item['diagnosis'],
          id: item['_id'],
          patient: item['patient'],
          doctor: item['doctor'],
          protocol: item['protocol'],
          status: item['status'],
          answers: item['answers'],
          createdAt: item['createdAt'],
          updatedAt: item['updatedAt'],
          v: item['__v'],
        );
        evisits.add(evisit);
      }
    }

    return evisits;
  } else {
    throw Exception('Failed to load data');
  }
}

Future<List<Protocol>> fetchProtocols() async {
  dio.options.headers['Cookie'] = await loadSavedCookies();
  Response response = await dio.get('/protocols');

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = (response.data);
    List<Protocol> protocols = [];

    for (var item in jsonData) {
      final protocol = Protocol(
        id: item['_id'],
        name: item['name'],
        questions: List<Question>.from(item['questions'].map((q) {
          return Question(
            text: q['text'],
            response: QuestionResponse(
              type: q['response']['type'],
              items: List<String>.from(q['response']['items']),
            ),
          );
        })),
      );

      protocols.add(protocol);
    }

    return protocols;
  } else {
    throw Exception('Failed to load data');
  }
}

List<Question> mapQuestions(dynamic queResponse) {
  List<Question> questions = [];

  for (var item in queResponse) {
    Question question = Question(
      text: item['text'],
      response: QuestionResponse(type: item['response']['type'], items: item['response']['items']),
    );

    questions.add(question);
  }

  print(questions.map((e) {
    print(e.response.type);
  }));

  return questions;
}

class PostEvisit {
  List<Answer> answers;
  String doctorId;
  String patientId;
  String protocolId;

  PostEvisit({ required this.answers, required this.doctorId, required this.patientId, required this.protocolId });
}

Future<void> createEvisit(PostEvisit data) async {
  try {
    await dio.post('/evisits',
      data: {
        "answers": data.answers,
        "doctorId": data.doctorId,
        "patientId": data.patientId,
        "protocolId": data.protocolId,
      },
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error: $error');
    }
  }
}

Future<void> editProtocol(String protocolId, List<Question> questions) async {
  try {
    final questionJsonList = questions.map((question) => question.toJson()).toList();

    await dio.post(
      '/protocols/$protocolId/questions',
      data: {"questions": questionJsonList},
    );
  } catch (error) {
    if (kDebugMode) {
      print('Error: $error');
    }
  }
}

Future<void> createDiagnosis(String evisitId, Diagnosis diagnosis) async {
  try {
    final questionJsonList = diagnosis.toJson();

    Response res = await dio.post(
      '/evisits/$evisitId/diagnosis',
      data: questionJsonList,
    );

    print(res);
  } catch (error) {
    if (kDebugMode) {
      print('Error: $error');
    }
  }
}