import 'produk.dart';

class ItemKeranjang {
  final Produk produk;
  int jumlah;

  ItemKeranjang({
    required this.produk,
    this.jumlah = 1,
  });

  Map<String, dynamic> keMap() {
    return {
      'idProduk': produk.id,
      'judul': produk.judul,
      'harga': produk.harga,
      'gambar': produk.gambar,
      'jumlah': jumlah,
    };
  }

  factory ItemKeranjang.dariMap(Map<String, dynamic> map) {
    return ItemKeranjang(
      produk: Produk(
        id: map['idProduk'],
        judul: map['judul'],
        harga: map['harga'],
        gambar: map['gambar'],
        deskripsi: '', // Deskripsi tidak wajib untuk keranjang
        kategori: '',  // Kategori tidak wajib untuk keranjang
      ),
      jumlah: map['jumlah'],
    );
  }
}
