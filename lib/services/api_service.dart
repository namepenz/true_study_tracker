import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/study_data.dart';

class ApiService {
  // 실제 서버 주소 (AWS EC2 IP가 바뀌면 여기만 수정하세요)
  static const String baseUrl = 'http://13.125.215.27:8000';

  static Future<StudyData?> fetchTodayStudyData(String userId) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/tutor/check-state'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'userId': userId}),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final decoded = json.decode(utf8.decode(response.bodyBytes));
        // 서버가 { "status": 200, "data": { ... } } 형식으로 응답할 때
        if (decoded['status'] == 200 && decoded['data'] != null) {
          return StudyData.fromJson(decoded['data']);
        }
        // 서버가 데이터를 바로 응답할 때 (최상위 레벨)
        if (decoded['userId'] != null) {
          return StudyData.fromJson(decoded);
        }
      } else {
        print('Server Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Network Error: $e');
    }

    // ─── 서버 연결 실패 시 Mock 데이터 (서버 준비 전 테스트용) ───
    // 서버가 정상 연동되면 아래 return 문을 지우고 return null; 로 변경하세요.
    print('[Mock] 서버 연결 실패 - Mock 데이터를 사용합니다.');
    return StudyData(
      userId: userId,
      date: _todayString(),
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

  static String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
