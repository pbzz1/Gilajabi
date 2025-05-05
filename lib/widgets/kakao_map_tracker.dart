import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import '../course/stamp_points.dart';

class KakaoMapTracker extends StatefulWidget {
  final List<Map<String, double>> polylinePoints;
  final List<StampPoint> stampPoints;
  final void Function()? onStopFollowing;

  const KakaoMapTracker({
    super.key,
    required this.polylinePoints,
    required this.stampPoints,
    this.onStopFollowing,
  });

  @override
  KakaoMapTrackerState createState() => KakaoMapTrackerState();
}

class KakaoMapTrackerState extends State<KakaoMapTracker> {
  InAppWebViewController? _webViewController;

  @override
  Widget build(BuildContext context) {
    return InAppWebView(
      initialFile: 'assets/kakao_map_tracking_template.html',
      initialSettings: InAppWebViewSettings(
        javaScriptEnabled: true,
        useShouldOverrideUrlLoading: true,
      ),
      onWebViewCreated: (controller) async {
        _webViewController = controller;
        await _waitForMapReady();

        final polylineJson = jsonEncode(widget.polylinePoints);
        await controller.evaluateJavascript(source: "drawPolyline($polylineJson);");

        final stampJson = jsonEncode(widget.stampPoints.map((e) => {
          "name": e.name,
          "lat": e.latitude,
          "lng": e.longitude,
        }).toList());
        await controller.evaluateJavascript(source: "addStampMarkers($stampJson);");
      },

      onConsoleMessage: (controller, message) {
        if (message.message == 'flutter_invokeStopFollowing') {
          widget.onStopFollowing?.call();
        }
      },
    );
  }

  void updateUserLocation(double lat, double lng) {
    _webViewController?.evaluateJavascript(
      source: "updateUserLocation($lat, $lng);",
    );
  }

  void moveToUser() {
    _webViewController?.evaluateJavascript(
      source: "moveToUser();",
    );
  }

  Future<void> _waitForMapReady() async {
    for (int i = 0; i < 10; i++) {
      final result = await _webViewController?.evaluateJavascript(
          source: 'window.flutter_ready'
      );
      if (result == true || result == 'true') break;
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  void evaluateJavascript(String js) {
    _webViewController?.evaluateJavascript(source: js);
  }
}
