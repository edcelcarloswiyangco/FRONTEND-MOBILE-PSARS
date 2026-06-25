import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import 'api_service.dart';

class AuthService {
  AuthService({required ApiService apiService}) : _apiService = apiService;

  static const _tokenKey = 'auth_token';

  final ApiService _apiService;
  SharedPreferences? _preferences;

  String? _token;
  AppUser? _currentUser;

  AppUser? get currentUser => _currentUser;
  String? get token => _token;

  ApiService get apiService => _apiService;

  Future<void> restoreSession() async {
    _preferences ??= await SharedPreferences.getInstance();
    final storedToken = _preferences!.getString(_tokenKey);

    if (storedToken == null || storedToken.isEmpty) {
      _token = null;
      _currentUser = null;
      return;
    }

    try {
      final user = await _apiService.me(storedToken);
      _token = storedToken;
      _currentUser = user;
    } catch (_) {
      await _clearSession();
    }
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.login(email: email, password: password);
    await _saveSession(result.token, result.user);
    return result.user;
  }

  Future<AppUser> register({
    required String firstName,
    String? middleName,
    required String lastName,
    String? suffix,
    required String email,
    required String password,
    required String countryCode,
    required String phoneNumber,
    String? houseNumber,
    String? buildingName,
    required String streetName,
    required String barangay,
    String? cityMunicipality,
    String? province,
    String? zipCode,
  }) async {
    final result = await _apiService.register(
      firstName: firstName,
      middleName: middleName,
      lastName: lastName,
      suffix: suffix,
      email: email,
      password: password,
      countryCode: countryCode,
      phoneNumber: phoneNumber,
      houseNumber: houseNumber,
      buildingName: buildingName,
      streetName: streetName,
      barangay: barangay,
      cityMunicipality: cityMunicipality,
      province: province,
      zipCode: zipCode,
    );
    await _saveSession(result.token, result.user);
    return result.user;
  }

  Future<AppUser> updateProfile({
    required String contactNumber,
    required String address,
  }) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw ApiException('Your session expired. Please login again.');
    }

    final user = await _apiService.updateMe(
      token: token,
      contactNumber: contactNumber,
      address: address,
    );
    _currentUser = user;
    return user;
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = _token;
    if (token == null || token.isEmpty) {
      throw ApiException('Your session expired. Please login again.');
    }

    await _apiService.changePassword(
      token: token,
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> logout() async {
    final token = _token;

    if (token != null) {
      try {
        await _apiService.logout(token);
      } catch (_) {
        // Clear the local session even if the remote call fails.
      }
    }

    await _clearSession();
  }

  Future<void> _saveSession(String token, AppUser user) async {
    _token = token;
    _currentUser = user;

    try {
      _preferences ??= await SharedPreferences.getInstance();
      await _preferences!.setString(_tokenKey, token);
    } catch (_) {
      // Keep the in-memory session even if local persistence fails.
    }
  }

  Future<void> _clearSession() async {
    _preferences ??= await SharedPreferences.getInstance();
    await _preferences!.remove(_tokenKey);
    _token = null;
    _currentUser = null;
  }
}
