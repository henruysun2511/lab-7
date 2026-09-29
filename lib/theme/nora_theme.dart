// Lab 7 – Form & Xác thực
// Sinh viên: Đặng Nhật Huy - MSSV: 26A4041188
// File: theme/nora_theme.dart – Design tokens bám theo static-ui/ui-sample-3/styles.css

import 'package:flutter/material.dart';

class NoraTheme {
  // --primary: oklch(0.55 0.18 250) ≈ #2563EB
  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1E3A8A);
  static const Color primaryLight = Color(0xFF3B82F6);
  static const Color primarySoft = Color(0xFFE3EDFF);

  // Nền field: --dash-bg
  static const Color fieldBg = Color(0xFFF1F5F9);
  static const Color border = Color(0xFFE2E8F0);

  static const Color ink = Color(0xFF1E293B);
  static const Color inkSoft = Color(0xFF64748B);
  static const Color inkFaint = Color(0xFF94A3B8);

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color danger = Color(0xFFDC2626);

  // .auth-wrap gradient trong ui-sample-3
  static const LinearGradient authGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primaryDark, primary, primaryLight],
  );

  static ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: primary),
      scaffoldBackgroundColor: Colors.white,
      inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    );
  }
}
