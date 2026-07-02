import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product.dart';
import '../utils/db_helper.dart';

class ProductRepository {
  final String _baseUrl = 'https://fakestoreapi.com';

  Future<bool> _hasInternet() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult is List) {
      return connectivityResult.any((r) => r != ConnectivityResult.none);
    }
    return connectivityResult != ConnectivityResult.none;
  }

  Future<List<Product>> getProducts() async {
    final hasInternet = await _hasInternet();
    
    if (hasInternet) {
      try {
        final response = await http.get(Uri.parse('$_baseUrl/products'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          final products = data.map((json) => Product.fromJson(json)).toList();
          
          // Cache to local DB
          await DatabaseHelper.instance.cacheProducts(products);
          return products;
        }
      } catch (e) {
        print("API Error: $e");
      }
    }
    
    // Fallback to local SQLite cache
    print("Fetching from Local Storage...");
    return await DatabaseHelper.instance.getCachedProducts();
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final hasInternet = await _hasInternet();
    
    if (hasInternet) {
      try {
        final response = await http.get(Uri.parse('$_baseUrl/products/category/$category'));
        if (response.statusCode == 200) {
          final List<dynamic> data = json.decode(response.body);
          return data.map((json) => Product.fromJson(json)).toList();
        }
      } catch (e) {
        print("API Error: $e");
      }
    }
    
    // Fallback to local SQLite cache filtered by category
    final localProducts = await DatabaseHelper.instance.getCachedProducts();
    return localProducts.where((p) => p.category.toLowerCase() == category.toLowerCase()).toList();
  }

  Future<List<Product>> searchProducts(String query) async {
    final allProducts = await getProducts(); // Fetches from API or Cache
    return allProducts.where((p) => p.title.toLowerCase().contains(query.toLowerCase())).toList();
  }
}
