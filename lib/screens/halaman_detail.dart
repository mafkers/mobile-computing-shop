import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/produk.dart';
import '../blocs/blok_keranjang.dart';
import '../blocs/blok_favorit.dart';

class HalamanDetail extends StatelessWidget {
  final Produk produk;

  // Halaman ini butuh data 'produk' saat dipanggil (sebagai parameter)
  const HalamanDetail({super.key, required this.produk});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(produk.judul),
        actions: [
          // Widget untuk memantau status Hati (Favorit)
          BlocBuilder<BlokFavorit, StateFavorit>(
            builder: (context, state) {
              bool apakahFavorit = false;
              // Jika berhasil dimuat, kita cari apakah produk ini ada di dalam daftar favorit
              if (state is FavoritBerhasilDimuat) {
                apakahFavorit = state.cekApakahFavorit(produk.id);
              }
              
              return IconButton(
                // Jika ya, hatinya merah penuh. Jika tidak, hatinya bolong.
                icon: Icon(apakahFavorit ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                onPressed: () {
                  // Kirim event ke BLoC untuk mengubah status favorit
                  context.read<BlokFavorit>().add(UbahStatusFavoritEvent(produk));
                  
                  // Munculkan notifikasi hitam kecil di bawah layar (Snackbar)
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(apakahFavorit ? 'Dihapus dari daftar favorit' : 'Ditambahkan ke favorit')),
                  );
                },
              );
            },
          )
        ],
      ),
      // SingleChildScrollView agar layarnya bisa di-scroll jika deskripsinya sangat panjang
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero adalah animasi terbang yang membuat gambar mulus menyambung dari halaman depan
            Hero(
              tag: produk.id,
              child: CachedNetworkImage(
                imageUrl: produk.gambar,
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
                    produk.judul,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '\$${produk.harga}',
                    style: const TextStyle(fontSize: 20, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      produk.kategori.toUpperCase(),
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Deskripsi Produk', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text(produk.deskripsi, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 30),
                  
                  // Tombol Lebar Penuh (Full Width) untuk Tambah ke Keranjang
                  BlocListener<BlokKeranjang, StateKeranjang>(
                    listener: (context, state) {
                      if (state is KeranjangBerhasilDimuat) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Berhasil ditambahkan ke Keranjang!'), backgroundColor: Colors.green),
                        );
                      } else if (state is KeranjangGagalDimuat) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(state.pesanPeringatan), backgroundColor: Colors.red),
                        );
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text('Tambah ke Keranjang'),
                        onPressed: () {
                          // Tembakkan event ke BLoC (Notifikasi akan dihandle oleh BlocListener di atas)
                          context.read<BlokKeranjang>().add(TambahKeKeranjangEvent(produk));
                        },
                      ),
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
