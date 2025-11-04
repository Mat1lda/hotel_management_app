class LoginResponse {
  final String token;
  final String role;

  LoginResponse({
    required this.token,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      'role': role,
    };
  }

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      role: json['role'] ?? '',
    );
  }

  @override
  String toString() {
    return 'LoginResponse(token: ${token.isNotEmpty ? "***" : "empty"}, role: $role)'; // Ẩn token vì lý do bảo mật
  }

  LoginResponse copyWith({
    String? token,
    String? role,
  }) {
    return LoginResponse(
      token: token ?? this.token,
      role: role ?? this.role,
    );
  }
}
