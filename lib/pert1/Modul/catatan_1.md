# Pertemuan 1: Pengenalan Flutter, Instalasi, dan Aplikasi Pertama

## Langkah Praktikum & Perintah Penting

### 1. Verifikasi Sistem
*   `flutter doctor`: Memeriksa kelengkapan instalasi SDK, teks editor, dan kesiapan emulator.
*   `flutter doctor --android-licenses`: Menyetujui dokumen lisensi Android SDK agar aplikasi bisa di-build.

### 2. Manajemen Proyek
*   `flutter create praktikum_1`: Membuat kerangka folder proyek baru.
*   `cd praktikum_1`: Berpindah ke dalam direktori proyek aktif.
*   `flutter run`: Mengompilasi dan menjalankan program ke perangkat target.

---

## Hasil Eksperimen Modul

### Bagian D & E: Tata Letak Dasar (Layout)
*   Mengubah teks bawaan menjadi identitas personal.
*   Mengganti komponen tunggal menjadi widget **`Column`** untuk menyusun objek (`Icon`, `SizedBox`, dan beberapa `Text`) berjejer rapi secara vertikal ke bawah tepat di tengah layar.

### Bagian F & Latihan Mandiri: Fitur Interaktif
*   Mengimplementasikan fungsi counter dinamis menggunakan tombol penambah (`add`) dan tombol pengurang (`remove`).
*   Menambahkan tombol **Reset** berbasis `ElevatedButton.icon` untuk mengembalikan angka ke kondisi awal (`0`).
*   Menerapkan logika pengondisian `if (_count > 0)` sebagai sistem keamanan validasi agar nilai counter tidak pernah menyentuh angka negatif.

### Tugas Akhir: Kartu Perkenalan
*   Membuat kartu perkenalan yang menampilkan ikon profil, nama, NIM, jurusan, dan hobi menggunakan kombinasi efisien dari widget `Column`, `Row`, `Divider`, `Padding`, dan `SizedBox`.

---

## Jawaban Pertanyaan Refleksi
1.  **Perbedaan Widget:** `Stateless` bersifat pasif dan permanen, sedangkan `Stateful` aktif dan bisa berubah bentuk mengikuti perubahan kondisi data (*state*).
2.  **Urgensi `setState()`:** Tanpa fungsi ini, nilai variabel di memori latar belakang memang berubah, tetapi layar visual perangkat tidak akan melakukan penyegaran (*refresh*).
3.  **Keuntungan Hot Reload:** Menghemat waktu development karena proses render perubahan kode berjalan dalam hitungan detik tanpa merusak status data yang sedang berjalan.
