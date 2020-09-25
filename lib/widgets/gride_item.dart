import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/product.dart';
import '../provider/products_provider.dart';
import '../widgets/product_item.dart';

class GridItem extends StatelessWidget {
  final bool showFavorite;

  GridItem({this.showFavorite});

  @override
  Widget build(BuildContext context) {
    final productsProvider = Provider.of<ProductsProvider>(context);
    List<Product> item =
        showFavorite ? productsProvider.favoriteItem : productsProvider.getItem;
    return GridView.builder(
      padding: EdgeInsets.all(10),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 10),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        value: item[index],
        child: ProductItem(),
      ),
      itemCount: item.length,
    );
  }
}
