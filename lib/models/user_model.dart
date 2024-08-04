class User {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  User({required this.accessToken, required this.refreshToken, required this.expiresIn});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      accessToken: json['access_token'],
      refreshToken: json['refresh_token'],
      expiresIn: json['expires_in'],
    );
  }
}
