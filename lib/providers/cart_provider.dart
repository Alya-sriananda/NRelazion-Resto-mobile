import 'package:flutter/material.dart';
import '../models/cart_model.dart';

class CartProvider with ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  int get totalAmount {
    int total = 0;
    for (var item in _items) {
      total += item.harga * item.quantity;
    }
    return total;
  }

  int get itemCount => _items.length;

  void addItem(String menuId, String nama, int harga, String gambarUrl, String size) {
    // Check if item with same ID and size already exists
    final index = _items.indexWhere((i) => i.menuId == menuId && i.size == size);
    
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(CartItem(
        id: DateTime.now().toString(),
        menuId: menuId,
        nama: nama,
        harga: harga,
        gambarUrl: gambarUrl,
        size: size,
      ));
    }
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void incrementQuantity(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      _items[index].quantity += 1;
      notifyListeners();
    }
  }

  void decrementQuantity(String id) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity -= 1;
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void updateItem(String id, String size, int quantity) {
    final index = _items.indexWhere((i) => i.id == id);
    if (index >= 0) {
      _items[index].size = size;
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }
}
