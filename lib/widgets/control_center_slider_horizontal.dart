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
    this.backgroundColor = const Color(0xFFBDBDBD), // gris base
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final fullWidth = constraints.maxWidth;
          final progressWidth = fullWidth * value;

          return Container(
            height: 60,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30),
              color: backgroundColor, // barra gris completa
            ),
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Relleno que crece de izquierda a derecha
                AnimatedContainer(
                  duration: duration,
                  width: progressWidth,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: gradient,
                  ),
                ),
                // Ícono fijo a la izquierda
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Icon(icon, color: Colors.white, size: 28),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
