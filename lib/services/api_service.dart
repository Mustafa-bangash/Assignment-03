import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/activity_model.dart';

class ApiService {
  // Use 10.0.2.2 for Android Emulator to access localhost
  static const String baseUrl = 'http://10.0.2.2:3000/api/activities';

  Future<List<ActivityModel>> fetchActivities() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((e) => ActivityModel.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      throw Exception('Failed to load activities');
    }
  }

  Future<bool> postActivity(ActivityModel activity) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: json.encode(activity.toJson()),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteActivity(String id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl/$id'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}