import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../service/auth_service.dart';
import '../model/request/register_request.dart';

class RegisterFormState {
  final String name;
  final String phoneNumber;
  final String email;
  final String address;
  final String gender;
  final DateTime? dob;
  final String identification;
  final String otpCode;
  final bool otpSent;
  final bool isSendingOtp;
  final String password;
  final String confirmPassword;
  final bool passwordVisible;
  final bool confirmPasswordVisible;
  final bool isSubmitting;
  final String? errorMessage;

  const RegisterFormState({
    this.name = '',
    this.phoneNumber = '',
    this.email = '',
    this.address = '',
    this.gender = '',
    this.dob,
    this.identification = '',
    this.otpCode = '',
    this.otpSent = false,
    this.isSendingOtp = false,
    this.password = '',
    this.confirmPassword = '',
    this.passwordVisible = false,
    this.confirmPasswordVisible = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  RegisterFormState copyWith({
    String? name,
    String? phoneNumber,
    String? email,
    String? address,
    String? gender,
    DateTime? dob,
    String? identification,
    String? otpCode,
    bool? otpSent,
    bool? isSendingOtp,
    String? password,
    String? confirmPassword,
    bool? passwordVisible,
    bool? confirmPasswordVisible,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return RegisterFormState(
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      identification: identification ?? this.identification,
      otpCode: otpCode ?? this.otpCode,
      otpSent: otpSent ?? this.otpSent,
      isSendingOtp: isSendingOtp ?? this.isSendingOtp,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      confirmPasswordVisible: confirmPasswordVisible ?? this.confirmPasswordVisible,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  bool get isLengthValid => password.length >= 8 && password.length <= 32;
  bool get hasUpper => RegExp(r'[A-Z]').hasMatch(password);
  bool get hasLower => RegExp(r'[a-z]').hasMatch(password);
  bool get hasNumOrSpecial => RegExp(r'[0-9]|[^A-Za-z0-9]').hasMatch(password);

  bool get isPasswordValid {
    return isLengthValid && hasUpper && hasLower && hasNumOrSpecial;
  }

  bool get isConfirmMatch => confirmPassword == password && confirmPassword.isNotEmpty;

  bool get isFormValid {
    return name.isNotEmpty &&
        phoneNumber.isNotEmpty &&
        email.isNotEmpty &&
        address.isNotEmpty &&
        gender.isNotEmpty &&
        dob != null &&
        identification.isNotEmpty &&
        otpSent &&
        otpCode.isNotEmpty &&
        isPasswordValid &&
        isConfirmMatch;
  }
}

class RegisterFormNotifier extends Notifier<RegisterFormState> {
  late final AuthService _authService;

  @override
  RegisterFormState build() {
    _authService = AuthService();
    return const RegisterFormState();
  }

  void setName(String value) {
    state = state.copyWith(name: value, errorMessage: null);
  }

  void setPhoneNumber(String value) {
    state = state.copyWith(phoneNumber: value, errorMessage: null);
  }

  void setEmail(String value) {
    state = state.copyWith(email: value, errorMessage: null);
  }

  void setAddress(String value) {
    state = state.copyWith(address: value, errorMessage: null);
  }

  void setGender(String value) {
    state = state.copyWith(gender: value, errorMessage: null);
  }

  void setDob(DateTime value) {
    state = state.copyWith(dob: value, errorMessage: null);
  }

  void setIdentification(String value) {
    state = state.copyWith(identification: value, errorMessage: null);
  }

  void setOtpCode(String value) {
    state = state.copyWith(otpCode: value, errorMessage: null);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void setConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value, errorMessage: null);
  }

  void togglePasswordVisible() {
    state = state.copyWith(passwordVisible: !state.passwordVisible);
  }

  void toggleConfirmPasswordVisible() {
    state = state.copyWith(confirmPasswordVisible: !state.confirmPasswordVisible);
  }

  static bool _isEmailValid(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<bool> sendOtp() async {
    final email = state.email.trim();
    if (email.isEmpty) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập email để nhận OTP.');
      return false;
    }
    if (!_isEmailValid(email)) {
      state = state.copyWith(errorMessage: 'Email không hợp lệ.');
      return false;
    }
    if (state.isSendingOtp) return false;

    state = state.copyWith(isSendingOtp: true, errorMessage: null);
    final result = await _authService.sendOtp(email);
    if (result['success'] == true) {
      state = state.copyWith(
        isSendingOtp: false,
        otpSent: true,
        errorMessage: null,
      );
      return true;
    }

    state = state.copyWith(
      isSendingOtp: false,
      otpSent: false,
      errorMessage: result['message'] ?? 'Gửi OTP thất bại. Vui lòng thử lại.',
    );
    return false;
  }

  Future<bool> submit() async {
    if (!state.isFormValid) {
      state = state.copyWith(
        errorMessage:
            state.otpSent ? 'Vui lòng kiểm tra lại các trường thông tin.' : 'Vui lòng gửi OTP trước khi đăng ký.',
      );
      return false;
    }
    
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    
    try {
      final registerRequest = RegisterRequest(
        email: state.email,
        password: state.password,
        name: state.name,
        phone: state.phoneNumber,
        address: state.address,
        gender: state.gender,
        dob: state.dob!,
        identification: state.identification,
        otpCode: state.otpCode,
      );

      final result = await _authService.register(registerRequest);
      
      if (result['success'] == true) {
        state = state.copyWith(isSubmitting: false);
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: result['message'] ?? 'Đăng ký thất bại. Vui lòng thử lại.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'Có lỗi xảy ra. Vui lòng thử lại.',
      );
      return false;
    }
  }
}

final registerFormProvider = NotifierProvider.autoDispose<RegisterFormNotifier, RegisterFormState>(() {
  return RegisterFormNotifier();
});


