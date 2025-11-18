import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Slider horizontal estilo "control center":
/// - barra completa (icono afuera)
/// - sin thumb ni números
/// - arrastre/tap en cualquier punto
/// - gradiente visible (izq→der) y sin huecos
class ControlCenterSliderHorizontal extends StatefulWidget {
  /// Valor normalizado [0.0 – 1.0]
  final double value;
  final ValueChanged<double> onChanged;

  final IconData icon;
  final Gradient gradient;

  /// Desactiva interacción/estilos (útil cuando el dispositivo está apagado)
  final bool enabled;

  /// Alto del control (barra)
  final double height;

  /// Texto para accesibilidad (opcional)
  final String? semanticLabel;

  const ControlCenterSliderHorizontal({
    super.key,
    required this.value,
    required this.onChanged,
    required this.icon,
    required this.gradient,
    this.enabled = true,
    this.height = 56,
    this.semanticLabel,
  });

  @override
  State<ControlCenterSliderHorizontal> createState() =>
      _ControlCenterSliderHorizontalState();
}

class _ControlCenterSliderHorizontalState
    extends State<ControlCenterSliderHorizontal> {
  bool _dragging = false;
  double _lastHapticStep = -1;

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    final cs = Theme.of(context).colorScheme;

    final iconBg = cs.surfaceVariant;
    final iconFg = cs.onSurfaceVariant;
    final v = widget.value.clamp(0.0, 1.0);

    return Semantics(
      label: widget.semanticLabel,
      value: '${(v * 100).round()}%',
      slider: true,
      enabled: widget.enabled,
      child: Row(
        children: [
          Container(
            width: h,
            height: h,
            decoration: BoxDecoration(
              color: widget.enabled ? iconBg : iconBg.withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.enabled ? iconFg : iconFg.withOpacity(0.4),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: _TrackBar(
              value: v,
              onChanged: widget.onChanged,
              gradient: widget.gradient,
              height: h,
              enabled: widget.enabled,
              dragging: _dragging,
              onDragState: (isDragging) {
                setState(() => _dragging = isDragging);
              },
              onHaptic: (newV) {
              
                final step = (newV * 10).floorToDouble();
                if (step != _lastHapticStep && _dragging && widget.enabled) {
                  HapticFeedback.selectionClick();
                  _lastHapticStep = step;
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TrackBar extends StatelessWidget {
  final double value; 
  final ValueChanged<double> onChanged;
  final Gradient gradient;
  final double height;
  final bool enabled;
  final bool dragging;
  final ValueChanged<bool> onDragState;
  final ValueChanged<double> onHaptic;

  const _TrackBar({
    required this.value,
    required this.onChanged,
    required this.gradient,
    required this.height,
    required this.enabled,
    required this.dragging,
    required this.onDragState,
    required this.onHaptic,
  });

  Gradient _horizontalize(Gradient g, {required bool enabled}) {
    List<Color> mapColors(List<Color> colors) =>
        colors.map((c) => enabled ? c : c.withOpacity(0.5)).toList();

    if (g is LinearGradient) {
      return LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: mapColors(g.colors),
        stops: g.stops,
        tileMode: g.tileMode,
        transform: g.transform,
      );
    } else if (g is RadialGradient) {
      return RadialGradient(
        center: g.center,
        radius: g.radius,
        colors: mapColors(g.colors),
        stops: g.stops,
        tileMode: g.tileMode,
        focal: g.focal,
        focalRadius: g.focalRadius,
        transform: g.transform,
      );
    } else if (g is SweepGradient) {
      return SweepGradient(
        center: g.center,
        startAngle: g.startAngle,
        endAngle: g.endAngle,
        colors: mapColors(g.colors),
        stops: g.stops,
        tileMode: g.tileMode,
        transform: g.transform,
      );
    }
    return g;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final radius = BorderRadius.circular(height / 2);
    final grad = _horizontalize(gradient, enabled: enabled);

    return LayoutBuilder(
      builder: (context, c) {
        final trackWidth = c.maxWidth;
        final fillW = (trackWidth * value).clamp(0.0, trackWidth);

        void setFromDx(double dx) {
          final local = dx.clamp(0.0, trackWidth);
          final newV = (local / trackWidth).clamp(0.0, 1.0);
          onHaptic(newV);
          onChanged(newV);
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled
              ? (d) {
                  onDragState(true);
                  setFromDx(d.localPosition.dx);
                }
              : null,
          onTapUp: enabled ? (_) => onDragState(false) : null,
          onHorizontalDragStart: enabled ? (_) => onDragState(true) : null,
          onHorizontalDragUpdate:
              enabled ? (d) => setFromDx(d.localPosition.dx) : null,
          onHorizontalDragEnd: enabled ? (_) => onDragState(false) : null,
          child: ClipRRect(
            borderRadius: radius,
            child: Container(
              height: height,
              decoration: BoxDecoration(
                color: cs.surfaceVariant.withOpacity(enabled ? 1 : 0.65),
                border: Border.all(color: cs.outlineVariant.withOpacity(0.5)),
              ),
              child: Stack(
                children: [
                  
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      duration:
                          dragging ? Duration.zero : const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      width: fillW,
                      decoration: BoxDecoration(gradient: grad),
                    ),
                  ),

                  if (dragging)
                    Positioned.fill(
                      child: IgnorePointer(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.white.withOpacity(0.06),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}