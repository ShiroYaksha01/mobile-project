import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/phka_chan_painter.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback onSignUp;
  const SignUpScreen({super.key, required this.onSignUp});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirmPass = true;
  bool _agreeToTerms = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: PhkaChanPainter(opacity: 0.04)),
          ),
          Positioned(
            top: -60,
            right: -60,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HColors.primaryContainer.withValues(alpha: 0.35),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    HColors.secondaryContainer.withValues(alpha: 0.2),
                    Colors.transparent
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  Center(
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: HColors.primary,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: HColors.primary.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          )
                        ],
                      ),
                      child: const Icon(
                        Icons.spa,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Text(
                      'Crafted in Cambodia',
                      style: HText.headlineLg.copyWith(color: HColors.primary),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Begin Your Heritage Journey',
                      style: HText.bodyMd.copyWith(
                        color: HColors.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Full Name Field
                  Text(
                    'FULL NAME',
                    style: HText.labelSm.copyWith(
                      color: HColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameCtrl,
                    keyboardType: TextInputType.name,
                    decoration: const InputDecoration(
                      hintText: 'Your full name',
                      prefixIcon: Icon(
                        Icons.person_outline,
                        color: HColors.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Field
                  Text(
                    'EMAIL ADDRESS',
                    style: HText.labelSm.copyWith(
                      color: HColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'your@email.com',
                      prefixIcon: Icon(
                        Icons.mail_outline,
                        color: HColors.onSurfaceVariant,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Field
                  Text(
                    'PASSWORD',
                    style: HText.labelSm.copyWith(
                      color: HColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passCtrl,
                    obscureText: _obscurePass,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: HColors.onSurfaceVariant,
                        size: 20,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(() => _obscurePass = !_obscurePass),
                        child: Icon(
                          _obscurePass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: HColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Confirm Password Field
                  Text(
                    'CONFIRM PASSWORD',
                    style: HText.labelSm.copyWith(
                      color: HColors.primary,
                      letterSpacing: 1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _confirmPassCtrl,
                    obscureText: _obscureConfirmPass,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(
                        Icons.lock_outline,
                        color: HColors.onSurfaceVariant,
                        size: 20,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () =>
                            setState(() => _obscureConfirmPass = !_obscureConfirmPass),
                        child: Icon(
                          _obscureConfirmPass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: HColors.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Terms & Conditions
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreeToTerms,
                          onChanged: (value) {
                            setState(() => _agreeToTerms = value ?? false);
                          },
                          activeColor: HColors.primary,
                          side: const BorderSide(
                            color: HColors.outlineVariant,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            text: 'I agree to the ',
                            style: HText.bodyMd.copyWith(
                              color: HColors.onSurfaceVariant,
                            ),
                            children: [
                              TextSpan(
                                text: 'Terms of Service',
                                style: HText.bodyMd.copyWith(
                                  color: HColors.secondary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: HText.bodyMd.copyWith(
                                  color: HColors.secondary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // Sign Up Button
                  ElevatedButton(
                    onPressed: _agreeToTerms ? widget.onSignUp : null,
                    child: Text(
                      'CREATE ACCOUNT',
                      style: HText.labelLg.copyWith(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Divider
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(color: HColors.outlineVariant),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'or',
                          style: HText.bodyMd.copyWith(
                            color: HColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      const Expanded(
                        child: Divider(color: HColors.outlineVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Google Sign Up Button
                  OutlinedButton.icon(
                    onPressed: widget.onSignUp,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: HColors.outlineVariant),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(
                      Icons.g_mobiledata,
                      color: HColors.onSurfaceVariant,
                    ),
                    label: Text(
                      'Sign up with Google',
                      style: HText.labelLg.copyWith(color: HColors.onSurface),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Sign In Link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: 'Already have an account? ',
                        style: HText.bodyMd.copyWith(
                          color: HColors.onSurfaceVariant,
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign In',
                            style: HText.bodyMd.copyWith(
                              color: HColors.secondary,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushNamed(context, '/login');
                              },
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
