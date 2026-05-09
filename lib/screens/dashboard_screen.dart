import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../services/study_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _formatTime(int totalSeconds) {
    final h = totalSeconds ~/ 3600;
    final m = (totalSeconds % 3600) ~/ 60;
    if (h == 0) return '${m}분';
    return '${h}시간 ${m.toString().padLeft(2, '0')}분';
  }

  String _getGrade(int percent) {
    if (percent >= 90) return 'S';
    if (percent >= 80) return 'A';
    if (percent >= 70) return 'B';
    if (percent >= 60) return 'C';
    return 'D';
  }

  String _getFeedback(int efficiency, int distractions) {
    if (efficiency >= 90) {
      return '오늘 최고의 집중력을 보여주셨습니다! 이 페이스를 유지해 보세요. 🎉';
    }
    if (efficiency >= 75) {
      return '좋은 집중력입니다. 잠깐씩 시선이 흔들릴 때 심호흡을 해보세요. 💪';
    }
    if (distractions > 5) {
      return '시선 이탈이 자주 감지되었습니다. 50분 집중 → 10분 휴식 패턴을 시도해 보세요. 🔄';
    }
    return '꾸준히 학습 중입니다. 환경 정리와 짧은 포커스 구간 설정을 추천드려요. 📚';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2FF),
      body: Consumer<StudyProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('서버에서 데이터를 가져오는 중...'),
                ],
              ),
            );
          }

          if (provider.error.isNotEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text('오류: ${provider.error}', style: TextStyle(color: Colors.grey.shade600)),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => provider.fetchStudyData('user001'),
                    icon: const Icon(Icons.refresh),
                    label: const Text('다시 시도'),
                  ),
                ],
              ),
            );
          }

          final data = provider.studyData;
          if (data == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_rounded, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('데이터가 없습니다.', style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          final efficiency = data.vrTotalTime > 0
              ? (data.pureFocusTime / data.vrTotalTime).clamp(0.0, 1.0)
              : 0.0;
          final efficiencyPercent = (efficiency * 100).round();

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 헤더 ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '오늘의 학습',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade900,
                            ),
                          ),
                          Text(
                            data.date,
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.indigo.shade50,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.headset_mic_rounded, color: Colors.indigo.shade400, size: 14),
                            const SizedBox(width: 6),
                            Text(
                              'VR 연동됨',
                              style: TextStyle(
                                color: Colors.indigo.shade600,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── 집중 효율 게이지 카드 ──
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.indigo.shade600, Colors.indigo.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withOpacity(0.35),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: 170,
                          height: 170,
                          child: CustomPaint(
                            painter: _GaugePainter(efficiency: efficiency),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '$efficiencyPercent%',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 44,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const Text(
                                    '집중 효율',
                                    style: TextStyle(color: Colors.white54, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _buildTimeItem(
                              '집중 시간',
                              _formatTime(data.pureFocusTime),
                              const Color(0xFF80FFB0),
                            ),
                            Container(width: 1, height: 40, color: Colors.white24),
                            _buildTimeItem(
                              'VR 총 접속',
                              _formatTime(data.vrTotalTime),
                              Colors.white70,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 통계 카드 2개 ──
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.visibility_off_rounded,
                          label: '시선 이탈 횟수',
                          value: '${data.distractionCount}회',
                          iconColor:
                              data.distractionCount > 5 ? Colors.redAccent : Colors.orange.shade700,
                          bgColor:
                              data.distractionCount > 5 ? Colors.red.shade50 : Colors.orange.shade50,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildStatCard(
                          icon: Icons.military_tech_rounded,
                          label: '집중 등급',
                          value: _getGrade(efficiencyPercent),
                          iconColor: Colors.amber.shade700,
                          bgColor: Colors.amber.shade50,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ── AI 피드백 카드 ──
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.indigo.shade50,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(Icons.auto_awesome, color: Colors.indigo.shade400, size: 18),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '오늘의 피드백',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade800,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _getFeedback(efficiencyPercent, data.distractionCount),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── 새로고침 버튼 ──
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => provider.fetchStudyData(data.userId),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('데이터 새로고침'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.indigo.shade200),
                        foregroundColor: Colors.indigo.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTimeItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: iconColor),
          ),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12, color: iconColor.withOpacity(0.7))),
        ],
      ),
    );
  }
}

// ── 원형 게이지 그리기 ──
class _GaugePainter extends CustomPainter {
  final double efficiency;
  const _GaugePainter({required this.efficiency});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const startAngle = -math.pi * 0.75;
    const fullSweep = math.pi * 1.5;

    // 배경 트랙
    final bgPaint = Paint()
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      fullSweep,
      false,
      bgPaint,
    );

    // 진행 게이지
    if (efficiency > 0) {
      final progressPaint = Paint()
        ..shader = LinearGradient(
          colors: [
            const Color(0xFF80FFB0),
            const Color(0xFF00E5FF),
          ],
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 14
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        fullSweep * efficiency,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) => old.efficiency != efficiency;
}
