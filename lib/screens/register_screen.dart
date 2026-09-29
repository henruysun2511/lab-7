// Lab 7 – Form & Xác thực
// Sinh viên: Đặng Nhật Huy - MSSV: 26A4041188
// Giao diện theo static-ui/ui-sample-3/screens/auth.html (Nora · SOLARN style)
// Lab 7.1 – Form đăng ký cơ bản | 7.2 – Validation + strength
// Lab 7.3 – Focus & bàn phím | 7.4 – Check email async

import 'dart:async';

import 'package:flutter/material.dart';

import '../student_info.dart';
import '../theme/nora_theme.dart';
import '../validators.dart';
import '../widgets/password_strength_meter.dart';
import 'success_screen.dart';

enum Gender { male, female, other }

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // ---------- Lab 7.1: Form key + Controllers ----------
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  // ---------- Lab 7.3: Quản lý Focus ----------
  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passFocus = FocusNode();
  final _confirmFocus = FocusNode();

  Gender _gender = Gender.male;
  DateTime? _dob;
  String? _dobError;
  bool _agreeTerms = false;
  String? _agreeError;

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  // ---------- Lab 7.4 ----------
  bool _isCheckingEmail = false;
  String? _emailAsyncError;
  Timer? _emailDebounce;
  int _emailCheckId = 0;

  @override
  void initState() {
    super.initState();
    _passCtrl.addListener(() => setState(() {}));
    _emailCtrl.addListener(_onEmailChangedDebounced);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passFocus.dispose();
    _confirmFocus.dispose();
    _emailDebounce?.cancel();
    super.dispose();
  }

  void _onEmailChangedDebounced() {
    _emailDebounce?.cancel();
    final email = _emailCtrl.text.trim();
    if (Validators.validateEmail(email) != null) {
      if (_emailAsyncError != null) {
        setState(() => _emailAsyncError = null);
      }
      return;
    }
    _emailDebounce = Timer(const Duration(milliseconds: 600), () async {
      final checkId = ++_emailCheckId;
      setState(() {
        _isCheckingEmail = true;
        _emailAsyncError = null;
      });
      final taken = await Validators.isEmailTaken(email);
      if (!mounted || checkId != _emailCheckId) return;
      setState(() {
        _isCheckingEmail = false;
        _emailAsyncError =
            taken ? 'Email này đã được sử dụng, hãy dùng email khác' : null;
      });
    });
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> _pickDob() async {
    FocusScope.of(context).unfocus();
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dob ?? DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Chọn ngày sinh',
      cancelText: 'Hủy',
      confirmText: 'Chọn',
    );
    if (picked != null) {
      setState(() {
        _dob = picked;
        _dobError = Validators.validateDob(picked);
      });
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() {
      _dobError = Validators.validateDob(_dob);
      _agreeError =
          _agreeTerms ? null : 'Bạn phải đồng ý với điều khoản sử dụng';
    });
    final formValid = _formKey.currentState?.validate() ?? false;
    if (!formValid || _dobError != null || !_agreeTerms) {
      _focusFirstInvalidField();
      return;
    }
    final email = _emailCtrl.text.trim();
    setState(() {
      _isSubmitting = true;
      _isCheckingEmail = true;
    });
    final taken = await Validators.isEmailTaken(email);
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _isCheckingEmail = false;
      _emailAsyncError =
          taken ? 'Email này đã được sử dụng, hãy dùng email khác' : null;
    });
    if (taken) {
      _formKey.currentState?.validate();
      _emailFocus.requestFocus();
      return;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đăng ký thành công!')),
    );
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SuccessScreen(
          fullName: _nameCtrl.text.trim(),
          email: email,
          phone: _phoneCtrl.text.trim(),
        ),
      ),
    );
  }

  void _focusFirstInvalidField() {
    if (Validators.validateFullName(_nameCtrl.text) != null) {
      _nameFocus.requestFocus();
    } else if (Validators.validateEmail(_emailCtrl.text) != null ||
        _emailAsyncError != null) {
      _emailFocus.requestFocus();
    } else if (Validators.validatePhone(_phoneCtrl.text) != null) {
      _phoneFocus.requestFocus();
    } else if (Validators.validatePassword(_passCtrl.text) != null) {
      _passFocus.requestFocus();
    } else if (Validators.validateConfirmPassword(
            _confirmCtrl.text, _passCtrl.text) !=
        null) {
      _confirmFocus.requestFocus();
    }
  }

  void _resetForm() {
    _formKey.currentState?.reset();
    _nameCtrl.clear();
    _emailCtrl.clear();
    _phoneCtrl.clear();
    _passCtrl.clear();
    _confirmCtrl.clear();
    setState(() {
      _dob = null;
      _dobError = null;
      _gender = Gender.male;
      _agreeTerms = false;
      _agreeError = null;
      _emailAsyncError = null;
    });
    FocusScope.of(context).unfocus();
  }

  // ---------- Style ui-sample-3: field nền xám, bo 12, icon mờ ----------
  InputDecoration _noraField({
    required String hint,
    required IconData icon,
    Widget? suffix,
    String? helper,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 13, color: NoraTheme.inkFaint),
      prefixIcon: Icon(icon, size: 17, color: NoraTheme.inkFaint),
      suffixIcon: suffix,
      filled: true,
      fillColor: NoraTheme.fieldBg,
      helperText: helper,
      helperStyle: const TextStyle(fontSize: 11, color: NoraTheme.inkSoft),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: NoraTheme.primary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: NoraTheme.danger, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: NoraTheme.danger, width: 1.5),
      ),
    );
  }

  Widget _lbl(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: NoraTheme.inkSoft,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nền gradient xanh giống .auth-wrap trong ui-sample-3
      body: Container(
        decoration: const BoxDecoration(gradient: NoraTheme.authGradient),
        child: SafeArea(
          bottom: false,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: SingleChildScrollView(
              keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
              child: Column(
                children: [
                  // ---- Auth mark: logo kính + Nora + slogan ----
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 28, 24, 22),
                    child: Column(
                      children: [
                        Container(
                          width: 84,
                          height: 84,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.14),
                            borderRadius: BorderRadius.circular(26),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.22),
                                blurRadius: 40,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Nora',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -1,
                          ),
                        ),
                        const Text(
                          'Tài chính thông minh',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.white70,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'SV: ${StudentInfo.displayName}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.white60,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ---- Auth sheet trắng bo 30px ----
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 26, 24, 30),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const Text(
                            'Tạo tài khoản',
                            style: TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.6,
                              color: NoraTheme.ink,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Đăng ký để tiếp tục hành trình',
                            style: TextStyle(
                              fontSize: 12.5,
                              color: NoraTheme.inkSoft,
                            ),
                          ),
                          const SizedBox(height: 20),

                          _lbl('Họ và tên *'),
                          TextFormField(
                            controller: _nameCtrl,
                            focusNode: _nameFocus,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.name],
                            decoration: _noraField(
                              hint: 'VD: Đặng Nhật Huy',
                              icon: Icons.person_outline,
                            ),
                            validator: Validators.validateFullName,
                            onFieldSubmitted: (_) =>
                                _emailFocus.requestFocus(),
                          ),
                          const SizedBox(height: 15),

                          _lbl('Email *'),
                          TextFormField(
                            controller: _emailCtrl,
                            focusNode: _emailFocus,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.emailAddress,
                            autofillHints: const [AutofillHints.email],
                            decoration: _noraField(
                              hint: 'VD: huy@example.com',
                              icon: Icons.mail_outline,
                              helper:
                                  'Thử admin@gmail.com để thấy email đã tồn tại (Lab 7.4)',
                              suffix: _isCheckingEmail
                                  ? const Padding(
                                      padding: EdgeInsets.all(12),
                                      child: SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2),
                                      ),
                                    )
                                  : (_emailAsyncError == null &&
                                          Validators.validateEmail(
                                                  _emailCtrl.text) ==
                                              null &&
                                          _emailCtrl.text.isNotEmpty)
                                      ? const Icon(Icons.check_circle,
                                          color: NoraTheme.success, size: 20)
                                      : null,
                            ),
                            validator: (v) =>
                                Validators.validateEmail(v) ??
                                _emailAsyncError,
                            onFieldSubmitted: (_) =>
                                _phoneFocus.requestFocus(),
                          ),
                          const SizedBox(height: 15),

                          _lbl('Số điện thoại *'),
                          TextFormField(
                            controller: _phoneCtrl,
                            focusNode: _phoneFocus,
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.phone,
                            autofillHints: const [
                              AutofillHints.telephoneNumber
                            ],
                            decoration: _noraField(
                              hint: 'VD: 0912345678',
                              icon: Icons.phone_outlined,
                            ),
                            validator: Validators.validatePhone,
                            onFieldSubmitted: (_) =>
                                _passFocus.requestFocus(),
                          ),
                          const SizedBox(height: 15),

                          _lbl('Mật khẩu *'),
                          TextFormField(
                            controller: _passCtrl,
                            focusNode: _passFocus,
                            textInputAction: TextInputAction.next,
                            obscureText: _obscurePass,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: _noraField(
                              hint: '≥8 ký tự, Hoa + thường + số + @#...',
                              icon: Icons.lock_outline,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscurePass
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 19,
                                  color: NoraTheme.inkFaint,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePass = !_obscurePass),
                              ),
                            ),
                            validator: Validators.validatePassword,
                            onFieldSubmitted: (_) =>
                                _confirmFocus.requestFocus(),
                          ),
                          const SizedBox(height: 8),
                          PasswordStrengthMeter(password: _passCtrl.text),
                          const SizedBox(height: 15),

                          _lbl('Xác nhận mật khẩu *'),
                          TextFormField(
                            controller: _confirmCtrl,
                            focusNode: _confirmFocus,
                            textInputAction: TextInputAction.done,
                            obscureText: _obscureConfirm,
                            autofillHints: const [AutofillHints.newPassword],
                            decoration: _noraField(
                              hint: 'Nhập lại mật khẩu',
                              icon: Icons.lock_reset,
                              suffix: IconButton(
                                icon: Icon(
                                  _obscureConfirm
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 19,
                                  color: NoraTheme.inkFaint,
                                ),
                                onPressed: () => setState(() =>
                                    _obscureConfirm = !_obscureConfirm),
                              ),
                            ),
                            validator: (v) =>
                                Validators.validateConfirmPassword(
                                    v, _passCtrl.text),
                            onFieldSubmitted: (_) =>
                                FocusScope.of(context).unfocus(),
                          ),
                          const SizedBox(height: 15),

                          _lbl('Ngày sinh *'),
                          InkWell(
                            onTap: _pickDob,
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 13),
                              decoration: BoxDecoration(
                                color: NoraTheme.fieldBg,
                                borderRadius: BorderRadius.circular(12),
                                border: _dobError != null
                                    ? Border.all(
                                        color: NoraTheme.danger, width: 1)
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cake_outlined,
                                      size: 17,
                                      color: NoraTheme.inkFaint),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      _dob == null
                                          ? 'Chọn ngày sinh'
                                          : _formatDate(_dob!),
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: _dob == null
                                            ? NoraTheme.inkFaint
                                            : NoraTheme.ink,
                                      ),
                                    ),
                                  ),
                                  const Icon(Icons.calendar_month,
                                      size: 19,
                                      color: NoraTheme.inkFaint),
                                ],
                              ),
                            ),
                          ),
                          if (_dobError != null)
                            Padding(
                              padding:
                                  const EdgeInsets.only(top: 6, left: 12),
                              child: Text(
                                _dobError!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: NoraTheme.danger),
                              ),
                            ),
                          const SizedBox(height: 15),

                          _lbl('Giới tính'),
                          SegmentedButton<Gender>(
                            segments: const [
                              ButtonSegment(
                                  value: Gender.male,
                                  label: Text('Nam'),
                                  icon: Icon(Icons.male, size: 16)),
                              ButtonSegment(
                                  value: Gender.female,
                                  label: Text('Nữ'),
                                  icon: Icon(Icons.female, size: 16)),
                              ButtonSegment(
                                  value: Gender.other,
                                  label: Text('Khác'),
                                  icon:
                                      Icon(Icons.transgender, size: 16)),
                            ],
                            selected: {_gender},
                            showSelectedIcon: false,
                            style: SegmentedButton.styleFrom(
                              selectedBackgroundColor:
                                  NoraTheme.primarySoft,
                              selectedForegroundColor: NoraTheme.primary,
                            ),
                            onSelectionChanged: (s) =>
                                setState(() => _gender = s.first),
                          ),
                          const SizedBox(height: 10),

                          Material(
                            color: Colors.transparent,
                            child: CheckboxListTile(
                              value: _agreeTerms,
                              contentPadding: EdgeInsets.zero,
                              controlAffinity:
                                  ListTileControlAffinity.leading,
                              activeColor: NoraTheme.primary,
                              title: const Text(
                                'Tôi đồng ý với điều khoản sử dụng *',
                                style: TextStyle(fontSize: 13.5),
                              ),
                              subtitle: _agreeError != null
                                  ? Text(_agreeError!,
                                      style: const TextStyle(
                                          color: NoraTheme.danger,
                                          fontSize: 12))
                                  : null,
                              onChanged: (v) => setState(() {
                                _agreeTerms = v ?? false;
                                _agreeError = _agreeTerms
                                    ? null
                                    : 'Bạn phải đồng ý với điều khoản sử dụng';
                              }),
                            ),
                          ),
                          const SizedBox(height: 6),

                          // Nút Đăng ký kiểu .btn-p
                          SizedBox(
                            height: 52,
                            child: FilledButton.icon(
                              onPressed:
                                  _isSubmitting ? null : _submit,
                              icon: _isSubmitting
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Icon(
                                      Icons.arrow_upward_rounded,
                                      size: 18),
                              label: Text(
                                _isSubmitting
                                    ? 'Đang xử lý...'
                                    : 'Đăng ký',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: NoraTheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                shadowColor: NoraTheme.primary
                                    .withValues(alpha: 0.35),
                                elevation: 8,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 50,
                            child: OutlinedButton.icon(
                              onPressed:
                                  _isSubmitting ? null : _resetForm,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Nhập lại',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w800)),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: const BorderSide(
                                    color: NoraTheme.border, width: 1.5),
                              ),
                            ),
                          ),

                          // Divider + Google (giống mẫu login)
                          const SizedBox(height: 16),
                          const Row(
                            children: [
                              Expanded(child: Divider()),
                              Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: 12),
                                child: Text('HOẶC',
                                    style: TextStyle(
                                        fontSize: 11,
                                        color: NoraTheme.inkFaint,
                                        fontWeight: FontWeight.w700)),
                              ),
                              Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 50,
                            child: OutlinedButton(
                              onPressed: () {},
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                side: const BorderSide(
                                    color: NoraTheme.border, width: 1.5),
                              ),
                              child: const Text('Tiếp tục với Google',
                                  style: TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w800,
                                      color: NoraTheme.ink)),
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Đã có tài khoản? ',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: NoraTheme.inkSoft)),
                              Text('Đăng nhập',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w900,
                                      color: NoraTheme.primary)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Center(
                            child: Text(
                              '${StudentInfo.labName}\nSV: ${StudentInfo.displayName}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: NoraTheme.inkFaint),
                            ),
                          ),
                        ],
                      ),
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
