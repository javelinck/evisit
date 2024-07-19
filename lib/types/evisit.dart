import 'package:dio/dio.dart';

class Diagnosis {
  final String text;
  final List<String> prescriptions;
  final String note;

  Diagnosis({
    required this.text,
    required this.prescriptions,
    required this.note,
  });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'prescriptions': prescriptions,
      'note': note,
    };
  }
}

class QuestionResponse {
  late final String type;
  final List<String> items;

  QuestionResponse({ required this.type, required this.items });

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'items': items,
    };
  }
}

class Question {
  final String text;
  final QuestionResponse response;

  Question({ required this.text, required this.response });

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'response': response.toJson(),
    };
  }
}

class Protocol {
  final String id;
  final String name;
  final List<Question> questions;

  Protocol({ required this.id, required this.name, required this.questions });
}

class Answer {
  final String text;
  late final String answer;

  Answer({ required this.text, required this.answer });

  // Convert Answer object to a JSON-encodable Map
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'answer': answer,
    };
  }
}

class Evisit {
  final dynamic diagnosis;
  final dynamic id;
  final dynamic patient;
  final dynamic doctor;
  final dynamic protocol;
  final dynamic status;
  final dynamic answers;
  final dynamic createdAt;
  final dynamic updatedAt;
  final dynamic v;

  Evisit({
    required this.diagnosis,
    required this.id,
    required this.patient,
    required this.doctor,
    required this.protocol,
    required this.status,
    required this.answers,
    required this.createdAt,
    required this.updatedAt,
    required this.v
  });
}

List<Evisit> mapEvisit(Response<dynamic> response) {
  List<Evisit> transformedArray = [];

  for (var item in response.data) {
    transformedArray.add(Evisit(
      diagnosis: item['diagnosis'],
      id: item['_id'],
      patient: item['patient'],
      doctor: item['doctor'],
      protocol: item['protocol'],
      status: item['status'],
      answers: item['answers'],
      createdAt: item['createdAt'],
      updatedAt: item['updatedAt'],
      v: item['__v']
    ));
  }

  return transformedArray;
}