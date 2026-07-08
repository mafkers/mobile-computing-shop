import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../blocs/blok_favorit.dart';
import 'halaman_detail.dart';

class HalamanFavorit extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Barang Impianku'),
      ),
      body: BlocBuilder<BlokFavorit, StateFavorit>(
        builder: (context, state) {
          if (state is FavoritSedangMemuat) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FavoritGagalDimuat) {
            return Center(child: Text(state.pesanPeringatan));
          } else if (state is FavoritBerhasilDimuat) {
            // Jika belum pernah nge-like satupun barang
            if (state.daftarFavorit.isEmpty) {
              return const Center(child: Text('Kamu belum memiliki barang favorit.'));
            }
            
            return ListView.builder(
              itemCount: state.daftarFavorit.length,
              itemBuilder: (context, index) {
                final produk = state.daftarFavorit[index];
                return ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: produk.gambar,
                    width: 50,
                  ),
                  title: Text(produk.judul, maxLines: 1),
                  subtitle: Text('\$${produk.harga}'),
                  // Tombol hati merah untuk membatalkan (unlike)
                  trailing: IconButton(
                    icon: const Icon(Icons.favorite, color: Colors.red),
                    onPressed: () {
                      context.read<BlokFavorit>().add(UbahStatusFavoritEvent(produk));
                    },
                  ),
                  // Kalau baris ini diklik, masuk ke halaman detail
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => HalamanDetail(produk: produk)));
                  },
                );
              },
            );
          }
          return const Center(child: Text('Kondisi tidak diketahui'));
        },
      ),
    );
  }
}
