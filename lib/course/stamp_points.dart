// 스탬프 모델 클래스
class StampPoint {
  final String name;
  final double latitude;
  final double longitude;
  final String description;

  const StampPoint({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
  });
}

// 각 코스별 스탬프 경유지 리스트
const List<StampPoint> baegakStampPoints = [
  StampPoint(name: '창의문', latitude: 37.592602, longitude: 126.966477, description: '백악구간의 시작점, 자하문(창의문) 근처.',),
  StampPoint(name: '백악산마루 전망대', latitude: 37.596976, longitude: 126.974750, description: '백악산 능선 중간의 조망 포인트.',),
  StampPoint(name: '청운대 쉼터', latitude: 37.595420, longitude: 126.971289, description: '도심이 보이는 조용한 쉼터.',),
  StampPoint(name: '숙정문', latitude: 37.593070, longitude: 126.982886, description: '조선의 북문, 북악구간 하이라이트.',),
  StampPoint(name: '말바위 안내소', latitude: 37.592322, longitude: 126.985284, description: '경복궁 뒤편 출입지점.',),
];

const List<StampPoint> naksanStampPoints = [
  StampPoint(name: '혜화문', latitude: 37.582604, longitude: 127.003960, description: '낙산구간 시작점'),
  StampPoint(name: '이화마을 벽화', latitude: 37.582836, longitude: 127.003485, description: '걷기 좋은 벽화마을 골목'),
  StampPoint(name: '낙산공원 전망대', latitude: 37.579365, longitude: 127.007202, description: '서울 도심 야경 조망 포인트'),
  StampPoint(name: '낙산 성곽길', latitude: 37.577226, longitude: 127.009180, description: '성곽 옆 좁은 길을 걷는 구간'),
  StampPoint(name: '흥인지문', latitude: 37.571514, longitude: 127.006523, description: '동대문, 코스 종점'),
];

const List<StampPoint> heunginjimunStampPoints = [
  StampPoint(name: '흥인지문', latitude: 37.571514, longitude: 127.006523, description: '흥인지문 출발지점'),
  StampPoint(name: '동대문디자인플라자', latitude: 37.566128, longitude: 127.009187, description: '서울 대표 디자인 공간'),
  StampPoint(name: '광희문', latitude: 37.564239, longitude: 127.005146, description: '작지만 역사적 의미 있는 성문'),
  StampPoint(name: '장충단공원', latitude: 37.559147, longitude: 127.006523, description: '동남측 끝, 공원 연계'),
  StampPoint(name: '약수역 성곽', latitude: 37.554494, longitude: 127.007235, description: '남측 끝자락 성곽길'),
];

const List<StampPoint> namsanStampPoints = [
  StampPoint(name: '장충단공원', latitude: 37.559147, longitude: 127.006523, description: '남산구간 북측 시작점'),
  StampPoint(name: '남산 북측 쉼터', latitude: 37.560885, longitude: 126.993622, description: '산책로 중간 쉼터'),
  StampPoint(name: '남산타워', latitude: 37.551169, longitude: 126.988220, description: '서울 상징 타워'),
  StampPoint(name: '안중근 의사 기념관', latitude: 37.553843, longitude: 126.982984, description: '의사 기념관으로 역사성 있음'),
  StampPoint(name: '백범광장', latitude: 37.547049, longitude: 126.981140, description: '남측 출입점'),
];

const List<StampPoint> sungnyemunStampPoints = [
  StampPoint(name: '숭례문', latitude: 37.559819, longitude: 126.975146, description: '서울 대표 남대문'),
  StampPoint(name: '회현역 4번 출구', latitude: 37.558509, longitude: 126.978933, description: '남산 가기 전 지점'),
  StampPoint(name: '서울역사박물관 산책로', latitude: 37.558807, longitude: 126.973070, description: '도심 속 조용한 산책길'),
  StampPoint(name: '소월길 입구', latitude: 37.555391, longitude: 126.984362, description: '남산 진입부 고즈넉한 길'),
  StampPoint(name: '남산공원 입구', latitude: 37.553083, longitude: 126.988336, description: '남산공원 초입'),
];

const List<StampPoint> inwangsanStampPoints = [
  StampPoint(name: '돈의문 터', latitude: 37.571389, longitude: 126.968830, description: '서대문 터 복원지점'),
  StampPoint(name: '인왕산 입구', latitude: 37.574510, longitude: 126.961055, description: '인왕산 트레킹 시작점'),
  StampPoint(name: '인왕산 중턱', latitude: 37.577025, longitude: 126.957300, description: '전망 좋은 구간'),
  StampPoint(name: '선바위', latitude: 37.579445, longitude: 126.956860, description: '전통 명승지'),
  StampPoint(name: '창의문', latitude: 37.592602, longitude: 126.966477, description: '인왕산과 백악 연결점'),
];