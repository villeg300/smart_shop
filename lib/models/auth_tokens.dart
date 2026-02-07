/// Modèle pour stocker les tokens JWT (access et refresh)
class AuthTokens {
  final String accessToken;
  final String refreshToken;

  const AuthTokens({required this.accessToken, required this.refreshToken});

  /// Créer depuis la réponse JSON de l'API
  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access'] as String,
      refreshToken: json['refresh'] as String,
    );
  }

  /// Convertir en JSON pour le stockage local
  Map<String, dynamic> toJson() {
    return {'access': accessToken, 'refresh': refreshToken};
  }

  @override
  String toString() => 'AuthTokens(access: ${accessToken.substring(0, 20)}...)';
}
