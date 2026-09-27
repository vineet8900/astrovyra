import 'package:flutter/material.dart';
import 'dart:async';

String normalizeAstrologerStatusKey(dynamic raw) {
  if (raw == null) return 'offline';
  final t = raw.toString().toLowerCase().trim();
  if (t == 'online' || t == '1' || t == 'true') return 'online';
  if (t == 'busy' || t == 'bussy' || t == '2') return 'busy';
  if (t == 'offline' || t == '0' || t == 'false' || t.isEmpty) {
    return 'offline';
  }
  return 'offline';
}

class BlinkingOnlineIndicator extends StatefulWidget {
  final Duration blinkFor;
  final bool stopGlowAfterBlink;

  const BlinkingOnlineIndicator({
    super.key,
    this.blinkFor = const Duration(seconds: 10),
    this.stopGlowAfterBlink = true,
  });

  @override
  BlinkingOnlineIndicatorState createState() => BlinkingOnlineIndicatorState();
}

class BlinkingOnlineIndicatorState extends State<BlinkingOnlineIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _scale;
  late Animation<Offset> _jolt;
  Timer? _stopTimer;
  bool _blinkStopped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100000),
      vsync: this,
    )..repeat(reverse: true);

    _stopTimer = Timer(widget.blinkFor, () {
      if (!mounted) return;
      setState(() => _blinkStopped = true);
      _controller.stop();
    });

    _opacity = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.22)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.22, end: 1.0)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_controller);

    _jolt = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween<Offset>(begin: Offset.zero, end: const Offset(0, -0.08))
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 35,
      ),
      TweenSequenceItem(
        tween: Tween<Offset>(begin: const Offset(0, -0.08), end: Offset.zero)
            .chain(CurveTween(curve: Curves.elasticOut)),
        weight: 65,
      ),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _stopTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_blinkStopped) {
      return Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: const Color(0xFF66BB6A),
          shape: BoxShape.circle,
          boxShadow: widget.stopGlowAfterBlink
              ? const []
              : [
                  BoxShadow(
                    color: const Color(0xFF66BB6A).withOpacity(0.35),
                    blurRadius: 6,
                    spreadRadius: 0.5,
                  ),
                ],
        ),
      );
    }
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(
        position: _jolt,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final glow = 2.0 + (_controller.value * 6.0);
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF66BB6A).withOpacity(0.55),
                      blurRadius: glow,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class AstrologerStatusDot extends StatelessWidget {
  final dynamic status;

  const AstrologerStatusDot({super.key, this.status});

  @override
  Widget build(BuildContext context) {
    final String s = normalizeAstrologerStatusKey(status);
    if (s == 'online') {
      return _OnlinePopDot();
    }
    if (s == 'busy') {
      return Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Color(0xFFF57C00),
          shape: BoxShape.circle,
        ),
      );
    }
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Color(0xFFC62828),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _OnlinePopDot extends StatefulWidget {
  const _OnlinePopDot();

  @override
  State<_OnlinePopDot> createState() => _OnlinePopDotState();
}

class _OnlinePopDotState extends State<_OnlinePopDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1400),
      vsync: this,
    );
    _scale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 40,
      ),
    ]).animate(_controller);
    _opacity = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
    ]).animate(_controller);
    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF66BB6A),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
