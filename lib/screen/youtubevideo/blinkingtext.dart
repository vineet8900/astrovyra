// import 'package:flutter/material.dart';

// /// A widget that makes its child text blink.
// class BlinkingText extends StatefulWidget {
//   final String text;
//   final TextStyle style;

//   const BlinkingText({
//     Key? key,
//     required this.text,
//     required this.style,
//   }) : super(key: key);

//   @override
//   _BlinkingTextState createState() => _BlinkingTextState();
// }

// class _BlinkingTextState extends State<BlinkingText>
//     with SingleTickerProviderStateMixin {
//   late final AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 400), // Controls the speed of the blink
//       vsync: this,
//     )..repeat(reverse: true);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _controller,
//       child: Text(
//         widget.text,
//         style: widget.style,
//       ),
//     );
//   }
// }


import 'package:flutter/material.dart';

/// A widget that creates a blinking/pulsing glow effect around its child.
class BlinkingBadge extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color borderColor;
  final Color glowColor;

  const BlinkingBadge({
    Key? key,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    required this.glowColor,
  }) : super(key: key);

  @override
  _BlinkingBadgeState createState() => _BlinkingBadgeState();
}

class _BlinkingBadgeState extends State<BlinkingBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Color?> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900), // Controls blink speed
    )..repeat(reverse: true);

    // This creates an animation that smoothly transitions the shadow color
    // from fully transparent to the bright glow color.
    _glowAnimation = ColorTween(
      begin: widget.glowColor.withOpacity(0.0),
      end: widget.glowColor,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder is an efficient way to apply animations.
    // It rebuilds only the necessary parts (the decoration) when the animation value changes.
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: widget.backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: widget.borderColor, width: 1.5),
            boxShadow: [
              // The key part: the shadow's color is now animated
              BoxShadow(
                color: _glowAnimation.value ?? Colors.transparent,
                blurRadius: 6.0,   // How soft the glow is
                spreadRadius: 2.0, // How far the glow extends
              ),
            ],
          ),
          child: widget.child,
        );
      },
      child: widget.child, // The child is passed here so it doesn't rebuild
    );
  }
}