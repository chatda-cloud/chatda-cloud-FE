# 🔍 Chatda (찾다) - AI 기반 분실물 매칭 앱 (프론트엔드)

**"잃어버린 물건, AI가 쉽고 빠르게 찾아드립니다."**

이 프로젝트는 **Flutter** 기반으로 작성된 크로스 플랫폼(iOS/Android) 모바일 인터페이스입니다. AWS AI 및 백엔드 서버와 연동하여 사용자의 분실물과 습득물을 스마트하게 연결해 주는 서비스입니다.

---

## 🌟 주요 기능 (MVP UI 화면 구성)

- **앱 부팅 스플래시 (Splash)**
  - 리플 파동 애니메이션 + 떠다니는 버블 장식으로 리퀴드 느낌 연출.
  - 로고 스케일/페이드 인 + 텍스트 슬라이드 업 애니메이션 후 로그인 화면으로 자연스럽게 전환.
- **하단 네비게이션 (Bottom Navigation)**
  - 유리 효과(Glassmorphism)와 그림자를 적용한 반투명 플로팅 네비게이션 바.
  - 컨텐츠 위로 오버레이되어 끊김 없이 부드럽고 넓은 화면 경험 제공.
- **홈 대시보드 (Home)**
  - AI 유사도 기반 **매칭 추천 현황 리스트** 제공 (더보기/접기로 확장 가능).
  - 매칭 추천 아이템별 **타임스탬프** 및 매칭률 뱃지 표시.
  - 우측 상단 알림 버튼을 통한 매칭 알림 내역 즉시 진입.
- **분실물 탐색 (Search)**
  - 리스트 뷰 및 **사진 위주 그리드 뷰** 상호 전환 기능.
  - 검색창 하단 **추천 태그** 선 노출 및 클릭 기반 태그 필터링.
  - 텍스트 검색어 입력 시 실시간 결과 필터링.
  - 카테고리 / 기간(날짜 선택) / 장소 기반의 상세 필터링 BottomSheet 제공.
  - 전체/분실물/습득물 **파스텔 톤 세그먼트 탭** 구분.
- **AI 기반 물건 등록 (Register)**
  - 하단 네비게이션 중앙 '등록' 탭 클릭 시 **분실물/습득물 선택 BottomSheet** 제공.
  - 카메라 모달 연동(시뮬레이션)으로 사진 업로드 시 **AI 자동 태그 추천** 기능.
  - AI 추천 태그(✨ 보라)와 수동 추가 태그(🏷️ 파랑)의 **시각적 구분** 제공.
  - 연필 아이콘 토글을 통한 수동 태그 추가 및 상세 설명 통합 입력 폼.
- **매칭 분석 & 1:1 연락처 공개 (Match Detail)**
  - AI 벡터 검색 기반 **유사도 스코어 바** 제공.
  - "내 물건이 맞아요" 버튼 클릭 시 상태 변경(MATCHED) 및 상대방 물품 보관장소, 연락처 안전하게 공개.
- **1:1 채팅 (Chat)**
  - 하단 네비게이션에서 바로 접근 가능한 **채팅 목록** 화면.
  - 읽지 않은 메시지 뱃지, 최근 대화 시간, 관련 물건명 표시.
  - 말풍선 기반 **1:1 채팅 상세** 화면 (메시지 송신 시뮬레이션 동작).
  - 채팅방 **검색** 기능 지원.
- **사용자 마이페이지 (MY)**
  - 밝은 테마의 전역 AppBar 및 프로필 카드 디자인을 통한 **앱 전체 디자인 언어 통합**.
  - 내 정보(닉네임, 이메일, 전화번호) 수정 기능.

## 🚀 주요 기능 (Current Status)

### 1. 인증 및 회원 관리
- **회원가입/로그인**: 이메일 기반 인증 및 자동 로그인 기능.
- **프로필 관리**: 닉네임 변경, 프로필 이미지 업로드(S3 연동), 비밀번호 재설정 메일 발송.
- **보안**: JWT 기반 인증 및 토큰 재발급(Refresh Token) 처리.

### 2. 아이템 등록 및 관리 (분실물/습득물)
- **스마트 등록**: 아이템 정보 입력 시 실시간 이미지 미리보기 제공.
- **AI 태깅 (AWS 연동)**: 이미지 업로드 시 AWS Rekognition 및 Gemini를 통한 자동 카테고리/특징 추출.
- **내역 관리**: 내가 등록한 분실물/습득물 목록 확인 및 수정/삭제 기능.

### 3. 탐색 및 매칭
- **탐색 (Explore)**: 등록된 아이템 목록 확인 (현재 내 아이템 중심 연동).
- **스마트 매칭**: 분실물과 습득물 간의 유사도 기반 자동 매칭 추천 (0.7 이상).
- **상세 정보**: 매칭된 아이템의 상세 정보 및 유사도 점수 확인.

## 🛠 기술 스택
- **Framework**: Flutter (Dart)
- **State Management**: Riverpod
- **Network**: Dio (HTTP Client)
- **Storage**: Flutter Secure Storage (Tokens)
- **Image**: Image Picker, Cached Network Image

## ⚙️ 시작하기 (Getting Started)

### 1. 사전 요구 사항 (Prerequisites)
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x 이상 권장)
- Android Studio / VS Code (Flutter 플러그인 설치)
- 실행할 에뮬레이터 또는 실제 디바이스 (Android/iOS)

### 2. 환경 변수 설정 (Configuration)
프로젝트 루트 디렉토리에 `.env` 파일을 생성하고 아래의 필수 환경 변수들을 설정해야 합니다. (이 값들이 없으면 API 연동이 되지 않습니다.)

```ini
# .env 파일 예시
BASE_URL=https://your-api-server.com
LAMBDA_URL=https://your-lambda-endpoint.com
```

### 3. 의존성 설치 및 실행
아래 명령어를 순서대로 실행하여 프로젝트를 구동합니다.

```bash
# 1. 패키지 다운로드
flutter pub get

# 2. 앱 실행 (환경 변수 파일 포함 필수)
flutter run --dart-define-from-file=.env
```

> [!TIP]
> VS Code를 사용하신다면 `.vscode/launch.json` 설정에 `--dart-define-from-file=.env`를 추가하여 F5 키만으로 편하게 실행할 수 있습니다.

---

## 📂 프로젝트 아키텍처 및 폴더 구조

```
lib/
├── common/             # 앱 내 공통 위젯 및 디자인 설정
│   └── widgets/        # ItemCard 등 재사용성이 높은 분리된 위젯 모음
├── features/           # 주요 화면(Screen) 기능 그룹
│   ├── auth/           # 스플래시 / 로그인 / 회원가입
│   ├── chat/           # 채팅 목록 / 1:1 대화 상세
│   ├── home/           # 홈 대시보드 (매칭 추천 현황)
│   ├── main/           # 하단 5탭 커스텀 네비게이션 메인 라우터
│   ├── match/          # 유사도 상세 분석 메뉴
│   ├── mypage/         # 마이페이지, 설정, 정보수정, 알림 설정
│   ├── notification/   # 매칭 알림 내역
│   ├── register/       # 분실/습득 등록 (사진 업로드 포함)
│   └── search/         # 탐색 뷰, 태그 필터, 검색어 필터, 상세 필터
├── providers/          # Riverpod 상태관리 (사용자 정보, 아이템 목록)
├── widgets/            # 앱 전역 공유 위젯 (ChatdaDialog 등)
├── services/           # 외부 API 및 백그라운드 환경설정
│   └── fcm_service.dart # Firebase Cloud Messaging 뼈대
└── main.dart           # 앱 테마(Material 3) 및 앱 루트 구동
```

---

## 🛠️ 개발 환경

- **Framework**: [Flutter](https://flutter.dev/)
- **상태관리**: [Riverpod](https://riverpod.dev/) (flutter_riverpod)
- **Target OS**: iOS / Android
- **Design System**: Material Design 3 + 리퀴드 글래스 커스텀 UI
