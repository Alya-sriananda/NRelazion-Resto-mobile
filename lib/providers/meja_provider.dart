import 'package:flutter/material.dart';
import '../models/meja_model.dart';
import '../services/api_service.dart';

class MejaProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<MejaModel> _meja = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<MejaModel> get meja => _meja;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchMeja() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final response = await _apiService.get('getMeja');
    
    if (response['success'] == true && response['data'] != null) {
      _meja = (response['data'] as List).map((i) => MejaModel.fromJson(i)).toList();
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal memuat meja';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addMeja(MejaModel mejaItem) async {
    _isLoading = true;
    notifyListeners();

    final data = mejaItem.toJson();
    data['action'] = 'addMeja';
    
    final response = await _apiService.post(data);
    
    if (response['success'] == true) {
      await fetchMeja();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal menambah meja';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateMeja(MejaModel mejaItem) async {
    _isLoading = true;
    notifyListeners();

    final data = mejaItem.toJson();
    data['action'] = 'updateMeja';
    
    final response = await _apiService.post(data);
    
    if (response['success'] == true) {
      await fetchMeja();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal mengubah meja';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteMeja(String id) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.post({'action': 'deleteMeja', 'id': id});
    
    if (response['success'] == true) {
      await fetchMeja();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal menghapus meja';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
