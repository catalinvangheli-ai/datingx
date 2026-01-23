import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/auth_user.dart';
import '../models/user_profile.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthUser? _currentAuthUser;
  bool _isLoading = false;
  String? _error;

  AuthUser? get currentAuthUser => _currentAuthUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentAuthUser != null;

  // Înregistrare utilizator nou
  Future<bool> register(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Validare email
      if (!_isValidEmail(email)) {
        _error = 'Email invalid';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Validare parolă
      if (password.length < 6) {
        _error = 'Parola trebuie să aibă cel puțin 6 caractere';
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // Call API
      final response = await ApiService.register(email, password);
      
      if (response['success'] == true) {
        // Salvează token
        final token = response['token'];
        ApiService.setToken(token);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_email', email);
        
        // Creează obiect utilizator
        _currentAuthUser = AuthUser(
          id: response['user']['id'],
          email: response['user']['email'],
          passwordHash: '',
          createdAt: DateTime.now(),
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Eroare la înregistrare';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Eroare la înregistrare: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Autentificare
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Call API
      final response = await ApiService.login(email, password);
      
      if (response['success'] == true) {
        // Salvează token
        final token = response['token'];
        ApiService.setToken(token);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', token);
        await prefs.setString('user_email', email);
        
        // Creează obiect utilizator
        _currentAuthUser = AuthUser(
          id: response['user']['id'],
          email: response['user']['email'],
          passwordHash: '',
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        );
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _error = response['message'] ?? 'Eroare la autentificare';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = 'Eroare la autentificare: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Deconectare
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_email');
    ApiService.setToken(null);
    _currentAuthUser = null;
    notifyListeners();
  }

  // Încarcă utilizatorul autentificat la pornirea aplicației
  Future<void> loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final email = prefs.getString('user_email');
      
      if (token != null && email != null) {
        ApiService.setToken(token);
        
        // Verifică token valid prin API call
        try {
          final response = await ApiService.getCurrentUser();
          if (response['success'] == true) {
            _currentAuthUser = AuthUser(
              id: response['user']['id'],
              email: response['user']['email'],
              passwordHash: '',
              createdAt: DateTime.now(),
            );
          }
        } catch (e) {
          // Token invalid - șterge-l
          await logout();
        }
        
        notifyListeners();
      }
    } catch (e) {
      print('Eroare la încărcarea utilizatorului: $e');
    }
  }

  // Șterge profilul (păstrează contul)
  Future<bool> deleteUserProfile() async {
    if (_currentAuthUser == null) return false;

    try {
      await ApiService.deleteProfile();
      
      return true;
    } catch (e) {
      print('Eroare la salvarea profilului: $e');
      return false;
    }
  }

  // Încarcă profilul utilizatorului din backend
  Future<Map<String, dynamic>?> loadUserProfileFromServer() async {
    if (_currentAuthUser == null) return null;

    try {
      final response = await ApiService.getProfile();
      if (response['success'] == true && response['profile'] != null) {
        return response['profile'];
      }
      return null;
    } catch (e) {
      print('Eroare la încărcarea profilului de pe server: $e');
      return null;
    }
  }

  // Încarcă profilul utilizatorului (din localStorage - deprecated)
  Future<UserProfile?> loadUserProfile() async {
    if (_currentAuthUser == null) return null;

    try {
      final prefs = await SharedPreferences.getInstance();
      final profilesJson = prefs.getString('profiles') ?? '{}';
      final profiles = Map<String, dynamic>.from(json.decode(profilesJson));
      
      if (profiles.containsKey(_currentAuthUser!.email)) {
        return UserProfile.fromJson(profiles[_currentAuthUser!.email]);
      }
      return null;
    } catch (e) {
      print('Eroare la încărcarea profilului: $e');
      return null;
    }
  }

  // Șterge contul utilizatorului complet (cont + profil)
  Future<bool> deleteAccount() async {
    if (_currentAuthUser == null) return false;

    try {
      await ApiService.deleteAccount();
      await logout();
      return true;
    } catch (e) {
      print('Eroare la ștergerea contului: $e');
      return false;
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
