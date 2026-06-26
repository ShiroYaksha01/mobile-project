import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/gold_button.dart';
import '../../core/widgets/loading_overlay.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthBloc>().add(
            AuthLoginRequested(
              _emailController.text.trim(),
              _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is AuthAuthenticated) {
          // If login is successful, router will automatically redirect to home,
          // but we can explicitly go there.
          context.go('/home');
        }
      },
      builder: (context, state) {
        return LoadingOverlay(
          isLoading: state is AuthLoading,
          child: Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 60),
                      // Festive / Branding header
                      Center(
                        child: Icon(
                          Icons.spa_rounded, // Placeholder for an elegant icon
                          size: 80,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: AppColors.primary,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to explore authentic Cambodian crafts.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 48),

                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty || !value.contains('@')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          prefixIcon: Icon(Icons.lock_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Login Button
                      GoldButton(
                        text: 'Sign In',
                        onPressed: _onLoginPressed,
                      ),
                      
                      const SizedBox(height: 24),

                      // Register Navigation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          TextButton(
                            onPressed: () {
                              context.push('/register');
                            },
                            child: Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}