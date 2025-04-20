// 스탬프 모델 클래스
class StampPoint {
  final String name;
  final double latitude;
  final double longitude;

  const StampPoint({
    required this.name,
    required this.latitude,
    required this.longitude,
  });
}

// 각 코스별 스탬프 경유지 리스트
const List<StampPoint> baegakStampPoints = [
  StampPoint(name: '백악 스탬프 1', latitude: 37.597389, longitude: 126.976555),
  StampPoint(name: '백악 스탬프 2', latitude: 37.5921782, longitude: 126.9879091),
  StampPoint(name: '백악 스탬프 3', latitude: 37.5924333, longitude: 126.9984555),

];

const List<StampPoint> naksanStampPoints = [
  StampPoint(name: '낙산 스탬프 1', latitude: 37.584663, longitude: 127.006928),
  StampPoint(name: '낙산 스탬프 2', latitude: 37.580029, longitude: 127.00887),
  StampPoint(name: '낙산 스탬프 3', latitude: 37.575281, longitude: 127.008802),

];

const List<StampPoint> heunginjimunStampPoints = [
  StampPoint(name: '흥인지문 스탬프 1', latitude: 37.568366, longitude: 127.010447),
  StampPoint(name: '흥인지문 스탬프 2', latitude: 37.56672, longitude: 127.011142),
  StampPoint(name: '흥인지문 스탬프 3', latitude: 37.565169, longitude: 127.010882),

];

const List<StampPoint> namsanStampPoints = [
  StampPoint(name: '남산 스탬프 1', latitude: 37.5504573, longitude: 127.0042518),
  StampPoint(name: '남산 스탬프 2', latitude: 37.549175, longitude: 126.994191),
  StampPoint(name: '남산 스탬프 3', latitude: 37.554102, longitude: 126.985425),

];

const List<StampPoint> sungnyemunStampPoints = [
  StampPoint(name: '숭례문 스탬프 1', latitude: 37.558965, longitude: 126.9744229),
  StampPoint(name: '숭례문 스탬프 2', latitude: 37.562108, longitude: 126.970748),
  StampPoint(name: '숭례문 스탬프 3', latitude: 37.565016, longitude: 126.97276),

];

const List<StampPoint> inwangsanStampPoints = [
  StampPoint(name: '인왕산 스탬프 1', latitude: 37.571256, longitude: 126.965513),
  StampPoint(name: '인왕산 스탬프 2', latitude: 37.576968, longitude: 126.9631121),
  StampPoint(name: '인왕산 스탬프 3', latitude: 37.5863801, longitude: 126.9607008),
];