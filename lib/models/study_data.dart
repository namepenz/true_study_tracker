class GazeData {
  final int hour;
  final int score;

  GazeData({required this.hour, required this.score});

  factory GazeData.fromJson(Map<String, dynamic> json) {
    return GazeData(
      hour: json['hour'] as int,
      score: json['score'] as int,
    );
  }
}

class StudyData {
  final String userId;
  final String date;
  final int vrTotalTime;
  final int pureFocusTime;
  final int distractionCount;
  final List<GazeData> gazeTimeline;

  StudyData({
    required this.userId,
    required this.date,
    required this.vrTotalTime,
    required this.pureFocusTime,
    required this.distractionCount,
    required this.gazeTimeline,
  });

  factory StudyData.fromJson(Map<String, dynamic> json) {
    return StudyData(
      userId: json['userId'] as String,
      date: json['date'] as String,
      vrTotalTime: json['vrTotalTime'] as int,
      pureFocusTime: json['pureFocusTime'] as int,
      distractionCount: json['distractionCount'] as int,
      gazeTimeline: (json['gazeTimeline'] as List)
          .map((item) => GazeData.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}
