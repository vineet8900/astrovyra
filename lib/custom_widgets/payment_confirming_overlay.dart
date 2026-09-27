import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:astrokavach/custom_widgets/styles.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PaymentConfirmingOverlay {
  static OverlayEntry? _entry;

  static void show(BuildContext context) {
    dismiss();
    final navigator = Navigator.of(context, rootNavigator: true);
    final overlay = navigator.overlay;
    if (overlay == null) return;
    _entry = OverlayEntry(
      builder: (ctx) => const _PaymentConfirmingLayer(),
    );
    overlay.insert(_entry!);
  }

  static void dismiss() {
    _entry?.remove();
    _entry = null;
  }

  static Future<T?> run<T>(
    BuildContext context,
    Future<T?> Function() task,
  ) async {
    if (!context.mounted) return null;
    show(context);
    try {
      return await task();
    } finally {
      dismiss();
    }
  }
}

class _PaymentSpinnerPainter extends CustomPainter {
  _PaymentSpinnerPainter({
    required this.angleOuter,
    required this.angleInner,
    required this.orbitPhase,
  });

  final double angleOuter;
  final double angleInner;
  final double orbitPhase;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final R = size.shortestSide / 2;
    final rOuter = R * 0.92;
    final rInner = R * 0.58;
    final rMid = R * 0.76;

    final track = Paint()
      ..color = const Color(0xFFE8EDF3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(c, rOuter, track);
    canvas.drawCircle(c, rInner, track);

    final outerRect = Rect.fromCircle(center: c, radius: rOuter);
    final outerArc = Paint()
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: [
          CustomStyles.pinki.withOpacity(0.15),
          CustomStyles.pinki,
          CustomStyles.ctaColor,
          CustomStyles.pinki.withOpacity(0.15),
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
        transform: GradientRotation(angleOuter),
      ).createShader(outerRect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.5
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: rOuter),
      angleOuter,
      2.35,
      false,
      outerArc,
    );

    final innerArc = Paint()
      ..color = CustomStyles.ctaColor.withOpacity(0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: rInner),
      angleInner,
      -2.1,
      false,
      innerArc,
    );

    final tau = math.pi * 2;
    for (var i = 0; i < 3; i++) {
      final ang = orbitPhase + i * tau / 3;
      final px = c.dx + rMid * math.cos(ang);
      final py = c.dy + rMid * math.sin(ang);
      final dotPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(px, py),
          6,
          [
            CustomStyles.pinki,
            CustomStyles.ctaColor.withOpacity(0.6),
          ],
        );
      canvas.drawCircle(Offset(px, py), 5, dotPaint);
    }

    final corePaint = Paint()
      ..shader = ui.Gradient.radial(
        c,
        R * 0.22,
        [
          CustomStyles.pinki.withOpacity(0.2),
          CustomStyles.pinki.withOpacity(0.05),
        ],
      );
    canvas.drawCircle(c, R * 0.22, corePaint);
    canvas.drawCircle(
      c,
      R * 0.1,
      Paint()..color = CustomStyles.pinki.withOpacity(0.35),
    );
  }

  @override
  bool shouldRepaint(covariant _PaymentSpinnerPainter oldDelegate) {
    return oldDelegate.angleOuter != angleOuter ||
        oldDelegate.angleInner != angleInner ||
        oldDelegate.orbitPhase != orbitPhase;
  }
}

class _PaymentConfirmingLayer extends StatefulWidget {
  const _PaymentConfirmingLayer();

  @override
  State<_PaymentConfirmingLayer> createState() =>
      _PaymentConfirmingLayerState();
}

class _PaymentConfirmingLayerState extends State<_PaymentConfirmingLayer>
    with TickerProviderStateMixin {
  late AnimationController _revealController;
  late AnimationController _spinOuter;
  late AnimationController _spinInner;
  late AnimationController _orbit;
  late Animation<double> _reveal;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    );
    _spinOuter = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _spinInner = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1650),
    )..repeat();
    _orbit = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
    _reveal = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );
    _revealController.forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _spinOuter.dispose();
    _spinInner.dispose();
    _orbit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final maxCard = math.min(340.0, mq.size.width - 40);

    return Material(
      color: Colors.black.withOpacity(0.52),
      child: Center(
        child: AnimatedBuilder(
          animation: _reveal,
          builder: (context, child) {
            final t = _reveal.value;
            return Transform.scale(
              scale: 0.82 + 0.18 * t,
              child: Opacity(opacity: t, child: child),
            );
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: BackdropFilter(
              filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
              child: Container(
                width: maxCard,
                padding: const EdgeInsets.fromLTRB(28, 36, 28, 32),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.94),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: Colors.white.withOpacity(0.65)),
                  boxShadow: [
                    BoxShadow(
                      color: CustomStyles.pinki.withOpacity(0.12),
                      blurRadius: 40,
                      spreadRadius: 0,
                      offset: const Offset(0, 16),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 108,
                      height: 108,
                      child: AnimatedBuilder(
                        animation:
                            Listenable.merge([_spinOuter, _spinInner, _orbit]),
                        builder: (context, _) {
                          return CustomPaint(
                            painter: _PaymentSpinnerPainter(
                              angleOuter: _spinOuter.value * math.pi * 2,
                              angleInner: -_spinInner.value * math.pi * 2,
                              orbitPhase: _orbit.value * math.pi * 2,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Please wait',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                        color: const Color(0xFF141414),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your payment is being confirmed',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Hang tight — this will only take a moment',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        height: 1.35,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
