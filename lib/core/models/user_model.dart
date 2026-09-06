enum UserRole { admin, karyawan }

enum UserStatus { aktif, cuti, nonAktif, belumDiatur }

class UserData {
  final String email;
  final String password;
  final String name;
  final String id;
  final String employeeId;
  final UserRole role;
  final bool isVerified;
  final UserStatus? status;

  const UserData({
    required this.email,
    required this.password,
    required this.name,
    required this.id,
    required this.employeeId,
    required this.role,
    this.isVerified = false,
    this.status,
  });

  UserData copyWith({
    String? email,
    String? password,
    String? name,
    String? id,
    String? employeeId,
    UserRole? role,
    bool? isVerified,
    UserStatus? status,
  }) {
    return UserData(
      email: email ?? this.email,
      password: password ?? this.password,
      name: name ?? this.name,
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      role: role ?? this.role,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{
      'email': email,
      'name': name,
      'id': id,
      'employeeId': employeeId,
      'role': role.name,
      'isVerified': isVerified,
    };
    if (status != null) {
      data['status'] = status!.name;
    }
    return data;
  }

  factory UserData.fromJson(Map<String, dynamic> map) {
    final UserRole role = _parseRole(map['role']?.toString());
    UserStatus? status = _parseStatus(map['status']?.toString());

    // Berikan default status jika role adalah karyawan dan status masih null
    if (role == UserRole.karyawan && status == null) {
      status = UserStatus.belumDiatur;
    }

    return UserData(
      email: map['email']?.toString() ?? '',
      password: '',
      name: map['name']?.toString() ?? 'No Name',
      id: map['id']?.toString() ?? '',
      employeeId: map['employeeId']?.toString() ?? '',
      role: role,
      isVerified: map['isVerified'] as bool? ?? false,
      status: status,
    );
  }

  static UserRole _parseRole(String? roleName) {
    if (roleName == null) return UserRole.karyawan;
    return UserRole.values.firstWhere(
      (e) => e.name == roleName,
      orElse: () => UserRole.karyawan,
    );
  }

  static UserStatus? _parseStatus(String? statusName) {
    if (statusName == null) return null;
    return UserStatus.values.firstWhere(
      (e) => e.name == statusName,
      orElse: () => UserStatus.belumDiatur,
    );
  }
}
