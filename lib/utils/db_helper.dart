import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';
import '../models/cart_item.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('shop_savvy.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
CREATE TABLE products (
  id INTEGER PRIMARY KEY,
  title TEXT,
  price REAL,
  description TEXT,
  category TEXT,
  image TEXT
)
''');

    await db.execute('''
CREATE TABLE cart (
  productId INTEGER PRIMARY KEY,
  title TEXT,
  price REAL,
  image TEXT,
  quantity INTEGER
)
''');

    await db.execute('''
CREATE TABLE favorites (
  productId INTEGER PRIMARY KEY,
  title TEXT,
  price REAL,
  image TEXT
)
''');
  }

  // --- Products Cache ---
  Future<void> cacheProducts(List<Product> products) async {
    final db = await instance.database;
    await db.delete('products'); // Clear old cache
    for (var product in products) {
      await db.insert('products', product.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Product>> getCachedProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => Product.fromMap(json)).toList();
  }

  // --- Cart Management ---
  Future<void> addToCart(CartItem item) async {
    final db = await instance.database;
    await db.insert('cart', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFromCart(int productId) async {
    final db = await instance.database;
    await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }

  Future<void> clearCart() async {
    final db = await instance.database;
    await db.delete('cart');
  }

  Future<List<CartItem>> getCartItems() async {
    final db = await instance.database;
    final result = await db.query('cart');
    return result.map((json) => CartItem.fromMap(json)).toList();
  }

  // --- Favorites Management ---
  Future<void> addFavorite(Product product) async {
    final db = await instance.database;
    await db.insert('favorites', {
      'productId': product.id,
      'title': product.title,
      'price': product.price,
      'image': product.image,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> removeFavorite(int productId) async {
    final db = await instance.database;
    await db.delete('favorites', where: 'productId = ?', whereArgs: [productId]);
  }

  Future<List<Product>> getFavorites() async {
    final db = await instance.database;
    final result = await db.query('favorites');
    return result.map((json) => Product(
      id: json['productId'] as int,
      title: json['title'] as String,
      price: json['price'] as double,
      image: json['image'] as String,
      description: '', // Favorites don't need full description in list
      category: '',
    )).toList();
  }
}
