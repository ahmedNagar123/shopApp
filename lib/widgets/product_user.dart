import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/provider/products_provider.dart';
import 'package:shop_app/screens/edit_product_screen.dart';

class ProductUser extends StatelessWidget {
  final String id;
  final String title;
  final String imageUrl;
  final String description;
  final double price;

  ProductUser(
      {this.id, this.title, this.imageUrl, this.description, this.price});

  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold.of(context);
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 4,
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text('\$${price.toString()}'),
        leading: CircleAvatar(
          backgroundImage: NetworkImage(
            imageUrl,
          ),
        ),
        trailing: Container(
          width: 100,
          child: Row(
            children: [
              IconButton(
                  icon: Icon(Icons.edit),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(EditProductScreen.routeName, arguments: id);
                  }),
              IconButton(
                  icon: Icon(Icons.delete),
                  color: Theme.of(context).errorColor,
                  onPressed: () async {
                    try {
                      await Provider.of<ProductsProvider>(context,
                              listen: false)
                          .removeItem(id);
                    } catch (error) {
                      scaffold.showSnackBar(
                          SnackBar(content: Text('Deleting failed')));
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
