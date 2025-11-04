class UserResponse {
  final int id;
  final String name;
  final String phone;
  final String gender;
  final String address;
  final DateTime dob;
  final String username;
  final String roleName;

  UserResponse({
    required this.id,
    required this.name,
    required this.phone,
    required this.gender,
    required this.address,
    required this.dob,
    required this.username,
    required this.roleName,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'gender': gender,
      'address': address,
      'dob': dob.toIso8601String(),
      'username': username,
      'roleName': roleName,
    };
  }

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      gender: json['gender'] ?? '',
      address: json['address'] ?? '',
      dob: json['dob'] != null ? DateTime.parse(json['dob']) : DateTime.now(),
      username: json['username'] ?? '',
      roleName: json['roleName'] ?? '',
    );
  }

  @override
  String toString() {
    return 'UserResponse(id: $id, name: $name, username: $username, phone: $phone, gender: $gender, address: $address, roleName: $roleName, dob: $dob)';
  }

  UserResponse copyWith({
    int? id,
    String? name,
    String? phone,
    String? gender,
    String? address,
    DateTime? dob,
    String? username,
    String? roleName,
  }) {
    return UserResponse(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      gender: gender ?? this.gender,
      address: address ?? this.address,
      dob: dob ?? this.dob,
      username: username ?? this.username,
      roleName: roleName ?? this.roleName,
    );
  }
}
