# Pertemuan 7: Mini Proyek Terpadu — TabungKu (To-Do List + Manajemen Keuangan)

## Ringkasan Teori Utama
*   **Aplikasi Terintegrasi (To-Do + Keuangan):** Menggabungkan konsep daftar aktivitas harian (*to-do list*) dengan pencatatan finansial praktis. Aktivitas dipilah menjadi tiga tipe keterikatan uang (Tidak melibatkan uang, Pemasukan, atau Pengeluaran) untuk melatih kebiasaan menabung mahasiswa.
*   **Database Agregasi (SQLite):** Pengolahan kalkulasi keuangan secara efisien langsung di dalam mesin database menggunakan kueri agregat (`COUNT`, `SUM`, `GROUP BY`). Memanfaatkan fungsi `CASE WHEN` untuk memilah jenis transaksi serta fungsi `COALESCE` untuk mengantisipasi nilai kosong (`NULL`) saat tabel belum memiliki baris data.
*   **Sinkronisasi State Antar-Tab (Observer Pattern):** Mengatasi tantangan pembaruan data secara *real-time* pada struktur navigasi multi-tab. Dengan memanfaatkan variabel global berbasis `ValueNotifier`, setiap perubahan data pada satu tab (seperti menambah data di tab Form) akan memicu pemicu sinyal yang didengarkan oleh tab lain melalui mekanisme `addListener` untuk memuat ulang data secara otomatis.
*   **Data Persistence & Konversi Tipe Data:**
    *   *SQLite:* Melakukan serialisasi data karena SQLite tidak mendukung tipe data Boolean bawaan Dart (dikonversi menjadi integer `0`/`1`) dan tipe data enum (dikonversi menjadi string `.name`).
    *   *Shared Preferences:* Menyimpan konfigurasi preferensi pengguna yang sifatnya ringan seperti status mode gelap, pilihan warna tema, dan nilai target tabungan harian agar tetap bertahan meskipun aplikasi dimatikan.

---

## Langkah Praktikum & Fitur Komponen

### Bagian A: Arsitektur Model Data & Utilitas
*   Merancang kelas model `Kegiatan` yang dilengkapi dengan fungsi pabrik `fromMap` dan metode `toMap` untuk menjembatani konversi data objek Dart dengan baris tabel SQLite.
*   Membuat berkas utilitas `format.dart` untuk standardisasi visual berupa format mata uang Rupiah dan standardisasi format penulisan teks tanggal internasional (`yyyy-MM-dd`) demi akurasi proses pengurutan database.

### Bagian B: Manajemen Data Lokal SQLite & Sinkronisasi Global
*   Membangun kelas `DbHelper` untuk menangani siklus hidup basis data (inisialisasi tabel, operasi CRUD kegiatan, dan kueri ringkasan laporan keuangan harian).
*   Menyematkan variabel pemantau `versiData` berjenis `ValueNotifier<int>` yang nilainya dinaikkan secara inkremental setiap kali operasi manipulasi data (tambah, ubah, hapus) berhasil dieksekusi.

### Bagian C: Antarmuka Beranda Hari Ini & Formulir Validasi
*   Merancang `BerandaPage` yang menerapkan penampung `FutureBuilder` untuk memuat data aktivitas harian dan mendengarkan sinyal `versiData` pada metode `initState` serta membersihkannya pada metode `dispose`.
*   Membangun `FormKegiatanPage` dengan sistem pengondisian dinamis, di mana kolom input "Nominal" dan "Kategori" otomatis disembunyikan/ditampilkan secara responsif mengikuti pilihan jenis keuangan yang dipilih pengguna.

### Bagian D: Laporan Visual & Pengaturan Preferensi
*   Menyusun halaman `LaporanPage` untuk menyajikan visualisasi data ringkasan harian, rincian pengeluaran berdasarkan 5 kategori utama (Makan, Transport, Belajar, Hiburan, Lainnya), serta rekam jejak tabungan 7 hari terakhir.
*   Merancang halaman `PengaturanPage` menggunakan widget pengatur nilai (seperti slider untuk target tabungan harian dan sakelar untuk tema) yang terhubung langsung dengan media penyimpanan `shared_preferences`.

---

## Jawaban Pertanyaan Refleksi
1.  **Penyimpanan Format Tanggal `yyyy-MM-dd`:** Karena format standar ISO ini memungkinkan teks diurutkan (*sorting*) dan dibandingkan (*comparison*) secara akurat menggunakan kueri SQL alfabet standar di SQLite, berbeda dengan format `dd/MM/yyyy` yang akan rancu jika diurutkan sebagai teks biasa.
2.  **Kueri Agregasi `SUM` vs Looping di Dart:** Menggunakan kueri `SUM` jauh lebih cepat dan hemat daya karena beban kalkulasi ribuan data diselesaikan langsung di dalam mesin database internal komputer, bukan di memori RAM aplikasi Flutter. Penghitungan di Dart baru tepat dipilih jika data membutuhkan manipulasi logika kode UI yang sangat rumit.
3.  **Sinkronisasi Tiga Tab & Risiko Lepas Listener:** Ketiga tab sinkron berkat variabel global pengirim sinyal `versiData` (`ValueNotifier`) yang memicu fungsi pemuatan ulang data. Jika fungsi `removeListener` lupa dipanggil pada metode `dispose()`, objek halaman yang sudah ditutup akan terus menggantung di memori, menyebabkan kebocoran memori (*memory leak*), dan menurunkan performa HP menjadi lemot.
4.  **Dampak Perhitungan Semua Kegiatan terhadap Pengguna:** Keputusan ini memberikan visualisasi anggaran riil kepada pengguna sejak awal aktivitas direncanakan, sehingga melatih kedisiplinan menabung dan mencegah pengguna kecolongan mengeluarkan uang melebihi anggaran yang tersedia.