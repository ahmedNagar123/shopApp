import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_drawer.dart';
import '../provider/orders.dart' show Orders;
import '../widgets/order_item.dart';

class OrdersScreen extends StatefulWidget {
  static const String routeName = '/order_screen';

  @override
  _OrdersScreenState createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  Future futureord;

  Future futureMethod() {
    futureord =
        Provider.of<Orders>(context, listen: false).fetchAndSetProducts();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    futureMethod();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Your Order',
          ),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future: futureord,
          builder: (ctx, orderData) {
            if (orderData.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              if (orderData.connectionState != ConnectionState.done) {
                return Center(
                  child: Text('Wrong please , try Again'),
                );
              } else {
                return Consumer<Orders>(
                  builder: (con, orderData, _) {
                    return ListView.builder(
                      itemCount: orderData.items.length,
                      itemBuilder: (ctx, index) => OrderItem(
                        orderItem: orderData.items[index],
                      ),
                    );
                  },
                );
              }
            }
          },
        ));
  }
}
