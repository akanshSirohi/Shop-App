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
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.imageUrl,
    this.isFavorite = false,
  });

  void _setFav(bool newVal) {
    isFavorite = newVal;
    notifyListeners();
  }

  Future<void> toggleFavStatus() async {
    // Firebase URL, erased mine for github
    final url =
        Uri.parse("https://my_prefix.firebasedatabase.app/products/$id.json");
    _setFav(!isFavorite);
    try {
      final resp = await http.patch(
        url,
        body: json.encode({
          'isFavourite': isFavorite,
        }),
      );
      if (resp.statusCode >= 400) {
        _setFav(!isFavorite);
      }
    } catch (err) {
      _setFav(!isFavorite);
    }
  }
}
