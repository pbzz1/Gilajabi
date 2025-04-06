// lib/nearby_facilities_page.dart
import 'package:flutter/material.dart';

class NearbyFacilitiesPage extends StatelessWidget {
  const NearbyFacilitiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('주변 시설'),
      ),
      body: const Center(
        child: Text(
          '주변 시설 페이지',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
