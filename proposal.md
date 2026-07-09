# PROPOSAL PROYEK PENGEMBANGAN APLIKASI
## "ShopSavvy: Simulasi Aplikasi E-Commerce Berbasis Clean Architecture dengan Implementasi Offline-First Database"

---

### 1. LATAR BELAKANG
Dalam era digitalisasi yang berkembang pesat, aplikasi perdagangan elektronik (*E-Commerce*) telah menjadi bagian integral dari kehidupan masyarakat sehari-hari. Aplikasi-aplikasi skala besar seperti Tokopedia, Shopee, maupun Amazon dituntut untuk memiliki performa yang tinggi, tahan terhadap fluktuasi jaringan internet (anti-lag), dan memiliki arsitektur kode yang terstruktur rapi agar mudah dikelola oleh banyak *developer*.

Salah satu masalah klasik yang sering dialami oleh pengguna aplikasi *mobile* adalah hilangnya koneksi internet secara tiba-tiba (seperti saat berada di dalam kereta atau *blank spot*), yang seringkali menyebabkan aplikasi *Crash* atau kehilangan data transaksi yang belum selesai (misalnya hilangnya daftar keranjang belanja). Selain itu, dari sudut pandang rekayasa perangkat lunak (*Software Engineering*), percampuran antara logika antarmuka (UI) dan logika bisnis di dalam satu wujud kode (*Spaghetti Code*) masih sering dijumpai pada aplikasi skala menengah, yang berujung pada sulitnya pemeliharaan (*maintenance*) dan tingginya tingkat *bug*.

Berangkat dari urgensi tersebut, proyek **"ShopSavvy"** ini diajukan sebagai bentuk implementasi langsung (*Proof of Concept*) dari praktik terbaik rekayasa perangkat lunak modern. Aplikasi ini dikembangkan untuk mendemonstrasikan penyelesaian masalah di atas melalui penerapan standar arsitektur kelas industri.

### 2. RUMUSAN MASALAH
Berdasarkan latar belakang di atas, rumusan masalah dalam proyek ini adalah:
1. Bagaimana merancang arsitektur aplikasi *E-Commerce* yang memisahkan secara ketat antara logika antarmuka visual (UI) dengan logika bisnis matematika?
2. Bagaimana membangun mekanisme pencegahan *Crash* atau layar kosong (blank) saat perangkat pengguna kehilangan koneksi internet secara tiba-tiba?
3. Bagaimana cara menyimpan status transaksional (seperti Keranjang Belanja dan Favorit) secara persisten agar tidak hilang saat aplikasi ditutup paksa (*Force Close*)?

### 3. TUJUAN PROYEK
Proyek ini bertujuan untuk:
1. **Mengimplementasikan Clean Architecture:** Menerapkan struktur kode BLoC (*Business Logic Component*) untuk menciptakan status *Zero Leaked Logic*, di mana komponen UI murni hanya bertindak sebagai entitas penampil data pasif.
2. **Membangun Sistem Offline-First:** Mengembangkan kapabilitas integrasi HTTP REST API dengan mekanisme pencadangan (*Fallback/Cache*) ke database SQLite internal secara asinkron.
3. **Persistensi Data Lokal:** Memastikan stabilitas data pengguna (*Cart* dan *Wishlist*) dengan penyimpanan relasional berbasis file di direktori privat sistem operasi *mobile*.

### 4. RUANG LINGKUP & BATASAN (SCOPE)
Aplikasi ini dikembangkan sebagai prototipe fungsional (simulasi) dengan batasan berikut:
- **Katalog Produk:** Data produk bersifat dinamis namun tersentralisasi menggunakan `FakeStoreAPI` sebagai pihak penyedia (*Mock API*).
- **Pembayaran (Gateway):** Sistem *Checkout* sebatas simulasi manipulasi data keranjang (menghapus isi keranjang secara total), belum diintegrasikan dengan *Payment Gateway* perbankan asli.
- **Platform:** Ditargetkan berjalan dengan optimal dan *smooth* pada *Operating System* Android dan iOS.

### 5. METODOLOGI & ARSITEKTUR SISTEM
Pengembangan aplikasi dilakukan menggunakan bahasa **Dart** melalui kerangka kerja **Flutter**. Sistem dirancang dalam tiga lapisan terpisah (3-Tier Clean Architecture):
1. **Presentation Layer (UI):** Menggunakan `BlocBuilder` untuk bereaksi pada perubahan data tanpa menggunakan `setState` agar menghindari kebocoran memori (*Memory Leak*).
2. **Business Logic Layer (BLoC):** Memanfaatkan package `flutter_bloc` dan `equatable`. Bertindak sebagai pusat manajer perhitungan dan pemicu validasi kondisi.
3. **Data Layer:** 
   - **Remote:** HTTP Service untuk mengambil JSON (*Representational State Transfer*).
   - **Local:** `sqflite` dan `path` untuk menyimpan dan membaca data berbasis SQL pada memori sekunder (ROM) perangkat.
   - **Konektivitas:** `connectivity_plus` sebagai sakelar pengambil keputusan kapan menggunakan Remote dan kapan menggunakan Local.

### 6. FITUR UTAMA APLIKASI
1. **Katalog Produk *Real-Time*:** Menampilkan daftar barang (Pakaian, Elektronik, Perhiasan) dengan gambar yang dikelola menggunakan `cached_network_image`.
2. **Smart Filter & Search:** Pengguna dapat mencari barang dan memfilter kategori (dengan UI *Chips*) secara lokal dan instan tanpa membebani *server* API.
3. **Keranjang Belanja Persisten:** Akumulasi penambahan barang, kuantitas, serta kalkulasi nilai total tagihan dilakukan secara otomatis dan terstruktur oleh BLoC.
4. **Manajemen Wishlist:** Penandaan barang favorit (*Toggle Liked*) yang terintegrasi dengan database luring.
5. **Mode Luring (Offline Mode):** Transisi otomatis tanpa celah (*seamless*) untuk menampilkan *cache* katalog terakhir apabila koneksi terputus.

### 7. KESIMPULAN
Proyek aplikasi **ShopSavvy** ini tidak sekadar menunjukkan kapabilitas fungsional antarmuka, melainkan sebuah demonstrasi teknis yang kuat tentang bagaimana aplikasi moderen harus dibangun dari dalam (arsitektur). Dengan 0 (Nol) *linter error*, ketiadaan logika bisnis yang bocor di sisi antarmuka, serta integrasi manajemen koneksi yang cerdas, aplikasi ini layak menjadi representasi standar koding tingkat profesional.

---
*Dibuat untuk keperluan evaluasi teknis, ujian, dan presentasi pengembangan perangkat lunak.*
