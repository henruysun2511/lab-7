// Lab 7 – Form & Xác thực
// Sinh viên: Đặng Nhật Huy - MSSV: 26A4041188
// File: widgets/password_strength_meter.dart
// Lab 7.2 – Hiển thị độ mạnh mật khẩu (style gọn, hợp ui-sample-3)

import 'package:flutter/material.dart';
import '../theme/nora_theme.dart';
import '../validators.dart';

class PasswordStrengthMeter extends StatelessWidget {
  final String password;

  const PasswordStrengthMeter({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    final score = Validators.passwordScore(password);
    final strength = Validators.strengthOf(password);
    final label = Validators.strengthLabel(strength);

    Color color;
    switch (strength) {
      case PasswordStrength.tooShort:
        color = NoraTheme.inkFaint;
        break;
      case PasswordStrength.weak:
        color = NoraTheme.danger;
        break;
      case PasswordStrength.fair:
        color = NoraTheme.warning;
        break;
      case PasswordStrength.good:
        color = NoraTheme.primary;
        break;
      case PasswordStrength.strong:
        color = NoraTheme.success;
        break;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Độ mạnh mật khẩu: ',
              style: TextStyle(fontSize: 12, color: NoraTheme.inkSoft),
            ),
            Text(
              password.isEmpty ? '—' : label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: password.isEmpty ? NoraTheme.inkFaint : color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (i) {
            final filled = i < score;
            return Expanded(
              child: Container(
                height: 6,
                margin: EdgeInsets.only(right: i == 4 ? 0 : 4),
                decoration: BoxDecoration(
                  color: filled ? color : NoraTheme.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        const Text(
          '• ≥8 ký tự • chữ HOA • chữ thường • số • ký tự đặc biệt',
          style: TextStyle(fontSize: 11, color: NoraTheme.inkFaint),
        ),
      ],
    );
  }
}
