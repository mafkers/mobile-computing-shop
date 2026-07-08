class Produk {
  final int id;
  final String judul;
  final double harga;
  final String deskripsi;
  final String kategori;
  final String gambar;

  Produk({
    required this.id,
    required this.judul,
    required this.harga,
    required this.deskripsi,
    required this.kategori,
    required this.gambar,
  });

  // Fungsi ini bertugas mengubah data JSON (dari internet) menjadi objek Dart.
  // Perhatikan bahwa teks (key) seperti 'id', 'title', dll adalah struktur asli dari internet,
  // sehingga tidak boleh diubah.
  factory Produk.dariJson(Map<String, dynamic> json) {
    return Produk(
      id: json['id'],
      judul: json['title'],
      harga: (json['price'] as num).toDouble(),
      deskripsi: json['description'],
      kategori: json['category'],
      gambar: json['image'],
    );
  }

  // Fungsi ini bertugas mengubah objek Dart menjadi format map agar bisa disimpan ke SQLite.
  Map<String, dynamic> keMap() {
    return {
      'id': id,
      'judul': judul,
      'harga': harga,
      'deskripsi': deskripsi,
      'kategori': kategori,
      'gambar': gambar,
    };
  }

  // Fungsi ini bertugas mengubah data mentah dari database SQLite kembali menjadi objek Dart.
  factory Produk.dariMap(Map<String, dynamic> map) {
    return Produk(
      id: map['id'],
      judul: map['judul'],
      harga: (map['harga'] as num).toDouble(),
      deskripsi: map['deskripsi'],
      kategori: map['kategori'],
      gambar: map['gambar'],
    );
  }
}
