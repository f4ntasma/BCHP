import 'dart:async';
import 'package:flutter/material.dart';

class FanProvider extends ChangeNotifier {
  bool fanOn = true;
  double speed = 50;
  double targetTemp = 24;
  double currentTemp = 26; // Simulado, más adelante puede venir de un sensor
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void toggleFan(bool value) {
    fanOn = value;
    notifyListeners();
  }

  void setSpeed(double val) {
    speed = val;
    notifyListeners();
  }

  void setTargetTemp(double val) {
    targetTemp = val;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if ((targetTemp - currentTemp).abs() < 0.1) {
        timer.cancel();
      } else if (currentTemp < targetTemp) {
        currentTemp += 0.1;
      } else {
        currentTemp -= 0.1;
      }
      notifyListeners();
    });
    notifyListeners();
  }

  Color getTempColor(double temp) {
    if (temp <= 20) return Colors.blueAccent;
    if (temp >= 28) return Colors.redAccent;
    return Colors.orangeAccent;
  }
}