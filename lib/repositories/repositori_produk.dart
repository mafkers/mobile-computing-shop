import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/produk.dart';
import '../utils/bantuan_database.dart';

class RepositoriProduk {
  final String _urlDasar = 'https://fakestoreapi.com';

  // Fungsi untuk mengecek apakah HP ada koneksi internet
  Future<bool> _cekInternet() async {
    var hasilKoneksi = await (Connectivity().checkConnectivity());
    return hasilKoneksi.any((r) => r != ConnectivityResult.none);
  }

  Future<List<Produk>> ambilSemuaProduk() async {
    final adaInternet = await _cekInternet();
    
    if (adaInternet) {
      try {
        final respon = await http.get(Uri.parse('$_urlDasar/products'));
        if (respon.statusCode == 200) {
          final List<dynamic> dataJson = json.decode(respon.body);
          final daftarProduk = dataJson.map((json) => Produk.dariJson(json)).toList();
          
          // Simpan ke database lokal sebagai cadangan (cache)
          await BantuanDatabase.instance.simpanCacheProduk(daftarProduk);
          return daftarProduk;
        }
      } catch (e) {
        debugPrint("Terjadi kesalahan API: $e");
      }
    }
    
    // Jika internet mati atau API error, ambil data cadangan dari SQLite lokal
    debugPrint("Mengambil data dari Penyimpanan Lokal...");
    return await BantuanDatabase.instance.ambilProdukDariCache();
  }

  Future<List<Produk>> ambilProdukBerdasarkanKategori(String kategori) async {
    final adaInternet = await _cekInternet();
    
    if (adaInternet) {
      try {
        final respon = await http.get(Uri.parse('$_urlDasar/products/category/$kategori'));
        if (respon.statusCode == 200) {
          final List<dynamic> dataJson = json.decode(respon.body);
          return dataJson.map((json) => Produk.dariJson(json)).toList();
        }
      } catch (e) {
        debugPrint("Terjadi kesalahan API: $e");
      }
    }
    
    // Jika offline, ambil dari cache lalu filter berdasarkan kategori
    final produkLokal = await BantuanDatabase.instance.ambilProdukDariCache();
    return produkLokal.where((p) => p.kategori.toLowerCase() == kategori.toLowerCase()).toList();
  }

  Future<List<Produk>> cariProduk(String kataKunci) async {
    // Meminta semua produk (entah dari API atau Cache) lalu menyaringnya
    final semuaProduk = await ambilSemuaProduk(); 
    return semuaProduk.where((p) => p.judul.toLowerCase().contains(kataKunci.toLowerCase())).toList();
  }
}
