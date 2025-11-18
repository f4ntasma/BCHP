import 'package:flutter/material.dart';
import 'motion.dart';

PageRouteBuilder<T> fadeThrough<T>(Widget page) {
  return PageRouteBuilder<T>(
    pageBuilder: (_, __, ___) => page,
    transitionDuration: AppMotion.slow,
    reverseTransitionDuration: AppMotion.med,
    transitionsBuilder: (context, anim, secAnim, child) {
      final fade = Tween<double>(begin: 0, end: 1)
          .chain(CurveTween(curve: AppMotion.standard))
          .animate(anim);

      final scale = Tween<double>(begin: 0.98, end: 1.0)
          .chain(CurveTween(curve: AppMotion.emphasized))
          .animate(anim);

      return FadeTransition(
        opacity: fade,
        child: ScaleTransition(scale: scale, child: child),
      );
    },
  );
}