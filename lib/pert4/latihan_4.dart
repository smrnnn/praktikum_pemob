import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: const PenggunaPage(),
    );
  }
}

class Pengguna {
  final int id;
  final String name;
  final String username;
  final String email;
  final String phone;
  final String website;
  final String city;

  const Pengguna({
    required this.id,
    required this.name,
    required this.username,
    required this.email,
    required this.phone,
    required this.website,
    required this.city,
  });

  factory Pengguna.fromJson(Map<String, dynamic> json) {
    return Pengguna(
      id: json['id'] as int,
      name: json['name'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String,
      website: json['website'] as String,
      city: (json['address'] as Map<String, dynamic>)['city'] as String,
    );
  }
}

Future<List<Pengguna>> ambilPengguna() async {
  final uri = Uri.parse(
    'https://jsonplaceholder.typicode.com/users',
  );

  final response = await http.get(uri).timeout(
    const Duration(seconds: 10),
  );

  if (response.statusCode != 200) {
    throw Exception(
      'Gagal memuat data (kode ${response.statusCode})',
    );
  }

  final List<dynamic> data = jsonDecode(response.body);

  return data
      .map((e) => Pengguna.fromJson(e as Map<String, dynamic>))
      .toList();
}

class PenggunaPage extends StatefulWidget {
  const PenggunaPage({super.key});

  @override
  State<PenggunaPage> createState() => _PenggunaPageState();
}

class _PenggunaPageState extends State<PenggunaPage> {
  late Future<List<Pengguna>> _future;
  String _jumlahText = '';

  @override
  void initState() {
    super.initState();
    _future = ambilPengguna();
  }

  Future<void> _muatUlang() async {
    setState(() {
      _future = ambilPengguna();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Daftar Pengguna $_jumlahText'),
      ),
      body: FutureBuilder<List<Pengguna>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Terjadi kesalahan:\n${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _muatUlang,
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted && _jumlahText != '(${data.length})') {
              setState(() {
                _jumlahText = '(${data.length})';
              });
            }
          });

          if (data.isEmpty) {
            return RefreshIndicator(
              onRefresh: _muatUlang,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 100),
                  Center(
                    child: Text(
                      'Tidak ada data',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _muatUlang,
            child: ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: data.length,
              itemBuilder: (context, i) {
                final p = data[i];

                return ListTile(
                  leading: CircleAvatar(
                    // ====== DIUBAH: Memberikan warna latar lingkaran netral ======
                    backgroundColor: Colors.grey[200],
                    foregroundColor: Colors.black,
                    child: Text(p.name[0]),
                  ),
                  title: Text(p.name),
                  subtitle: Text(p.email),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailPenggunaPage(
                          pengguna: p,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class DetailPenggunaPage extends StatelessWidget {
  final Pengguna pengguna;

  const DetailPenggunaPage({
    super.key,
    required this.pengguna,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(pengguna.name),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Username'),
            subtitle: Text(pengguna.username),
          ),
          ListTile(
            leading: const Icon(Icons.email),
            title: const Text('Email'),
            subtitle: Text(pengguna.email),
          ),
          ListTile(
            leading: const Icon(Icons.phone),
            title: const Text('Telepon'),
            subtitle: Text(pengguna.phone),
          ),
          ListTile(
            leading: const Icon(Icons.location_city),
            title: const Text('Kota'),
            subtitle: Text(pengguna.city),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Situs Web'),
            subtitle: Text(pengguna.website),
          ),
        ],
      ),
    );
  }
}
