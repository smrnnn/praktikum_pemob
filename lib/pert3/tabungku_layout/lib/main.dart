
import 'package:flutter/material.dart';

// Fungsi utama untuk menjalankan aplikasi TabungKu.
void main() {
  runApp(const TabungKuApp());
}

// Widget utama untuk mengatur tema dan halaman aplikasi.
class TabungKuApp extends StatelessWidget {
  const TabungKuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TabungKu',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: const Color(0xFF176B59),
        scaffoldBackgroundColor: const Color(0xFFF5F8F7),
      ),
      home: const RingkasanPage(),
    );
  }
}

// Halaman utama yang menampilkan ringkasan tabungan.
class RingkasanPage extends StatelessWidget {
  const RingkasanPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar sebagai bagian judul halaman.
      appBar: AppBar(
        title: const Text('Ringkasan Tabungan'),
        centerTitle: true,
        backgroundColor: const Color(0xFF176B59),
        foregroundColor: Colors.white,
      ),

      // ListView memungkinkan halaman digulir pada layar kecil.
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Center dan Container membatasi lebar pada tablet.
          Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 650),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Kartu utama berisi informasi tabungan.
                  Card(
                    color: Colors.white,
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Baris nama tabungan dan ikon.
                          const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Tabungan Masa Depan',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.account_balance_wallet_outlined,
                                color: Color(0xFF176B59),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          // Informasi saldo tabungan.
                          const Text(
                            'Total Saldo',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Rp 2.750.000',
                            style: TextStyle(
                              fontSize: 27,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF176B59),
                            ),
                          ),

                          const SizedBox(height: 20),
                          const Divider(),
                          const SizedBox(height: 8),

                          // Row untuk label dan nominal target.
                          const Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Target Tabungan',
                                  style: TextStyle(fontSize: 13),
                                ),
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Rp 5.000.000',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Judul bagian kategori.
                  const Text(
                    'Menu Tabungan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Row membagi tiga kategori secara seimbang.
                  Row(
                    children: [
                      Expanded(
                        child: kategori(
                          Icons.savings_outlined,
                          'Menabung',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: kategori(
                          Icons.arrow_upward_outlined,
                          'Tarik',
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: kategori(
                          Icons.history,
                          'Riwayat',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Judul bagian daftar transaksi.
                  const Text(
                    'Riwayat Transaksi',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Tiga transaksi dengan data statis.
                  transaksi(
                    'Tabungan Mingguan',
                    '10 November 2026',
                    '+ Rp 250.000',
                    Colors.green,
                  ),
                  transaksi(
                    'Setoran Tabungan',
                    '8 November 2026',
                    '+ Rp 150.000',
                    Colors.green,
                  ),
                  transaksi(
                    'Penarikan Dana',
                    '5 November 2026',
                    '- Rp 100.000',
                    Colors.red,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Container untuk menampilkan ikon dan nama kategori.
  Widget kategori(IconData ikon, String nama) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 18,
        horizontal: 4,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            ikon,
            size: 28,
            color: const Color(0xFF176B59),
          ),
          const SizedBox(height: 8),
          Text(
            nama,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }

  // Card untuk judul, tanggal, dan nominal transaksi.
  Widget transaksi(
      String judul,
      String tanggal,
      String nominal,
      Color warna,
      ) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Expanded memberi ruang untuk informasi transaksi.
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    judul,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    tanggal,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Nominal transaksi di sisi kanan.
            Text(
              nominal,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: warna,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
