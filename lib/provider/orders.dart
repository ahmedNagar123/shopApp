import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../provider/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _items = [];

  List<OrderItem> get items {
    return [..._items];
  }

  Future<void> addOrder(double total, List<CartItem> cartItem) async {
    var timeStamp = DateTime.now();
    const url = 'https://shopapp-12be9.firebaseio.com/order.json';
    try {
      final response = await http.post(url,
          body: json.encode({
            'amount': total,
            'product': cartItem.map((prod) {
              return {
                'title': prod.title,
                'price': prod.price,
                'quantity': prod.quantity,
              };
            }).toList(),
            'dateTime': timeStamp.toIso8601String(),
          }));
      final orderAdded = OrderItem(
          id: jsonDecode(response.body)['name'],
          amount: total,
          products: cartItem,
          dateTime: timeStamp);
      _items.add(orderAdded);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> fetchAndSetProducts() async {
    const url = 'https://shopapp-12be9.firebaseio.com/order.json';
    try {
      final response = await http.get(url);
      List<OrderItem> orderItem = [];
      final dataResponse = jsonDecode(response.body) as Map<String, dynamic>;
      if (dataResponse == null) {
        return;
      }
      dataResponse.forEach((ordId, order) {
        orderItem.add(OrderItem(
          id: ordId,
          amount: order['amount'],
          dateTime: DateTime.parse(order['dateTime']),
          products: (order['product'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  title: item['title'],
                  quantity: item['quantity'],
                  price: item['price'],
                ),
              )
              .toList(),
        ));
      });
      _items = orderItem;
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
