// Lab 7 – Form & Xác thực
// Sinh viên: Đặng Nhật Huy - MSSV: 26A4041188
// File: validators.dart
// Lab 7.2 – Quy tắc xác thực & độ mạnh mật khẩu

/// Điểm mạnh mật khẩu từ 0..5
enum PasswordStrength {
  tooShort, // 0
  weak, // 1
  fair, // 2
  good, // 3-4
  strong, // 5
}

class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  // SĐT Việt Nam: 10 số, bắt đầu 03, 05, 07, 08, 09
  static final RegExp _phoneRegex = RegExp(r'^(03|05|07|08|09)\d{8}$');

  // ---------- Lab 7.1 + 7.2: Validate từng field ----------

  static String? validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ và tên';
    }
    final name = value.trim();
    if (name.length < 3) {
      return 'Họ tên phải có ít nhất 3 ký tự';
    }
    // Mỗi từ phải >= 2 ký tự (tránh nhập "A B")
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length < 2) {
      return 'Vui lòng nhập đầy đủ họ và tên';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập email';
    }
    if (!_emailRegex.hasMatch(value.trim())) {
      return 'Email không đúng định dạng (vd: ten@example.com)';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phone = value.trim().replaceAll(RegExp(r'[\s.]'), '');
    if (!_phoneRegex.hasMatch(phone)) {
      return 'SĐT phải có 10 số, bắt đầu bằng 03/05/07/08/09';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng nhập mật khẩu';
    }
    if (value.length < 8) {
      return 'Mật khẩu phải có ít nhất 8 ký tự';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Mật khẩu cần ít nhất 1 chữ HOA (A-Z)';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Mật khẩu cần ít nhất 1 chữ thường (a-z)';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Mật khẩu cần ít nhất 1 chữ số (0-9)';
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`\[\]\\;/]').hasMatch(value)) {
      return 'Mật khẩu cần ít nhất 1 ký tự đặc biệt (!@#...)';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Vui lòng xác nhận mật khẩu';
    }
    if (value != password) {
      return 'Mật khẩu xác nhận không khớp';
    }
    return null;
  }

  static String? validateDob(DateTime? dob) {
    if (dob == null) return 'Vui lòng chọn ngày sinh';
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month ||
        (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    if (age < 13) return 'Bạn phải từ 13 tuổi trở lên';
    if (dob.isAfter(now)) return 'Ngày sinh không hợp lệ';
    return null;
  }

  // ---------- Lab 7.2: Tính độ mạnh mật khẩu (0..5 điểm) ----------
  // 1đ: >=8 ký tự, 1đ: chữ hoa, 1đ: chữ thường, 1đ: số, 1đ: ký tự đặc biệt
  static int passwordScore(String password) {
    int score = 0;
    if (password.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(password)) score++;
    if (RegExp(r'[a-z]').hasMatch(password)) score++;
    if (RegExp(r'[0-9]').hasMatch(password)) score++;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>_\-+=~`\[\]\\;/]').hasMatch(password)) {
      score++;
    }
    return score;
  }

  static PasswordStrength strengthOf(String password) {
    final s = passwordScore(password);
    if (password.isEmpty || password.length < 6) {
      return PasswordStrength.tooShort;
    }
    if (s <= 1) return PasswordStrength.weak;
    if (s == 2) return PasswordStrength.fair;
    if (s <= 4) return PasswordStrength.good;
    return PasswordStrength.strong;
  }

  static String strengthLabel(PasswordStrength s) {
    switch (s) {
      case PasswordStrength.tooShort:
        return 'Quá ngắn';
      case PasswordStrength.weak:
        return 'Yếu';
      case PasswordStrength.fair:
        return 'Trung bình';
      case PasswordStrength.good:
        return 'Mạnh';
      case PasswordStrength.strong:
        return 'Rất mạnh';
    }
  }

  // ---------- Lab 7.4: Giả lập kiểm tra email bất đồng bộ ----------
  // Giả lập gọi API: email đã tồn tại nếu nằm trong danh sách này.
  static const List<String> takenEmails = [
    'admin@gmail.com',
    'test@example.com',
    'huy@gmail.com',
    'taken@gmail.com',
  ];

  /// Giả lập network delay 800ms rồi trả về true nếu email đã được dùng.
  static Future<bool> isEmailTaken(String email) async {
    await Future.delayed(const Duration(milliseconds: 800));
    return takenEmails.contains(email.trim().toLowerCase());
  }
}
