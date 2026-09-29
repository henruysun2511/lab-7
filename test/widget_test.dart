// Lab 7 – Form & Xác thực
// Sinh viên: Đặng Nhật Huy - MSSV: 26A4041188
import 'package:flutter_test/flutter_test.dart';
import 'package:lab_7/main.dart';

void main() {
  testWidgets('Register form smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const Lab7App());

    // Form đăng ký phải hiển thị
    expect(find.text('Tạo tài khoản'), findsOneWidget);
    expect(find.text('Họ và tên *'), findsOneWidget);
    expect(find.text('Email *'), findsOneWidget);
    expect(find.text('Đăng ký'), findsOneWidget);
    expect(find.textContaining('Đặng Nhật Huy'), findsWidgets);
  });
}
