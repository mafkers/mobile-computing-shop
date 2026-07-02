import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../blocs/favorite_bloc.dart';
import 'detail_page.dart';

class FavoritePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: BlocBuilder<FavoriteBloc, FavoriteState>(
        builder: (context, state) {
          if (state is FavoriteLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoriteError) {
            return Center(child: Text(state.message));
          } else if (state is FavoriteLoaded) {
            if (state.favorites.isEmpty) {
              return const Center(child: Text('You have no favorite products.'));
            }
            return ListView.builder(
              itemCount: state.favorites.length,
              itemBuilder: (context, index) {
                final product = state.favorites[index];
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: product.image,
                    width: 50,
                  ),
                  title: Text(product.title, maxLines: 1),
                  subtitle: Text('\$${product.price}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      context.read<FavoriteBloc>().add(ToggleFavoriteEvent(product));
                    },
                  ),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(product: product)));
                  },
                );
              },
            );
          }
          return const Center(child: Text('Unknown State'));
        },
      ),
    );
  }
}
