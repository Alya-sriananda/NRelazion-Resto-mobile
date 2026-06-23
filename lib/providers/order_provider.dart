import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchOrders({String status = 'semua'}) async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'cached_orders_$status';
    final cachedOrdersStr = prefs.getString(cacheKey);
    
    if (cachedOrdersStr != null) {
      try {
        final decoded = json.decode(cachedOrdersStr);
        _orders = (decoded as List).map((i) => OrderModel.fromJson(i)).toList();
        _isLoading = false;
        notifyListeners();
      } catch (_) {}
    }

    final response = await _apiService.get('getOrders', params: {'status': status});
    
    if (response['success'] == true && response['data'] != null) {
      _orders = (response['data'] as List).map((i) => OrderModel.fromJson(i)).toList();
      prefs.setString(cacheKey, json.encode(response['data']));
    } else {
      if (cachedOrdersStr == null) {
        _errorMessage = response['message']?.toString() ?? 'Gagal memuat pesanan';
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus, {String? notes}) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.post({
      'action': 'updateOrderStatus',
      'order_id': orderId,
      'status': newStatus,
      if (notes != null) 'notes': notes,
    });
    
    if (response['success'] == true) {
      await fetchOrders();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal mengubah status pesanan';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addOrder(OrderModel order) async {
    _isLoading = true;
    notifyListeners();

    final data = order.toJson();
    data['action'] = 'addOrder';
    
    final response = await _apiService.post(data);
    
    if (response['success'] == true) {
      await fetchOrders();
      return true;
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal membuat pesanan';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
