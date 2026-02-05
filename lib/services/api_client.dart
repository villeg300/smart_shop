import 'dart:convert';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class ApiClient {
  ApiClient({required this.baseUrl});

  final String baseUrl;
  final GetStorage _storage = GetStorage();

  String? get _token => _storage.read<String>('auth_token');

  Future<http.Response> get(String path) {
    return http.get(_uri(path), headers: _headers());
  }

  Future<http.Response> post(String path, Map<String, dynamic> body) {
    return http.post(_uri(path), headers: _headers(), body: jsonEncode(body));
  }

  Future<http.Response> put(String path, Map<String, dynamic> body) {
    return http.put(_uri(path), headers: _headers(), body: jsonEncode(body));
  }

  Future<http.Response> delete(String path) {
    return http.delete(_uri(path), headers: _headers());
  }

  void saveToken(String token) {
    _storage.write('auth_token', token);
  }

  void clearToken() {
    _storage.remove('auth_token');
  }

  Uri _uri(String path) {
    return Uri.parse('$baseUrl$path');
  }

  Map<String, String> _headers() {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }
}
