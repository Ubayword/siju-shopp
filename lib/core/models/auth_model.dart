class AuthResponse {
  final UserData user;
  final String token;

  AuthResponse({required this.user, required this.token});

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      // Menyesuaikan struktur JSON standar Laravel (biasanya token di luar atau di dalam data)
      user: UserData.fromJson(json['user'] ?? json['data']['user'] ?? {}),
      token: json['token'] ?? json['data']['token'] ?? '',
    );
  }
}

class UserData {
  final String id;
  final String name;
  final String email;
  final String? role;
  final String? avatarUrl;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    this.role,
    this.avatarUrl,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      role: json['role'],
      avatarUrl: json['avatar_url'] ?? json['profile_photo_url'],
    );
  }
}