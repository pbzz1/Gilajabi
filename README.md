# 길라잡이 (Gilajabi)

[![시연 영상]]([https://www.youtube.com/watch?v=gxJPX3VBRrU](https://youtube.com/shorts/gxJPX3VBRrU))

https://youtube.com/shorts/gxJPX3VBRrU?feature=share

한양도성길을 따라 걷는 도보 여행자들을 위한 종합 안내 앱입니다.  
코스 정보, 실시간 위치 기반 스탬프, 커뮤니티 기능까지 한 번에 제공하는 **플러터 기반 모바일 애플리케이션**입니다.

---

## 📱 주요 기능

### ✅ 1. 코스 안내 및 지도 연동
- 한양도성길 6개 구간(백악, 낙산, 흥인지문, 남산, 숭례문, 인왕산) 상세 정보 제공
- Kakao Map과 연동된 **웹 기반 코스 지도** 탑재
- 터치 시 구간 별 설명 페이지로 이동

### ✅ 2. 실시간 위치 기반 스탬프 시스템 (예정)
- 사용자의 GPS 기반 위치를 추적
- 특정 지점 도착 시 자동으로 스탬프 획득
- 향후 도보 미션/리워드 연동 계획

### ✅ 3. 게시판 기능
- 사용자 간 정보 공유 및 후기 작성 가능
- Firebase Firestore에 저장
- Kakao 로그인 연동으로 사용자 인증

### ✅ 4. 카카오 로그인
- 카카오 SDK를 통해 간편 로그인 제공
- 사용자 닉네임, 프로필 연동

---

## 🛠️ 사용 기술

| 분류     | 기술                                                         |
|----------|--------------------------------------------------------------|
| 프론트엔드 | Flutter 3.x                                                  |
| 상태 관리 | Provider                                                     |
| 지도      | Kakao Maps API + WebView                                     |
| 백엔드    | Firebase (Authentication, Firestore, Storage)               |
| 인증      | Kakao Flutter SDK                                           |

---

## 🖥️ 프로젝트 구조
lib/
├── course/ # 각 구간별 코스 정보 페이지
├── screens/ # 홈, 게시판, 프로필 등 주요 탭
├── login.dart # 카카오톡 로그인 구현
├── myhomepage.dart # 메인 탭 관리
├── app.dart # 로그인 상태 기반 화면 전환
├── main.dart # 앱 시작점 및 Kakao 초기화
