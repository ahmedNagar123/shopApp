import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_drawer.dart';
import '../provider/products_provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/product_user.dart';

class UserProductScreen extends StatelessWidget {
  static const String routeName = '/user_product';

  Future<void> refreshData(BuildContext context) async {
    await Provider.of<ProductsProvider>(context, listen: false)
        .fetchAndSetProducts();
  }

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.of(context).pushNamed(EditProductScreen.routeName);
            },
          )
        ],
        title: Text('Your products'),
      ),
      drawer: AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => refreshData(context),
        child: ListView.builder(
          itemBuilder: (ctx, index) => ProductUser(
            id: productsData.getItem[index].id,
            title: productsData.getItem[index].title,
            imageUrl: productsData.getItem[index].imageUrl,
            description: productsData.getItem[index].description,
            price: productsData.getItem[index].price,
          ),
          itemCount: productsData.itemLength(),
        ),
      ),
    );
  }
}
