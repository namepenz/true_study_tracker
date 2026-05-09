import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/study_data.dart';

class ApiService {
  // TODO: 실제 EC2 IP 주소로 변경하세요! (예: 'http://123.45.67.89:8000')
  static const String baseUrl = 'http://123.45.67.89:8000';

  static Future<StudyData?> fetchTodayStudyData(String userId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/study/today?userId=$userId'));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        if (decoded['status'] == 200 && decoded['data'] != null) {
          return StudyData.fromJson(decoded['data']);
        }
      } else {
        print('Server Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Network Error: $e');
      // 네트워크 연결 실패 시 예외 처리 (서버가 아직 안 켜져 있을 때 앱이 죽지 않도록 방어)
      
      // 테스트를 위해 에러 발생 시 가짜 데이터(Mock)를 리턴합니다.
      // 나중에는 이 부분을 지우고 null을 리턴하거나 에러 화면을 띄워야 합니다.
      return StudyData(
        userId: userId,
        date: "2026-05-01",
        vrTotalTime: 15600,
        pureFocusTime: 13512,
        distractionCount: 3,
        gazeTimeline: [
          GazeData(hour: 9, score: 100),
          GazeData(hour: 10, score: 95),
          GazeData(hour: 11, score: 20),
          GazeData(hour: 12, score: 80),
          GazeData(hour: 13, score: 90),
        ],
      );
    }
    return null;
  }
}
