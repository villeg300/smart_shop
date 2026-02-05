import 'package:smart_shop/data/mock_data.dart';
import 'package:smart_shop/models/user.dart';
import 'package:smart_shop/services/api_client.dart';

class AuthService {
  AuthService(this._client);

  final ApiClient _client;

  Future<User> login({
    required String email,
    required String password,
  }) async {
    // TODO: replace with real API call.
    await Future.delayed(const Duration(milliseconds: 500));
    _client.saveToken('mock-jwt-token');
    return mockUsers.first;
  }

  Future<User> register({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    // TODO: replace with real API call.
    await Future.delayed(const Duration(milliseconds: 500));
    _client.saveToken('mock-jwt-token');
    return User(id: 'user-002', name: name, email: email, phone: phone);
  }

  Future<void> logout() async {
    _client.clearToken();
  }
}
