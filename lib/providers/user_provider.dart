import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

class UserProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<UserModel> _users = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchUsers() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _apiService.get('getUsers');
    
    if (response['success'] == true && response['data'] != null) {
      _users = (response['data'] as List).map((i) => UserModel.fromJson(i)).toList();
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal memuat user';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addUser(UserModel user, {String password = ''}) async {
    _isLoading = true;
    notifyListeners();

    final data = user.toJson();
    data['action'] = 'addUser';
    if (password.isNotEmpty) data['password'] = password;
    
    final response = await _apiService.post(data);
    
    if (response['success'] == true) {
      await fetchUsers();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal menambah user';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUser(UserModel user, {String? password}) async {
    _isLoading = true;
    notifyListeners();

    final data = user.toJson();
    data['action'] = 'updateUser';
    if (password != null && password.isNotEmpty) data['password'] = password;
    
    final response = await _apiService.post(data);
    
    if (response['success'] == true) {
      await fetchUsers();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal mengubah user';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String id) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.post({'action': 'deleteUser', 'id': id});
    
    if (response['success'] == true) {
      await fetchUsers();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal menghapus user';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
