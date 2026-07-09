import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/produk.dart';
import '../utils/bantuan_database.dart';

// --- BAGIAN EVENT ---
abstract class EventFavorit extends Equatable {
  const EventFavorit();
  @override
  List<Object> get props => [];
}

class MuatFavoritEvent extends EventFavorit {}

class UbahStatusFavoritEvent extends EventFavorit {
  final Produk produk;
  const UbahStatusFavoritEvent(this.produk);
  @override
  List<Object> get props => [produk];
}

// --- BAGIAN STATE ---
abstract class StateFavorit extends Equatable {
  const StateFavorit();
  @override
  List<Object> get props => [];
}

class FavoritAwal extends StateFavorit {}

class FavoritSedangMemuat extends StateFavorit {}

class FavoritBerhasilDimuat extends StateFavorit {
  final List<Produk> daftarFavorit;
  const FavoritBerhasilDimuat(this.daftarFavorit);
  
  // Memeriksa apakah suatu produk ada di daftar favorit
  bool cekApakahFavorit(int idProduk) => daftarFavorit.any((p) => p.id == idProduk);
  
  @override
  List<Object> get props => [daftarFavorit];
}

class FavoritGagalDimuat extends StateFavorit {
  final String pesanPeringatan;
  const FavoritGagalDimuat(this.pesanPeringatan);
  @override
  List<Object> get props => [pesanPeringatan];
}

// --- BAGIAN BLOC ---
class BlokFavorit extends Bloc<EventFavorit, StateFavorit> {
  BlokFavorit() : super(FavoritAwal()) {
    
    on<MuatFavoritEvent>((event, emit) async {
      emit(FavoritSedangMemuat());
      try {
        final favoritLokal = await BantuanDatabase.instance.ambilDaftarFavorit();
        emit(FavoritBerhasilDimuat(favoritLokal));
      } catch (e) {
        emit(FavoritGagalDimuat("Gagal memuat barang favorit: $e"));
      }
    });

    on<UbahStatusFavoritEvent>((event, emit) async {
      try {
        final favoritLama = await BantuanDatabase.instance.ambilDaftarFavorit();
        final apakahSudahFavorit = favoritLama.any((p) => p.id == event.produk.id);
        
        // Logika Toggle: Kalau sudah ada dihapus, kalau belum ada ditambahkan
        if (apakahSudahFavorit) {
          await BantuanDatabase.instance.hapusFavorit(event.produk.id);
        } else {
          await BantuanDatabase.instance.tambahFavorit(event.produk);
        }
        
        final favoritTerbaru = await BantuanDatabase.instance.ambilDaftarFavorit();
        emit(FavoritBerhasilDimuat(favoritTerbaru));
      } catch (e) {
        emit(FavoritGagalDimuat("Gagal mengubah status favorit: $e"));
      }
    });
    
  }
}
