# 길라잡이 (Gilajabi)

Kakao Maps API을 활용한 한양 도성길 산책 콘텐츠 어플

![Image](https://github.com/user-attachments/assets/7090d4bb-ad02-4921-a606-f3216fe59ddf)
![Image](https://github.com/user-attachments/assets/dc740080-49da-4c9e-a72c-649084941244)

---

## 📚 목차

- [👨‍💻 팀원 소개](#-팀원-소개)
- [📂 프로젝트 구조](#-프로젝트-구조)
- [📽️ 시연 영상](#-시연-영상)
- [📱 주요 기능](#-주요-기능)
  - [1. 카카오로 로그인](#1-카카오로-로그인)
  - [2. 코스별 안내](#2-코스별-안내)
  - [3. 스탬프 투어](#3-스탬프-투어)
  - [4. 게시판](#4-게시판)
  - [5. 날씨 정보](#5-날씨-정보)
  - [6. 만보기](#6-만보기)
  - [7. 메모장](#7-메모장)
  - [8. 프로필](#8-프로필)
  - [9. 설정](#9-설정)
- [🖼️ 소개 판넬](#-소개-판넬)

---

## 👨‍💻 팀원 소개

| 이름 | 역할 |
|------|------|
| 고지성 | 어플 실행 테스트 및 기능 정상 작동 확인 관리 |
| 김태훈 | 팀장, UI/UX 개발, API 사용 설계 |
| 박상욱 | 사용자 정보 관리 및 환경 설정 시스템 설계 및 구현 |
| 이태석 | Firebase 연동과 관리, 게시판 시스템 구축 |
| 최민준 | 카카오 로그인 연결, 코스 선택과 스탬프 기능 구축 |

---

## 📂 프로젝트 구조

![Image](https://github.com/user-attachments/assets/925fdf95-69fc-4898-8d12-bcfaac83e98c)

| 분야 | 기술 |
|------|------|
| 프레임워크 | Flutter |
| 개발 언어 | Dart |
| 로그인 | Kakao SDK |
| 지도 | Kakao Maps API |
| 백엔드 | Firebase Firestore, Firebase Storage |

---

## 📽️ 시연 영상 <a id="-시연-영상"></a>

[![시연 영상 썸네일](https://img.youtube.com/vi/gxJPX3VBRrU/0.jpg)](https://youtu.be/gxJPX3VBRrU?si=cpbIlLwUzAHBUuQI)

---

## 📱 주요 기능

### 1. 카카오로 로그인
- 별도의 회원가입 없이 카카오 계정으로 로그인 가능
- 사용자 닉네임, 프로필 연동
  
![Image](https://github.com/user-attachments/assets/61d7a346-0510-4c33-82dc-b08c1debdc39) ![Image](https://github.com/user-attachments/assets/e6f0ad8a-513a-4e15-b3bd-a9ecc533f988)

### 2. 코스별 안내
- 백악, 낙산, 흥인지문, 남산, 숭례문, 인왕산 6개 구간의 상세 경로 제공
- 터치 시 구간 별 설명 페이지로 이동
  
![Image](https://github.com/user-attachments/assets/156fe1b7-ad4f-4300-b446-dea9c7aba951)

### 3. 스탬프 투어
- 실시간 위치 추적 및 스탬프 위치 도착 안내 기능
- 각 경로에 설정된 위치 도달 시 스탬프 기록
- 스탬프 완료 여부에 따라 맵 마커 변경
- 스탬프 기록은 Firebase에 저장되어 언제든 재확인 가능
  
![Image](https://github.com/user-attachments/assets/9353c0c1-8f19-4b9a-be49-ab3e5e53592f) ![Image](https://github.com/user-attachments/assets/c1fb640b-4d9e-4396-b427-65d0a4af38ba)

### 4. 게시판
- 글 작성, 수정, 삭제, 댓글 작성 기능
- 이미지 업로드
- 좋아요 기능 + 검색 기능 지원
- 사용자 간 정보 공유 및 후기 작성 가능

![Image](https://github.com/user-attachments/assets/125cae3d-385f-4ed9-896a-b0423b74f7d2) ![Image](https://github.com/user-attachments/assets/d7207f1a-5d15-425a-aecf-61e1467eac9e)

### 5. 날씨 정보
- 실시간 기온 및 날씨 표시
- 위치 권한 승인 후 자동 위치 기반 날씨 로드
  
![Image](https://github.com/user-attachments/assets/53fb3310-304c-4ecc-afbd-316dc757b723)

### 6. 만보기
- 사용자 걸음 수 측정 기능
  
![Image](https://github.com/user-attachments/assets/53fb3310-304c-4ecc-afbd-316dc757b723) ![Image](https://github.com/user-attachments/assets/1dd8db57-78d6-4b0a-bf8b-d0eae99da3f3)

### 7. 메모장
- 간단한 메모 작성 기능
  
![Image](https://github.com/user-attachments/assets/fda5199c-21cd-4a3e-827c-ca1dad107801)

### 8. 프로필
- 내 닉네임 변경
- 내가 쓴 글 / 좋아요한 글 / 내 스탬프 보기
- 로그아웃 기능
  
![Image](https://github.com/user-attachments/assets/0e27dc9d-ae47-47ea-9cc6-af14c0b8f337) ![Image](https://github.com/user-attachments/assets/1987193b-f303-45aa-992c-5a18182eb17c) ![Image](https://github.com/user-attachments/assets/998f6351-694b-48cc-9b0c-bcdd8044f343)

### 9. 설정
- 라이트 모드 / 다크 모드 전환 기능
- 한글 모드 / 영어 모드 전환 기능
  
![Image](https://github.com/user-attachments/assets/4429ee92-cf81-4919-a614-208ed0b8408c)
  
---

## 🖼️ 소개 판넬 <a id="-소개-판넬"></a>

![Image](https://github.com/user-attachments/assets/7ec8379a-708d-452f-b92b-9c835d806c02)
