import 'package:chat_app/models/user_model.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:flutter/widgets.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider(){
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_authService.isLoggedIn) {
        _currentUser = await _authService.getCurrentUserProfile();
      }
    } catch (e) {
     _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup({
    required String email,
    required String password,
    required String userName,
    String? fullName,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.signup(
        email: email,
        password: password,
        userName: userName,
        fullName: fullName,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    } 
  }
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.signIn(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();
    await _authService.signOut();
    _currentUser = null;
    _isLoading = false;
    notifyListeners();
  }
  Future<bool> updateProfile({
    String? userName,
    String? fullName,
    String? avatarUrl,
    String? bio,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _currentUser = await _authService.updateProfile(
        username: userName,
        fullName: fullName,
        avatarUrl: avatarUrl,
        bio: bio,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  Future<bool> resetPassword(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.resetPassword(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> refreshUser() async {
    try {
      _currentUser = await _authService.getCurrentUserProfile();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
}
void clearError() {
    _error = null;
    notifyListeners();
  }
}