import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import '../dummy_data.dart';
import 'product.dart';

class Products with ChangeNotifier {
  List<Product> _items = DUMMY_DATA;

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchProducts() async {
    final url =
        Uri.parse("https://my_prefix.firebasedatabase.app/products.json");
    try {
      final resp = await http.get(url);
      final data =
          json.decode(resp.body) ?? <String, dynamic>{} as Map<String, dynamic>;
      if (data == <String, dynamic>{}) {
        return;
      }
      final List<Product> loadedProducts = [];
      data.forEach((prodId, prodData) {
        loadedProducts.add(
          Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            imageUrl: prodData['imageUrl'],
            isFavorite: prodData['isFavourite'],
          ),
        );
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> addProduct(Product product) async {
    final url =
        Uri.parse("https://my_prefix.firebasedatabase.app/products.json");
    try {
      final resp = await http.post(
        url,
        body: json.encode({
          'title': product.title,
          'description': product.description,
          'imageUrl': product.imageUrl,
          'price': product.price,
          'isFavourite': product.isFavorite,
        }),
      );
      final obj = json.decode(resp.body);

      final newProduct = Product(
          id: obj['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _items.add(newProduct);
      notifyListeners();
    } catch (err) {
      print(err);
      throw err;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final indx = _items.indexWhere((prod) => id == prod.id);
    if (indx >= 0) {
      final url =
          Uri.parse("https://my_prefix.firebasedatabase.app/products/$id.json");
      await http.patch(
        url,
        body: json.encode({
          'title': newProduct.title,
          'description': newProduct.description,
          'imageUrl': newProduct.imageUrl,
          'price': newProduct.price,
        }),
      );
      _items[indx] = newProduct;
      notifyListeners();
    }
  }

  Future<void> deleteProduct(String id) async {
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final url =
        Uri.parse("https://my_prefix.firebasedatabase.app/products/$id.json");
    final resp = await http.delete(url);
    if (resp.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException("Couldn't delete product!");
    }
    existingProduct.dispose();
  }
}
