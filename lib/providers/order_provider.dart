import 'package:flutter/material.dart';
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

    final response = await _apiService.get('getOrders', params: {'status': status});
    
    if (response['success'] == true && response['data'] != null) {
      _orders = (response['data'] as List).map((i) => OrderModel.fromJson(i)).toList();
    } else {
      _errorMessage = response['message']?.toString() ?? 'Gagal memuat pesanan';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> updateOrderStatus(String orderId, String newStatus) async {
    _isLoading = true;
    notifyListeners();

    final response = await _apiService.post({
      'action': 'updateOrderStatus',
      'order_id': orderId,
      'status': newStatus,
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
