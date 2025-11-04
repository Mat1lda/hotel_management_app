import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_provider.dart';
import '../service/auth_service.dart';
import '../model/request/login_request.dart';
import '../model/response/login_response.dart';

class LoginFormState {
  final String usernameOrMemberId; // email/username/HHonors number
  final String password;
  final bool passwordVisible;
  final bool isSubmitting;
  final String? errorMessage;

  const LoginFormState({
    this.usernameOrMemberId = '',
    this.password = '',
    this.passwordVisible = false,
    this.isSubmitting = false,
    this.errorMessage,
  });

  LoginFormState copyWith({
    String? usernameOrMemberId,
    String? password,
    bool? passwordVisible,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return LoginFormState(
      usernameOrMemberId: usernameOrMemberId ?? this.usernameOrMemberId,
      password: password ?? this.password,
      passwordVisible: passwordVisible ?? this.passwordVisible,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }

  bool get isFormValid => usernameOrMemberId.isNotEmpty && password.isNotEmpty;
}

class LoginFormNotifier extends Notifier<LoginFormState> {
  late final AuthService _authService;

  @override
  LoginFormState build() {
    _authService = AuthService();
    return const LoginFormState();
  }

  void setUsername(String value) {
    state = state.copyWith(usernameOrMemberId: value, errorMessage: null);
  }

  void setPassword(String value) {
    state = state.copyWith(password: value, errorMessage: null);
  }

  void togglePasswordVisible() {
    state = state.copyWith(passwordVisible: !state.passwordVisible);
  }

  Future<bool> submit() async {
    if (!state.isFormValid) {
      state = state.copyWith(errorMessage: 'Vui lòng nhập đầy đủ tài khoản và mật khẩu.');
      return false;
    }
    
    state = state.copyWith(isSubmitting: true, errorMessage: null);
    
    try {
      final loginRequest = LoginRequest(
        email: state.usernameOrMemberId,
        password: state.password,
      );

      final result = await _authService.login(loginRequest);
      
      if (result['success'] == true) {
        final loginResponse = result['data'] as LoginResponse;
        final authNotifier = ref.read(authProvider.notifier);
        await authNotifier.setUserWithRealInfo(
          loginResponse: loginResponse,
        );
        
        state = state.copyWith(isSubmitting: false);
        return true;
      } else {
        state = state.copyWith(
          isSubmitting: false,
          errorMessage: result['message'] ?? 'Email hoặc mật khẩu không đúng',
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

final loginFormProvider = NotifierProvider.autoDispose<LoginFormNotifier, LoginFormState>(() {
  return LoginFormNotifier();
});


