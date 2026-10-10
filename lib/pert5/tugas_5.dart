import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _gelap = false;
  bool _memuat = true;

  @override
  void initState() {
    super.initState();
    _muatPengaturan();
  }

  Future<void> _muatPengaturan() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      _gelap = prefs.getBool('gelap') ?? false;
      _memuat = false;
    });
  }

  Future<void> _ubahTema(bool nilai) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('gelap', nilai);

    if (!mounted) return;

    setState(() {
      _gelap = nilai;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_memuat) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: 'Pencatat Pengeluaran',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness:
        _gelap ? Brightness.dark : Brightness.light,
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
      ),
      home: PengeluaranPage(
        gelap: _gelap,
        onTemaChanged: _ubahTema,
      ),
    );
  }
}

class Pengeluaran {
  final int? id;
  final String nama;
  final int jumlah;
  final String kategori;
  final String tanggal;

  const Pengeluaran({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.kategori,
    required this.tanggal,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'kategori': kategori,
      'tanggal': tanggal,
    };
  }

  factory Pengeluaran.fromMap(
      Map<String, Object?> map,
      ) {
    return Pengeluaran(
      id: map['id'] as int,
      nama: map['nama'] as String,
      jumlah: map['jumlah'] as int,
      kategori: map['kategori'] as String,
      tanggal: map['tanggal'] as String,
    );
  }
}

class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }

    final path = p.join(
      await getDatabasesPath(),
      'pengeluaran.db',
    );

    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE pengeluaran('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'nama TEXT NOT NULL, '
              'jumlah INTEGER NOT NULL, '
              'kategori TEXT NOT NULL, '
              'tanggal TEXT NOT NULL)',
        );
      },
    );

    return _db!;
  }

  static Future<int> tambah(
      Pengeluaran pengeluaran,
      ) async {
    final db = await database;

    return db.insert(
      'pengeluaran',
      pengeluaran.toMap(),
    );
  }

  static Future<List<Pengeluaran>> semua() async {
    final db = await database;

    final rows = await db.query(
      'pengeluaran',
      orderBy: 'tanggal DESC, id DESC',
    );

    return rows.map(Pengeluaran.fromMap).toList();
  }

  static Future<int> ubah(
      Pengeluaran pengeluaran,
      ) async {
    final db = await database;

    return db.update(
      'pengeluaran',
      pengeluaran.toMap(),
      where: 'id = ?',
      whereArgs: [pengeluaran.id],
    );
  }

  static Future<int> hapus(int id) async {
    final db = await database;

    return db.delete(
      'pengeluaran',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  static Future<int> total() async {
    final db = await database;

    final result = await db.rawQuery(
      'SELECT SUM(jumlah) AS total FROM pengeluaran',
    );

    return (result.first['total'] as int?) ?? 0;
  }
}

class PengeluaranPage extends StatefulWidget {
  final bool gelap;
  final Future<void> Function(bool) onTemaChanged;

  const PengeluaranPage({
    super.key,
    required this.gelap,
    required this.onTemaChanged,
  });

  @override
  State<PengeluaranPage> createState() =>
      _PengeluaranPageState();
}

class _PengeluaranPageState
    extends State<PengeluaranPage> {
  late Future<List<Pengeluaran>> _future;
  int _total = 0;

  @override
  void initState() {
    super.initState();
    _muatData();
  }

  Future<void> _muatData() async {
    final futureData = DbHelper.semua();
    final total = await DbHelper.total();

    if (!mounted) return;

    setState(() {
      _future = futureData;
      _total = total;
    });
  }

  String _formatRupiah(int angka) {
    final teks = angka.toString();
    final buffer = StringBuffer();

    for (int i = 0; i < teks.length; i++) {
      if (i > 0 &&
          (teks.length - i) % 3 == 0) {
        buffer.write('.');
      }

      buffer.write(teks[i]);
    }

    return 'Rp $buffer';
  }

  Future<void> _bukaForm([
    Pengeluaran? pengeluaran,
  ]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FormPengeluaranPage(
          pengeluaran: pengeluaran,
        ),
      ),
    );

    if (!mounted) return;

    _muatData();
  }

  Future<void> _hapus(
      Pengeluaran pengeluaran,
      ) async {
    final hasil = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Pengeluaran'),
          content: Text(
            'Hapus "${pengeluaran.nama}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (hasil == true) {
      await DbHelper.hapus(
        pengeluaran.id!,
      );

      if (!mounted) return;

      _muatData();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Pengeluaran berhasil dihapus',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pencatat Pengeluaran'),
        actions: [
          Switch(
            value: widget.gelap,
            onChanged: widget.onTemaChanged,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  'Total Pengeluaran',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _formatRupiah(_total),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Pengeluaran>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Galat: ${snapshot.error}',
                    ),
                  );
                }

                final data = snapshot.data ?? [];

                if (data.isEmpty) {
                  return const Center(
                    child: Text(
                      'Belum ada pengeluaran',
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(
                    bottom: 80,
                  ),
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    final pengeluaran = data[index];

                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          pengeluaran.nama[0]
                              .toUpperCase(),
                        ),
                      ),
                      title: Text(
                        pengeluaran.nama,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${pengeluaran.kategori} • '
                            '${pengeluaran.tanggal}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatRupiah(
                              pengeluaran.jumlah,
                            ),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'ubah') {
                                _bukaForm(
                                  pengeluaran,
                                );
                              } else if (value ==
                                  'hapus') {
                                _hapus(
                                  pengeluaran,
                                );
                              }
                            },
                            itemBuilder: (context) {
                              return const [
                                PopupMenuItem(
                                  value: 'ubah',
                                  child: Text('Ubah'),
                                ),
                                PopupMenuItem(
                                  value: 'hapus',
                                  child: Text('Hapus'),
                                ),
                              ];
                            },
                          ),
                        ],
                      ),
                      onTap: () {
                        _bukaForm(
                          pengeluaran,
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton:
      FloatingActionButton.extended(
        onPressed: () {
          _bukaForm();
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}

class FormPengeluaranPage extends StatefulWidget {
  final Pengeluaran? pengeluaran;

  const FormPengeluaranPage({
    super.key,
    this.pengeluaran,
  });

  @override
  State<FormPengeluaranPage> createState() =>
      _FormPengeluaranPageState();
}

class _FormPengeluaranPageState
    extends State<FormPengeluaranPage> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _namaController;
  late final TextEditingController _jumlahController;
  late final TextEditingController _tanggalController;

  String _kategori = 'Makanan';

  final List<String> _kategoriList = [
    'Makanan',
    'Transportasi',
    'Belanja',
    'Tagihan',
    'Hiburan',
    'Lainnya',
  ];

  @override
  void initState() {
    super.initState();

    _namaController = TextEditingController(
      text: widget.pengeluaran?.nama ?? '',
    );

    _jumlahController = TextEditingController(
      text: widget.pengeluaran?.jumlah.toString() ?? '',
    );

    _tanggalController = TextEditingController(
      text: widget.pengeluaran?.tanggal ?? '',
    );

    if (widget.pengeluaran != null) {
      _kategori = widget.pengeluaran!.kategori;
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    _tanggalController.dispose();
    super.dispose();
  }

  Future<void> _pilihTanggal() async {
    final sekarang = DateTime.now();

    final tanggal = await showDatePicker(
      context: context,
      initialDate: sekarang,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (tanggal == null) return;

    final bulan =
    tanggal.month.toString().padLeft(2, '0');

    final hari =
    tanggal.day.toString().padLeft(2, '0');

    _tanggalController.text =
    '${tanggal.year}-$bulan-$hari';
  }

  Future<void> _simpan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final pengeluaran = Pengeluaran(
      id: widget.pengeluaran?.id,
      nama: _namaController.text.trim(),
      jumlah: int.parse(
        _jumlahController.text.trim(),
      ),
      kategori: _kategori,
      tanggal: _tanggalController.text.trim(),
    );

    if (widget.pengeluaran == null) {
      await DbHelper.tambah(pengeluaran);
    } else {
      await DbHelper.ubah(pengeluaran);
    }

    if (!mounted) return;

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final baru = widget.pengeluaran == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          baru
              ? 'Tambah Pengeluaran'
              : 'Ubah Pengeluaran',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Pengeluaran',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Nama wajib diisi';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _jumlahController,
              keyboardType:
              TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                prefixText: 'Rp ',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Jumlah wajib diisi';
                }

                final jumlah = int.tryParse(
                  value.trim(),
                );

                if (jumlah == null) {
                  return 'Jumlah harus berupa angka';
                }

                if (jumlah <= 0) {
                  return 'Jumlah harus lebih dari 0';
                }

                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: _kategoriList.map(
                    (kategori) {
                  return DropdownMenuItem(
                    value: kategori,
                    child: Text(kategori),
                  );
                },
              ).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _kategori = value;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _tanggalController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Tanggal',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  onPressed: _pilihTanggal,
                  icon: const Icon(
                    Icons.calendar_month,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null ||
                    value.trim().isEmpty) {
                  return 'Tanggal wajib diisi';
                }

                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: _simpan,
                child: Text(
                  baru
                      ? 'Simpan Pengeluaran'
                      : 'Simpan Perubahan',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}