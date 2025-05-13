import 'package:flutter/material.dart';

import 'package:gilajabi/screens/home/menu_buttons.dart';
import 'package:gilajabi/screens/home/iamge_banner.dart';
import 'package:gilajabi/screens/home/weather_banner.dart';
import 'package:gilajabi/screens/home/step_counter_banner.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 16),
          const ImageBanner(), // 이미지 배너
          const SizedBox(height: 15),
          WeatherBanner(), // 날씨 배너
          const SizedBox(height: 15),
          StepCounterBanner(), // 만보기 배너
          const SizedBox(height: 15),
          const MenuButtons(), // 메뉴 버튼
        ],
      ),
    );
  }
}