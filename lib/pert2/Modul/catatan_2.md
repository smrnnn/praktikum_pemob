# Pertemuan 2: Layout, ListView, dan Navigasi Antar Halaman

## Ringkasan Teori Utama
*   **Container & Layouting:** `Container` berfungsi sebagai kotak serbaguna untuk mengatur warna dasar, jarak tepi, dan sudut melengkung. Pengaturan komponen horizontal menggunakan `Row` dan vertikal menggunakan `Column`.
*   **Widget Expanded:** Komponen khusus yang bertugas memaksa memanfaatkan sisa ruang yang ada sekaligus mencegah munculnya eror (*overflow*) saat teks terlalu panjang.
*   **ListView.builder:** Metode pembuatan daftar item yang sangat efisien (*lazy loading*) karena hanya menggambar ulang item yang sedang terlihat di area layar perangkat.
*   **Navigator (Navigation Stack):** Fitur pengelola tumpukan halaman di Flutter. Perintah `Navigator.push` digunakan untuk membuka halaman baru (menumpuk ke atas), sementara `Navigator.pop` digunakan untuk menutup halaman aktif dan kembali.

---

## Langkah Praktikum & Fitur Komponen

### Bagian A: Layout Kartu Profil
*   Mempelajari pembungkusan teks nama  dan NIM ke dalam widget `Expanded` agar posisinya fleksibel di sebelah kanan ikon `CircleAvatar`.
*   Menerapkan dekorasi `BoxDecoration` untuk mengubah warna kartu profil menjadi biru muda bersudut tumpul (`borderRadius`).

### Bagian B: Model Data dan ListView
*   Membuat model data terstruktur menggunakan kelas khusus (`class Makanan`) yang menampung properti nama dan harga objek.
*   Menampilkan deretan daftar menu secara berulang ke bawah memanfaatkan kombinasi efisien dari widget `ListView.builder`, `Card`, dan `ListTile`.

### Bagian C & Latihan Mandiri: Navigasi Detail
*   Memasang aksi `onPressed` dan `onTap` untuk memicu perpindahan halaman dari menu utama ke halaman detail tujuan (`DetailPage`).
*   Mengirimkan objek data secara spesifik melalui parameter *constructor* kelas halaman detail.
*   Membuat tombol "Kembali" interaktif yang menjalankan fungsi `Navigator.pop` untuk kembali ke rute halaman utama.

### Tugas: Aplikasi Daftar Kontak
*   Menerapkan seluruh materi bab dengan membuat aplikasi daftar kontak lengkap dengan pengiriman identitas nama, nomor telepon, dan email, serta modifikasi inisial huruf otomatis pada komponen `CircleAvatar`.

---

## Jawaban Pertanyaan Refleksi
1.  **ListView vs ListView.builder:** `ListView` biasa langsung memuat seluruh data di awal , sedangkan `ListView.builder` hanya memuat data yang tampak di layar.
2.  **Solusi Overflow:** Teks panjang pada `Row` meluap karena `Row` tidak memiliki batas lebar alami. Widget `Expanded` menuntaskan eror ini dengan memaksa teks tersebut turun ke bawah mengikuti sisa lebar ruang yang tersedia.
3.  **Mekanisme Kirim Data:** Data dikirim dengan cara memasukkan referensi objek data secara langsung ke dalam parameter *constructor* kelas halaman tujuan saat memicu fungsi perpindahan `Navigator.push`.
