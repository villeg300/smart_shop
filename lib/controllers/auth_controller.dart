import 'dart:async';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_shop/models/user.dart';
import 'package:smart_shop/config/app_config.dart';
import 'package:smart_shop/controllers/order_controller.dart';
import 'package:smart_shop/services/api_client.dart';
import 'package:smart_shop/services/app_feedback_service.dart';
import 'package:smart_shop/services/auth_service.dart';

/// Contrôleur d'authentification avec GetX
class AuthController extends GetxController {
  final GetStorage _storage = GetStorage();
  late final AuthService _authService;
  late final ApiClient _apiClient;

  // États observables
  final Rx<User?> _currentUser = Rx<User?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isFirstTime = true.obs;
  final RxBool _isInitialized = false.obs;
  Completer<void>? _initCompleter;

  // Getters
  User? get currentUser => _currentUser.value;
  Rx<User?> get currentUserRx => _currentUser;
  bool get isLoading => _isLoading.value;
  bool get isFirstTime => _isFirstTime.value;
  bool get isInitialized => _isInitialized.value;
  bool get isAuthenticated => _currentUser.value != null;

  @override
  void onInit() {
    super.onInit();
    _apiClient = ApiClient(baseUrl: AppConfig.baseUrl);
    _authService = AuthService(_apiClient);

    _loadInitialState();
  }

  /// Charger l'état initial de l'application
  Future<void> _loadInitialState() async {
    _initCompleter ??= Completer<void>();
    try {
      _isFirstTime.value = _storage.read('isFirstTime') ?? true;

      if (await _apiClient.isAuthenticatedAsync()) {
        await loadCurrentUser();
        await _bootstrapUserScopedData();
      }
    } finally {
      _isInitialized.value = true;
      if (_initCompleter != null && !_initCompleter!.isCompleted) {
        _initCompleter!.complete();
      }
    }
  }

  Future<void> waitUntilInitialized() async {
    if (_isInitialized.value) {
      return;
    }
    _initCompleter ??= Completer<void>();
    await _initCompleter!.future;
  }

  /// Marquer que ce n'est plus la première fois
  void setFirstTimeDone() {
    _isFirstTime.value = false;
    _storage.write('isFirstTime', false);
  }

  /// 1. INSCRIPTION
  Future<bool> register({
    required String phoneNumber,
    required String fullName,
    required String email,
    required String password,
    String? avatarPath,
  }) async {
    try {
      _isLoading.value = true;

      final loginResponse = await _authService.register(
        phoneNumber: phoneNumber,
        fullName: fullName,
        email: email,
        password: password,
        avatarPath: avatarPath,
      );

      _currentUser.value = loginResponse.user;
      await _bootstrapUserScopedData(force: true);

      AppFeedbackService.showSuccess(
        title: 'Bienvenue !',
        message: 'Votre compte a été créé avec succès.',
        mode: FeedbackDisplayMode.popup,
        actionLabel: 'Commencer',
      );

      return true;
    } catch (e) {
      AppFeedbackService.showError(title: 'Inscription échouée', error: e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 2. CONNEXION
  Future<bool> login({
    required String phoneNumber,
    required String password,
  }) async {
    try {
      _isLoading.value = true;

      final loginResponse = await _authService.login(
        phoneNumber: phoneNumber,
        password: password,
      );

      _currentUser.value = loginResponse.user;
      await _bootstrapUserScopedData(force: true);

      AppFeedbackService.showSuccess(
        title: 'Bienvenue',
        message: 'Connexion réussie !',
      );

      return true;
    } catch (e) {
      AppFeedbackService.showError(title: 'Erreur de connexion', error: e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 3. DÉCONNEXION
  Future<void> logout() async {
    _currentUser.value = null;
    _resetUserScopedData();
    await _authService.logout();

    AppFeedbackService.showSuccess(
      title: 'Déconnexion',
      message: 'Vous avez été déconnecté.',
    );
  }

  /// 4. CHARGER LE PROFIL UTILISATEUR
  Future<void> loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      _currentUser.value = user;
    } catch (e) {
      // Token expiré ou invalide — déconnexion silencieuse
      await _authService.logout();
      _currentUser.value = null;
      _resetUserScopedData();
    }
  }

  /// 5. METTRE À JOUR LE PROFIL
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarPath,
  }) async {
    try {
      _isLoading.value = true;

      final updatedUser = await _authService.updateProfile(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        avatarPath: avatarPath,
      );

      _currentUser.value = updatedUser;

      AppFeedbackService.showSuccess(
        title: 'Succès',
        message: 'Profil mis à jour.',
      );

      return true;
    } catch (e) {
      AppFeedbackService.showError(title: 'Erreur', error: e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 6. CHANGER LE MOT DE PASSE
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      AppFeedbackService.showSuccess(
        title: 'Succès',
        message: 'Mot de passe modifié.',
        mode: FeedbackDisplayMode.popup,
        actionLabel: 'OK',
      );

      return true;
    } catch (e) {
      AppFeedbackService.showError(title: 'Erreur', error: e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 7. DEMANDER LA RÉINITIALISATION DU MOT DE PASSE
  Future<bool> requestPasswordReset({required String email}) async {
    try {
      _isLoading.value = true;

      await _authService.requestPasswordReset(email: email);

      AppFeedbackService.showSuccess(
        title: 'Email envoyé',
        message: 'Vérifiez votre boîte mail.',
        mode: FeedbackDisplayMode.popup,
        actionLabel: 'OK',
      );

      return true;
    } catch (e) {
      AppFeedbackService.showError(title: 'Erreur', error: e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 8. CONFIRMER LA RÉINITIALISATION DU MOT DE PASSE
  Future<bool> confirmPasswordReset({
    required String uid,
    required String token,
    required String newPassword,
  }) async {
    try {
      _isLoading.value = true;

      await _authService.confirmPasswordReset(
        uid: uid,
        token: token,
        newPassword: newPassword,
      );

      AppFeedbackService.showSuccess(
        title: 'Succès',
        message: 'Mot de passe réinitialisé.',
        mode: FeedbackDisplayMode.popup,
        actionLabel: 'Se connecter',
      );

      return true;
    } catch (e) {
      AppFeedbackService.showError(title: 'Erreur', error: e);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 9. RAFRAÎCHIR LES DONNÉES UTILISATEUR
  Future<void> refreshUserData() async {
    if (isAuthenticated) {
      await loadCurrentUser();
    }
  }

  Future<void> _bootstrapUserScopedData({bool force = false}) async {
    if (Get.isRegistered<OrderController>()) {
      await Get.find<OrderController>().ensureBootstrapped(force: force);
    }
  }

  void _resetUserScopedData() {
    if (Get.isRegistered<OrderController>()) {
      Get.find<OrderController>().clearData();
    }
  }
}
