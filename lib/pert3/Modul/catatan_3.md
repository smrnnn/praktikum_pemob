# Pertemuan 3: Form Input dan State Management

## Ringkasan Teori Utama
*   **Input & Validasi:** Komponen `TextField` digunakan untuk menerima masukan teks yang nilainya dikontrol via `TextEditingController`. Untuk validasi data berlapis, digunakan widget `Form` bersama `TextFormField` yang dilengkapi parameter `validator` untuk mendeteksi eror.
*   **Ephemeral State vs App State:**
    *   *Ephemeral State* adalah data lokal yang cakupannya hanya ada pada satu widget halaman saja (dikelola lewat `setState`).
    *   *App State* adalah data global yang cakupannya luas dan digunakan bersama oleh banyak halaman sekaligus.
*   **Provider Management:** Solusi arsitektur untuk memisahkan data dari UI dengan cara menaruh objek state (`ChangeNotifier`) di atas pohon widget. Saat data diubah dan memicu `notifyListeners()`, seluruh komponen yang berlangganan otomatis digambar ulang.
*   **Watch vs Read:**
    *   `context.watch<T>()`: Berfungsi membaca data sekaligus ikut me-*refresh* UI saat data berubah (dipasang di dalam metode `build`).
    *   `context.read<T>()`: Berfungsi membaca data satu kali saja tanpa me-*refresh* UI (dipasang di dalam fungsi klik tombol/callback).

---

## Langkah Praktikum & Fitur Komponen

### Bagian A & B: Form Input Dasar dan Validasi
*   Menerapkan input teks menggunakan `TextField` dan wajib menggunakan perintah `_controller.dispose()` di dalam fungsi penutup halaman untuk mengosongkan RAM dan mencegah kebocoran memori.
*   Membangun struktur formulir terintegrasi (`FormPage`) yang memvalidasi kolom nama wajib diisi, format teks email wajib mengandung karakter `@`, menu *dropdown* pilihan jurusan, serta penguncian tombol simpan sebelum komponen *checkbox* persetujuan dicentang.

### Bagian C & D: Aplikasi Daftar Tugas dengan Provider
*   Mengunduh dan mendaftarkan dependensi paket global melalui perintah terminal `flutter pub add provider`.
*   Membuat model data terpusat `TugasModel` berbasis `ChangeNotifier` untuk menangani fungsi penambahan, pencoretan teks tugas selesai (`toggle`), dan penghapusan item data.
*   Menghubungkan halaman utama (`TugasPage`) dan halaman input (`TambahPage`) agar dapat saling berbagi data tugas yang sama secara *real-time* via manajemen Provider.

### Latihan Mandiri & Tugas Akhir
*   **Latihan Mandiri:** Menambahkan validasi minimal 3 karakter pada judul tugas, menyematkan tombol penghapusan massal tugas selesai (`hapusSelesai()`), memicu animasi pop-up `SnackBar`, dan merancang tampilan teks kondisi kosong *"Belum ada tugas"*.
*   **Tugas Akhir:** Membangun aplikasi "Daftar Belanja" dua halaman yang memvalidasi nama barang, batasan jumlah angka di atas 0, kategori *dropdown*, serta memantau jumlah sisa belanjaan belum dibeli pada judul atas *AppBar*.

---

## Jawaban Pertanyaan Refleksi
1.  **Urgensi Dispose Controller:** `TextEditingController` wajib di-*dispose* untuk melepaskan objek dari memori latar belakang saat halaman ditutup. Jika dilewatkan, kontroler akan tetap aktif dan memicu eror kebocoran memori (*memory leak*).
2.  **Kapan Menggunakan State:** Fungsi `setState` cukup digunakan apabila data hanya berpengaruh pada satu halaman widget mandiri (lokal), sedangkan paket `Provider` wajib digunakan saat data perlu dibagikan dan dimanipulasi lintas halaman yang berbeda (global).
3.  **Dampak Lupa notifyListeners():** Nilai variabel data internal di dalam memori program sebenarnya berhasil diubah, namun tampilan visual pada layar HP tidak akan mengalami pembaruan (*refresh*). Hal ini dikarenakan Flutter tidak menerima sinyal perintah untuk menggambar ulang widget yang terhubung.
4.  **Watch vs Read pada Tombol:** Di dalam fungsi klik `onPressed`, kita hanya perlu memanggil fungsi aksi perubahan data sebanyak satu kali saja, sehingga wajib menggunakan `context.read`. Jika menggunakan `context.watch`, widget tombol tersebut akan ikut terpicu untuk menggambar ulang diri secara sia-sia setiap kali ada data yang berubah.
