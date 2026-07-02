import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'repositories/product_repository.dart';
import 'blocs/product_bloc.dart';
import 'blocs/cart_bloc.dart';
import 'blocs/favorite_bloc.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provide a single instance of the repository
    final ProductRepository productRepository = ProductRepository();

    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductBloc>(
          create: (context) => ProductBloc(productRepository)..add(FetchProductsEvent()),
        ),
        BlocProvider<CartBloc>(
          create: (context) => CartBloc()..add(LoadCartEvent()),
        ),
        BlocProvider<FavoriteBloc>(
          create: (context) => FavoriteBloc()..add(LoadFavoritesEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'ShopSavvy',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HomePage(),
      ),
    );
  }
}
