import 'package:dio/dio.dart';

import '../providers/auth_provider.dart';
import '../types/user.dart';

Future<User> fetchUserDataAndTransform() async {
  dio.options.headers['Cookie'] = await loadSavedCookies();
  Response response = await dio.get('/auth/current-user');

  if (response.statusCode == 200) {
    final dynamic jsonData = (response.data);
    User user = User(
      id: jsonData['_id'],
      username: jsonData['username'],
      password: jsonData['password'],
      role: jsonData['role'],
      name: jsonData['name'],
      allergies: jsonData['allergies'],
      dob: jsonData['dob'],
      gender: jsonData['gender'],
      address: jsonData['address'],
      zip: jsonData['zip'],
      city: jsonData['city'],
      state: jsonData['state'],
      phone: jsonData['phone'],
      email: jsonData['email']
    );

    return user;
  } else {
    throw Exception('Failed to load data');
  }
}

User mappingUser(dynamic data) {
  return User(
      id: data['_id'],
      username: data['username'],
      password: data['password'],
      role: data['role'],
      name: data['name'],
      dob: data['dob'],
      gender: data['gender'],
      address: data['address'],
      zip: data['zip'],
      city: data['city'],
      state: data['state'],
      phone: data['phone'],
      email: data['email']
  );
}

Future<List<User>> fetchPatientList() async {
  final response = await dio.get('/patients');

  return _mapUsersList(response);
}

Future<List<User>> fetchDoctorList() async {
  final response = await dio.get('/doctors');

  return _mapUsersList(response);
}

List<User> _mapUsersList(Response<dynamic> response) {
  if (response.statusCode == 200) {
    final List<dynamic> jsonData = (response.data);
    List<User> users = [];

    for (var userData in jsonData) {
      users.add(mappingUser(userData));
    }

    return users;
  } else {
    throw Exception('Failed to fetch doctor list');
  }
}