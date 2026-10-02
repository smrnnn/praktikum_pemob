import 'package:flutter/material.dart';

class Kontak {
  final String nama;
  final String telepon;
  final String email;

  const Kontak(
      this.nama,
      this.telepon,
      this.email,
      );
}

const daftarKontak = [
  Kontak(
    'Mikka',
    '081234567890',
    'mikka@gmail.com',
  ),
  Kontak(
    'Ayesha',
    '082345678901',
    'ayesha@gmail.com',
  ),
  Kontak(
    'Nuy',
    '083456789012',
    'nuy@gmail.com',
  ),
  Kontak(
    'Kei',
    '084567890123',
    'kei@gmail.com',
  ),
  Kontak(
    'Bunga',
    '085678901234',
    'bunga@gmail.com',
  ),
  Kontak(
    'Askara',
    '086789012345',
    'askara@gmail.com',
  ),
];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Kontak',
      theme: ThemeData(
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: const ContactListPage(),
    );
  }
}

class ContactListPage extends StatelessWidget {
  const ContactListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Kontak'),
      ),

      body: ListView.builder(
        itemCount: daftarKontak.length,
        itemBuilder: (context, index) {
          final kontak = daftarKontak[index];

          return ListTile(

            leading: CircleAvatar(
              child: Text(
                kontak.nama[0],
              ),
            ),

            title: Text(
              kontak.nama,
            ),

            subtitle: Text(
              kontak.telepon,
            ),

            trailing: const Icon(
              Icons.chevron_right,
            ),

            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ContactDetailPage(
                    kontak: kontak,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ContactDetailPage extends StatelessWidget {
  final Kontak kontak;

  const ContactDetailPage({
    super.key,
    required this.kontak,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          kontak.nama,
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            CircleAvatar(
              radius: 50,
              child: Text(
                kontak.nama[0],
                style: const TextStyle(
                  fontSize: 40,
                ),
              ),
            ),

            const SizedBox(height: 24),

            Text(
              kontak.nama,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Nomor Telepon',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              kontak.telepon,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              'Email',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            Text(
              kontak.email,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Kembali',
              ),
            ),
          ],
        ),
      ),
    );
  }
}