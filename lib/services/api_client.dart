import 'dart:convert';
import 'dart:async';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

/// Client API avec gestion automatique du refresh token
class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  final GetStorage _storage = GetStorage();

  // Clés de stockage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  // Getters pour les tokens
  String? get accessToken => _storage.read<String>(_accessTokenKey);
  String? get refreshToken => _storage.read<String>(_refreshTokenKey);

  /// Sauvegarder les tokens
  void saveTokens({required String access, required String refresh}) {
    _storage.write(_accessTokenKey, access);
    _storage.write(_refreshTokenKey, refresh);
  }

  /// Sauvegarder uniquement l'access token (après refresh)
  void saveAccessToken(String access) {
    _storage.write(_accessTokenKey, access);
  }

  /// Supprimer tous les tokens
  void clearTokens() {
    _storage.remove(_accessTokenKey);
    _storage.remove(_refreshTokenKey);
  }

  /// Vérifier si l'utilisateur est authentifié
  bool get isAuthenticated => accessToken != null && refreshToken != null;

  /// Headers par défaut
  Map<String, String> _headers({bool includeAuth = true}) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (includeAuth && accessToken != null) {
      headers['Authorization'] = 'Bearer $accessToken';
    }

    return headers;
  }

  /// Construire l'URI
  Uri _uri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  /// GET request avec auto-refresh
  Future<http.Response> get(String path) async {
    return _requestWithRetry(() => http.get(_uri(path), headers: _headers()));
  }

  /// POST request avec auto-refresh
  Future<http.Response> post(
    String path,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    return _requestWithRetry(
      () => http.post(
        _uri(path),
        headers: _headers(includeAuth: includeAuth),
        body: jsonEncode(body),
      ),
      includeAuth: includeAuth,
    );
  }

  /// PUT request avec auto-refresh
  Future<http.Response> put(String path, Map<String, dynamic> body) async {
    return _requestWithRetry(
      () => http.put(_uri(path), headers: _headers(), body: jsonEncode(body)),
    );
  }

  /// DELETE request avec auto-refresh
  Future<http.Response> delete(String path) async {
    return _requestWithRetry(
      () => http.delete(_uri(path), headers: _headers()),
    );
  }

  /// PATCH request avec auto-refresh
  Future<http.Response> patch(String path, Map<String, dynamic> body) async {
    return _requestWithRetry(
      () => http.patch(_uri(path), headers: _headers(), body: jsonEncode(body)),
    );
  }

  /// Effectuer une requête avec retry automatique si token expiré
  Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() request, {
    bool includeAuth = true,
  }) async {
    // Première tentative
    http.Response response = await request();

    // Si 401 Unauthorized et qu'on a un refresh token, on rafraîchit
    if (response.statusCode == 401 && includeAuth && refreshToken != null) {
      final refreshed = await _refreshAccessToken();

      if (refreshed) {
        // Réessayer la requête avec le nouveau token
        response = await request();
      }
    }

    return response;
  }

  /// Rafraîchir l'access token avec le refresh token
  Future<bool> _refreshAccessToken() async {
    try {
      final response = await http.post(
        _uri('/api/auth/jwt/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access'] as String;
        saveAccessToken(newAccessToken);
        return true;
      } else {
        // Refresh token invalide ou expiré
        clearTokens();
        return false;
      }
    } catch (e) {
      print('Erreur lors du refresh du token: $e');
      return false;
    }
  }

  /// Vérifier si le token est valide
  Future<bool> verifyToken() async {
    if (accessToken == null) return false;

    try {
      final response = await http.post(
        _uri('/api/auth/jwt/verify/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': accessToken}),
      );

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
