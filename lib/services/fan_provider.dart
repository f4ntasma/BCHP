import 'package:flutter/material.dart';

class FanProvider extends ChangeNotifier {
  bool fanOn = true;
  double speed = 50;
  double targetTemp = 24;
  double currentTemp = 26; // Simulado, más adelante puede venir de un sensor

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
    notifyListeners();
  }

  Color getTempColor(double temp) {
    if (temp <= 20) return Colors.blueAccent;
    if (temp >= 28) return Colors.redAccent;
    return Colors.orangeAccent;
  }
}