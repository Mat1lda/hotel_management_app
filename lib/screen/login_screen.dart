import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/login_provider.dart';
import '../utility/app_colors.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Đăng nhập',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 21),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLoginCard(context, form, notifier),
              const SizedBox(height: 16),
              _buildJoinCard(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginCard(BuildContext context, LoginFormState form, LoginFormNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TextField(
            label: 'Tên đăng nhập hoặc số thẻ thành viên',
            hint: '',
            onChanged: notifier.setUsername,
          ),
          const SizedBox(height: 16),
          _PasswordField(
            label: 'Mật khẩu',
            hint: '',
            obscure: !form.passwordVisible,
            onToggle: notifier.togglePasswordVisible,
            onChanged: notifier.setPassword,
          ),
          const SizedBox(height: 16),
          if (form.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                form.errorMessage!,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: form.isSubmitting ? null : () async {
                final success = await notifier.submit();
                if (context.mounted && success) {
                  Navigator.of(context).pop();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.cardBackground,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Text(
                form.isSubmitting ? 'Đang xử lý...' : 'Đăng nhập',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: TextButton(
              onPressed: () {},
              child: const Text('Quên mật khẩu?', style: TextStyle(color: AppColors.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJoinCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Chưa là thành viên?',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/register');
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: const BorderSide(color: AppColors.primary, width: 1.2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: const Text('Tham gia ngay', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Thông tin của bạn được bảo mật.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final String hint;
  final TextInputType? keyboardType;
  final ValueChanged<String> onChanged;

  const _TextField({
    required this.label,
    required this.hint,
    this.keyboardType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.iconUnselected, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary.withOpacity(0.8), width: 1.0),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final String hint;
  final bool obscure;
  final VoidCallback onToggle;
  final ValueChanged<String> onChanged;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          obscureText: obscure,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.cardBackground,
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            suffixIcon: IconButton(
              icon: Icon(obscure ? Icons.visibility : Icons.visibility_off, color: AppColors.textSecondary),
              onPressed: onToggle,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.textSecondary.withOpacity(0.25),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: AppColors.primary.withOpacity(0.8),
                width: 1.0,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}


