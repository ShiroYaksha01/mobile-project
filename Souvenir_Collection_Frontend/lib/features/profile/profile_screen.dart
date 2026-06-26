import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/auth/auth_event.dart';
import '../../blocs/auth/auth_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/gold_button.dart';
import '../../models/user.dart';
import '../../services/media_service.dart';
import '../../services/user_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isEditing = false;
  bool _isSaving = false;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _addressCtrl;
  String? _avatarUrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
    _addressCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _populateFields(User user) {
    _nameCtrl.text = user.name;
    _phoneCtrl.text = user.phone ?? '';
    _addressCtrl.text = user.address ?? '';
    _avatarUrl = user.avatar;
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 512);
    if (xFile == null) return;

    final bytes = await xFile.readAsBytes();
    if (!mounted) return;

    try {
      final mediaService = context.read<MediaService>();
      final url = await mediaService.uploadMediaBytes(
        bytes,
        'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      setState(() => _avatarUrl = url);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Avatar upload failed: $e')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) return;

      final userService = context.read<UserService>();
      await userService.updateProfile(
        authState.user.id,
        name: _nameCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        address: _addressCtrl.text.trim(),
        avatar: _avatarUrl,
      );

      // Refresh the auth bloc with updated user
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckRequested());
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final user = state is AuthAuthenticated ? state.user : null;
        if (user != null && _nameCtrl.text.isEmpty) _populateFields(user);

        return Scaffold(
          backgroundColor: HColors.background,
          appBar: AppBar(
            backgroundColor: HColors.surface,
            title: Text(
              _isEditing ? 'Edit Profile' : 'My Profile',
              style: HText.headlineMd.copyWith(color: HColors.primary),
            ),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: HColors.primary),
              onPressed: () => context.go('/home'),
            ),
            actions: [
              if (user != null)
                TextButton(
                  onPressed: () {
                    if (_isEditing) {
                      _saveProfile();
                    } else {
                      setState(() => _isEditing = true);
                    }
                  },
                  child: Text(
                    _isEditing ? 'Save' : 'Edit',
                    style: HText.labelLg.copyWith(color: HColors.primary),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Avatar — tappable in edit mode
                  GestureDetector(
                    onTap: _isEditing ? _pickAvatar : null,
                    child: Stack(
                      children: [
                        Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: HColors.primaryContainer.withValues(alpha: 0.2),
                            border: Border.all(color: HColors.primary, width: 2),
                            image: (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                ? DecorationImage(
                                    image: NetworkImage(_avatarUrl!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: (_avatarUrl == null || _avatarUrl!.isEmpty)
                              ? Center(
                                  child: Text(
                                    (user?.name.isNotEmpty == true)
                                        ? user!.name[0].toUpperCase()
                                        : '?',
                                    style: HText.headlineLg.copyWith(
                                      color: HColors.primary,
                                      fontSize: 36,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: HColors.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: HColors.surface, width: 2),
                              ),
                              child: const Icon(
                                Icons.camera_alt,
                                size: 16,
                                color: HColors.surface,
                              ),
                            ),
                          ),
                      ],
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
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

                  if (_isEditing) ...[
                    _buildTextField('Name', _nameCtrl,
                        validator: (v) =>
                            v == null || v.trim().isEmpty ? 'Required' : null),
                    const SizedBox(height: 14),
                    _buildTextField('Phone', _phoneCtrl),
                    const SizedBox(height: 14),
                    _buildTextField('Address', _addressCtrl, maxLines: 2),
                    const SizedBox(height: 24),
                    GoldButton(
                      text: _isSaving ? 'Saving…' : 'Save Changes',
                      onPressed: _isSaving ? null : _saveProfile,
                      isLoading: _isSaving,
                    ),
                  ] else ...[
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
                      icon: Icons.phone_outlined,
                      label: 'Phone',
                      value: user?.phone ?? '—',
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      icon: Icons.location_on_outlined,
                      label: 'Address',
                      value: user?.address ?? '—',
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: HText.bodyMd.copyWith(color: HColors.outline),
        filled: true,
        fillColor: HColors.surfaceContainerLowest,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: HColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: HColors.outlineVariant.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: HColors.primary, width: 2),
        ),
      ),
      style: HText.bodyLg.copyWith(color: HColors.onSurface),
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
        border:
            Border.all(color: HColors.outlineVariant.withValues(alpha: 0.5)),
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
