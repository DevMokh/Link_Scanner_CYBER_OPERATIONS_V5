import 'package:flutter/material.dart';

import '../core/theme.dart';

/// Rectangular terminal panel used by scan tools and reports.
class Panel extends StatelessWidget {
  const Panel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: glassDecoration(border: borderColor ?? C.line, radius: 9),
      child: child,
    );
  }
}

/// Technical section label, styled like a terminal command/comment.
class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(1, 8, 1, 10),
      child: Row(
        children: [
          const Text('//', style: TextStyle(color: C.accent, fontSize: 13, fontWeight: FontWeight.w900, fontFamily: 'monospace')),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text.toUpperCase(),
              style: const TextStyle(
                color: C.text,
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.65,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

InputDecoration fieldDecoration({String? hint, Widget? suffix}) {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: c),
      );
  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: C.muted, fontSize: 13),
    filled: true,
    fillColor: C.bg,
    suffixIcon: suffix,
    contentPadding: const EdgeInsets.all(14),
    enabledBorder: border(C.line),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: C.accent, width: 1.5),
    ),
    border: border(C.line),
  );
}

void toast(BuildContext context, String message) {
  final m = ScaffoldMessenger.of(context);
  m.hideCurrentSnackBar();
  m.showSnackBar(SnackBar(content: Text(message)));
}

ButtonStyle outlineButtonStyle() => OutlinedButton.styleFrom(
      foregroundColor: C.accent,
      side: const BorderSide(color: C.line),
      padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );

ButtonStyle filledButtonStyle() => FilledButton.styleFrom(
      backgroundColor: C.accent,
      foregroundColor: C.onAccent,
      elevation: 0,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
    );

/// Main command button in the cyber terminal visual language.
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.height = 54,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Opacity(
      opacity: enabled ? 1 : 0.42,
      child: Container(
        decoration: BoxDecoration(
          color: C.accent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: enabled ? glow(C.accent, opacity: 0.18, blur: 14) : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: onPressed,
            child: SizedBox(
              height: height,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: C.onAccent, size: 21),
                  const SizedBox(width: 9),
                  Text(
                    label,
                    style: const TextStyle(
                      color: C.onAccent,
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Subtle technical grid that adds depth without using heavy image assets.
class CyberGrid extends StatelessWidget {
  const CyberGrid({super.key, required this.child, this.opacity = 0.22});

  final Widget child;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CyberGridPainter(opacity),
      child: child,
    );
  }
}

class _CyberGridPainter extends CustomPainter {
  const _CyberGridPainter(this.opacity);
  final double opacity;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = alpha(C.secondary, opacity * 0.30)
      ..strokeWidth = 0.45;
    const step = 24.0;
    for (double x = 0; x <= size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y <= size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    final edge = Paint()
      ..color = alpha(C.accent, opacity * 0.4)
      ..strokeWidth = 1.1;
    canvas.drawLine(const Offset(0, 0), Offset(size.width, 0), edge);
  }

  @override
  bool shouldRepaint(covariant _CyberGridPainter oldDelegate) => oldDelegate.opacity != opacity;
}
