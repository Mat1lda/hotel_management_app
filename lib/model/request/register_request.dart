class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String address;
  final String gender;
  final DateTime dob;
  final String identification;
  final String otpCode;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.address,
    required this.gender,
    required this.dob,
    required this.identification,
    required this.otpCode,
  });

  static String _formatLocalDate(DateTime d) {
    final y = d.year.toString().padLeft(4, '0');
    final m = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$y-$m-$day';
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'address': address,
      'gender': gender,
      'dob': _formatLocalDate(dob),
      'identification': identification,
      'otpCode': otpCode,
    };
  }

  factory RegisterRequest.fromJson(Map<String, dynamic> json) {
    return RegisterRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      address: json['address'] ?? '',
      gender: json['gender'] ?? '',
      dob: DateTime.tryParse(json['dob']?.toString() ?? '') ?? DateTime(2000),
      identification: json['identification'] ?? '',
      otpCode: json['otpCode'] ?? '',
    );
  }

  @override
  String toString() {
    return 'RegisterRequest(email: $email, name: $name, phone: $phone, address: $address, gender: $gender, dob: $dob, identification: $identification)';
  }

  RegisterRequest copyWith({
    String? email,
    String? password,
    String? name,
    String? phone,
    String? address,
    String? gender,
    DateTime? dob,
    String? identification,
    String? otpCode,
  }) {
    return RegisterRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,
      identification: identification ?? this.identification,
      otpCode: otpCode ?? this.otpCode,
    );
  }
}
