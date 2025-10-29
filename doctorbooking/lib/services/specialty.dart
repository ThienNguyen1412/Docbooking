import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:doctorbooking/models/specialty.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SpecialityService {
  static const String baseUrl = "http://192.168.111.219:5101/api/speciality";

  Future<List<Specialty>> ListSpecialty() async {
    final url = Uri.parse('$baseUrl');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Specialty.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load specialties');
    }
  }
}
