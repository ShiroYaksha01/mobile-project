import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;

        return Scaffold(
          backgroundColor: HColors.background,
          appBar: AppBar(
            backgroundColor: HColors.surface,
            title: Text('My Profile',
                style: HText.headlineMd.copyWith(color: HColors.primary)),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: HColors.primary),
              onPressed: () => context.go('/home'),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                // Avatar
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: HColors.primaryContainer.withValues(alpha: 0.2),
                    border: Border.all(color: HColors.primary, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      (user?.name.isNotEmpty == true)
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: HText.headlineLg.copyWith(
                        color: HColors.primary,
                        fontSize: 36,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  user?.name ?? 'Guest',
                  style: HText.headlineMd.copyWith(color: HColors.onSurface),
                ),
                const SizedBox(height: 4),
                Text(
                  user?.email ?? '',
                  style: HText.bodyMd.copyWith(color: HColors.outline),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: HColors.primaryContainer.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user?.role ?? 'Customer',
                    style: HText.labelSm.copyWith(color: HColors.primary),
                  ),
                ),
                const SizedBox(height: 32),

                // Info Cards
                _InfoCard(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: user?.email ?? '—',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.person_outline,
                  label: 'Name',
                  value: user?.name ?? '—',
                ),
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.badge_outlined,
                  label: 'Role',
                  value: user?.role ?? 'Customer',
                ),
                const SizedBox(height: 32),

                // Sign Out Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      context.read<AuthBloc>().add(AuthLogoutRequested());
                      context.go('/login');
                    },
                    icon: const Icon(Icons.logout, color: HColors.error),
                    label: Text(
                      'Sign Out',
                      style: HText.labelLg.copyWith(color: HColors.error),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: HColors.error),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: HColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: HColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Icon(icon, color: HColors.primary, size: 22),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: HText.labelSm.copyWith(color: HColors.outline)),
              const SizedBox(height: 2),
              Text(value,
                  style: HText.bodyLg.copyWith(color: HColors.onSurface)),
            ],
          ),
        ],
      ),
    );
  }
}
