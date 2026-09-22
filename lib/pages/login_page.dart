import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:time_capsule/providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const Color _background = Color(0xFF0B0B1E);
  static const Color _surface = Color(0xFF15152B);
  static const Color _surfaceLight = Color(0xFF1D1D38);
  static const Color _purple = Color(0xFF651FFF);
  static const Color _purpleLight = Color(0xFF9D7CFF);
  static const Color _textPrimary = Colors.white;
  static const Color _textSecondary = Color(0xFFA8A7C0);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authService = ref.read(authServiceProvider);

      await authService.signIn(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _parseError(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _parseError(String error) {
    if (error.contains('Invalid login credentials') ||
        error.contains('invalid_credentials')) {
      return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
    }

    if (error.contains('Email not confirmed')) {
      return 'กรุณายืนยันอีเมลก่อนเข้าสู่ระบบ';
    }

    if (error.contains('network') || error.contains('SocketException')) {
      return 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต';
    }

    if (error.contains('too_many_requests') || error.contains('rate limit')) {
      return 'ลองใหม่อีกครั้งในอีกสักครู่';
    }

    return 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: SafeArea(
        child: Stack(
          children: [
            // Decorative glow
            Positioned(
              top: -120,
              right: -80,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _purple.withValues(alpha: 0.12),
                ),
              ),
            ),

            Positioned(
              bottom: -140,
              left: -100,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _purpleLight.withValues(alpha: 0.06),
                ),
              ),
            ),

            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo
                      Center(
                        child: Container(
                          width: 82,
                          height: 82,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [_purple, _purpleLight],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _purple.withValues(alpha: 0.3),
                                blurRadius: 28,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.hourglass_bottom_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      const Text(
                        'ยินดีต้อนรับกลับ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _textPrimary,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        'เข้าสู่ระบบเพื่อดู Time Capsule ของคุณ',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _textSecondary, fontSize: 14),
                      ),

                      const SizedBox(height: 36),

                      // Login card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'เข้าสู่ระบบ',
                              style: TextStyle(
                                color: _textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            const SizedBox(height: 20),

                            // Email
                            const Text(
                              'อีเมล',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              autocorrect: false,
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'example@email.com',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF666680),
                                ),
                                prefixIcon: const Icon(
                                  Icons.email_outlined,
                                  color: _textSecondary,
                                ),
                                filled: true,
                                fillColor: _surfaceLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  borderSide: BorderSide(
                                    color: _purple,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'กรุณากรอกอีเมล';
                                }

                                if (!v.contains('@') || !v.contains('.')) {
                                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                                }

                                return null;
                              },
                            ),

                            const SizedBox(height: 18),

                            // Password
                            const Text(
                              'รหัสผ่าน',
                              style: TextStyle(
                                color: _textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 8),

                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _login(),
                              style: const TextStyle(
                                color: _textPrimary,
                                fontSize: 15,
                              ),
                              decoration: InputDecoration(
                                hintText: 'กรอกรหัสผ่าน',
                                hintStyle: const TextStyle(
                                  color: Color(0xFF666680),
                                ),
                                prefixIcon: const Icon(
                                  Icons.lock_outline,
                                  color: _textSecondary,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    color: _textSecondary,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () =>
                                          _obscurePassword = !_obscurePassword,
                                    );
                                  },
                                ),
                                filled: true,
                                fillColor: _surfaceLight,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide.none,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: BorderSide(
                                    color: Colors.white.withValues(alpha: 0.05),
                                  ),
                                ),
                                focusedBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  borderSide: BorderSide(
                                    color: _purple,
                                    width: 1.5,
                                  ),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                  ),
                                ),
                                focusedErrorBorder: const OutlineInputBorder(
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(14),
                                  ),
                                  borderSide: BorderSide(
                                    color: Colors.redAccent,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'กรุณากรอกรหัสผ่าน';
                                }

                                return null;
                              },
                            ),

                            // Error
                            if (_errorMessage != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(
                                    alpha: 0.08,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: Colors.redAccent.withValues(
                                      alpha: 0.25,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.error_outline_rounded,
                                      color: Colors.redAccent,
                                      size: 19,
                                    ),
                                    const SizedBox(width: 9),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: const TextStyle(
                                          color: Color(0xFFFF8A8A),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],

                            const SizedBox(height: 24),

                            // Login button
                            SizedBox(
                              height: 54,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _purple,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: _purple.withValues(
                                    alpha: 0.45,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  elevation: 0,
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'เข้าสู่ระบบ',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Register
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'ยังไม่มีบัญชี? ',
                            style: TextStyle(
                              color: _textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          TextButton(
                            onPressed: () => context.push('/register'),
                            style: TextButton.styleFrom(
                              foregroundColor: _purpleLight,
                            ),
                            child: const Text(
                              'สมัครสมาชิก',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
