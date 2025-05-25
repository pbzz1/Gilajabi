# 길라잡이 (Gilajabi)

한양도성을 따라 걷는 코스 가이드 앱

![Image](https://github.com/user-attachments/assets/f2b9db9e-1a74-4085-a1de-f0acd2ed9d24)

---

## 🧑🏼‍🧒🏻‍🧒🏼 팀원 소개

| 이름 | 역할 |
|------|------|
| 고지성 | 어플 실행 테스트 및 기능 정상 작동 확인 관리 |
| 김태훈 | 팀장, UI/UX 개발, API 사용 설계 |
| 박상욱 | 사용자 정보 관리 및 환경 설정 시스템 설계 및 구현 |
| 이태석 | Firebase 연동과 관리, 게시판 시스템 구축 |
| 최민준 | 카카오 로그인 연결, 코스 선택과 스탬프 기능 구축 |

---

## 📂 프로젝트 구조

![Image](https://github.com/user-attachments/assets/1f932dc7-3e86-4226-9f28-eb58bb08d956)

---

## 🛠 기술 스택

| 분야 | 기술 |
|------|------|
| 프레임워크 | Flutter |
| 개발 언어 | Dart |
| 로그인 | Kakao SDK (카카오계정 로그인) |
| 지도 | Kakao Maps API |
| 백엔드 | Firebase Firestore, Firebase Storage |

---

## 📽️ 시연 영상

[![시연 영상 썸네일](https://img.youtube.com/vi/gxJPX3VBRrU/0.jpg)](https://youtu.be/gxJPX3VBRrU?si=cpbIlLwUzAHBUuQI)

---

## 📱 주요 기능

![Image](https://github.com/user-attachments/assets/ba39dd2e-acc0-40c5-81f2-70168634f035) ![Image](https://github.com/user-attachments/assets/e9c99a80-b07d-46d8-b6db-5b0c103e7727)

### 0. 카카오로 로그인
- 별도의 회원가입 없이 카카오 계정으로 로그인 가능
- 사용자 닉네임, 프로필 연동

### 1. 코스별 도보 안내
- 백악, 낙산, 흥인지문, 남산, 숭례문, 인왕산 6개 구간의 상세 경로 제공
- 터치 시 구간 별 설명 페이지로 이동

### 2. 스탬프 투어
- 실시간 위치 추적 및 스탬프 위치 도착 안내 기능
- 각 경로에 설정된 위치 도달 시 스탬프 기록
- 스탬프 완료 여부에 따라 맵 마커 변경
- 스탬프 기록은 Firebase에 저장되어 언제든 재확인 가능

### 3. 게시판
- 글 작성, 수정, 삭제, 댓글 작성 가능
- 이미지 업로드
- 좋아요 기능 + 검색 기능 지원
- 사용자 간 정보 공유 및 후기 작성 가능

### 4. 날씨 정보
- 실시간 기온 및 날씨 표시
- 위치 권한 승인 후 자동 위치 기반 날씨 로드

### 5. 만보기
- 사용자 걸음 수 측정 기능

### 6. 메모장
- 간단한 메모 작성 기능

### 7. 마이페이지
- 내 닉네임 변경
- 내가 쓴 글 / 좋아요한 글 / 내 스탬프 보기
- 로그아웃 기능

---

## 🖼️ 소개 판넬

![Image](https://github.com/user-attachments/assets/43c7e4fc-604c-41bc-9611-0a752f45600d)
