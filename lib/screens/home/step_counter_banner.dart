import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StepCounterBanner extends StatefulWidget {
  const StepCounterBanner({super.key});

  @override
  State<StepCounterBanner> createState() => _StepCounterBannerState();
}

class _StepCounterBannerState extends State<StepCounterBanner> {
  Stream<StepCount>? _stepCountStream;
  int _steps = 0;
  int _baseDeviceSteps = 0;
  int _latestDeviceSteps = 0;

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  Future<void> _syncTodaySteps() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final savedDateStr = prefs.getString('lastStepResetDate');
    final savedDate = savedDateStr != null ? DateTime.tryParse(savedDateStr) : null;

    if (savedDate == null || savedDate.isBefore(today)) {
      _baseDeviceSteps = _latestDeviceSteps;
      await prefs.setInt('baseDeviceSteps', _baseDeviceSteps);
      await prefs.setString('lastStepResetDate', today.toIso8601String());
    } else {
      _baseDeviceSteps = prefs.getInt('baseDeviceSteps') ?? 0;
    }
  }

  void _startListening() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream?.listen((StepCount event) async {
      _latestDeviceSteps = event.steps;
      await _syncTodaySteps();
      setState(() {
        _steps = _latestDeviceSteps - _baseDeviceSteps;
        if (_steps < 0) _steps = 0;
      });
    }).onError((error) {
      print('만보기 오류: \$error');
    });
  }

  void _resetSteps() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final lastDeviceSteps = _steps + _baseDeviceSteps;
    await prefs.setInt('baseDeviceSteps', lastDeviceSteps);
    await prefs.setString('lastStepResetDate', today.toIso8601String());

    setState(() {
      _baseDeviceSteps = lastDeviceSteps;
      _steps = 0;
    });
  }

  void _showResetConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('걸음 수 초기화'),
        content: const Text('걸음 수를 초기화하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () {
              _resetSteps();
              Navigator.pop(context);
            },
            child: const Text('초기화'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.directions_walk, size: 30, color: Colors.blueAccent),
                const SizedBox(width: 12),
                Text('걸음 수: $_steps', style: const TextStyle(fontSize: 20)),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _showResetConfirmationDialog,
              icon: const Icon(Icons.refresh),
              label: const Text('초기화'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


