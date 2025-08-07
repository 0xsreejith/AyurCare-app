import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_model.dart';
import '../../data/services/api_service.dart';

class AuthProvider with ChangeNotifier {
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isAuthenticated = false;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _isAuthenticated;

  final ApiService _apiService;

  AuthProvider(this._apiService);

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    _isAuthenticated = false;
    notifyListeners();

    try {
      final result = await _apiService.login(username, password);
      _user = result['user'] as User?;
      _token = result['token'] as String?;
      
      if (_token != null && _token!.isNotEmpty) {
        _apiService.setToken(_token!);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        _isAuthenticated = true;
      } else {
        throw Exception('Token not received from server');
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');
    if (_token != null && _token!.isNotEmpty) {
      _apiService.setToken(_token!);
      _isAuthenticated = true;
      // Try to load user data if we have a token
      try {
        // You might want to add a method to verify token and get user data
        // For now, we'll just mark as authenticated
      } catch (e) {
        // Token might be invalid, clear it
        await logout();
      }
    }
    notifyListeners();
  }

  Future<void> logout() async {
    _user = null;
    _token = null;
    _isAuthenticated = false;
    _apiService.setToken('');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }
}