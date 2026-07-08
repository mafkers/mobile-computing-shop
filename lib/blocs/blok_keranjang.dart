import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/item_keranjang.dart';
import '../models/produk.dart';
import '../utils/bantuan_database.dart';

// --- BAGIAN EVENT (Perintah dari Layar) ---
abstract class EventKeranjang extends Equatable {
  const EventKeranjang();
  @override
  List<Object> get props => [];
}

class MuatKeranjangEvent extends EventKeranjang {}

class TambahKeKeranjangEvent extends EventKeranjang {
  final Produk produk;
  const TambahKeKeranjangEvent(this.produk);
  @override
  List<Object> get props => [produk];
}

class HapusDariKeranjangEvent extends EventKeranjang {
  final int idProduk;
  const HapusDariKeranjangEvent(this.idProduk);
  @override
  List<Object> get props => [idProduk];
}

class KosongkanKeranjangEvent extends EventKeranjang {}

// --- BAGIAN STATE (Kondisi Layar) ---
abstract class StateKeranjang extends Equatable {
  const StateKeranjang();
  @override
  List<Object> get props => [];
}

class KeranjangAwal extends StateKeranjang {}

class KeranjangSedangMemuat extends StateKeranjang {}

class KeranjangBerhasilDimuat extends StateKeranjang {
  final List<ItemKeranjang> daftarItem;
  const KeranjangBerhasilDimuat(this.daftarItem);
  
  // Menghitung total tagihan belanjaan secara otomatis
  double get totalHarga => daftarItem.fold(0, (total, itemLancar) => total + (itemLancar.produk.harga * itemLancar.jumlah));
  
  @override
  List<Object> get props => [daftarItem];
}

class KeranjangGagalDimuat extends StateKeranjang {
  final String pesanPeringatan;
  const KeranjangGagalDimuat(this.pesanPeringatan);
  @override
  List<Object> get props => [pesanPeringatan];
}

// --- BAGIAN BLOC (Logika Perhitungan) ---
class BlokKeranjang extends Bloc<EventKeranjang, StateKeranjang> {
  BlokKeranjang() : super(KeranjangAwal()) {
    
    on<MuatKeranjangEvent>((event, emit) async {
      emit(KeranjangSedangMemuat());
      try {
        final barangKeranjang = await BantuanDatabase.instance.ambilIsiKeranjang();
        emit(KeranjangBerhasilDimuat(barangKeranjang));
      } catch (e) {
        emit(KeranjangGagalDimuat("Gagal memuat isi keranjang: $e"));
      }
    });

    on<TambahKeKeranjangEvent>((event, emit) async {
      try {
        // Cek apakah barang sudah pernah dimasukkan ke keranjang
        final keranjangLama = await BantuanDatabase.instance.ambilIsiKeranjang();
        final barangDitemukan = keranjangLama.where((item) => item.produk.id == event.produk.id).toList();
        
        if (barangDitemukan.isNotEmpty) {
          // Jika ada, tambahkan saja jumlahnya
          final itemSama = barangDitemukan.first;
          itemSama.jumlah += 1;
          await BantuanDatabase.instance.tambahKeKeranjang(itemSama);
        } else {
          // Jika belum ada, masukkan barang baru
          await BantuanDatabase.instance.tambahKeKeranjang(ItemKeranjang(produk: event.produk));
        }
        
        final keranjangTerbaru = await BantuanDatabase.instance.ambilIsiKeranjang();
        emit(KeranjangBerhasilDimuat(keranjangTerbaru));
      } catch (e) {
        emit(KeranjangGagalDimuat("Gagal memasukkan barang ke keranjang: $e"));
      }
    });

    on<HapusDariKeranjangEvent>((event, emit) async {
      try {
        await BantuanDatabase.instance.hapusDariKeranjang(event.idProduk);
        final keranjangTerbaru = await BantuanDatabase.instance.ambilIsiKeranjang();
        emit(KeranjangBerhasilDimuat(keranjangTerbaru));
      } catch (e) {
        emit(KeranjangGagalDimuat("Gagal menghapus dari keranjang: $e"));
      }
    });
    
    on<KosongkanKeranjangEvent>((event, emit) async {
      try {
        await BantuanDatabase.instance.kosongkanKeranjang();
        emit(const KeranjangBerhasilDimuat([]));
      } catch (e) {
        emit(KeranjangGagalDimuat("Gagal mengosongkan keranjang: $e"));
      }
    });
    
  }
}
