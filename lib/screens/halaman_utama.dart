import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../blocs/blok_produk.dart';
import '../blocs/blok_keranjang.dart';
import '../models/produk.dart';
import 'halaman_detail.dart';
import 'halaman_keranjang.dart';
import 'halaman_favorit.dart';

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  
  // Fungsi ini otomatis berjalan satu kali saat layar pertama kali dibuka
  @override
  void initState() {
    super.initState();
    // Kita tembak Event untuk mengambil produk dari API saat aplikasi baru mulai
    context.read<BlokProduk>().add(AmbilSemuaProdukEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toko Pintar'),
        actions: [
          // Tombol menuju layar Favorit
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanFavorit())),
          ),
          
          // Widget untuk memantau status keranjang (menampilkan angka kecil merah)
          BlocBuilder<BlokKeranjang, StateKeranjang>(
            builder: (context, state) {
              int totalBarang = 0;
              // Jika data keranjang sukses dimuat, kita jumlahkan angka quantity-nya
              if (state is KeranjangBerhasilDimuat) {
                totalBarang = state.totalBarang;
              }
              
              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanKeranjang())),
                  ),
                  // Jika ada barang di keranjang, tampilkan bulatan merah
                  if (totalBarang > 0)
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
                          '$totalBarang',
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
          // Kolom Pencarian (Search Bar)
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari barang di sini...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              ),
              // Ketika huruf diketik, fungsi ini langsung jalan (real-time filtering)
              onChanged: (kataKunci) {
                context.read<BlokProduk>().add(CariProdukEvent(kataKunci));
              },
            ),
          ),
          
          // Filter Kategori
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                _buatTombolKategori(context, 'Semua', ''),
                const SizedBox(width: 8),
                _buatTombolKategori(context, 'Electronics', 'electronics'),
                const SizedBox(width: 8),
                _buatTombolKategori(context, 'Jewelery', 'jewelery'),
                const SizedBox(width: 8),
                _buatTombolKategori(context, 'Men\'s Clothing', "men's clothing"),
                const SizedBox(width: 8),
                _buatTombolKategori(context, 'Women\'s Clothing', "women's clothing"),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Daftar Produk
          Expanded(
            child: RefreshIndicator(
              // Fitur tarik ke bawah untuk menyegarkan (Pull to refresh)
              onRefresh: () async {
                context.read<BlokProduk>().add(AmbilSemuaProdukEvent());
              },
              child: BlocBuilder<BlokProduk, StateProduk>(
                builder: (context, state) {
                  // Jika sedang loading, tampilkan putaran
                  if (state is ProdukSedangMemuat) {
                    return const Center(child: CircularProgressIndicator());
                  } 
                  // Jika error, tampilkan teks error
                  else if (state is ProdukGagalDimuat) {
                    return Center(child: Text(state.pesanPeringatan));
                  } 
                  // Jika sukses dimuat, tampilkan daftar produk
                  else if (state is ProdukBerhasilDimuat) {
                    // Cek jika daftarnya kosong (tidak ada hasil pencarian)
                    if (state.daftarProduk.isEmpty) {
                      return ListView(
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                          const Icon(Icons.search_off, size: 80, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Center(child: Text('Barang tidak ditemukan.', style: TextStyle(fontSize: 18, color: Colors.grey))),
                          const Center(child: Text('Tarik layar ke bawah untuk refresh.', style: TextStyle(fontSize: 14, color: Colors.grey))),
                        ],
                      );
                    }
                    
                    // Bentuk daftar menjadi Kotak-kotak (Grid)
                    return GridView.builder(
                      padding: const EdgeInsets.all(10),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: state.daftarProduk.length,
                      itemBuilder: (context, index) {
                        final produk = state.daftarProduk[index];
                        return _buatKartuProduk(context, produk);
                      },
                    );
                  }
                  return const Center(child: Text("Tidak ada data"));
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Fungsi bantuan untuk membuat kartu (Card) produk agar kodingan di atas tidak terlalu panjang
  Widget _buatKartuProduk(BuildContext context, Produk produk) {
    return GestureDetector(
      // Ketika diklik, pindah ke Halaman Detail
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanDetail(produk: produk)));
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
                // CachedNetworkImage akan menyimpan gambar ke memori HP agar hemat kuota
                child: CachedNetworkImage(
                  imageUrl: produk.gambar,
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
                    produk.judul,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis, // Jika teks panjang, akan jadi titik-titik
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '\$${produk.harga}',
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

  // Fungsi bantuan untuk membuat tombol filter kategori
  Widget _buatTombolKategori(BuildContext context, String label, String kategoriApi) {
    return ActionChip(
      label: Text(label),
      onPressed: () {
        if (kategoriApi.isEmpty) {
          context.read<BlokProduk>().add(AmbilSemuaProdukEvent());
        } else {
          context.read<BlokProduk>().add(AmbilProdukBerdasarkanKategoriEvent(kategoriApi));
        }
      },
    );
  }
}
