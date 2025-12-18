class AdminUser {
  final String userUuid;
  final String email;
  final String? name;
  final String? role;

  AdminUser({
    required this.userUuid,
    required this.email,
    this.name,
    this.role,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      userUuid: json['userUuid'],
      email: json['email'],
      name: json['name'],
      role: json['role'],
    );
  }
}
class AdminUpdateUserRequest {
  final String userUuid;
  final String? newEmail;
  final String? newPassword;

  AdminUpdateUserRequest({
    required this.userUuid,
    this.newEmail,
    this.newPassword,
  });

  Map<String, dynamic> toJson() => {
        'userUuid': userUuid,
        'newEmail': newEmail,
        'newPassword': newPassword,
      };
}
