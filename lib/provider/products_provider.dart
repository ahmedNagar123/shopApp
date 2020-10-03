import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/module/httpException.dart';

import 'product.dart';

class ProductsProvider with ChangeNotifier {
  List<Product> _item = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];
  final String authToken;
  final String userId;

  ProductsProvider(this.authToken, this._item, this.userId);

  List<Product> get getItem {
    return [..._item];
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://shopapp-12be9.firebaseio.com/products.json?auth=$authToken&$filterString';
    try {
      final response = await http.get(url);
      List<Product> productData = [];
      final dataResponse = json.decode(response.body) as Map<String, dynamic>;
      if (dataResponse == null) {
        return;
      }
      url =
          'https://shopapp-12be9.firebaseio.com/userFavorites/$userId.json?auth=$authToken';

      final favoriteResponse = await http.get(url);
      final favoriteData = jsonDecode(favoriteResponse.body);
      dataResponse.forEach((prodId, product) {
        productData.add(
          Product(
              id: prodId,
              title: product['title'],
              description: product['description'],
              price: product['price'],
              imageUrl: product['imageUrl'],
              isFavorite:
                  favoriteData == null ? false : favoriteData[prodId] ?? false),
        );
      });
      _item = (productData);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> addItem(Product product) async {
    final url =
        'https://shopapp-12be9.firebaseio.com/products.json?auth=$authToken';
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
            'creatorId': userId,
          }));
      final productAdded = Product(
          id: jsonDecode(response.body)['name'],
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl);
      _item.add(productAdded);
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateItem(String id, Product product) async {
    final prodIndex = _item.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://shopapp-12be9.firebaseio.com/products/$id.json?auth=$authToken';
      await http.patch(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'price': product.price,
            'imageUrl': product.imageUrl,
          }));
      _item[prodIndex] = product;
      notifyListeners();
    } else {
      print('....');
    }
  }

  Future<void> removeItem(String id) async {
    final url =
        'https://shopapp-12be9.firebaseio.com/products/$id.json?auth=$authToken';
    final existingProductIndex = _item.indexWhere((prod) => prod.id == id);
    var existingProduct = _item[existingProductIndex];
    _item.removeWhere((prod) => prod.id == id);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _item.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }

  List<Product> get favoriteItem {
    return _item.where((prodItem) => prodItem.isFavorite).toList();
  }

  int itemLength() {
    return _item.length;
  }

  Product findById(String id) {
    return _item.firstWhere((item) => item.id == id);
  }
}
