import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:smart_shop/models/login_response.dart';
import 'package:smart_shop/models/user.dart';
import 'package:smart_shop/services/api_client.dart';

/// Service d'authentification avec Djoser
class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  /// 1. INSCRIPTION (Register)
  /// Créer un nouveau compte utilisateur
  Future<LoginResponse> register({
    required String phoneNumber,
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        '/api/auth/users/',
        {
          'phone_number': phoneNumber,
          'full_name': fullName,
          'email': email,
          'password': password,
          're_password': password, // Djoser requiert la confirmation
        },
        includeAuth: false, // Pas besoin d'auth pour l'inscription
      );

      if (response.statusCode == 201) {
        // Inscription réussie, maintenant se connecter automatiquement
        return await login(phoneNumber: phoneNumber, password: password);
      } else {
        final error = jsonDecode(response.body);
        throw _handleError(error);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 2. CONNEXION (Login)
  /// Se connecter et récupérer les tokens JWT + infos utilisateur
  Future<LoginResponse> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      final response = await _client.post('/api/auth/jwt/create/', {
        'phone_number': phoneNumber,
        'password': password,
      }, includeAuth: false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final loginResponse = LoginResponse.fromJson(data);

        // Sauvegarder les tokens
        _client.saveTokens(
          access: loginResponse.tokens.accessToken,
          refresh: loginResponse.tokens.refreshToken,
        );

        return loginResponse;
      } else {
        final error = jsonDecode(response.body);
        throw _handleError(error);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 3. DÉCONNEXION (Logout)
  /// Se déconnecter (supprimer les tokens localement)
  Future<void> logout() async {
    _client.clearTokens();
  }

  /// 4. RÉCUPÉRER LE PROFIL UTILISATEUR
  /// Obtenir les informations de l'utilisateur connecté
  Future<User> getCurrentUser() async {
    try {
      final response = await _client.get('/api/auth/users/me/');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(data);
      } else {
        throw Exception('Impossible de récupérer le profil utilisateur');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 5. METTRE À JOUR LE PROFIL
  /// Modifier les informations de l'utilisateur
  Future<User> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['full_name'] = fullName;
      if (email != null) body['email'] = email;
      if (phoneNumber != null) body['phone_number'] = phoneNumber;

      final response = await _client.patch('/api/auth/users/me/', body);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return User.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw _handleError(error);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 6. CHANGER LE MOT DE PASSE
  /// Modifier le mot de passe de l'utilisateur connecté
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _client.post('/api/auth/users/set_password/', {
        'current_password': currentPassword,
        'new_password': newPassword,
        're_new_password': newPassword,
      });

      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw _handleError(error);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 7. MOT DE PASSE OUBLIÉ - DEMANDER LA RÉINITIALISATION
  /// Envoyer un email avec le code de réinitialisation
  Future<void> requestPasswordReset({required String email}) async {
    try {
      final response = await _client.post('/api/auth/users/reset_password/', {
        'email': email,
      }, includeAuth: false);

      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw _handleError(error);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 8. MOT DE PASSE OUBLIÉ - CONFIRMER LA RÉINITIALISATION
  /// Utiliser le UID et TOKEN reçus par email pour définir un nouveau mot de passe
  Future<void> confirmPasswordReset({
    required String uid,
    required String token,
    required String newPassword,
  }) async {
    try {
      final response = await _client
          .post('/api/auth/users/reset_password_confirm/', {
            'uid': uid,
            'token': token,
            'new_password': newPassword,
            're_new_password': newPassword,
          }, includeAuth: false);

      if (response.statusCode != 204) {
        final error = jsonDecode(response.body);
        throw _handleError(error);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// 9. RAFRAÎCHIR LE TOKEN
  /// Obtenir un nouveau access token avec le refresh token
  Future<bool> refreshToken() async {
    try {
      if (_client.refreshToken == null) return false;

      final response = await http.post(
        Uri.parse('${_client.baseUrl}/api/auth/jwt/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': _client.refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access'] as String;
        _client.saveAccessToken(newAccessToken);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  /// 10. VÉRIFIER SI LE TOKEN EST VALIDE
  Future<bool> verifyToken() async {
    return await _client.verifyToken();
  }

  /// 11. VÉRIFIER SI L'UTILISATEUR EST CONNECTÉ
  bool get isAuthenticated => _client.isAuthenticated;

  /// Gérer les erreurs de l'API
  String _handleError(dynamic error) {
    if (error is Map<String, dynamic>) {
      // Erreurs de validation de Djoser
      if (error.containsKey('detail')) {
        return error['detail'] as String;
      }

      // Erreurs de champs
      final messages = <String>[];
      error.forEach((key, value) {
        if (value is List) {
          messages.addAll(value.map((e) => '$key: $e'));
        } else {
          messages.add('$key: $value');
        }
      });
      return messages.join('\n');
    }
    return 'Une erreur est survenue';
  }
}
