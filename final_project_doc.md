# Final Project: ShopSavvy (Aplikasi E-Commerce)

Aplikasi **ShopSavvy** adalah *final project* yang dibangun menggunakan arsitektur BLoC yang menggabungkan REST API (FakeStore API) dan *Local Storage* (SQLite) sebagai mekanisme *offline-fallback* (jika internet terputus).

---

## 1. Flow & Jumlah Halaman
Aplikasi E-Commerce "ShopSavvy" terdiri dari **4 Halaman Utama**:
1. **Home Page (`home_page.dart`)**: Menampilkan daftar produk (Grid) dari FakeStore API. 
   - **Fitur Khusus**: 
     - **Search Bar** di bagian atas untuk mem-filter barang secara *real-time* (Sama seperti tugas Movie Catalog).
     - **Pull-to-Refresh** (*Swipe* ke bawah) untuk memuat ulang data ke API.
2. **Detail Page (`detail_page.dart`)**: Menampilkan detail lengkap barang (harga, deskripsi, gambar). Terdapat tombol aksi **"Add to Cart"** dan **"Favorite (Heart Icon)"**.
3. **Cart Page (`cart_page.dart`)**: Berisi daftar barang belanjaan. Pengguna bisa menghapus barang individu, atau memencet tombol **Checkout** di bagian bawah yang akan memunculkan notifikasi sukses dan mengosongkan keranjang di database.
4. **Favorite Page (`favorite_page.dart`)**: Menampilkan semua produk yang telah ditandai sebagai favorit oleh pengguna.
   - **Flow:** Jika pengguna kembali menekan ikon hati merah, produk dihapus dari daftar favorit.

*(Catatan: Desain antarmuka/Mockup UI dapat divisualisasikan langsung dengan meng-compile `flutter run`, menghasilkan tampilan rapi dengan `GridView` dan `Card` yang memiliki estetika membulat/rounded).*

---

## 2. Arsitektur Proyek (Best Practice BLoC)

Seluruh logika UI dan State Management dipisahkan dengan bersih (Clean Architecture).

### ⚙️ Struktur Diagram BLoC & Layering
- **Data Layer (API & Local Storage)**
  - `ProductRepository`: Mengendalikan sumber data. Jika perangkat Online (terhubung internet), mengambil dari `fakestoreapi.com` dan menyimpannya (Caching) ke SQLite. Jika Offline, otomatis membaca data terakhir dari tabel `products` di SQLite.
  - `DatabaseHelper`: Menangani pembuatan tabel `products`, `cart`, dan `favorites` secara persisten menggunakan library `sqflite`.
- **Domain Layer (BLoC)**
  - `ProductBloc`: Menangani state list produk (`ProductLoading`, `ProductLoaded`, `ProductError`).
  - `CartBloc`: Mengatur logika keranjang belanja (Tambah, Hapus, Kosongkan) serta menghitung *Grand Total* belanja.
  - `FavoriteBloc`: Mengatur *toggle* favorit yang disinkronisasikan langsung ke SQLite.
- **Presentation Layer (UI / Widget)**
  - Memanfaatkan `MultiBlocProvider` di `main.dart` untuk membungkus keseluruhan aplikasi.
  - Setiap Page (layar) **hanya bertugas mendengarkan** (`BlocBuilder`) dan melempar event, **TIDAK MENGANDUNG LOGIKA DATA** sama sekali.

---

## 3. Library / Package yang Digunakan

| Package | Deskripsi (Fungsi dalam Proyek) |
| --- | --- |
| **`flutter_bloc`** & **`bloc`** | Otak utama *State Management*, mengatur arus lalu lintas data secara reaktif (*Event-Driven*). |
| **`equatable`** | Digunakan di dalam *state* BLoC untuk mempermudah perbandingan (*value-based comparison*) antar *state* agar UI tidak dirender ulang tanpa alasan. |
| **`http`** | Melakukan koneksi protokol GET ke layanan *REST API Backend* publik (*FakeStore API*). |
| **`sqflite`** | Implementasi *Local Storage* SQLite murni untuk menyimpan keranjang belanja, barang favorit, dan Caching produk (sebagai *fallback* internet). |
| **`path_provider`** | Mencari direktori sistem berkas yang aman di internal OS Android/iOS untuk meletakkan *file* database SQLite. |
| **`connectivity_plus`** | Mengecek secara dinamis apakah HP memiliki koneksi internet via WiFi atau Seluler sebelum memutuskan memanggil API atau SQLite. |
| **`cached_network_image`** | Mencegah *re-download* berulang pada gambar produk (menambah performa rendering) dan menampilkan *placeholder loading* yang elegan. |
