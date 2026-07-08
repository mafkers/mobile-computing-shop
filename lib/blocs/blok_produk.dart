import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/produk.dart';
import '../repositories/repositori_produk.dart';

// --- BAGIAN EVENT (Kejadian / Perintah dari Antarmuka) ---
abstract class EventProduk extends Equatable {
  const EventProduk();
  @override
  List<Object> get props => [];
}

class AmbilSemuaProdukEvent extends EventProduk {}

class AmbilProdukBerdasarkanKategoriEvent extends EventProduk {
  final String kategori;
  const AmbilProdukBerdasarkanKategoriEvent(this.kategori);
  @override
  List<Object> get props => [kategori];
}

class CariProdukEvent extends EventProduk {
  final String kataKunci;
  const CariProdukEvent(this.kataKunci);
  @override
  List<Object> get props => [kataKunci];
}

// --- BAGIAN STATE (Kondisi / Hasil dari BLoC) ---
abstract class StateProduk extends Equatable {
  const StateProduk();
  @override
  List<Object> get props => [];
}

class ProdukAwal extends StateProduk {}

class ProdukSedangMemuat extends StateProduk {}

class ProdukBerhasilDimuat extends StateProduk {
  final List<Produk> daftarProduk;
  const ProdukBerhasilDimuat(this.daftarProduk);
  @override
  List<Object> get props => [daftarProduk];
}

class ProdukGagalDimuat extends StateProduk {
  final String pesanPeringatan;
  const ProdukGagalDimuat(this.pesanPeringatan);
  @override
  List<Object> get props => [pesanPeringatan];
}

// --- BAGIAN BLOC (Otak Pemroses) ---
class BlokProduk extends Bloc<EventProduk, StateProduk> {
  final RepositoriProduk repositori;

  BlokProduk(this.repositori) : super(ProdukAwal()) {
    
    on<AmbilSemuaProdukEvent>((event, emit) async {
      emit(ProdukSedangMemuat());
      try {
        final produk = await repositori.ambilSemuaProduk();
        emit(ProdukBerhasilDimuat(produk));
      } catch (e) {
        emit(ProdukGagalDimuat("Gagal mengambil data produk: $e"));
      }
    });

    on<AmbilProdukBerdasarkanKategoriEvent>((event, emit) async {
      emit(ProdukSedangMemuat());
      try {
        final produk = await repositori.ambilProdukBerdasarkanKategori(event.kategori);
        emit(ProdukBerhasilDimuat(produk));
      } catch (e) {
        emit(ProdukGagalDimuat("Gagal mengambil data produk: $e"));
      }
    });

    on<CariProdukEvent>((event, emit) async {
      emit(ProdukSedangMemuat());
      try {
        if (event.kataKunci.isEmpty) {
          final produk = await repositori.ambilSemuaProduk();
          emit(ProdukBerhasilDimuat(produk));
        } else {
          final produk = await repositori.cariProduk(event.kataKunci);
          emit(ProdukBerhasilDimuat(produk));
        }
      } catch (e) {
        emit(ProdukGagalDimuat("Gagal mencari produk: $e"));
      }
    });
    
  }
}
