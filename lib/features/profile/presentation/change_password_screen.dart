import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/components/tw_snackbar.dart';
import '../../../core/components/tw_button.dart';
import '../../../core/components/tw_text_field.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    
    try {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _newPasswordController.text),
      );
      
      if (!mounted) return;
      TWSnackbar.showSuccess(context, 'Password updated successfully!');
      Navigator.pop(context);
    } on AuthException catch (e) {
      TWSnackbar.showError(context, e.message);
    } catch (e) {
      TWSnackbar.showError(context, 'Failed to update password');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.paper),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Change Password',
          style: AppTypography.heading3.copyWith(color: AppColors.paper),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Your new password must be at least 6 characters long.',
                  style: AppTypography.bodyMedium.copyWith(color: AppColors.muted),
                ),
                const SizedBox(height: 32),
                TWTextField(
                  label: 'New Password',
                  hintText: 'Enter new password',
                  controller: _newPasswordController,
                  obscureText: true,
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TWTextField(
                  label: 'Confirm New Password',
                  hintText: 'Re-enter new password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (val) {
                    if (val != _newPasswordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const Spacer(),
                TWButton(
                  label: 'Update Password',
                  onPressed: _isLoading ? null : _updatePassword,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
