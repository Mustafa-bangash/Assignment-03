import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/activity_model.dart';

class LocalStorageService {
  static const String key = 'recent_activities';

  Future<void> saveRecentActivities(List<ActivityModel> activities) async {
    final prefs = await SharedPreferences.getInstance();
    // Take only first 5
    List<ActivityModel> recent = activities.take(5).toList();
    List<String> jsonList = recent.map((a) => json.encode(a.toJson())).toList();
    await prefs.setStringList(key, jsonList);
  }

  Future<List<ActivityModel>> getRecentActivities() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? jsonList = prefs.getStringList(key);
    if (jsonList != null) {
      return jsonList.map((str) => ActivityModel.fromJson(json.decode(str))).toList();
    }
    return [];
  }
}