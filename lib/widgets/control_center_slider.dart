import 'package:flutter/material.dart';

class ControlCenterSliderHorizontal extends StatelessWidget {
  final double value; // 0.0 - 1.0
  final ValueChanged<double> onChanged;
  final IconData icon;
  final Gradient gradient;
  final Color backgroundColor;
  final Duration duration;

  const ControlCenterSliderHorizontal({
    super.key,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.gradient,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.duration = const Duration(milliseconds: 250),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        final box = context.findRenderObject() as RenderBox;
        final local = box.globalToLocal(details.globalPosition);
        final newValue = (local.dx / box.size.width);
        onChanged(newValue.clamp(0.0, 1.0));
      },
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: backgroundColor,
        ),
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            // Barra animada de progreso
            AnimatedFractionallySizedBox(
              widthFactor: value,
              duration: duration,
              curve: Curves.easeInOut,
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: duration,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: gradient,
                ),
              ),
            ),
            // Ícono fijo a la izquierda
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Icon(icon, color: Colors.white, size: 28),
            ),
          ],
        ),
      ),
    );
  }
}
