import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrderProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<Order> _availableOrders = [];
  List<Order> _activeOrders = [];
  bool _loading = false;

  List<Order> get availableOrders => _availableOrders;
  List<Order> get activeOrders => _activeOrders;
  bool get loading => _loading;

  OrderProvider() {
    _apiService.init();
  }

  Future<void> fetchOrders() async {
    _loading = true;
    notifyListeners();
    try {
      final List<dynamic> data = await _apiService.request('/api/orders/delivery/available');
      _availableOrders = data.map((json) => Order.fromJson(json)).toList();
      
      final List<dynamic> activeData = await _apiService.request('/api/orders/delivery/active');
      _activeOrders = activeData.map((json) => Order.fromJson(json)).toList();
    } catch (e) {
      print('Error fetching orders: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _apiService.request(
        '/api/orders/$orderId/status',
        method: 'PATCH',
        body: {'status': status},
      );
      await fetchOrders();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> acceptOrder(String orderId) async {
    await updateOrderStatus(orderId, 'accepted');
  }
}
