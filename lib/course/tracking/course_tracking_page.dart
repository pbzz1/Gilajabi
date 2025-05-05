import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import '../../widgets/kakao_map_tracker.dart';
import '../stamp_points.dart';

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
  bool _loading = true;

  bool _followUser = true;
  double _distanceToTarget = 0.0;
  late StampPoint targetPoint;
  bool _canStamp = false;

  @override
  void initState() {
    super.initState();
    _loadUserId();
    remainingStamps = List.from(widget.stampPoints);
    _loadPolyline().then((_) => _startTracking());
  }

  Future<void> _loadUserId() async {
    try {
      final user = await UserApi.instance.me();
      globalUserId = user.id.toString();
    } catch (e) {
      print('userId 로드 실패: $e');
    }
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
    final position = await Geolocator.getCurrentPosition();
    _mapKey.currentState?.updateUserLocation(position.latitude, position.longitude);
    await Future.delayed(const Duration(seconds: 3));

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

        setState(() {
          _distanceToTarget = distance;

          if (distance <= 30) {
            if (!_canStamp) {
              _canStamp = true;
              Fluttertoast.showToast(msg: "경유지 도착! 스탬프를 찍어주세요!");
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

      if (remainingStamps.isEmpty) {
        Fluttertoast.showToast(
          msg: "🎉 모든 경유지 스탬프 완료!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
        );
      }
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.courseName} 코스 추적')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          KakaoMapTracker(
            key: _mapKey,
            polylinePoints: _polylinePoints,
            stampPoints: widget.stampPoints,
            onStopFollowing: () {
              setState(() => _followUser = false);
            },
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.8),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "다음 경유지까지 ${_distanceToTarget.toStringAsFixed(1)}m",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Visibility(
              visible: _canStamp,
              child: ElevatedButton(
                onPressed: onReachedTarget,
                child: const Text("📸 스탬프 찍기"),
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
