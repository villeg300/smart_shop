import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get_storage/get_storage.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// Client API avec gestion automatique du refresh token
class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  final GetStorage _storage = GetStorage();
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Clés de stockage
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static String? _accessTokenCache;
  static String? _refreshTokenCache;
  static bool _tokensHydrated = false;
  static Completer<void>? _hydrateCompleter;

  // Getters pour les tokens
  String? get accessToken => _accessTokenCache;
  String? get refreshToken => _refreshTokenCache;

  Future<void> _hydrateTokens() async {
    if (_tokensHydrated) {
      return;
    }
    if (_hydrateCompleter != null) {
      await _hydrateCompleter!.future;
      return;
    }

    _hydrateCompleter = Completer<void>();
    try {
      final access = await _secureStorage.read(key: _accessTokenKey);
      final refresh = await _secureStorage.read(key: _refreshTokenKey);

      _accessTokenCache = access;
      _refreshTokenCache = refresh;

      // Migration douce: on nettoie l'ancien stockage non sécurisé.
      final legacyAccess = _storage.read<String>(_accessTokenKey);
      final legacyRefresh = _storage.read<String>(_refreshTokenKey);
      if (legacyAccess != null || legacyRefresh != null) {
        _storage.remove(_accessTokenKey);
        _storage.remove(_refreshTokenKey);
      }

      _tokensHydrated = true;
      _hydrateCompleter?.complete();
    } catch (e) {
      debugPrint('Erreur hydratation tokens: $e');
      _tokensHydrated = true;
      _hydrateCompleter?.complete();
    } finally {
      _hydrateCompleter = null;
    }
  }

  /// Sauvegarder les tokens
  Future<void> saveTokens({
    required String access,
    required String refresh,
  }) async {
    _accessTokenCache = access;
    _refreshTokenCache = refresh;
    _tokensHydrated = true;

    await Future.wait([
      _secureStorage.write(key: _accessTokenKey, value: access),
      _secureStorage.write(key: _refreshTokenKey, value: refresh),
    ]);
  }

  /// Sauvegarder uniquement l'access token (après refresh)
  Future<void> saveAccessToken(String access) async {
    _accessTokenCache = access;
    _tokensHydrated = true;
    await _secureStorage.write(key: _accessTokenKey, value: access);
  }

  /// Supprimer tous les tokens
  Future<void> clearTokens() async {
    _accessTokenCache = null;
    _refreshTokenCache = null;
    _tokensHydrated = true;

    await Future.wait([
      _secureStorage.delete(key: _accessTokenKey),
      _secureStorage.delete(key: _refreshTokenKey),
    ]);

    _storage.remove(_accessTokenKey);
    _storage.remove(_refreshTokenKey);
  }

  /// Vérifier si l'utilisateur est authentifié
  bool get isAuthenticated => accessToken != null && refreshToken != null;

  Future<bool> isAuthenticatedAsync() async {
    await _hydrateTokens();
    return isAuthenticated;
  }

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
    final base = Uri.parse(baseUrl.trim());
    final endpoint = Uri.parse(path.trim());

    var endpointPath = endpoint.path;
    if (!endpointPath.startsWith('/')) {
      endpointPath = '/$endpointPath';
    }

    final baseSegments = base.pathSegments.where(
      (segment) => segment.isNotEmpty,
    );
    final baseHasApi = baseSegments.contains('api');

    if (baseHasApi && endpointPath.startsWith('/api/')) {
      endpointPath = endpointPath.replaceFirst('/api', '');
    } else if (!baseHasApi && !endpointPath.startsWith('/api/')) {
      endpointPath = '/api$endpointPath';
    }

    final basePath = base.path.endsWith('/')
        ? base.path.substring(0, base.path.length - 1)
        : base.path;
    final mergedPath = '${basePath.isEmpty ? '' : basePath}$endpointPath';

    return base.replace(
      path: mergedPath,
      queryParameters: endpoint.queryParameters.isEmpty
          ? null
          : endpoint.queryParameters,
    );
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

  /// Multipart request avec auto-refresh
  Future<http.Response> multipart(
    String method,
    String path, {
    Map<String, String>? fields,
    Map<String, String>? filePaths,
    bool includeAuth = true,
  }) async {
    final safeFields = Map<String, String>.from(fields ?? const {});
    final safeFilePaths = Map<String, String>.from(filePaths ?? const {});

    Future<http.Response> sendMultipart() async {
      final request = http.MultipartRequest(method, _uri(path));
      final headers = _headers(includeAuth: includeAuth)
        ..remove('Content-Type');

      request.headers.addAll(headers);
      request.fields.addAll(safeFields);

      for (final entry in safeFilePaths.entries) {
        final filePath = entry.value.trim();
        if (filePath.isEmpty) continue;

        request.files.add(
          await http.MultipartFile.fromPath(entry.key, filePath),
        );
      }

      final streamedResponse = await request.send();
      return http.Response.fromStream(streamedResponse);
    }

    return _requestWithRetry(sendMultipart, includeAuth: includeAuth);
  }

  /// Effectuer une requête avec retry automatique si token expiré
  Future<http.Response> _requestWithRetry(
    Future<http.Response> Function() request, {
    bool includeAuth = true,
  }) async {
    await _hydrateTokens();

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
      await _hydrateTokens();
      if (refreshToken == null || refreshToken!.isEmpty) {
        return false;
      }

      final response = await http.post(
        _uri('/api/auth/jwt/refresh/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh': refreshToken}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final newAccessToken = data['access'] as String;
        await saveAccessToken(newAccessToken);
        return true;
      } else {
        // Refresh token invalide ou expiré
        await clearTokens();
        return false;
      }
    } catch (e) {
      debugPrint('Erreur lors du refresh du token: $e');
      return false;
    }
  }

  /// Vérifier si le token est valide
  Future<bool> verifyToken() async {
    await _hydrateTokens();
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
