// Lab 7 – Form & Xác thực
// Sinh viên: Đặng Nhật Huy - MSSV: 26A4041188
// File: main.dart – Điểm khởi chạy (theme Nora theo ui-sample-3)
// Chạy web: flutter run -d chrome

import 'package:flutter/material.dart';
import 'screens/register_screen.dart';
import 'student_info.dart';
import 'theme/nora_theme.dart';

void main() {
  runApp(const Lab7App());
}

class Lab7App extends StatelessWidget {
  const Lab7App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '${StudentInfo.labName} - ${StudentInfo.fullName}',
      debugShowCheckedModeBanner: false,
      theme: NoraTheme.theme(),
      home: const RegisterScreen(),
    );
  }
}
