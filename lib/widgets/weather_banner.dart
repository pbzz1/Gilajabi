import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherBanner extends StatefulWidget {
  const WeatherBanner({super.key});

  @override
  State<WeatherBanner> createState() => _WeatherBannerState();
}

class _WeatherBannerState extends State<WeatherBanner> {
  String? description;
  double? temp;
  String? locationName;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      setState(() {
        error = null;
        description = null;
        temp = null;
        locationName = null;
      });

      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (!serviceEnabled || permission == LocationPermission.deniedForever) {
        setState(() => error = "위치 권한이 거부되었습니다.");
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      final lat = position.latitude;
      final lon = position.longitude;

      // ✅ 위치 → 주소 변환 (한글 시/구/동)
      final placemarks = await placemarkFromCoordinates(lat, lon, localeIdentifier: "ko");
      final placemark = placemarks.first;
      locationName =
          "${placemark.administrativeArea ?? ''} ${placemark.locality ?? ''} ${placemark.subLocality ?? ''}".trim();

      final apiKey = '37b530c875ea7fa6fc68a929423bcf0a'; // OpenWeatherMap API 키
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        setState(() => error = "API 오류: ${response.statusCode}");
        return;
      }

      final data = jsonDecode(response.body);
      if (data['weather'] == null || data['main'] == null) {
        setState(() => error = "날씨 정보가 없습니다.");
        return;
      }

      setState(() {
        description = data['weather'][0]['description'];
        temp = data['main']['temp']?.toDouble();
        error = null;
      });
    } catch (e) {
      setState(() => error = "날씨 정보를 불러오지 못했습니다.");
      print("날씨 오류: $e");
    }
  }

  /// ✅ 날씨 설명 기반 아이콘
  IconData getWeatherIcon(String? desc) {
    final d = desc?.toLowerCase() ?? '';
    if (d.contains('비')) return Icons.umbrella;
    if (d.contains('눈')) return Icons.ac_unit;
    if (d.contains('맑')) return Icons.wb_sunny;
    if (d.contains('흐림') || d.contains('구름')) return Icons.cloud;
    return Icons.wb_cloudy;
  }

  /// ✅ 기온 기반 색상
  Color getWeatherColor(double? temp) {
    if (temp == null) return Colors.grey;
    if (temp >= 30) return Colors.redAccent;
    if (temp >= 20) return Colors.orange;
    if (temp >= 10) return Colors.blueGrey;
    return Colors.lightBlue;
  }

  @override
  Widget build(BuildContext context) {
    final infoText = () {
      if (error != null) {
        return Text(error!, style: const TextStyle(fontSize: 16, color: Colors.redAccent));
      }
      if (description == null || temp == null) {
        return const Text("날씨 정보를 불러오는 중...", style: TextStyle(fontSize: 16));
      }
      return Text(
        "$description / ${temp!.toStringAsFixed(1)}°C",
        style: TextStyle(
          fontSize: 16,
          color: getWeatherColor(temp),
        ),
      );
    }();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 위치 + 새로고침
              Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      locationName ?? '위치 확인 중...',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: _loadWeather,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // 날씨 아이콘 + 텍스트
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    getWeatherIcon(description),
                    size: 40,
                    color: getWeatherColor(temp),
                  ),
                  const SizedBox(width: 12),
                  infoText,
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
