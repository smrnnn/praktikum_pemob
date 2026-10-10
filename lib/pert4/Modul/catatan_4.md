#  Pertemuan 4: Mengambil Data dari REST API (HTTP, Async, dan FutureBuilder)

## Ringkasan Teori Utama
*   **Asynchronous Dart:** Proses pengambilan data dari server luar membutuhkan jeda waktu. Agar UI tidak membeku, digunakan `Future` sebagai penampung data masa depan, kata kunci `async` untuk menandai fungsi asinkron, dan `await` untuk menunggu proses muat data selesai.
*   **Model Data (fromJson):** Mengubah data mentah berformat JSON (`Map<String, dynamic>`) dari internet menjadi objek model kelas Dart yang terstruktur sehingga penulisan kode lebih aman dari salah ketik (*auto-complete*).
*   **FutureBuilder & Snapshot:** Widget yang bertugas memantau status kondisi *Future* secara otomatis melalui parameter `snapshot` untuk membedakan 3 kondisi: *waiting* (loading), *hasError* (eror), dan *hasData* (berhasil).

---

## Langkah Praktikum & Fitur Komponen

### Bagian A: Dasar Future & FutureBuilder
*   Mensimulasikan jeda muat data lokal selama 2 detik menggunakan fungsi `Future.delayed`.
*   Memahami aturan wajib penempatan inisialisasi objek *Future* di dalam metode `initState()` agar data tidak dimuat ulang secara berulang-ulang (*infinite loop*) saat terjadi *rebuild* layar.

### Bagian B & C: Integrasi Paket HTTP & Model Data
*   Memasang pustaka jaringan internet eksternal via perintah terminal: `flutter pub add http`.
*   Menambahkan hak akses jaringan internet `<uses-permission android:name="android.permission.INTERNET"/>` pada berkas konfigurasi *AndroidManifest*.
*   Membangun kelas `class Pengguna` dan fungsi `ambilPengguna()` untuk mengurai (*parsing*) data larik JSON publik dari platform *JSONPlaceholder*.

### Bagian D & E: Penyajian Data & Halaman Detail
*   Menampilkan data nama dan email secara dinamis ke dalam `ListView.builder`.
*   Menghubungkan parameter `onTap` di daftar utama menuju halaman `DetailPenggunaPage` dengan memanfaatkan widget `ListTile` untuk memunculkan informasi email, nomor telepon, dan alamat website secara lengkap.

### Bagian F, Latihan, & Tugas Akhir
*   **Simulasi Penanganan Galat:** Melakukan uji coba kegagalan sistem dengan menyalahkan alamat URL (eror kode server 404) dan mematikan jaringan paket data internet (*SocketException*) lengkap dengan tombol coba lagi.
*   **Latihan Mandiri:** Menambahkan properti *username* dan data bersarang objek kota (`address.city`), membungkus halaman utama dengan sistem geser tarik bawah `RefreshIndicator`, serta menyematkan indikator total jumlah data pada *AppBar*.
*   **Tugas Akhir:** Membangun aplikasi "Daftar Postingan" dua halaman yang mengintegrasikan dua *endpoint* API terpisah (`/posts` dan `/comments`) untuk menampilkan isi tulisan artikel utuh beserta baris komentar terikat di bagian bawahnya secara responsif.

---

## Jawaban Pertanyaan Refleksi
1.  **Dampak Future di dalam build():** Proses penarikan data dari server API internet akan dieksekusi terus-menerus tanpa henti (*looping*) setiap kali layar bergeser, karena metode `build()` dipanggil berkali-kali oleh mesin Flutter.
2.  **StatusCode vs HasError:** Perintah `response.statusCode` digunakan khusus untuk mendeteksi status respons dari server (seperti kode sukses 200 atau eror 404/500), sedangkan perintah `snapshot.hasError` mendeteksi eror sistem di internal perangkat (seperti kuota internet HP habis total).
3.  **Urgensi Kelas Model:** Untuk menghindari *human error* akibat salah ketik teks kunci data mentah. Kelas model memberikan validasi tipe data yang aman dan memicu fitur rekomendasi kode otomatis (*auto-complete*) pada editor.
4.  **Kewajiban Status Loading/Error:** Demi kepastian kenyamanan pengguna (*User Experience*). Indikator *loading* menandakan aplikasi sedang bekerja mengambil data dari internet (UI tidak membeku), dan status *error* memberikan arahan solusi jelas jika terjadi gangguan koneksi.
