import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../blocs/cart_bloc.dart';

class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              context.read<CartBloc>().add(ClearCartEvent());
            },
          )
        ],
      ),
      body: BlocBuilder<CartBloc, CartState>(
        builder: (context, state) {
          if (state is CartLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is CartError) {
            return Center(child: Text(state.message));
          } else if (state is CartLoaded) {
            if (state.items.isEmpty) {
              return const Center(child: Text('Your cart is empty.'));
            }
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.items.length,
                    itemBuilder: (context, index) {
                      final item = state.items[index];
                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: item.product.image,
                          width: 50,
                        ),
                        title: Text(item.product.title, maxLines: 1),
                        subtitle: Text('\$${item.product.price} x ${item.quantity}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            context.read<CartBloc>().add(RemoveFromCartEvent(item.product.id));
                          },
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text('\$${state.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: () {
                          context.read<CartBloc>().add(ClearCartEvent());
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Checkout Successful!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('Checkout', style: TextStyle(color: Colors.white, fontSize: 16)),
                      ),
                    ],
                  ),
                )
              ],
            );
          }
          return const Center(child: Text('Unknown State'));
        },
      ),
    );
  }
}
