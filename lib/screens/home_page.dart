import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../blocs/product_bloc.dart';
import '../blocs/cart_bloc.dart';
import '../models/product.dart';
import 'detail_page.dart';
import 'cart_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(FetchProductsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ShopSavvy'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FavoritePage())),
          ),
          BlocBuilder<CartBloc, CartState>(
            builder: (context, state) {
              int count = 0;
              if (state is CartLoaded) {
                count = state.items.fold(0, (sum, item) => sum + item.quantity);
              }
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CartPage())),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                        child: Text(
                          '$count',
                          style: const TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                ],
              );
            },
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              onChanged: (query) {
                context.read<ProductBloc>().add(SearchProductsEvent(query));
              },
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                context.read<ProductBloc>().add(FetchProductsEvent());
              },
              child: BlocBuilder<ProductBloc, ProductState>(
                builder: (context, state) {
                  if (state is ProductLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ProductError) {
                    return Center(child: Text(state.message));
                  } else if (state is ProductLoaded) {
                    if (state.products.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                          const Icon(Icons.search_off, size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Center(child: Text('No products found.', style: TextStyle(fontSize: 18, color: Colors.grey))),
                          const Center(child: Text('Pull to refresh or try another search.', style: TextStyle(fontSize: 14, color: Colors.grey))),
                        ],
                      );
                    }
                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: state.products.length,
                      itemBuilder: (context, index) {
                        final product = state.products[index];
                        return _buildProductCard(context, product);
                      },
                    );
                  }
                  return const Center(child: Text("No Data"));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(product: product)));
      },
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                child: CachedNetworkImage(
                  imageUrl: product.image,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
