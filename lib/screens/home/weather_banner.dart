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
    _loadWeather();
  }

  @override
  void dispose() {
    _rotationController.dispose();
    super.dispose();
  }

  Future<void> _loadWeather() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
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

      final placemarks = await placemarkFromCoordinates(lat, lon, localeIdentifier: "ko");
      final placemark = placemarks.first;
      locationName = "${placemark.administrativeArea ?? ''} ${placemark.locality ?? ''} ${placemark.subLocality ?? ''}".trim();

      final apiKey = '37b530c875ea7fa6fc68a929423bcf0a'; // Replace with your real API key
      final url = Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=kr',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        setState(() => error = "API 오류: ${response.statusCode}");
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
        error = "날씨 정보를 불러오지 못했습니다.";
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
    final infoText = () {
      if (error != null) {
        return Text(error!, style: const TextStyle(fontSize: 16, color: Colors.redAccent));
      }
      if (description == null || temp == null) {
        return const Text("날씨 정보를 불러오는 중...", style: TextStyle(fontSize: 16, color: Colors.black));
      }
      return Text(
        "$description / ${temp!.toStringAsFixed(1)}°C",
        style: TextStyle(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.blue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  locationName ?? '위치 확인 중...',
                  style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.bold),
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
                    _loadWeather();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
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