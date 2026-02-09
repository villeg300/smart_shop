import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smart_shop/models/user.dart';
import 'package:smart_shop/services/api_client.dart';
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

  // Getters
  User? get currentUser => _currentUser.value;
  Rx<User?> get currentUserRx => _currentUser;
  bool get isLoading => _isLoading.value;
  bool get isFirstTime => _isFirstTime.value;
  bool get isAuthenticated =>
      _apiClient.isAuthenticated && _currentUser.value != null;

  @override
  void onInit() {
    super.onInit();

    // Initialiser l'API client (remplacez par votre URL)
    _apiClient = ApiClient(baseUrl: 'http://192.168.11.173:8000');
    // _apiClient = ApiClient(baseUrl: 'http://192.168.127.234:8000');
    _authService = AuthService(_apiClient);

    // Charger l'état initial
    _loadInitialState();
  }

  /// Charger l'état initial de l'application
  Future<void> _loadInitialState() async {
    _isFirstTime.value = _storage.read('isFirstTime') ?? true;

    // Si l'utilisateur a des tokens, essayer de récupérer son profil
    if (_apiClient.isAuthenticated) {
      await loadCurrentUser();
    }
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
  }) async {
    try {
      _isLoading.value = true;

      final loginResponse = await _authService.register(
        phoneNumber: phoneNumber,
        fullName: fullName,
        email: email,
        password: password,
      );

      _currentUser.value = loginResponse.user;

      Get.snackbar(
        'Succès',
        'Compte créé avec succès !',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
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

      Get.snackbar(
        'Bienvenue',
        'Connexion réussie !',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar(
        'Erreur de connexion',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// 3. DÉCONNEXION
  Future<void> logout() async {
    await _authService.logout();
    _currentUser.value = null;

    Get.snackbar(
      'Déconnexion',
      'Vous êtes déconnecté',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// 4. CHARGER LE PROFIL UTILISATEUR
  Future<void> loadCurrentUser() async {
    try {
      final user = await _authService.getCurrentUser();
      _currentUser.value = user;
    } catch (e) {
      // Si erreur (token expiré, etc.), déconnecter
      await logout();
    }
  }

  /// 5. METTRE À JOUR LE PROFIL
  Future<bool> updateProfile({
    String? fullName,
    String? email,
    String? phoneNumber,
  }) async {
    try {
      _isLoading.value = true;

      final updatedUser = await _authService.updateProfile(
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
      );

      _currentUser.value = updatedUser;

      Get.snackbar(
        'Succès',
        'Profil mis à jour',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
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

      Get.snackbar(
        'Succès',
        'Mot de passe modifié',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
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

      Get.snackbar(
        'Email envoyé',
        'Vérifiez votre boîte mail',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
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

      Get.snackbar(
        'Succès',
        'Mot de passe réinitialisé',
        snackPosition: SnackPosition.BOTTOM,
      );

      return true;
    } catch (e) {
      Get.snackbar('Erreur', e.toString(), snackPosition: SnackPosition.BOTTOM);
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
}
