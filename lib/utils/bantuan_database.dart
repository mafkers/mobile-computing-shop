import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/produk.dart';
import '../models/item_keranjang.dart';

class BantuanDatabase {
  // Ini adalah pola Singleton, agar database hanya dibuka satu kali
  static final BantuanDatabase instance = BantuanDatabase._init();
  static Database? _database;

  BantuanDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Kita buat file database baru bernama toko_pintar.db
    _database = await _initDB('toko_pintar.db');
    return _database!;
  }

  Future<Database> _initDB(String namaFile) async {
    final lokasiDb = await getDatabasesPath();
    final lokasiLengkap = join(lokasiDb, namaFile);

    return await openDatabase(
      lokasiLengkap,
      version: 1,
      onCreate: _buatDatabase,
    );
  }

  Future _buatDatabase(Database db, int version) async {
    await db.execute('''
CREATE TABLE produk (
  id INTEGER PRIMARY KEY,
  judul TEXT,
  harga REAL,
  deskripsi TEXT,
  kategori TEXT,
  gambar TEXT
)
''');

    await db.execute('''
CREATE TABLE keranjang (
  idProduk INTEGER PRIMARY KEY,
  judul TEXT,
  harga REAL,
  gambar TEXT,
  jumlah INTEGER
)
''');

    await db.execute('''
CREATE TABLE favorit (
  idProduk INTEGER PRIMARY KEY,
  judul TEXT,
  harga REAL,
  gambar TEXT
)
''');
  }

  // --- Manajemen Cache Produk ---
  Future<void> simpanCacheProduk(List<Produk> daftarProduk) async {
    final db = await instance.database;
    await db.delete('produk'); // Bersihkan cache lama
    for (var p in daftarProduk) {
      await db.insert('produk', p.keMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
  }

  Future<List<Produk>> ambilProdukDariCache() async {
    final db = await instance.database;
    final hasil = await db.query('produk');
    return hasil.map((json) => Produk.dariMap(json)).toList();
  }

  // --- Manajemen Keranjang ---
  Future<void> tambahKeKeranjang(ItemKeranjang item) async {
    final db = await instance.database;
    await db.insert('keranjang', item.keMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> hapusDariKeranjang(int idProduk) async {
    final db = await instance.database;
    await db.delete('keranjang', where: 'idProduk = ?', whereArgs: [idProduk]);
  }

  Future<void> kosongkanKeranjang() async {
    final db = await instance.database;
    await db.delete('keranjang');
  }

  Future<List<ItemKeranjang>> ambilIsiKeranjang() async {
    final db = await instance.database;
    final hasil = await db.query('keranjang');
    return hasil.map((json) => ItemKeranjang.dariMap(json)).toList();
  }

  // --- Manajemen Favorit ---
  Future<void> tambahFavorit(Produk produk) async {
    final db = await instance.database;
    await db.insert('favorit', {
      'idProduk': produk.id,
      'judul': produk.judul,
      'harga': produk.harga,
      'gambar': produk.gambar,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> hapusFavorit(int idProduk) async {
    final db = await instance.database;
    await db.delete('favorit', where: 'idProduk = ?', whereArgs: [idProduk]);
  }

  Future<List<Produk>> ambilDaftarFavorit() async {
    final db = await instance.database;
    final hasil = await db.query('favorit');
    return hasil.map((json) => Produk(
      id: json['idProduk'] as int,
      judul: json['judul'] as String,
      harga: json['harga'] as double,
      gambar: json['gambar'] as String,
      deskripsi: '', // Favorit tidak butuh deskripsi penuh di list
      kategori: '',
    )).toList();
  }
}
