import 'package:flutter/material.dart';
import '../models/menu_model.dart';

class FavoriteProvider with ChangeNotifier {
  final List<MenuModel> _favorites = [];

  List<MenuModel> get favorites => _favorites;

  bool isFavorite(String id) {
    return _favorites.any((m) => m.id == id);
  }

  void toggleFavorite(MenuModel menu) {
    final index = _favorites.indexWhere((m) => m.id == menu.id);
    if (index >= 0) {
      _favorites.removeAt(index);
    } else {
      _favorites.add(menu);
    }
    notifyListeners();
  }
}
