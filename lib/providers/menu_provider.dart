import 'package:flutter/material.dart';
import '../models/menu_model.dart';
import '../services/api_service.dart';

class MenuProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<MenuModel> _menus = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<MenuModel> get menus => _menus;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchMenus() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _apiService.get('getMenu');
    
    if (response['success'] == true && response['data'] != null) {
      _menus = (response['data'] as List).map((i) => MenuModel.fromJson(i)).toList();
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal memuat menu';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMenu(MenuModel menu) async {
    _isLoading = true;
    notifyListeners();

    final data = menu.toJson();
    data['action'] = 'addMenu';
    
    final response = await _apiService.post(data);
    
    if (response['success'] == true) {
      await fetchMenus();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal menambah menu';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMenu(MenuModel menu) async {
    _isLoading = true;
    notifyListeners();

    final data = menu.toJson();
    data['action'] = 'updateMenu';
    
    final response = await _apiService.post(data);
    
    if (response['success'] == true) {
      await fetchMenus();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal mengubah menu';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMenu(String id) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.post({'action': 'deleteMenu', 'id': id});
    
    if (response['success'] == true) {
      await fetchMenus();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal menghapus menu';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
