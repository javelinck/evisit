import 'package:dio/dio.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String name;
  final int role;
  final String? allergies;
  final String dob;
  final String gender;
  final String address;
  final String password;
  final String zip;
  final String city;
  final String state;
  final String phone;

  User({ required this.role, this.allergies, required this.password, required this.dob, required this.gender, required this.name, required  this.address, required  this.zip, required  this.city, required  this.state, required  this.phone, required this.id, required this.username, required this.email});
}

User mapUser(Response<dynamic> response) {
  return User(
      id: response.data['_id'],
      username: response.data['username'],
      role: response.data['role'],
      name: response.data['name'],
      password: response.data['password'],
      allergies: response.data['allergies'],
      dob: response.data['dob'],
      gender: response.data['gender'],
      address: response.data['address'],
      zip: response.data['zip'],
      city: response.data['city'],
      state: response.data['state'],
      phone: response.data['phone'],
      email: response.data['email']
  );
}