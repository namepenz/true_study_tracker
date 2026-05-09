# true_study_tracker

<p align="center">
  <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" />
  <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" />
  <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey" />
</p>

<br/>

> **Gaze-In VR 학습 시스템**의 모바일 분석 앱  
> VR 세션 동안 수집된 시선 데이터를 서버에서 받아, 오늘의 집중도·학습 패턴을 시각화합니다.

### 연관 저장소
| 저장소 | 설명 |
|--------|------|
| [GazeIn](https://github.com/namepenz/GazeIn) | Unity VR 클라이언트 + FastAPI 백엔드 |
| **이 저장소 (true_study_tracker)** | Flutter 학습 분석 모바일 앱 |

---

## 📱 주요 화면

### 대시보드 (오늘의 학습)
- 원형 집중 효율 게이지 (0~100%)
- S / A / B / C / D 집중 등급
- VR 총 접속 시간 vs 실제 집중 시간
- 시선 이탈 횟수
- AI 피드백 메시지

### 집중도 리포트
- 시간대별 시선 집중도 꺾은선 그래프
- 딴짓 횟수 / 집중 효율 요약 카드
- 맞춤형 학습 피드백

---

## 🏗️ 아키텍처

```
lib/
├── main.dart                    # 앱 진입점, Provider 설정, 탭 네비게이션
├── models/
│   └── study_data.dart          # StudyData, GazeData 데이터 모델
├── services/
│   ├── api_service.dart         # 서버 HTTP 통신 (POST /tutor/check-state)
│   └── study_provider.dart      # 상태 관리 (ChangeNotifier)
└── screens/
    ├── dashboard_screen.dart    # 메인 대시보드 (집중 게이지 + 요약)
    └── report_screen.dart       # 상세 리포트 (차트 + 피드백)
```

---

## 🔌 서버 연동

앱이 서버에 보내는 요청:

```
POST http://<서버 IP>:8000/tutor/check-state
Content-Type: application/json

{ "userId": "user001" }
```

서버가 돌려줘야 하는 응답:

```json
{
  "status": 200,
  "data": {
    "userId": "user001",
    "date": "2026-05-09",
    "vrTotalTime": 7200,
    "pureFocusTime": 5400,
    "distractionCount": 3,
    "gazeTimeline": [
      { "hour": 9,  "score": 95 },
      { "hour": 10, "score": 72 },
      { "hour": 11, "score": 40 }
    ]
  }
}
```

| 필드 | 타입 | 설명 |
|------|------|------|
| `vrTotalTime` | int | VR 총 접속 시간 **(초 단위)** |
| `pureFocusTime` | int | 실제 집중 시간 **(초 단위)** |
| `distractionCount` | int | 시선 이탈 횟수 |
| `gazeTimeline[].hour` | int | 시각 (0~23) |
| `gazeTimeline[].score` | int | 집중 점수 0~100 |

> **서버 IP 변경 방법**: `lib/services/api_service.dart` 7번째 줄 `baseUrl` 수정

---

## 🛠️ 기술 스택

| 항목 | 내용 |
|------|------|
| Framework | Flutter 3.x |
| 언어 | Dart |
| 상태 관리 | Provider (ChangeNotifier) |
| HTTP | `http` 패키지 |
| 차트 | `fl_chart` 패키지 |
| 지원 플랫폼 | Android, iOS, Web |

---

## 🚀 실행 방법

### 1. 저장소 클론
```bash
git clone https://github.com/namepenz/true_study_tracker.git
cd true_study_tracker
```

### 2. 의존성 설치
```bash
flutter pub get
```

### 3. 서버 IP 설정
`lib/services/api_service.dart` 열고 `baseUrl` 수정:
```dart
static const String baseUrl = 'http://실제서버IP:8000';
```

### 4. 실행

**Android (실기기 연결 후):**
```bash
flutter run -d <device_id>
```

**웹 브라우저:**
```bash
flutter run -d chrome
```

> ⚠️ 서버 미연결 시 Mock 데이터로 동작합니다 (개발 테스트용)

---

## 📝 개발 현황

- [x] Flutter 프로젝트 초기 구성
- [x] Provider 기반 상태 관리
- [x] 서버 API 연동 구조 (`api_service.dart`)
- [x] 대시보드 화면 (원형 게이지 + 등급 카드)
- [x] 집중도 리포트 화면 (시간대별 꺾은선 그래프)
- [x] Mock 데이터 Fallback (서버 미연결 시 자동 전환)
- [ ] 실제 서버 연동 테스트
- [ ] 푸시 알림 (학습 리마인더)
- [ ] 주간 / 월간 리포트
