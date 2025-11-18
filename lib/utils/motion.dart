import 'package:flutter/animation.dart';

class AppMotion {
  // Duraciones
  static const fast = Duration(milliseconds: 160);
  static const med  = Duration(milliseconds: 280);
  static const slow = Duration(milliseconds: 480);

  // Curvas
  static const spring    = Cubic(0.20, 0.80, 0.20, 1.00); // rebote suave
  static const emphasized= Cubic(0.05, 0.80, 0.10, 1.00); // material emphasized
  static const standard  = Curves.easeInOutCubic;
}
