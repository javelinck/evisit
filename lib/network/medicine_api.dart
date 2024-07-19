import 'package:dio/dio.dart';

import '../providers/auth_provider.dart';
import '../types/medicines.dart';

Future<List<Medicine>> fetchMedicine() async {
  dio.options.headers['Cookie'] = await loadSavedCookies();
  Response response = await dio.get('/medicines');

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = (response.data);
    List<Medicine> medicines = [];

    for (var item in jsonData) {
      Medicine medicine = Medicine(
        id: item['_id'],
        name: item['name'],
        description: item['description'],
        image: item['image']
      );
      medicines.add(medicine);
    }
    return medicines;
  } else {
    throw Exception('Failed to load data');
  }
}