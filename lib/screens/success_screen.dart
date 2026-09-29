// Lab 7 – Form & Xác thực
// Sinh viên: Đặng Nhật Huy - MSSV: 26A4041188
// File: screens/success_screen.dart – Style theo ui-sample-3 (gradient + card trắng)

import 'package:flutter/material.dart';
import '../student_info.dart';
import '../theme/nora_theme.dart';

class SuccessScreen extends StatelessWidget {
  final String fullName;
  final String email;
  final String phone;

  const SuccessScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration:
            const BoxDecoration(gradient: NoraTheme.authGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                padding: const EdgeInsets.all(26),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 40,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: NoraTheme.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(26),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 48,
                        color: NoraTheme.success,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Chúc mừng! 🎉',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: NoraTheme.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Đăng ký thành công',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: NoraTheme.inkSoft,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: NoraTheme.fieldBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          _row('Họ tên', fullName),
                          const Divider(height: 16),
                          _row('Email', email),
                          const Divider(height: 16),
                          _row('SĐT', phone),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'SV: ${StudentInfo.displayName}',
                      style: const TextStyle(
                          fontSize: 11, color: NoraTheme.inkFaint),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Quay lại form',
                            style: TextStyle(fontWeight: FontWeight.w800)),
                        style: FilledButton.styleFrom(
                          backgroundColor: NoraTheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
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

  Widget _row(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 70,
          child: Text(label,
              style: const TextStyle(
                  color: NoraTheme.inkSoft, fontSize: 12)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: NoraTheme.ink,
                fontSize: 13),
          ),
        ),
      ],
    );
  }
}
