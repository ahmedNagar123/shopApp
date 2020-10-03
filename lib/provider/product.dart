import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  void _toggle(bool newVal) {
    isFavorite = newVal;
    notifyListeners();
  }

  void isToggle(String authToken, String user) async {
    final old = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    try {
      final url =
          'https://shopapp-12be9.firebaseio.com/userFavorites/$user/$id.json?auth=$authToken';
      final response = await http.put(
        url,
        body: jsonEncode(isFavorite),
      );
      if (response.statusCode >= 400) {
        _toggle(old);
      }
    } catch (_) {
      _toggle(old);
    }
  }
}
