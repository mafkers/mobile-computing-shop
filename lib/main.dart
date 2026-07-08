import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'repositories/repositori_produk.dart';
import 'blocs/blok_produk.dart';
import 'blocs/blok_keranjang.dart';
import 'blocs/blok_favorit.dart';
import 'screens/halaman_utama.dart';

void main() {
  runApp(const AplikasiTokoPintar());
}

class AplikasiTokoPintar extends StatelessWidget {
  const AplikasiTokoPintar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Menyediakan satu instansiasi Repositori untuk dipakai bersama-sama
    final RepositoriProduk repositoriProduk = RepositoriProduk();

    return MultiBlocProvider(
      providers: [
        // BLoC untuk mengurus daftar produk. Saat dibentuk, otomatis menembak Event AmbilSemuaProduk
        BlocProvider<BlokProduk>(
          create: (context) => BlokProduk(repositoriProduk)..add(AmbilSemuaProdukEvent()),
        ),
        // BLoC untuk mengurus keranjang belanja. Saat dibentuk, otomatis menembak Event MuatKeranjang
        BlocProvider<BlokKeranjang>(
          create: (context) => BlokKeranjang()..add(MuatKeranjangEvent()),
        ),
        // BLoC untuk mengurus daftar favorit. Saat dibentuk, otomatis menembak Event MuatFavorit
        BlocProvider<BlokFavorit>(
          create: (context) => BlokFavorit()..add(MuatFavoritEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'Toko Pintar (ShopSavvy)',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: HalamanUtama(),
      ),
    );
  }
}
