import 'package:flutter/material.dart';
import '../models/activity_model.dart';
import '../services/api_service.dart';
import '../services/local_storage_service.dart';

class ActivityProvider with ChangeNotifier {
  List<ActivityModel> _activities = [];
  bool _isLoading = false;

  List<ActivityModel> get activities => _activities;
  bool get isLoading => _isLoading;

  final ApiService _apiService = ApiService();
  final LocalStorageService _storageService = LocalStorageService();

  Future<void> loadActivities() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Try fetching from API
      _activities = await _apiService.fetchActivities();
      // Sync to local storage
      await _storageService.saveRecentActivities(_activities);
    } catch (e) {
      // If API fails, load from local storage (Offline Mode)
      _activities = await _storageService.getRecentActivities();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addActivity(ActivityModel activity) async {
    // Optimistic update
    _activities.insert(0, activity);
    notifyListeners();

    bool success = await _apiService.postActivity(activity);
    if (success) {
      await _storageService.saveRecentActivities(_activities);
    } else {
      // Handle sync failure (could allow retry logic here)
    }
  }

  Future<void> deleteActivity(String id) async {
    _activities.removeWhere((a) => a.id == id);
    notifyListeners();
    await _apiService.deleteActivity(id);
    await _storageService.saveRecentActivities(_activities);
  }
}