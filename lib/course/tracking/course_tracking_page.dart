import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:provider/provider.dart';

import 'package:gilajabi/course/tracking/kakao_map_tracker.dart';
import 'package:gilajabi/course/tracking/stamp_points.dart';
import 'package:gilajabi/screens/home/home.dart';
import 'package:gilajabi/providers/app_settings_provider.dart';

String? globalUserId;

typedef PolylinePoint = Map<String, double>;

class CourseTrackingPage extends StatefulWidget {
  final String courseName;
  final String polylineJsonFile;
  final List<StampPoint> stampPoints;

  const CourseTrackingPage({
    super.key,
    required this.courseName,
    required this.polylineJsonFile,
    required this.stampPoints,
  });

  @override
  State<CourseTrackingPage> createState() => _CourseTrackingPageState();
}

class _CourseTrackingPageState extends State<CourseTrackingPage> {
  final GlobalKey<KakaoMapTrackerState> _mapKey = GlobalKey();
  StreamSubscription<Position>? _positionStream;
  List<PolylinePoint> _polylinePoints = [];
  List<StampPoint> remainingStamps = [];
  Set<String>? takenNames;

  bool _loading = true;
  bool _followUser = true;
  double _distanceToTarget = 0.0;
  late StampPoint targetPoint;
  bool _canStamp = false;

  @override
  void initState() {
    super.initState();
    _loadUserId(); // 내부에서 _loadUserStamps 호출됨
    _loadPolyline().then((_) => _startTracking());
  }

  Future<void> _loadUserId() async {
    try {
      final user = await UserApi.instance.me();
      globalUserId = user.id.toString();
      await _loadUserStamps();
    } catch (e) {
      print('userId 로드 실패: $e');
    }
  }

  Future<void> _loadUserStamps() async {
    if (globalUserId == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(globalUserId)
        .collection('stamps')
        .where('course', isEqualTo: widget.courseName)
        .get();

    final takenSet = snapshot.docs.map((doc) => doc['name'] as String).toSet();

    setState(() {
      takenNames = takenSet; // 초기화
      remainingStamps = widget.stampPoints
          .where((stamp) => !takenSet.contains(stamp.name))
          .toList();
    });
  }

  Future<void> _loadPolyline() async {
    final jsonStr = await rootBundle.loadString('assets/json/${widget.polylineJsonFile}');
    final List<dynamic> jsonList = jsonDecode(jsonStr);

    setState(() {
      _polylinePoints = jsonList.map<PolylinePoint>((e) => {
        "lat": (e[0] as num).toDouble(),
        "lng": (e[1] as num).toDouble(),
      }).toList();
      _loading = false;
    });
  }
  void _startTracking() async {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context, listen: false).isKoreanMode;

    final position = await Geolocator.getCurrentPosition();
    _mapKey.currentState?.updateUserLocation(position.latitude, position.longitude);

    await Future.delayed(const Duration(seconds: 3)); // 경로 먼저 보여주기

    _positionStream = Geolocator.getPositionStream().listen((position) {
      _mapKey.currentState?.updateUserLocation(position.latitude, position.longitude);

      if (remainingStamps.isNotEmpty) {
        targetPoint = findClosestStamp(position.latitude, position.longitude, remainingStamps);
        final distance = Geolocator.distanceBetween(
          position.latitude,
          position.longitude,
          targetPoint.latitude,
          targetPoint.longitude,
        );

        setState(() async {
          _distanceToTarget = distance;

          if (distance <= 30) {
            if (!_canStamp) {
              _canStamp = true;

              Fluttertoast.showToast(
                msg: isKoreanMode
                    ? "경유지 도착! 스탬프를 찍어주세요!"
                    : "You’ve reached the stop! Please take a stamp!",
              );
            }
          } else {
            if (_canStamp) {
              _canStamp = false;
            }
          }
        });
      }
    });
  }

  StampPoint findClosestStamp(double userLat, double userLng, List<StampPoint> stamps) {
    double minDistance = double.infinity;
    late StampPoint closest;

    for (var stamp in stamps) {
      final distance = Geolocator.distanceBetween(
        userLat,
        userLng,
        stamp.latitude,
        stamp.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        closest = stamp;
      }
    }
    return closest;
  }

  void onReachedTarget() async {
    final stamp = targetPoint;

    if (globalUserId == null) {
      Fluttertoast.showToast(msg: "로그인이 필요합니다.");
      return;
    }

    await saveStamp(
      userId: globalUserId!,
      courseName: widget.courseName,
      stampName: stamp.name,
      lat: stamp.latitude,
      lng: stamp.longitude,
    );

    Fluttertoast.showToast(msg: "스탬프 저장 완료!");

    setState(() {
      remainingStamps.remove(stamp);
      _canStamp = false;
      takenNames!.add(stamp.name); // ✅ null 아님 확정
    });

    // ✅ JS에 찍은 스탬프 이름 목록 다시 전달
    final updatedNames = jsonEncode(takenNames!.toList());
    _mapKey.currentState?.evaluateJavascript("setTakenStampNames($updatedNames);");

    // ✅ 전체 스탬프 마커 다시 그림
    final stampList = widget.stampPoints.map((s) => {
      "name": s.name,
      "lat": s.latitude,
      "lng": s.longitude,
    }).toList();
    final jsonStampList = jsonEncode(stampList);
    _mapKey.currentState?.evaluateJavascript("addStampMarkers($jsonStampList);");

    if (remainingStamps.isEmpty) {
      Fluttertoast.showToast(
        msg: "🎉 모든 경유지 스탬프 완료!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
      );
    }
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context).isKoreanMode;
    if (takenNames == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isKoreanMode
              ? '${widget.courseName} 코스 추적'
              : 'Tracking ${widget.courseName}',
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          KakaoMapTracker(
            key: _mapKey,
            polylinePoints: _polylinePoints,
            stampPoints: widget.stampPoints,
            takenStampNames: takenNames!,
            onStopFollowing: () => setState(() => _followUser = false),
          ),
          Positioned(
            bottom: 160,
            left: 20,
            right: 20,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey[800]),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const MyHomePage()),
                      (route) => false,
                );
              },
              child: Text(
                isKoreanMode ? "🏁 코스 종료" : "🏁 End Course",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                border: Border.all(color: Colors.black.withOpacity(0.4)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                isKoreanMode
                    ? "${widget.stampPoints.length - remainingStamps.length} / ${widget.stampPoints.length} 스탬프 완료"
                    : "${widget.stampPoints.length - remainingStamps.length} / ${widget.stampPoints.length} stamps complete",
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 70,
            left: 20,
            right: 20,
            child: Visibility(
              visible: _canStamp,
              child: ElevatedButton(
                onPressed: onReachedTarget,
                child: Text(
                  isKoreanMode ? "📸 스탬프 찍기" : "📸 Take Stamp",
                ),
              ),
            ),
          ),
        ],
      ),
    );

  }

  Future<void> saveStamp({
    required String userId,
    required String courseName,
    required String stampName,
    required double lat,
    required double lng,
  }) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('stamps')
        .doc('${courseName}_$stampName')
        .set({
      'course': courseName,
      'name': stampName,
      'lat': lat,
      'lng': lng,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
}