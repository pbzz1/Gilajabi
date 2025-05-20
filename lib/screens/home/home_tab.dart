import 'package:flutter/material.dart';

import 'package:gilajabi/screens/home/iamge_banner.dart';
import 'package:gilajabi/screens/home/menu_buttons.dart';
import 'package:gilajabi/screens/home/weather_banner.dart';
import 'package:gilajabi/screens/home/step_counter_banner.dart';

class HomeTab extends StatefulWidget {
  final bool permissionsGranted;
  const HomeTab({super.key, required this.permissionsGranted});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: [
          const SizedBox(height: 15),
          const ImageBanner(),
          const SizedBox(height: 15),
          widget.permissionsGranted
              ? const WeatherBanner()
              : const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
          const SizedBox(height: 15),
          const StepCounterBanner(),
          const SizedBox(height: 15),
          const MenuButtons(),
        ],
      ),
    );
  }
}