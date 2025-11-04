class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String phone;
  final String address;
  final String gender;
  final String roleName;
  final DateTime dob;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    required this.phone,
    required this.address,
    required this.gender,
    required this.roleName,
    required this.dob,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'name': name,
      'phone': phone,
      'address': address,
      'gender': gender,
      'roleName': roleName,
      'dob': dob.toIso8601String(),
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
      roleName: json['roleName'] ?? '',
      dob: DateTime.parse(json['dob']),
    );
  }

  @override
  String toString() {
    return 'RegisterRequest(email: $email, name: $name, phone: $phone, address: $address, gender: $gender, roleName: $roleName, dob: $dob)';
  }

  RegisterRequest copyWith({
    String? email,
    String? password,
    String? name,
    String? phone,
    String? address,
    String? gender,
    String? roleName,
    DateTime? dob,
  }) {
    return RegisterRequest(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      roleName: roleName ?? this.roleName,
      dob: dob ?? this.dob,
    );
  }
}
