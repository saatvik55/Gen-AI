class AuthToken {
  final String accessToken;
  final String tokenType;

  AuthToken({required this.accessToken, this.tokenType = 'bearer'});

  factory AuthToken.fromJson(Map<String, dynamic> json) => AuthToken(
        accessToken: json['access_token'] as String,
        tokenType: json['token_type'] as String? ?? 'bearer',
      );
}

class UserModel {
  final int id;
  final String? fullName;
  final String? email;
  final String? phone;
  final bool isActive;
  final String createdAt;

  UserModel({
    required this.id,
    this.fullName,
    this.email,
    this.phone,
    required this.isActive,
    required this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        fullName: json['full_name'] as String?,
        email: json['email'] as String?,
        phone: json['phone'] as String?,
        isActive: json['is_active'] as bool,
        createdAt: json['created_at'] as String,
      );

  String get displayName => fullName ?? email ?? phone ?? 'User';
}
