import 'package:flutter/material.dart';

import 'models.dart';

/// Link Scanner // Cyber Operations theme.
/// Near-black terminal surfaces, phosphor green controls and restrained cyan telemetry.
class C {
  C._();

  static const Color bg = Color(0xFF050907);
  static const Color surface = Color(0xFF0A120E);
  static const Color surface2 = Color(0xFF101C16);
  static const Color line = Color(0xFF1C3A2B);

  /// Phosphor green: primary interaction and active state.
  static const Color accent = Color(0xFFB7FF35);
  static const Color accentDeep = Color(0xFF5DAB19);

  /// Cyan: telemetry and secondary navigation, not risk state.
  static const Color secondary = Color(0xFF00D9E8);
  static const Color green = Color(0xFF51F58A);
  static const Color amber = Color(0xFFFFD34E);
  static const Color orange = Color(0xFFFF914D);
  static const Color red = Color(0xFFFF5263);
  static const Color text = Color(0xFFE8F3EA);
  static const Color muted = Color(0xFF8CA294);
  static const Color onAccent = Color(0xFF071006);
}

Color alpha(Color c, double o) => c.withAlpha((o * 255).round());

List<BoxShadow> glow(
  Color c, {
  double opacity = 0.18,
  double blur = 18,
  double spread = 0,
}) => <BoxShadow>[
      BoxShadow(
        color: alpha(c, opacity * 0.48),
        blurRadius: blur,
        spreadRadius: spread,
      ),
    ];

BoxDecoration glassDecoration({
  Color? border,
  double radius = 10,
  bool glowing = false,
}) {
  final edge = border ?? C.line;
  return BoxDecoration(
    color: C.surface,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: edge),
    boxShadow: glowing ? glow(border ?? C.accent) : null,
  );
}

Color levelColor(RiskLevel l) {
  switch (l) {
    case RiskLevel.low:
      return C.green;
    case RiskLevel.medium:
      return C.amber;
    case RiskLevel.high:
      return C.orange;
    case RiskLevel.critical:
      return C.red;
  }
}

Color severityColor(Severity s) {
  switch (s) {
    case Severity.good:
      return C.green;
    case Severity.info:
      return C.muted;
    case Severity.warn:
      return C.amber;
    case Severity.danger:
      return C.red;
  }
}

IconData severityIcon(Severity s) {
  switch (s) {
    case Severity.good:
      return Icons.check_circle_rounded;
    case Severity.info:
      return Icons.info_rounded;
    case Severity.warn:
      return Icons.warning_amber_rounded;
    case Severity.danger:
      return Icons.dangerous_rounded;
  }
}

String fmtTime(DateTime t) {
  String two(int n) => n < 10 ? '0$n' : '$n';
  return '${t.day}/${t.month}  ${two(t.hour)}:${two(t.minute)}';
}

ThemeData buildTheme() {
  final base = ColorScheme.fromSeed(
    seedColor: C.accent,
    brightness: Brightness.dark,
  );
  final scheme = base.copyWith(
    primary: C.accent,
    onPrimary: C.onAccent,
    secondary: C.secondary,
    surface: C.surface,
    onSurface: C.text,
    error: C.red,
    surfaceContainerLowest: C.bg,
    surfaceContainerLow: C.surface,
    surfaceContainer: C.surface,
    surfaceContainerHigh: C.surface2,
    surfaceContainerHighest: C.surface2,
    outline: C.line,
    outlineVariant: C.line,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: scheme,
    scaffoldBackgroundColor: C.bg,
    visualDensity: VisualDensity.standard,
    appBarTheme: const AppBarTheme(
      backgroundColor: C.bg,
      foregroundColor: C.text,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: C.bg,
      surfaceTintColor: Colors.transparent,
    ),
    cardTheme: CardThemeData(
      color: C.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: C.line),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: C.bg,
      indicatorColor: alpha(C.accent, 0.12),
      surfaceTintColor: Colors.transparent,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      iconTheme: WidgetStateProperty.resolveWith<IconThemeData>((states) {
        final on = states.contains(WidgetState.selected);
        return IconThemeData(color: on ? C.accent : C.muted, size: 22);
      }),
      labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
        final on = states.contains(WidgetState.selected);
        return TextStyle(
          color: on ? C.accent : C.muted,
          fontSize: 11,
          fontWeight: on ? FontWeight.w900 : FontWeight.w500,
        );
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: C.bg,
      hintStyle: const TextStyle(color: C.muted),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: C.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: C.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: C.accent, width: 1.4),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith<Color>((states) =>
          states.contains(WidgetState.selected) ? C.onAccent : C.muted),
      trackColor: WidgetStateProperty.resolveWith<Color>((states) =>
          states.contains(WidgetState.selected) ? C.accent : C.surface2),
      trackOutlineColor: WidgetStateProperty.resolveWith<Color>((states) =>
          states.contains(WidgetState.selected) ? C.accent : C.line),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: C.accent,
      inactiveTrackColor: C.line,
      thumbColor: C.accent,
      overlayColor: alpha(C.accent, 0.12),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: C.accent,
      linearTrackColor: C.surface2,
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: C.accent,
      selectionHandleColor: C.accent,
      selectionColor: alpha(C.accent, 0.26),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: C.accent),
    ),
    dividerTheme: const DividerThemeData(color: C.line, space: 1),
    snackBarTheme: const SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: C.surface2,
      contentTextStyle: TextStyle(color: C.text),
    ),
  );
}
