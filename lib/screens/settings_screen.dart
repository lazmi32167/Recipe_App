import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/account_service.dart';
import '../services/theme_controller.dart';
import 'change_password_screen.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final accountService = AccountService();
  bool isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final themeController = ThemeScope.of(context);
    final user = FirebaseAuth.instance.currentUser;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          const _SectionHeading(title: 'APPEARANCE'),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            title: 'Dark Mode',
            subtitle: _themeLabel(themeController.mode),
            trailing: Switch(
              value: themeController.mode == ThemeMode.dark,
              onChanged: (enabled) => themeController.setMode(
                enabled ? ThemeMode.dark : ThemeMode.light,
              ),
            ),
          ),
          _SettingsTile(
            icon: Icons.brightness_6_outlined,
            title: 'Theme Preference',
            subtitle: 'Choose how the app follows your device',
            onTap: () => _chooseTheme(context, themeController),
          ),
          const SizedBox(height: 24),
          const _SectionHeading(title: 'ACCOUNT'),
          _SettingsTile(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            subtitle: user?.displayName?.isNotEmpty == true
                ? user!.displayName!
                : 'Update your full name',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfileScreen()),
            ),
          ),
          _SettingsTile(
            icon: Icons.lock_outline,
            title: 'Change Password',
            subtitle: 'Update your account password securely',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          const SizedBox(height: 24),
          const _SectionHeading(title: 'SESSION'),
          _SettingsTile(
            icon: Icons.logout,
            title: 'Logout',
            subtitle: 'Sign out of this account',
            onTap: () => _confirmLogout(context),
          ),
          _SettingsTile(
            icon: Icons.delete_outline,
            title: 'Delete Account',
            subtitle: 'Permanently remove your account and data',
            color: colorScheme.error,
            onTap: isDeleting ? null : () => _confirmDeleteAccount(context),
            trailing: isDeleting
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : null,
          ),
          const SizedBox(height: 24),
          const _SectionHeading(title: 'ABOUT'),
          const _SettingsTile(
            icon: Icons.restaurant_menu,
            title: 'Recipe App',
            subtitle: 'Version 1.0.0',
          ),
          const _SettingsTile(
            icon: Icons.info_outline,
            title: 'About',
            subtitle: 'Discover, save, and share recipes in one place.',
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light mode';
      case ThemeMode.dark:
        return 'Dark mode';
      case ThemeMode.system:
        return 'System default';
    }
  }

  Future<void> _chooseTheme(
    BuildContext context,
    ThemeModeController controller,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text(
                'Theme Preference',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: DropdownButtonFormField<ThemeMode>(
                initialValue: controller.mode,
                decoration: const InputDecoration(labelText: 'Theme'),
                items: ThemeMode.values
                    .map(
                      (option) => DropdownMenuItem<ThemeMode>(
                        value: option,
                        child: Text(_themeLabel(option)),
                      ),
                    )
                    .toList(),
                onChanged: (mode) async {
                  if (mode == null) return;
                  await controller.setMode(mode);
                  if (sheetContext.mounted) Navigator.pop(sheetContext);
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (error) {
      if (mounted) _showMessage(error.message ?? 'Unable to logout.');
    } catch (_) {
      if (mounted) _showMessage('Unable to logout. Please try again.');
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final passwordController = TextEditingController();
    final password = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete Account?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This permanently deletes your profile, saved recipes, favorites, and recipes you created. This action cannot easily be undone.',
            ),
            const SizedBox(height: 16),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Enter your password to continue',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, passwordController.text),
            child: const Text('Delete Account'),
          ),
        ],
      ),
    );
    passwordController.dispose();
    if (password == null || password.isEmpty || !mounted) return;

    setState(() {
      isDeleting = true;
    });
    try {
      await accountService.deleteAccount(password: password);
    } on FirebaseAuthException catch (error) {
      if (mounted) _showMessage(_deleteErrorMessage(error));
    } catch (_) {
      if (mounted) {
        _showMessage('Unable to delete your account. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isDeleting = false;
        });
      }
    }
  }

  String _deleteErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'The password is incorrect.';
      case 'requires-recent-login':
        return 'Please sign in again before deleting your account.';
      case 'network-request-failed':
        return 'Network error. Check your connection and try again.';
      default:
        return error.message ?? 'Unable to delete your account.';
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;

  const _SectionHeading({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 13,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? color;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final foregroundColor = color ?? Theme.of(context).colorScheme.onSurface;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        enabled: onTap != null || trailing != null,
        onTap: onTap,
        leading: Icon(
          icon,
          color: color ?? Theme.of(context).colorScheme.primary,
        ),
        title: Text(title, style: TextStyle(color: foregroundColor)),
        subtitle: Text(subtitle),
        trailing: trailing ?? const Icon(Icons.chevron_right),
      ),
    );
  }
}
