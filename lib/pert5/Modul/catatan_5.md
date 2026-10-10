# Pertemuan 5: Penyimpanan Lokal (SharedPreferences dan SQLite)

## Ringkasan Teori Utama
*   **Data Persistence (Penyimpanan Lokal):** Berguna agar data aplikasi tetap tersimpan aman di dalam memori perangkat keras HP dan tidak hilang saat aplikasi ditutup atau dimatikan sepenuhnya.
*   **SharedPreferences:** Jenis penyimpanan lokal berbasis pasangan kunci-nilai (*key-value pairs*) yang sangat cocok digunakan untuk menyimpan data konfigurasi atau pengaturan berskala kecil (seperti status mode gelap, nama pengguna, atau pilihan filter terakhir).
*   **Database SQLite (sqflite):** Sistem manajemen basis data relasional lokal yang kuat untuk mengelola data dalam jumlah besar dan terstruktur (seperti data catatan atau daftar transaksi keuangan).
*   **Keamanan SQL Injection:** Melindungi basis data dari manipulasi pihak luar dengan memanfaatkan tanda tanya `?` sebagai *placeholder* pada parameter `where` dan menyalurkan nilainya secara terpisah via `whereArgs`.

---

## Langkah Praktikum & Fitur Komponen

### Bagian A: SharedPreferences (Pengaturan Sederhana)
*   Memasang pustaka penyimpanan data ringan melalui perintah terminal: `flutter pub add shared_preferences`.
*   Membangun halaman pengaturan dinamis yang mampu menyimpan string nama, melacak hitungan berapa kali aplikasi dibuka secara otomatis, serta merubah sistem kecerahan warna tema menggunakan sakelar `SwitchListTile` berbasis `Brightness.dark`.

### Bagian B & C: Menyiapkan SQLite & Halaman Daftar Catatan
*   Memasang paket basis data terstruktur melalui perintah terminal: `flutter pub add sqflite path`.
*   Merancang kelas model objek `Catatan` lengkap dengan fungsi pemetaan data `toMap()` dan generator instan `fromMap()`.
*   Membuat modul helper `DbHelper` untuk menginisialisasi rute `catatan.db` dan mengeksekusi operasi baca data (`db.query`) serta hapus data (`db.delete`) yang dirender secara otomatis menggunakan `FutureBuilder`.

### Bagian D: Form Tambah dan Ubah Catatan
*   Merancang satu lembar formulir serbaguna yang dilindungi oleh validasi `FormKey`.
*   Sistem mampu mendeteksi tipe pemicu: jika mendeteksi parameter data bernilai kosong (*null*) maka tombol akan memicu fungsi `DbHelper.tambah()`, sedangkan jika form terbuka membawa data objek lama maka tombol otomatis beralih memicu fungsi pembaharuan `DbHelper.ubah()`.

### Latihan Mandiri & Tugas Akhir
*   **Latihan Mandiri:** Mengintegrasikan kolom isian teks "Cari catatan" berbasis filter `where: 'judul LIKE ?'`, menambahkan menu *pop-up* pengurutan data terbaru/terlama, menyematkan penanda tanggal waktu pembuatan catatan, serta menambahkan sistem perlindungan `AlertDialog` konfirmasi hapus data.
*   **Tugas Akhir:** Membangun aplikasi keuangan "Pencatat Pengeluaran" terpadu dalam skema mode gelap yang memvalidasi nama pengeluaran, batasan jumlah angka di atas nol, kategori belanja via *dropdown*, serta menampilkan rangkuman kartu total kalkulasi pengeluaran menggunakan perintah SQL `SELECT SUM(jumlah)`.

---

## Jawaban Pertanyaan Refleksi
1.  **Keterbatasan SharedPreferences:** Kurang cocok untuk menyimpan ratusan catatan karena sistem ini membaca seluruh data ke dalam memori RAM sekaligus saat aplikasi dibuka. Solusi yang jauh lebih efisien adalah beralih menggunakan database SQLite (`sqflite`).
2.  **Urgensi Placeholder ? dan whereArgs:** Digunakan sebagai benteng pertahanan mutlak untuk mencegah serangan *SQL Injection*. Cara ini memisahkan perintah SQL utama dari string teks mentah input pengguna agar tidak dapat dieksploitasi.
3.  **Alasan Muat Ulang Setelah Form:** Layar daftar utama perlu disegarkan kembali agar data terbaru yang baru saja disimpan atau diubah dari halaman form dapat ditarik dari SQLite dan langsung ditampilkan secara *real-time*. Pada proyek ini, proses penyegaran dipicu dengan memanggil fungsi `_muat()` setelah perintah rute `await Navigator.push()` diselesaikan.
4.  **Fungsi onCreate dan onUpgrade:**
    *   `onCreate` berjalan sekali saja di awal saat berkas database pertama kali dibuat di HP untuk merancang struktur tabel dasar.
    *   `onUpgrade` dijalankan otomatis ketika nilai konfigurasi `version` dinaikkan ke tingkat yang lebih tinggi untuk memodifikasi atau menambah kolom tabel baru tanpa merusak baris data lama yang sudah tersimpan.
