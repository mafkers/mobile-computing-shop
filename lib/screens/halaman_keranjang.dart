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
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Tagihan:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              '\$${state.totalHarga.toStringAsFixed(2)}', 
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // Tombol Checkout
                        BlocListener<BlokKeranjang, StateKeranjang>(
                          listenWhen: (previous, current) {
                            if (previous is KeranjangBerhasilDimuat && current is KeranjangBerhasilDimuat) {
                              return previous.daftarItem.isNotEmpty && current.daftarItem.isEmpty;
                            }
                            return current is KeranjangGagalDimuat;
                          },
                          listener: (context, state) {
                            if (state is KeranjangBerhasilDimuat && state.daftarItem.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Pembayaran Sukses! Terima kasih.'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            } else if (state is KeranjangGagalDimuat) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.pesanPeringatan), backgroundColor: Colors.red),
                              );
                            }
                          },
                          child: SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                              ),
                              onPressed: () {
                                context.read<BlokKeranjang>().add(KosongkanKeranjangEvent());
                              },
                              child: const Text(
                                'Checkout Sekarang',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
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
