import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop/Screens/cart_screen.dart';
import 'package:shop/Screens/edit_product_screen.dart';
import 'package:shop/Screens/order_screen.dart';
import 'package:shop/Screens/product_details_screen.dart';
import 'package:shop/Screens/proudect_screen.dart';
import 'package:shop/Screens/splash_screen.dart';
import 'package:shop/Screens/user_product_screen.dart';
import 'package:shop/provider/auth.dart';
import 'package:shop/provider/cart.dart';
import 'package:shop/provider/orders.dart';
import 'package:shop/provider/product.dart';

import 'Screens/auth_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: Auth()),
        ChangeNotifierProvider.value(value: Product()),
        ChangeNotifierProvider.value(value: cart()),
        ChangeNotifierProvider.value(value: Orders()),

      ],
      child:
      Consumer<Auth>(
    builder: (buildContext,auth,_)=>MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(

              primarySwatch: Colors.blue,
            ),
            routes: {
              AuthScreen.routeName:(buildContext)=>AuthScreen(),
              CartScreen.routeName:(buildContext)=>CartScreen(),
              EditProductScreen.routeName:(buildContext)=>EditProductScreen(),
              OrderScreen.routeName:(buildContext)=>OrderScreen(),
              ProductDetailsScreen.routeName:(buildContext)=>ProductDetailsScreen(),
              ProudectScreen.routeName:(buildContext)=>ProudectScreen(),
              UserProductScreen.routeName:(buildContext)=>UserProductScreen(),
            },
    home: auth.isAuth?ProudectScreen():FutureBuilder(
    future: auth.tryAutoLogin(),
    builder: (BuildContext context,AsyncSnapshot snapshot)=>snapshot.connectionState==ConnectionState.waiting?
    SplashScreen():AuthScreen()),
      ),
    )


    );
  }
}


