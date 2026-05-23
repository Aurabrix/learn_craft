import 'package:flutter/material.dart';

class AppToast {
  AppToast._();

  static const _redFill    = Color(0xFFFF4B4B);
  static const _redShadow  = Color(0xFFCC3333);
  static const _greenFill  = Color(0xFF58CC02);
  static const _greenShadow = Color(0xFF46A302);

  static OverlayEntry? _currentEntry;

  static void show(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    // Remove the previous toast immediately
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _DuoToast(
        message: message,
        isError: isError,
        fillColor:   isError ? _redFill   : _greenFill,
        shadowColor: isError ? _redShadow : _greenShadow,
        icon: isError
            ? Icons.cancel_rounded
            : Icons.check_circle_rounded,
        onDone: () {
          entry.remove();
          if (_currentEntry == entry) _currentEntry = null;
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  static void error(BuildContext context, String message) =>
      show(context, message, isError: true);

  static void success(BuildContext context, String message) =>
      show(context, message, isError: false);
}

// ── Overlay widget — slides down from top ────────────────────
class _DuoToast extends StatefulWidget {
  const _DuoToast({
    required this.message,
    required this.isError,
    required this.fillColor,
    required this.shadowColor,
    required this.icon,
    required this.onDone,
  });

  final String message;
  final bool isError;
  final Color fillColor;
  final Color shadowColor;
  final IconData icon;
  final VoidCallback onDone;

  @override
  State<_DuoToast> createState() => _DuoToastState();
}

class _DuoToastState extends State<_DuoToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();

    // Auto-dismiss after 3 s
    Future.delayed(const Duration(seconds: 3), _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDone();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.of(context).padding.top + 12;

    return Positioned(
      top: top,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: widget.fillColor,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: widget.shadowColor,
                      offset: const Offset(0, 4),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 22),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.none,
                        ),
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
