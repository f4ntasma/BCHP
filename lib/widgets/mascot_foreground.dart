import 'package:flutter/material.dart';
import 'dart:math' as math;

class MascotForeground extends StatefulWidget {
  const MascotForeground({super.key});

  @override
  State<MascotForeground> createState() => _MascotForegroundState();
}

class _MascotForegroundState extends State<MascotForeground>
    with TickerProviderStateMixin {
  late final AnimationController _appear; // animación de entrada
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<double> _translateY;
  late final AnimationController _float;

  bool _showBubble = true;
  late final String _message;

  static const _messages = [
    '¡Bienvenido! ✨',
    'Tu smart home te esperaba 😎',
    'Todo listo para empezar 🙌',
    'Hagamos magia con tus luces 🔆',
    '¿Listx para el control total? 🚀',
  ];

  @override
  void initState() {
    super.initState();
    _message = (_messages.toList()..shuffle()).first;
    _appear = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    final curve = CurvedAnimation(parent: _appear, curve: Curves.easeOutBack);
    _opacity    = Tween<double>(begin: 0.0, end: 1.0).animate(curve);
    _scale      = Tween<double>(begin: 0.92, end: 1.0).animate(curve);
    _translateY = Tween<double>(begin: 40.0, end: 0.0).animate(curve);
    _float = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _appear.forward();

  }

  @override
  void dispose() {
    _appear.dispose();
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: LayoutBuilder(
        builder: (context, c) {
          final w = c.maxWidth;
          final h = c.maxHeight;

          final imgW = (w * 0.86).clamp(280.0, 520.0);
          final bubbleBottom = math.max(24.0, h * 0.42);
          final bubbleLeft = math.max(12.0, w * 0.08);

          final cs = Theme.of(context).colorScheme;

          return Stack(
            children: [
              AnimatedBuilder(
                animation: _appear,
                builder: (_, __) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: Opacity(
                      opacity: _opacity.value,
                      child: Transform.translate(
                        offset: Offset(0, _translateY.value),
                        child: Transform.scale(
                          scale: _scale.value,
                          child: Transform.translate(
                            offset: Offset(
                              math.sin(_float.value * 2 * math.pi) * 12,
                              0,
                            ),
                            child: Image.asset(
                              'assets/images/bcp-pet.png',
                              width: imgW,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              Positioned(
                left: bubbleLeft,
                bottom: bubbleBottom,
                child: AnimatedSlide(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  offset: _showBubble ? Offset.zero : const Offset(0, 0.15),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOut,
                    opacity: _showBubble ? 1 : 0,
                    child: _SpeechBubble(
                      text: _message,
                      background: cs.surface,
                      border: cs.outlineVariant.withOpacity(0.6),
                      textColor: cs.onSurface,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class MascotBackground extends StatelessWidget {
  const MascotBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/images/fondoapp.avif',
            fit: BoxFit.cover,
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Theme.of(context).scaffoldBackgroundColor,
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.0),
                ],
                stops: const [0.0, 0.6],
              ),
            ),
          ),
        ),
      ],
    );
  }
}


class _SpeechBubble extends StatelessWidget {
  final String text;
  final Color background;
  final Color border;
  final Color textColor;

  const _SpeechBubble({
    required this.text,
    required this.background,
    required this.border,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        const Positioned(
          left: 18,
          bottom: -8,
          child: _BubbleTail(),
        ),
      ],
    );
  }
}

class _BubbleTail extends StatelessWidget {
  const _BubbleTail();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Transform.rotate(
      angle: 0.8,
      child: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            left: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
            bottom: BorderSide(color: cs.outlineVariant.withOpacity(0.6)),
          ),
        ),
      ),
    );
  }
}
