import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/response/login_response.dart';
import '../model/response/user_response.dart';
import '../service/auth_service.dart';

class User {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String gender;
  final String address;
  final DateTime dob;
  final String identification;
  final String username;
  final String roleName;
  final String? token;
  final String avatar;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.gender,
    required this.address,
    required this.dob,
    required this.identification,
    required this.username,
    required this.roleName,
    this.token,
    required this.avatar,
  });

  factory User.fromUserResponse(UserResponse userResponse, {String? token}) {
    return User(
      id: userResponse.id,
      name: userResponse.name,
      email: userResponse.username,
      phone: userResponse.phone,
      gender: userResponse.gender,
      address: userResponse.address,
      dob: userResponse.dob,
      identification: userResponse.identification,
      username: userResponse.username,
      roleName: userResponse.roleName,
      token: token,
      avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
    );
  }
}

class AuthState {
  final bool isLoggedIn;
  final User? user;
  final bool isLoading;

  const AuthState({
    this.isLoggedIn = false,
    this.user,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isLoggedIn,
    User? user,
    bool? isLoading,
  }) {
    return AuthState(
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  late final AuthService _authService;

  @override
  AuthState build() {
    _authService = AuthService();
    return const AuthState();
  }

  Future<void> setUserWithRealInfo({
    required LoginResponse loginResponse,
  }) async {
    state = state.copyWith(isLoading: true);

    try {
      final result = await _authService.getUserInfo(loginResponse.token);
      
      if (result['success'] == true) {
        final userResponse = result['data'] as UserResponse;
        final user = User.fromUserResponse(userResponse, token: loginResponse.token);
        
        state = state.copyWith(
          isLoggedIn: true,
          user: user,
          isLoading: false,
        );
      } else {
        final user = User(
          id: 0,
          name: 'User',
          email: 'user@example.com',
          phone: '',
          gender: '',
          address: '',
          dob: DateTime.now(),
          identification: '',
          username: 'user@example.com',
          roleName: loginResponse.role,
          token: loginResponse.token,
          avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
        );
        
        state = state.copyWith(
          isLoggedIn: true,
          user: user,
          isLoading: false,
        );
      }
    } catch (e) {
      // Fallback nếu có lỗi
      final user = User(
        id: 0,
        name: 'User',
        email: 'user@example.com',
        phone: '',
        gender: '',
        address: '',
        dob: DateTime.now(),
        identification: '',
        username: 'user@example.com',
        roleName: loginResponse.role,
        token: loginResponse.token,
        avatar: 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?ixlib=rb-4.0.3&auto=format&fit=crop&w=200&q=80',
      );
      
      state = state.copyWith(
        isLoggedIn: true,
        user: user,
        isLoading: false,
      );
    }
  }


  void logout() {
    state = const AuthState();
  }

  void updateLocation(String newLocation) {
    if (state.user != null) {
      final updatedUser = User(
        id: state.user!.id,
        name: state.user!.name,
        email: state.user!.email,
        phone: state.user!.phone,
        gender: state.user!.gender,
        address: newLocation, // Cập nhật address thay vì location
        dob: state.user!.dob,
        identification: state.user!.identification,
        username: state.user!.username,
        roleName: state.user!.roleName,
        token: state.user!.token,
        avatar: state.user!.avatar,
      );
      state = state.copyWith(user: updatedUser);
    }
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
