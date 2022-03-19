import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import './cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    required this.id,
    required this.amount,
    required this.products,
    required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [..._orders];
  }

  Future<void> fetchOrders() async {
    final url = Uri.parse("https://my_prefix.firebasedatabase.app/orders.json");
    try {
      final resp = await http.get(url);
      final data =
          json.decode(resp.body) ?? <String, dynamic>{} as Map<String, dynamic>;
      if (data == <String, dynamic>{}) {
        return;
      }
      final List<OrderItem> loadedOrders = [];

      data.forEach((orderId, orderData) {
        loadedOrders.add(
          OrderItem(
            id: orderId,
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>)
                .map(
                  (item) => CartItem(
                    id: item['id'],
                    title: item['title'],
                    quantity: item['quantity'],
                    price: item['price'],
                  ),
                )
                .toList(),
            amount: orderData['amount'],
          ),
        );
      });
      _orders = loadedOrders.reversed.toList();
      notifyListeners();
    } catch (err) {
      print(err);
    }
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final url = Uri.parse("https://my_prefix.firebasedatabase.app/orders.json");
    final timeStamp = DateTime.now();
    try {
      final resp = await http.post(
        url,
        body: json.encode({
          'amount': total,
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price
                  })
              .toList(),
          'dateTime': timeStamp.toIso8601String(),
        }),
      );
      final obj = json.decode(resp.body);
      _orders.insert(
        0,
        OrderItem(
          id: obj['name'],
          amount: total,
          products: cartProducts,
          dateTime: timeStamp,
        ),
      );
      notifyListeners();
    } catch (err) {
      print("Order Err: ");
      print(err);
    }
  }
}
