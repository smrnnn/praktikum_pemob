# Pertemuan 6: Tema, Routing & Navigasi, serta Animasi Lanjutan

## Ringkasan Teori Utama
*   **Dynamic Theme (Material 3):** Memanfaatkan komponen `ThemeData` untuk menyimpan panduan visual (gaya warna dan tipografi). Cukup menentukan satu komponen warna dasar (*seed color*), Flutter akan otomatis merancang seluruh palet warna terang/gelap yang adaptif dibaca melalui fungsi `Theme.of(context)`.
*   **Centralized Named Routes:** Mengelola perpindahan rute halaman secara teratur dan aman menggunakan string penanda rute bernama (`pushNamed`). Penanganan argumen objek data dikendalikan terpusat melalui fungsi callback `onGenerateRoute`.
*   **Stateful Tab Navigation:** Menggunakan kombinasi widget `NavigationBar` dan `IndexedStack` untuk membangun navigasi multi-tab bawah yang mampu menahan siklus hidup (*state*) setiap halaman agar data tidak ter-*refresh* saat berpindah tab.
*   **Flutter Animation Toolkit:**
    *   *Animasi Implisit:* Pergerakan visual otomatis yang dipicu perubahan status variabel di dalam fungsi `setState` (seperti `AnimatedContainer` & `AnimatedOpacity`).
    *   *Transisi Hero:* Efek animasi perpindahan objek visual yang terlihat seolah "terbang" dan membesar secara mulus dari halaman asal ke halaman tujuan.
    *   *Animasi Eksplisit:* Kontrol pergerakan visual secara presisi menggunakan bantuan penggerak `AnimationController` untuk fungsi mulai, henti, atau berputar terus-menerus.

---

## Langkah Praktikum & Fitur Komponen

### Bagian A: Manajemen Tema Terang/Gelap
*   Membuat struktur detektor perubahan global berbasis `ValueNotifier` untuk memantau status mode kegelapan layar dan seleksi 4 variasi warna dasar.
*   Merancang widget pengaturan sakelar `SwitchListTile` yang terhubung secara responsif untuk memperbarui struktur kecerahan visual aplikasi secara langsung.

### Bagian B: Named Routes, Argumen, dan Hero Transition
*   Mendaftarkan inisialisasi rute utama `'/'` dan merancang fungsi penyaringan data argumen `Item` pada metode `onGenerateRoute` di berkas `MaterialApp`.
*   Memasang elemen pembungkus `Hero` dengan kode `tag` terikat pada ikon `CircleAvatar` daftar menu beranda agar dapat mengeksekusi transisi perpindahan visual melayang yang mulus menuju halaman detail.

### Bagian C & D: Lembar Demo Animasi & Penyatuan ShellPage
*   Membangun kelas `AnimasiTab` yang memanfaatkan mixin `SingleTickerProviderStateMixin` untuk menyajikan pengujian fungsionalitas kotak dinamis `AnimatedContainer`, efek skala teks angka `AnimatedSwitcher`, dan roda gigi berputar `RotationTransition`.
*   Merancang kelas penampung `ShellPage` untuk merangkai halaman Beranda, Animasi, dan Pengaturan ke dalam kesatuan bar navigasi bawah.

### Latihan Mandiri & Tugas Akhir
*   **Latihan Mandiri:** Mengintegrasikan paket pustaka `shared_preferences` untuk menyimpan preferensi skema warna tema pilihan pengguna, menyematkan bar menu samping `Drawer`, memodifikasi transisi detail via efek pudar `FadeTransition` pada `PageRouteBuilder`, menangani kesalahan halaman via `onUnknownRoute` (Eror 404), serta menyisipkan demonstrasi fungsional komponen `AnimatedOpacity`.
*   **Tugas Akhir:** Membangun aplikasi inovatif "Katalog Gadget Interaktif" tiga tab terpadu (Katalog, Demo Animasi, Tema) yang memisahkan seluruh kelas arsitektur data, melancarkan aksi argumen perpindahan detail produk lewat transisi Hero, serta mengeliminasi penulisan warna kaku (*hardcoded*) demi mendukung transisi mode gelap yang adaptif.

---

## Jawaban Pertanyaan Refleksi
1.  **Implisit vs Eksplisit:** Animasi implisit diatur otomatis oleh sistem saat nilai variabel berubah (cocok untuk perubahan simpel ganti ukuran/warna). Animasi eksplisit membutuhkan pengendali manual `AnimationController` (wajib dipilih jika butuh kontrol penuh seperti gerakan berputar terus-menerus atau tombol jeda).
2.  **Mekanisme Tag Hero:** Dua widget `Hero` wajib memiliki nilai tag identik sebagai kunci pelacak rute penerbangan objek antarlayar. Jika ada dua tag yang sama muncul ganda secara bersamaan di dalam satu area halaman, aplikasi akan mengalami kegagalan sistem (*crash*) karena kebingungan mendeteksi objek tujuan.
3.  **Keuntungan Theme.of(context):** Menghasilkan pewarnaan aplikasi yang fleksibel dan dinamis karena otomatis mengikuti konfigurasi tema global (seperti langsung menyesuaikan warna latar belakang dan teks secara otomatis saat beralih ke Mode Gelap).
4.  **IndexedStack vs Navigator:** Widget `IndexedStack` hanya menyembunyikan tampilan tab tanpa menghapus riwayat data dari memori (status halaman tetap aktif/tidak ter-*refresh*). Sementara `Navigator` benar-benar membuka lembar rute baru dari nol dengan sistem penumpukan rute (*stack*).
5.  **Urgensi Dispose Controller:** Objek `AnimationController` wajib dihilangkan lewat metode `dispose()` untuk mematikan mesin penggerak detak animasi (*ticker*) di latar belakang saat halaman ditutup. Jika terlewat, mesin akan terus mengonsumsi RAM dan memicu kebocoran memori (*memory leak*).
