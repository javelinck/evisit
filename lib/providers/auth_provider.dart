import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../types/evisit.dart';
import '../types/user.dart';

Dio dio = Dio(BaseOptions(
  baseUrl: 'https://evisit.dev.abnk.uk/api/v1',
  contentType: 'application/json',
  connectTimeout: const Duration(seconds: 5),
  receiveTimeout: const Duration(seconds: 5),
));

Future<String?> loadSavedCookies() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('cookies');
}

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _id;
  String? _name;
  int? _role;
  String? _cookies;
  List<Evisit>? _eVisits;

  User? get user => _user;
  String? get id => _id;
  String? get name => _name;
  int? get role => _role;
  String? get cookies => _cookies;
  List<Evisit>? get eVisits => _eVisits;

  Future<void> saveId(String newId) async {
    _id = newId;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_id', newId);
    notifyListeners();
  }

  Future<void> saveName(String newName) async {
    _name = newName;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_name', newName);
    notifyListeners();
  }

  Future<void> saveRole(int newRole) async {
    _role = newRole;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('role', newRole);
    notifyListeners();
  }

  Future<void> loadSavedId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _id = prefs.getString('auth_id');
    notifyListeners();
  }

  Future<void> loadSavedName() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _name = prefs.getString('auth_name');
    notifyListeners();
  }

  Future<void> loadSavedRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _role = prefs.getInt('role');
    notifyListeners();
  }

  Future<void> saveCookies(String newCookies) async {
    _cookies = newCookies;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('cookies', newCookies);
  }

  Future<void> signIn(String username, String password) async {
    try {
      Response response = await dio.post(
        '/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      await saveId(response.data['_id']);
      await saveName(response.data['name']);
      await saveRole(response.data['role']);

      dynamic partsArray = response.headers['set-cookie'];

      List<String> selectedParts = partsArray.where((part) {
        return part.startsWith('session=') || part.startsWith('session.sig=');
      }).toList();

      String givenString = selectedParts.join('; ');

      List<String> parts = givenString.split('; ');
      List<String> selectedStringParts = parts.where((part) {
        return part.startsWith('session=') || part.startsWith('session.sig=');
      }).toList();

      String transformedString = selectedStringParts.join('; ');

      dio.options.headers['Cookie'] = transformedString;

      await saveCookies(transformedString);

      _user = mapUser(response);
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    }

    notifyListeners();
  }

  Future<void> logout() async {
    try {
      dio.options.headers['Cookie'] = await loadSavedCookies();
      await dio.post('/auth/logout');

      _user = null;
      _id = null;
      _cookies = null;
      _role = null;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_id');
      await prefs.remove('role');
      await prefs.remove('cookies');
      notifyListeners();
    } catch (error) {
      if (kDebugMode) {
        print('Error: $error');
      }
    }
  }
}
