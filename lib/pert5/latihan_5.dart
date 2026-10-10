import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Praktikum 5',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const CatatanPage(),
    );
  }
}

// =========================================================================
// MODEL DATA: KOLOM dibuat (LATIHAN POIN 3)
// =========================================================================
class Catatan {
  final int? id;
  final String judul;
  final String isi;
  final String dibuat;

  const Catatan({
    this.id,
    required this.judul,
    required this.isi,
    required this.dibuat,
  });

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'dibuat': dibuat,
    };
  }

  factory Catatan.fromMap(Map<String, Object?> m) {
    return Catatan(
      id: m['id'] as int?,
      judul: m['judul'] as String,
      isi: m['isi'] as String,
      dibuat: (m['dibuat'] as String?) ?? '',
    );
  }
}

// =========================================================================
// HELPER DATABASE: VERSION 2 & ONUPGRADE (LATIHAN POIN 3)
// =========================================================================
class DbHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;

    final path = p.join(await getDatabasesPath(), 'catatan.db');

    _db = await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE catatan('
              'id INTEGER PRIMARY KEY AUTOINCREMENT, '
              'judul TEXT NOT NULL, '
              'isi TEXT NOT NULL, '
              'dibuat TEXT NOT NULL'
              ')',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('ALTER TABLE catatan ADD COLUMN dibuat TEXT');
          await db.update(
            'catatan',
            {'dibuat': DateTime.now().toIso8601String()},
            where: 'dibuat IS NULL',
          );
        }
      },
    );

    return _db!;
  }

  static Future<int> tambah(Catatan c) async {
    final db = await database;
    return db.insert('catatan', c.toMap());
  }

  static Future<List<Catatan>> semua({String orderBy = 'id DESC'}) async {
    final db = await database;
    final rows = await db.query('catatan', orderBy: orderBy);
    return rows.map(Catatan.fromMap).toList();
  }

  // LATIHAN POIN 2: MENCARI DATA MENGGUNAKAN WHERE LIKE
  static Future<List<Catatan>> cari(String kata, {String orderBy = 'id DESC'}) async {
    final db = await database;
    final rows = await db.query(
      'catatan',
      where: 'judul LIKE ?',
      whereArgs: ['%$kata%'],
      orderBy: orderBy,
    );
    return rows.map(Catatan.fromMap).toList();
  }

  static Future<int> ubah(Catatan c) async {
    final db = await database;
    return db.update('catatan', c.toMap(), where: 'id = ?', whereArgs: [c.id]);
  }

  static Future<int> hapus(int id) async {
    final db = await database;
    return db.delete('catatan', where: 'id = ?', whereArgs: [id]);
  }
}

// =========================================================================
// HALAMAN DAFTAR CATATAN UTAMA (LATIHAN POIN 2 & POIN 4)
// =========================================================================
class CatatanPage extends StatefulWidget {
  const CatatanPage({super.key});

  @override
  State<CatatanPage> createState() => _CatatanPageState();
}

class _CatatanPageState extends State<CatatanPage> {
  late Future<List<Catatan>> _future;
  final TextEditingController _searchController = TextEditingController();
  String _urutan = 'terbaru';

  @override
  void initState() {
    super.initState();
    _future = DbHelper.semua();
    _searchController.addListener(_muat);
    _ambilUrutanSaved();
  }

  @override
  void dispose() {
    _searchController.removeListener(_muat);
    _searchController.dispose();
    super.dispose();
  }

  // LATIHAN POIN 4: MEMBACA URUTAN DARI SHARED PREFERENCES
  Future<void> _ambilUrutanSaved() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _urutan = prefs.getString('urutan') ?? 'terbaru';
    });
    _muat();
  }

  // LATIHAN POIN 4: MENYIMPAN PILIHAN URUTAN
  Future<void> _simpanUrutanSaved(String nilai) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('urutan', nilai);
    setState(() {
      _urutan = nilai;
    });
    _muat();
  }

  String get _orderByText {
    if (_urutan == 'terlama') {
      return 'dibuat ASC';
    }
    return 'dibuat DESC';
  }

  void _muat() {
    final kata = _searchController.text.trim();
    setState(() {
      if (kata.isEmpty) {
        _future = DbHelper.semua(orderBy: _orderByText);
      } else {
        _future = DbHelper.cari(kata, orderBy: _orderByText);
      }
    });
  }

  Future<void> _buka([Catatan? catatan]) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FormCatatanPage(catatan: catatan)),
    );
    if (!mounted) return;
    _muat();
  }

  // LATIHAN POIN 1: ALERT DIALOG KONFIRMASI HAPUS DATA
  Future<void> _konfirmasiHapus(Catatan c) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Hapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (konfirmasi == true) {
      await DbHelper.hapus(c.id!);
      _muat();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Catatan'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            initialValue: _urutan,
            onSelected: _simpanUrutanSaved,
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'terbaru', child: Text('Terbaru')),
              PopupMenuItem(value: 'terlama', child: Text('Terlama')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Cari catatan',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _searchController.clear(),
                )
                    : null,
                border: const OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Catatan>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Galat: ${snapshot.error}'));
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Center(child: Text('Belum ada catatan'));
                }
                return ListView.builder(
                  itemCount: data.length,
                  itemBuilder: (context, i) {
                    final c = data[i];
                    return ListTile(
                      title: Text(c.judul),
                      subtitle: Text(
                        'Dibuat: ${c.dibuat.split('T')[0]}\n${c.isi}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => _buka(c),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _konfirmasiHapus(c),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _buka(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

// =========================================================================
// HALAMAN FORM EDIT & TAMBAH DATA (LATIHAN POIN 3)
// =========================================================================
class FormCatatanPage extends StatefulWidget {
  final Catatan? catatan;
  const FormCatatanPage({super.key, this.catatan});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _judul;
  late final TextEditingController _isi;

  @override
  void initState() {
    super.initState();
    _judul = TextEditingController(text: widget.catatan?.judul ?? '');
    _isi = TextEditingController(text: widget.catatan?.isi ?? '');
  }

  @override
  void dispose() {
    _judul.dispose();
    _isi.dispose();
    super.dispose();
  }
  Future _simpan() async {
    if (!_formKey.currentState!.validate()) return;
    final waktuSekarang = widget.catatan?.dibuat ?? DateTime.now().toIso8601String();
    final c = Catatan(
      id: widget.catatan?.id,
      judul: _judul.text.trim(),
      isi: _isi.text.trim(),
      dibuat: waktuSekarang,
    );
    if (widget.catatan == null) {
      await DbHelper.tambah(c);
    } else {
      await DbHelper.ubah(c);
    }
    if (!mounted) return;
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    final baru = widget.catatan == null;
    return Scaffold(
      appBar: AppBar(title: Text(baru ? 'Catatan Baru' : 'Ubah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judul,
              decoration: const InputDecoration(labelText: 'Judul', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib diisi' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _isi,
              maxLines: 6,
              decoration: const InputDecoration(labelText: 'Isi catatan', border: OutlineInputBorder()),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _simpan, child: const Text('Simpan')),
          ],
        ),
      ),
    );
  }
}