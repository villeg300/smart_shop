import 'user.dart';
import 'auth_tokens.dart';

/// Réponse complète du login incluant tokens + infos utilisateur
class LoginResponse {
  final AuthTokens tokens;
  final User user;

  const LoginResponse({required this.tokens, required this.user});

  /// Créer depuis la réponse JSON de l'API Django
  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      tokens: AuthTokens(
        accessToken: json['access'] as String,
        refreshToken: json['refresh'] as String,
      ),
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access': tokens.accessToken,
      'refresh': tokens.refreshToken,
      'user': user.toJson(),
    };
  }
}
