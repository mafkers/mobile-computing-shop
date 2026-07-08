import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../blocs/blok_keranjang.dart';

class HalamanKeranjang extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Keranjang Belanja'),
        actions: [
          // Tombol sapu untuk membuang semua isi keranjang
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              context.read<BlokKeranjang>().add(KosongkanKeranjangEvent());
            },
          )
        ],
      ),
      body: BlocBuilder<BlokKeranjang, StateKeranjang>(
        builder: (context, state) {
          if (state is KeranjangSedangMemuat) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is KeranjangGagalDimuat) {
            return Center(child: Text(state.pesanPeringatan));
          } else if (state is KeranjangBerhasilDimuat) {
            // Jika tidak ada barang yang mau dibeli
            if (state.daftarItem.isEmpty) {
              return const Center(child: Text('Keranjang Anda kosong. Ayo belanja!'));
            }
            
            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: state.daftarItem.length,
                    itemBuilder: (context, index) {
                      final item = state.daftarItem[index];
                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: item.produk.gambar,
                          width: 50,
                        ),
                        title: Text(item.produk.judul, maxLines: 1),
                        subtitle: Text('\$${item.produk.harga} x ${item.jumlah} buah'),
                        trailing: IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            // Event untuk menghapus 1 baris barang ini dari keranjang
                            context.read<BlokKeranjang>().add(HapusDariKeranjangEvent(item.produk.id));
                          },
                        ),
                      );
                    },
                  ),
                ),
                // Bagian bawah (Footer) untuk kalkulasi total harga dan tombol Checkout
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey[200],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Tagihan:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(
                            '\$${state.totalHarga.toStringAsFixed(2)}', 
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)
                          ),
                        ],
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                        ),
                        onPressed: () {
                          // Karena ini simulasi, checkout hanya menghapus data keranjang
                          context.read<BlokKeranjang>().add(KosongkanKeranjangEvent());
                          
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Pembayaran Sukses! Terima kasih.'),
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
          return const Center(child: Text('Kondisi tidak diketahui'));
        },
      ),
    );
  }
}
