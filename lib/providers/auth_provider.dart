import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import 'dart:convert';

class AuthProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String _errorMessage = '';

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _apiService.post({
      'action': 'login',
      'email': email,
      'password': password,
    });

    if (response['success'] == true && response['data'] != null) {
      _currentUser = UserModel.fromJson(response['data']);
      
      // Save session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_currentUser!.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Login gagal';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register(String nama, String email, String password, String telepon) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _apiService.post({
      'action': 'addUser',
      'nama': nama,
      'email': email,
      'password': password,
      'role': 'customer',
      'telepon': telepon,
      'foto_url': '',
    });

    _isLoading = false;
    if (response['success'] == true) {
      notifyListeners();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Registrasi gagal';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString('user');
    if (userStr != null) {
      _currentUser = UserModel.fromJson(json.decode(userStr));
      notifyListeners();
    }
  }

  Future<bool> updateProfile(UserModel updatedUser) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final data = updatedUser.toJson();
    data['action'] = 'updateUser';

    final response = await _apiService.post(data);

    if (response['success'] == true) {
      _currentUser = updatedUser;
      
      // Update session
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user', json.encode(_currentUser!.toJson()));
      
      _isLoading = false;
      notifyListeners();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal update profil';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _currentUser = null;
    notifyListeners();
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('user')) return false;
    
    final userStr = prefs.getString('user');
    if (userStr == null) return false;
    
    try {
      _currentUser = UserModel.fromJson(json.decode(userStr));
      notifyListeners();
      return true;
    } catch (e) {
      return false;
    }
  }
}
