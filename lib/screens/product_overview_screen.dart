import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/app_drawer.dart';
import 'package:shop_app/provider/cart.dart';
import 'package:shop_app/provider/products_provider.dart';
import 'package:shop_app/screens/cart_screen.dart';
import 'package:shop_app/widgets/badge.dart';

import '../widgets/gride_item.dart';

enum FilterOption { isFavorite, isAll }

class ProductOverviewScreen extends StatefulWidget {
  static const String routeName = '/product_overview';

  @override
  _ProductOverviewScreenState createState() => _ProductOverviewScreenState();
}

class _ProductOverviewScreenState extends State<ProductOverviewScreen> {
  var _showOnlyFavorite = false;
  var _inInit = true;
  var inLoading = false;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    if (_inInit) {
      setState(() {
        inLoading = true;
      });
      try {
        Provider.of<ProductsProvider>(context).fetchAndSetProducts().then((_) {
          setState(() {
            inLoading = false;
          });
        });
      } catch (error) {
        print(error);
      }
    }
    _inInit = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MyShop'),
        actions: <Widget>[
          PopupMenuButton(
            onSelected: (FilterOption selectedValue) {
              setState(() {
                if (selectedValue == FilterOption.isFavorite) {
                  _showOnlyFavorite = true;
                }
                if (selectedValue == FilterOption.isAll) {
                  _showOnlyFavorite = false;
                }
              });
            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_) => [
              PopupMenuItem(
                child: Text('isFavorite'),
                value: FilterOption.isFavorite,
              ),
              PopupMenuItem(
                child: Text('isAll'),
                value: FilterOption.isAll,
              ),
            ],
          ),
          Consumer<Cart>(
              builder: (ctx, cart, ch) => Badge(
                    value: cart.getLength.toString(),
                    child: IconButton(
                        icon: Icon(Icons.shopping_cart),
                        onPressed: () {
                          Navigator.of(context).pushNamed(CartScreen.routeName);
                        }),
                  ))
        ],
      ),
      drawer: AppDrawer(),
      body: inLoading
          ? Center(child: CircularProgressIndicator())
          : GridItem(showFavorite: _showOnlyFavorite),
    );
  }
}
