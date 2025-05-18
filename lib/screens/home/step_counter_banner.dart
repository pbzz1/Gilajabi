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
      print('만보기 오류: $error');
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
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('취소')),
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
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        border: Border.all(color: Colors.black.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(2, 4)),
        ],
      ),

      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: Row(
        children: [
          const SizedBox(width: 40),
          const Icon(Icons.directions_walk, size: 40, color: Colors.teal),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('오늘의 걸음 수', style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w500)),
                const SizedBox(height: 6),
                Text('$_steps 걸음',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    )),
              ],
            ),
          ),
          IconButton(
            onPressed: _showResetConfirmationDialog,
            icon: const Icon(Icons.autorenew, color: Colors.teal),
            tooltip: '초기화',
          ),
        ],
      ),
    );
  }
}
