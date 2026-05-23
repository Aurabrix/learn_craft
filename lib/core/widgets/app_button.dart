import 'package:flutter/material.dart';
import 'package:learn_craft/core/services/feedback_service.dart';

/// Drop-in replacement for [ElevatedButton] that fires haptic + sound on press.
class AppElevatedButton extends StatelessWidget {
  const AppElevatedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: style,
      onPressed: onPressed == null
          ? null
          : () {
              FeedbackService.instance.tap();
              onPressed!();
            },
      child: child,
    );
  }
}

/// Drop-in replacement for [OutlinedButton] with feedback.
class AppOutlinedButton extends StatelessWidget {
  const AppOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.style,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: style,
      onPressed: onPressed == null
          ? null
          : () {
              FeedbackService.instance.tap();
              onPressed!();
            },
      child: child,
    );
  }
}

/// Wraps any widget with tap feedback (haptic + sound).
class TapFeedback extends StatelessWidget {
  const TapFeedback({super.key, required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FeedbackService.instance.tap();
        onTap();
      },
      child: child,
    );
  }
}
