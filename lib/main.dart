import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/cart_model.dart';
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/food_management_screen.dart';
import 'screens/order_management_screen.dart';
import 'screens/splash_screen.dart';
import 'db_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initDB();
  runApp(
    ChangeNotifierProvider(
      create: (_) => CartModel(),
      child: FoodOrderingApp(),
    ),
  );
}

class FoodOrderingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Food Ordering App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: SplashScreen(),
      routes: {
        '/home': (context) => HomeScreen(),
        '/cart': (context) => CartScreen(),
        '/food-management': (context) => FoodManagementScreen(),
        '/order-management': (context) => OrderManagementScreen(),
      },
    );
  }
}
