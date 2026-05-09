import 'package:flutter/material.dart';
import '../models/study_data.dart';
import 'api_service.dart';

class StudyProvider with ChangeNotifier {
  StudyData? _studyData;
  bool _isLoading = false;
  String _error = '';

  StudyData? get studyData => _studyData;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> fetchStudyData(String userId) async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final data = await ApiService.fetchTodayStudyData(userId);
      if (data != null) {
        _studyData = data;
      } else {
        _error = '데이터를 불러오지 못했습니다.';
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
