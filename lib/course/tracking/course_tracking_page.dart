import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import '../../widgets/kakao_map_tracker.dart';
import '../stamp_points.dart';

class CourseTrackingPage extends StatefulWidget {
  final String courseName;
  final String polylineJsonFile; // 파일명만 넘김
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
  List<Map<String, double>> _polylinePoints = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPolyline().then((_) => _startTracking());
  }

  Future<void> _loadPolyline() async {
    final jsonStr = await rootBundle.loadString('assets/json/${widget.polylineJsonFile}');
    final List<dynamic> jsonList = jsonDecode(jsonStr);

    setState(() {
      _polylinePoints = jsonList.map<Map<String, double>>((point) {
        final List<dynamic> coords = point; // 👈 각 point가 [lat, lng] 형태의 List
        return {
          "lat": (coords[0] as num).toDouble(),
          "lng": (coords[1] as num).toDouble(),
        };
      }).toList();
      _loading = false;
    });
  }


  Future<void> _startTracking() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) return;
    }

    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.best),
    ).listen((Position position) {
      _mapKey.currentState?.updateUserLocation(position.latitude, position.longitude);
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
          : KakaoMapTracker(
        key: _mapKey,
        polylinePoints: _polylinePoints,
        stampPoints: widget.stampPoints,
      ),
    );
  }
}
