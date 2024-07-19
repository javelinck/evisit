import '../types/user.dart';

List<User> filterUsersByName(List<User> users, String query) {
  return users.where((user) => user.name.toLowerCase().contains(query.toLowerCase())).toList();
}