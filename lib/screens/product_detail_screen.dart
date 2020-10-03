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
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(firstWhere.title),
              background: Hero(
                tag: firstWhere.id,
                child: Image.network(
                  firstWhere.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: 300,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${firstWhere.price.toString()}',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(10),
              child: Text(
                '\$${firstWhere.description.toString()}',
                textAlign: TextAlign.center,
                softWrap: true,
              ),
            ),
            SizedBox(
              height: 800,
            )
          ]))
        ],
      ),
    );
  }
}
