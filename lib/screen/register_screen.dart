import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/register_provider.dart';
import '../utility/app_colors.dart';

class RegisterScreen extends ConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final form = ref.watch(registerFormProvider);
    final notifier = ref.read(registerFormProvider.notifier);

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
          'Đăng ký Grand Hotel ngay',
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
              _buildPerksCard(),
              const SizedBox(height: 16),
              _buildProfileDetailsCard(notifier),
              const SizedBox(height: 16),
              _PasswordField(
                label: 'Mật khẩu',
                hint: 'Tạo mật khẩu',
                obscure: !form.passwordVisible,
                onToggle: notifier.togglePasswordVisible,
                onChanged: notifier.setPassword,
                isError: form.password.isNotEmpty && !form.isPasswordValid,
              ),
              const SizedBox(height: 12),
              _PasswordRules(
                lengthOk: form.isLengthValid,
                upperOk: form.hasUpper,
                lowerOk: form.hasLower,
                numberOrSpecialOk: form.hasNumOrSpecial,
              ),
              const SizedBox(height: 16),
              _PasswordField(
                label: 'Xác nhận mật khẩu',
                hint: 'Nhập lại mật khẩu',
                obscure: !form.confirmPasswordVisible,
                onToggle: notifier.toggleConfirmPasswordVisible,
                onChanged: notifier.setConfirmPassword,
                isError: form.confirmPassword.isNotEmpty && !form.isConfirmMatch,
                helperErrorText: form.confirmPassword.isNotEmpty && !form.isConfirmMatch
                    ? 'Mật khẩu xác nhận không trùng'
                    : null,
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
              _TermsText(),
              const SizedBox(height: 16),
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
                    form.isSubmitting ? 'Đang xử lý...' : 'Tham gia miễn phí',
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    const Text('Đã có tài khoản? ', style: TextStyle(color: AppColors.textSecondary)),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/login');
                      },
                      child: const Text('Đăng nhập', style: TextStyle(color: AppColors.primary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPerksCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Nhận quyền lợi khi bạn tham gia:',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 12),
          _PerkRow(icon: Icons.attach_money, text: 'Giá tốt nhất'),
          SizedBox(height: 8),
          _PerkRow(icon: Icons.card_giftcard, text: 'Dùng điểm đổi kỳ nghỉ và nhiều hơn'),
          SizedBox(height: 8),
          _PerkRow(icon: Icons.check_circle_outline, text: 'Chọn phòng với Check-in Số'),
          SizedBox(height: 8),
          _PerkRow(icon: Icons.vpn_key, text: 'Dùng app như là Chìa khóa Số'),
        ],
      ),
    );
  }

  Widget _buildProfileDetailsCard(RegisterFormNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border:  Border.all(color: Colors.white),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin hồ sơ',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tất cả các trường là bắt buộc trừ khi ghi chú tùy chọn.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _TextField(
            label: 'Họ và tên',
            hint: 'Nhập họ và tên đầy đủ',
            onChanged: notifier.setName,
          ),
          const SizedBox(height: 16),
          _TextField(
            label: 'Email',
            hint: 'Nhập email',
            keyboardType: TextInputType.emailAddress,
            onChanged: notifier.setEmail,
          ),
          const SizedBox(height: 16),
          _TextField(
            label: 'Số điện thoại',
            hint: 'Nhập số điện thoại',
            keyboardType: TextInputType.phone,
            onChanged: notifier.setPhoneNumber,
          ),
          const SizedBox(height: 16),
          _TextField(
            label: 'Địa chỉ',
            hint: 'Nhập địa chỉ',
            onChanged: notifier.setAddress,
          ),
          const SizedBox(height: 16),
          _GenderField(
            onChanged: notifier.setGender,
          ),
          const SizedBox(height: 16),
          _DateField(
            label: 'Ngày sinh',
            hint: 'Chọn ngày sinh',
            onChanged: notifier.setDob,
          ),
        ],
      ),
    );
  }
}

class _PerkRow extends StatelessWidget {
  final IconData icon;
  final String text;
  const _PerkRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ],
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
  final bool isError;
  final String? helperErrorText;

  const _PasswordField({
    required this.label,
    required this.hint,
    required this.obscure,
    required this.onToggle,
    required this.onChanged,
    this.isError = false,
    this.helperErrorText,
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
                color: isError ? AppColors.error : AppColors.textSecondary.withOpacity(0.25),
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: isError ? AppColors.error : AppColors.primary.withOpacity(0.8),
                width: 1.0,
              ),
            ),
            errorText: helperErrorText,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _PasswordRules extends StatelessWidget {
  final bool lengthOk;
  final bool upperOk;
  final bool lowerOk;
  final bool numberOrSpecialOk;
  const _PasswordRules({
    required this.lengthOk,
    required this.upperOk,
    required this.lowerOk,
    required this.numberOrSpecialOk,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rule('Từ 8 đến 32 ký tự', lengthOk),
        _rule('Có ít nhất 1 chữ hoa', upperOk),
        _rule('Có ít nhất 1 chữ thường', lowerOk),
        _rule('Có ít nhất 1 số (0–9) hoặc ký tự đặc biệt', numberOrSpecialOk),
      ],
    );
  }

  Widget _rule(String text, bool checked) {
    return Row(
      children: [
        Icon(
          checked ? Icons.check_circle : Icons.radio_button_unchecked,
          color: checked ? AppColors.success : AppColors.textSecondary,
          size: 18,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _TermsText extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Text(
      'Bằng cách bấm Tham gia miễn phí, bạn đồng ý với các điều khoản chương trình và chính sách quyền riêng tư. Bạn có thể hủy nhận ưu đãi qua email bất cứ lúc nào trong hồ sơ.',
      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
    );
  }
}

class _GenderField extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const _GenderField({required this.onChanged});

  @override
  State<_GenderField> createState() => _GenderFieldState();
}

class _GenderFieldState extends State<_GenderField> {
  String? selectedGender;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Giới tính',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.iconUnselected, width: 1.0),
          ),
          child: DropdownButtonFormField<String>(
            value: selectedGender,
            decoration: const InputDecoration(
              hintText: 'Chọn giới tính',
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              border: InputBorder.none,
            ),
            items: const [
              DropdownMenuItem(value: 'Nam', child: Text('Nam')),
              DropdownMenuItem(value: 'Nữ', child: Text('Nữ')),
              DropdownMenuItem(value: 'Khác', child: Text('Khác')),
            ],
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
              if (value != null) {
                widget.onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatefulWidget {
  final String label;
  final String hint;
  final ValueChanged<DateTime> onChanged;

  const _DateField({
    required this.label,
    required this.hint,
    required this.onChanged,
  });

  @override
  State<_DateField> createState() => _DateFieldState();
}

class _DateFieldState extends State<_DateField> {
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: selectedDate ?? DateTime(2000),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.primary,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppColors.textPrimary,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() {
                selectedDate = date;
              });
              widget.onChanged(date);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.iconUnselected, width: 1.0),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate != null
                      ? '${selectedDate!.day.toString().padLeft(2, '0')}/${selectedDate!.month.toString().padLeft(2, '0')}/${selectedDate!.year}'
                      : widget.hint,
                  style: TextStyle(
                    color: selectedDate != null ? AppColors.textPrimary : AppColors.textSecondary,
                  ),
                ),
                const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}


