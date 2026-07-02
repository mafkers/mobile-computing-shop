import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../models/product.dart';
import '../blocs/cart_bloc.dart';
import '../blocs/favorite_bloc.dart';

class DetailPage extends StatelessWidget {
  final Product product;

  const DetailPage({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.title),
        actions: [
          BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              bool isFav = false;
              if (state is FavoriteLoaded) {
                isFav = state.favorites.any((p) => p.id == product.id);
              }
              return IconButton(
                icon: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                onPressed: () {
                  context.read<FavoriteBloc>().add(ToggleFavoriteEvent(product));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(isFav ? 'Removed from favorites' : 'Added to favorites')),
                  );
                },
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Hero(
              tag: product.id,
              child: CachedNetworkImage(
                imageUrl: product.image,
                height: 300,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(product.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Add to Cart'),
                      onPressed: () {
                        context.read<CartBloc>().add(AddToCartEvent(product));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added to Cart!')),
                        );
                      },
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
