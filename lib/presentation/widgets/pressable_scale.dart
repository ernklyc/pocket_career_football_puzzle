import 'package:flutter/material.dart';

/// Basınca küçülen buton wrapper — oyun ekranındaki gibi fiziksel basış hissi.
/// Herhangi bir child widget'ı sarar; onTapDown/Up/Cancel ile scale 0.92 animasyonu uygular.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressedScale;

  const PressableScale({
    super.key,
    required this.child,
    this.onTap,
    this.pressedScale = 0.92,
  });

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap != null ? (_) => setState(() => _pressed = true) : null,
      onTapUp: widget.onTap != null ? (_) => setState(() => _pressed = false) : null,
      onTapCancel: widget.onTap != null ? () => setState(() => _pressed = false) : null,
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: const Duration(milliseconds: 80),
        curve: Curves.easeInOut,
        child: Opacity(
          opacity: widget.onTap != null ? 1.0 : 0.5,
          child: widget.child,
        ),
      ),
    );
  }
}
