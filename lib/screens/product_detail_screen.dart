import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/products_provider.dart';

class ProductDetailsScreen extends StatelessWidget {
  static const String routeName = '/product-detail';

  @override
  Widget build(BuildContext context) {
    final id = ModalRoute.of(context).settings.arguments as String;
    final firstWhere = Provider.of<ProductsProvider>(context).findById(id);
    return Scaffold(
      appBar: AppBar(
        title: Text(firstWhere.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              child: Image.network(
                firstWhere.imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: 300,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${firstWhere.price.toString()}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${firstWhere.description.toString()}',
            )
          ],
        ),
      ),
    );
  }
}
