import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/phka_chan_painter.dart';

class SignInScreen extends StatefulWidget {
  final VoidCallback onSignIn;
  const SignInScreen({super.key, required this.onSignIn});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HColors.background,
      body: Stack(children: [
        Positioned.fill(child: CustomPaint(painter: PhkaChanPainter(opacity: 0.04))),
        Positioned(top: -60, right: -60,
            child: Container(width: 220, height: 220,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      HColors.primaryContainer.withValues(alpha: 0.35), Colors.transparent])))),
        Positioned(bottom: -40, left: -40,
            child: Container(width: 180, height: 180,
                decoration: BoxDecoration(shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      HColors.secondaryContainer.withValues(alpha: 0.2), Colors.transparent])))),
        SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              const SizedBox(height: 60),
              Center(
                  child: Container(
                      width: 72, height: 72,
                      decoration: BoxDecoration(
                          color: HColors.primary, borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: HColors.primary.withValues(alpha: 0.3),
                              blurRadius: 20, offset: const Offset(0, 8))]),
                      child: const Icon(Icons.spa, color: Colors.white, size: 36))),
              const SizedBox(height: 20),
              Center(child: Text('Crafted in Cambodia',
                  style: HText.headlineLg.copyWith(color: HColors.primary))),
              const SizedBox(height: 6),
              Center(child: Text('Heritage Festive Access',
                  style: HText.bodyMd.copyWith(color: HColors.onSurfaceVariant))),
              const SizedBox(height: 48),

              Text('EMAIL ADDRESS',
                  style: HText.labelSm.copyWith(color: HColors.primary, letterSpacing: 1)),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                      hintText: 'your@email.com',
                      prefixIcon: Icon(Icons.mail_outline, color: HColors.onSurfaceVariant, size: 20))),
              const SizedBox(height: 20),

              Text('PASSWORD',
                  style: HText.labelSm.copyWith(color: HColors.primary, letterSpacing: 1)),
              const SizedBox(height: 8),
              TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                      hintText: '••••••••',
                      prefixIcon: const Icon(Icons.lock_outline, color: HColors.onSurfaceVariant, size: 20),
                      suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscure = !_obscure),
                          child: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                              color: HColors.onSurfaceVariant, size: 20)))),
              const SizedBox(height: 10),
              Align(alignment: Alignment.centerRight,
                  child: Text('Forgot password?',
                      style: HText.labelSm.copyWith(color: HColors.secondary))),
              const SizedBox(height: 28),

              ElevatedButton(
                  onPressed: widget.onSignIn,
                  child: Text('SIGN IN TO HERITAGE',
                      style: HText.labelLg.copyWith(color: Colors.white))),
              const SizedBox(height: 16),

              Row(children: [
                const Expanded(child: Divider(color: HColors.outlineVariant)),
                Padding(padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text('or', style: HText.bodyMd.copyWith(color: HColors.onSurfaceVariant))),
                const Expanded(child: Divider(color: HColors.outlineVariant)),
              ]),
              const SizedBox(height: 16),

              OutlinedButton.icon(
                  onPressed: widget.onSignIn,
                  style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      side: const BorderSide(color: HColors.outlineVariant),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  icon: const Icon(Icons.g_mobiledata, color: HColors.onSurfaceVariant),
                  label: Text('Continue with Google',
                      style: HText.labelLg.copyWith(color: HColors.onSurface))),
              const SizedBox(height: 32),

              Center(child: RichText(text: TextSpan(
                  text: 'New to Heritage? ',
                  style: HText.bodyMd.copyWith(color: HColors.onSurfaceVariant),
                  children: [TextSpan(
                      text: 'Create Account',
                      style: HText.bodyMd.copyWith(color: HColors.secondary,
                          fontWeight: FontWeight.w600, decoration: TextDecoration.underline),
                      recognizer: TapGestureRecognizer()..onTap = () {
                        Navigator.pushNamed(context, '/register');
                      })]))),
              const SizedBox(height: 32),
            ]),
          ),
        ),
      ]),
    );
  }
}