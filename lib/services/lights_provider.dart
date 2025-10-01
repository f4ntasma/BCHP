import 'package:flutter/material.dart';

class LightsProvider extends ChangeNotifier {
  double brightness = 50;
  double warmth = 4000;
  Map<String, bool> rooms = {
    "Sala": true,
    "Cocina": false,
    "Dormitorio": true,
  };

  void toggleRoom(String room, bool value) {
    rooms[room] = value;
    notifyListeners();
  }

  void addRoom(String room) {
    rooms[room] = false;
    notifyListeners();
  }

  void removeRoom(String room) {
    rooms.remove(room);
    notifyListeners();
  }

  void setBrightness(double val) {
    brightness = val;
    notifyListeners();
  }

  void setWarmth(double val) {
    warmth = val;
    notifyListeners();
  }
}