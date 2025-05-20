import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:provider/provider.dart';
import 'package:gilajabi/providers/app_settings_provider.dart';

class WeatherBanner extends StatefulWidget {
  const WeatherBanner({super.key});

  @override
  State<WeatherBanner> createState() => _WeatherBannerState();
}

class _WeatherBannerState extends State<WeatherBanner> with SingleTickerProviderStateMixin {
  String? description;
  double? temp;
  String? locationName;
  String? iconCode;
  String? error;
  bool isLoading = true;
  late AnimationController _rotationController;

  @override
  void initState() {
    super.initState();
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadWeather();
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context, listen: false).isKoreanMode;

    if (!mounted) return;
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        setState(() {
          error = isKoreanMode
              ? "위치 권한이 없어 날씨를 불러올 수 없습니다."
              : "Location permission not granted.";
          isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      final lat = position.latitude;
      final lon = position.longitude;

      final placemarks = await placemarkFromCoordinates(lat, lon, localeIdentifier: "ko");
      final placemark = placemarks.first;
      locationName = "${placemark.administrativeArea ?? ''} ${placemark.locality ?? ''} ${placemark.subLocality ?? ''}".trim();

      final apiKey = '37b530c875ea7fa6fc68a929423bcf0a';
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        setState(() => error = isKoreanMode
            ? "API 오류: ${response.statusCode}"
            : "API error: ${response.statusCode}");
        return;
      }

      final data = jsonDecode(response.body);
      setState(() {
        description = data['weather'][0]['description'];
        iconCode = data['weather'][0]['icon'];
        temp = data['main']['temp']?.toDouble();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = isKoreanMode
            ? "날씨 정보를 불러오지 못했습니다."
            : "Failed to load weather information.";
        isLoading = false;
      });
    }
  }

  Color getBackgroundColor(double? temp) {
    if (temp == null) return Colors.grey.shade300;
    if (temp >= 30) return Colors.red.shade100;
    if (temp >= 20) return Colors.orange.shade100;
    if (temp >= 10) return Colors.blueGrey.shade100;
    return Colors.lightBlue.shade100;
  }

  @override
  Widget build(BuildContext context) {
    final isKoreanMode = Provider.of<AppSettingsProvider>(context).isKoreanMode;
    final infoText = () {
      if (error != null) {
        return Text(error!, style: const TextStyle(fontSize: 16, color: Colors.redAccent));
      }
      if (description == null || temp == null) {
        return Text(
          isKoreanMode ? "날씨 정보를 불러오는 중..." : "Loading weather info...",
          style: const TextStyle(fontSize: 16, color: Colors.black),
        );
      }
      return Text(
        "$description / ${temp!.toStringAsFixed(1)}°C",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      );
    }();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: getBackgroundColor(temp),
        border: Border.all(color: Colors.black.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locationName ?? (isKoreanMode ? '위치 확인 중...' : 'Locating...'),
                  style: const TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              AnimatedBuilder(
                animation: _rotationController,
                builder: (_, child) {
                  return Transform.rotate(
                    angle: _rotationController.value * 6.28,
                    child: child,
                  );
                },
                child: IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    _rotationController.forward(from: 0);
                    _loadWeather(); // 🔁 새로고침에도 위치 요청
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconCode != null)
                Image.network(
                  'https://openweathermap.org/img/wn/$iconCode@2x.png',
                  width: 50,
                  height: 50,
                ),
              const SizedBox(width: 12),
              infoText,
            ],
          ),
        ],
      ),
    );
  }
}
