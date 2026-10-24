import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

const Color biru = Color(0xFF4776E6);
const Color hijau = Color(0xFF219C75);
const Color merah = Color(0xFFE46B72);
const Color latar = Color(0xFFF5F7FC);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.load();
  await DbHelper.init();
  runApp(const TabungKuApp());
}

// ================= SETTINGS =================

class AppSettings {
  static late SharedPreferences prefs;
  static bool darkMode = false;
  static int seed = 0xFF4776E6;
  static double target = 200000;

  static Future<void> load() async {
    prefs = await SharedPreferences.getInstance();
    darkMode = prefs.getBool('darkMode') ?? false;
    seed = prefs.getInt('seed') ?? 0xFF4776E6;
    target = prefs.getDouble('target') ?? 200000;
  }

  static Future<void> save() async {
    await prefs.setBool('darkMode', darkMode);
    await prefs.setInt('seed', seed);
    await prefs.setDouble('target', target);
  }
}

// ================= MODEL =================

enum Tipe { tanpa, pemasukan, pengeluaran }

class Kegiatan {
  int? id;
  String judul;
  String tanggal;
  bool selesai;
  Tipe tipe;
  int nominal;
  String kategori;

  Kegiatan({
    this.id,
    required this.judul,
    required this.tanggal,
    this.selesai = false,
    required this.tipe,
    this.nominal = 0,
    this.kategori = '-',
  });

  Map<String, Object?> toMap() => {
    'id': id,
    'judul': judul,
    'tanggal': tanggal,
    'selesai': selesai ? 1 : 0,
    'tipe': tipe.name,
    'nominal': nominal,
    'kategori': kategori,
  };

  factory Kegiatan.fromMap(Map<String, Object?> m) => Kegiatan(
    id: m['id'] as int,
    judul: m['judul'] as String,
    tanggal: m['tanggal'] as String,
    selesai: (m['selesai'] as int) == 1,
    tipe: Tipe.values.byName(m['tipe'] as String),
    nominal: m['nominal'] as int,
    kategori: m['kategori'] as String,
  );
}

class Ringkasan {
  final int jumlah, selesai, pemasukan, pengeluaran;

  Ringkasan({
    required this.jumlah,
    required this.selesai,
    required this.pemasukan,
    required this.pengeluaran,
  });

  int get tabungan => pemasukan - pengeluaran;
}

// ================= DATABASE =================

class DbHelper {
  static Database? _db;
  static final ValueNotifier<int> versiData = ValueNotifier(0);

  static Future<void> init() async {
    final lokasi = p.join(await getDatabasesPath(), 'tabungku.db');
    _db = await openDatabase(
      lokasi,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE kegiatan (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            judul TEXT NOT NULL,
            tanggal TEXT NOT NULL,
            selesai INTEGER NOT NULL DEFAULT 0,
            tipe TEXT NOT NULL,
            nominal INTEGER NOT NULL DEFAULT 0,
            kategori TEXT NOT NULL DEFAULT '-'
          )
        ''');
      },
    );
  }

  static Database get db => _db!;

  static Future<List<Kegiatan>> semua(String tanggal) async {
    final rows = await db.query(
      'kegiatan',
      where: 'tanggal = ?',
      whereArgs: [tanggal],
      orderBy: 'id DESC',
    );
    return rows.map(Kegiatan.fromMap).toList();
  }

  static Future<void> tambah(Kegiatan k) async {
    await db.insert('kegiatan', k.toMap());
    versiData.value++;
  }

  static Future<void> ubah(Kegiatan k) async {
    await db.update('kegiatan', k.toMap(),
        where: 'id = ?', whereArgs: [k.id]);
    versiData.value++;
  }

  static Future<void> hapus(int id) async {
    await db.delete('kegiatan', where: 'id = ?', whereArgs: [id]);
    versiData.value++;
  }

  static Future<Ringkasan> ringkasan(String tanggal) async {
    final rows = await db.rawQuery('''
      SELECT COUNT(*) AS jumlah,
        COALESCE(SUM(selesai),0) AS selesai,
        COALESCE(SUM(CASE WHEN tipe='pemasukan'
          THEN nominal ELSE 0 END),0) AS masuk,
        COALESCE(SUM(CASE WHEN tipe='pengeluaran'
          THEN nominal ELSE 0 END),0) AS keluar
      FROM kegiatan WHERE tanggal = ?
    ''', [tanggal]);

    final r = rows.first;
    return Ringkasan(
      jumlah: r['jumlah'] as int,
      selesai: r['selesai'] as int,
      pemasukan: r['masuk'] as int,
      pengeluaran: r['keluar'] as int,
    );
  }

  static Future<Map<String, int>> perKategori(String tanggal) async {
    final rows = await db.rawQuery('''
      SELECT kategori, SUM(nominal) AS total
      FROM kegiatan
      WHERE tanggal = ? AND tipe = 'pengeluaran'
      GROUP BY kategori
      ORDER BY total DESC
    ''', [tanggal]);

    return {
      for (final r in rows)
        r['kategori'] as String: r['total'] as int,
    };
  }

  static Future<List<Map<String, Object?>>> tujuhHari() async {
    return db.rawQuery('''
      SELECT tanggal,
        COALESCE(SUM(CASE WHEN tipe='pemasukan'
          THEN nominal ELSE 0 END),0) AS masuk,
        COALESCE(SUM(CASE WHEN tipe='pengeluaran'
          THEN nominal ELSE 0 END),0) AS keluar
      FROM kegiatan
      WHERE tanggal >= date('now','localtime','-6 days')
        AND tanggal <= date('now','localtime')
      GROUP BY tanggal ORDER BY tanggal DESC
    ''');
  }
}

// ================= UTILITAS =================

String tanggalISO(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';

String rupiah(int n) {
  final s = n.abs().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
        (_) => '.',
  );
  return '${n < 0 ? '-' : ''}Rp $s';
}

String namaTipe(Tipe t) => switch (t) {
  Tipe.tanpa => 'Tanpa transaksi',
  Tipe.pemasukan => 'Pemasukan',
  Tipe.pengeluaran => 'Pengeluaran',
};

String tanggalIndo(DateTime d) {
  const bulan = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
  ];
  return '${d.day} ${bulan[d.month - 1]} ${d.year}';
}

void pesan(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

// ================= APP =================

class TabungKuApp extends StatefulWidget {
  const TabungKuApp({super.key});

  @override
  State<TabungKuApp> createState() => _TabungKuAppState();
}

class _TabungKuAppState extends State<TabungKuApp> {
  void refreshTheme() => setState(() {});

  ThemeData buatTema(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: Color(AppSettings.seed),
      brightness: brightness,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? latar
          : const Color(0xFF111827),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: brightness == Brightness.light
            ? Colors.white
            : const Color(0xFF1F2937),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: brightness == Brightness.light
                ? const Color(0xFFE9EDF5)
                : Colors.white10,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? const Color(0xFFF7F8FC)
            : const Color(0xFF263244),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TabungKu',
      debugShowCheckedModeBanner: false,
      theme: buatTema(Brightness.light),
      darkTheme: buatTema(Brightness.dark),
      themeMode: AppSettings.darkMode ? ThemeMode.dark : ThemeMode.light,
      routes: {
        '/': (_) => ShellPage(onThemeChanged: refreshTheme),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/form') {
          return MaterialPageRoute(
            builder: (_) => FormKegiatanPage(
              item: settings.arguments as Kegiatan?,
            ),
          );
        }
        return null;
      },
    );
  }
}

// ================= WIDGET KECIL =================

class JudulBagian extends StatelessWidget {
  final String judul;
  final String? aksi;
  final VoidCallback? onAksi;

  const JudulBagian(this.judul, {super.key, this.aksi, this.onAksi});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(judul, style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      )),
      if (aksi != null)
        TextButton(onPressed: onAksi, child: Text(aksi!)),
    ],
  );
}

class KartuAngka extends StatelessWidget {
  final String judul;
  final int angka;
  final IconData ikon;
  final Color warna;

  const KartuAngka({
    super.key,
    required this.judul,
    required this.angka,
    required this.ikon,
    required this.warna,
  });

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: warna.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(ikon, color: warna),
          ),
          const SizedBox(height: 12),
          Text(judul, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 5),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              rupiah(angka),
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: warna,
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

// ================= NAVIGASI =================

class ShellPage extends StatefulWidget {
  final VoidCallback onThemeChanged;
  const ShellPage({super.key, required this.onThemeChanged});

  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const BerandaPage(),
      const LaporanPage(),
      PengaturanPage(onChanged: widget.onThemeChanged),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(index: index, children: pages),
      ),
      floatingActionButton: index == 0
          ? FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/form'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah kegiatan'),
      )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Hari Ini',
          ),
          NavigationDestination(
            icon: Icon(Icons.insert_chart_outlined_rounded),
            selectedIcon: Icon(Icons.insert_chart_rounded),
            label: 'Laporan',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune_rounded),
            selectedIcon: Icon(Icons.tune),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// ================= BERANDA =================

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  late Future<List<Kegiatan>> daftar;
  late Future<Ringkasan> ringkas;

  String get hariIni => tanggalISO(DateTime.now());

  @override
  void initState() {
    super.initState();
    _muat();
    DbHelper.versiData.addListener(_muat);
  }

  void _muat() {
    daftar = DbHelper.semua(hariIni);
    ringkas = DbHelper.ringkasan(hariIni);
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DbHelper.versiData.removeListener(_muat);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 100),
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tanggalIndo(DateTime.now()).toUpperCase(),
                    style: TextStyle(
                      color: warna.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Halo, Teman! 👋',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Yuk, atur kegiatan dan tabunganmu.',
                    style: TextStyle(color: warna.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              radius: 26,
              backgroundColor: warna.primaryContainer,
              child: Icon(Icons.savings_rounded,
                  size: 29, color: warna.primary),
            ),
          ],
        ),
        const SizedBox(height: 24),
        FutureBuilder<Ringkasan>(
          future: ringkas,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }
            final r = snapshot.data!;
            final progress =
            (r.tabungan / AppSettings.target).clamp(0.0, 1.0);
            final negatif = r.tabungan < 0;
            final tercapai = r.tabungan >= AppSettings.target;

            return Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: negatif
                      ? [const Color(0xFFD95F67), const Color(0xFFB83D55)]
                      : [Color(AppSettings.seed), const Color(0xFF76A0FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Color(AppSettings.seed).withValues(alpha: 0.20),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Total tabungan hari ini',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Icon(
                        negatif
                            ? Icons.warning_amber_rounded
                            : Icons.account_balance_wallet_rounded,
                        color: Colors.white,
                        size: 27,
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      rupiah(r.tabungan),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Kemajuan target',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 9),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 800),
                      builder: (context, value, _) =>
                          LinearProgressIndicator(
                            value: value,
                            minHeight: 9,
                            backgroundColor: Colors.white30,
                            color: Colors.white,
                          ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    negatif
                        ? 'Pengeluaran melebihi pemasukan. Yuk evaluasi!'
                        : tercapai
                        ? 'Hebat! Target tabunganmu tercapai 🎉'
                        : 'Target harian ${rupiah(AppSettings.target.toInt())}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 22),
        const JudulBagian('Ringkasan keuangan'),
        const SizedBox(height: 8),
        FutureBuilder<Ringkasan>(
          future: ringkas,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }
            final r = snapshot.data!;
            return Row(
              children: [
                Expanded(
                  child: KartuAngka(
                    judul: 'Pemasukan',
                    angka: r.pemasukan,
                    ikon: Icons.south_west_rounded,
                    warna: hijau,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: KartuAngka(
                    judul: 'Pengeluaran',
                    angka: r.pengeluaran,
                    ikon: Icons.north_east_rounded,
                    warna: merah,
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        JudulBagian(
          'Kegiatan hari ini',
          aksi: 'Tambah',
          onAksi: () => Navigator.pushNamed(context, '/form'),
        ),
        const SizedBox(height: 8),
        FutureBuilder<List<Kegiatan>>(
          future: daftar,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (snapshot.hasError) {
              return const Text('Gagal memuat kegiatan.');
            }
            final data = snapshot.data ?? [];

            if (data.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    children: [
                      Icon(Icons.event_note_rounded,
                          size: 48, color: warna.primary),
                      const SizedBox(height: 12),
                      const Text(
                        'Belum ada kegiatan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Tambahkan kegiatan pertamamu hari ini.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: warna.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Column(
              children: data.map((k) {
                final uang = k.tipe == Tipe.pemasukan;
                final ikon = k.tipe == Tipe.pemasukan
                    ? Icons.south_west_rounded
                    : k.tipe == Tipe.pengeluaran
                    ? Icons.north_east_rounded
                    : Icons.task_alt_rounded;
                final warnaIkon =
                uang ? hijau : k.tipe == Tipe.pengeluaran ? merah : biru;

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5, horizontal: 6),
                    child: ListTile(
                      leading: Checkbox(
                        value: k.selesai,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        onChanged: (v) async {
                          k.selesai = v ?? false;
                          await DbHelper.ubah(k);
                        },
                      ),
                      title: Text(
                        k.judul,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          decoration: k.selesai
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 5),
                        child: Text(
                          k.tipe == Tipe.tanpa
                              ? 'Tanpa transaksi'
                              : '${k.kategori == '-' ? namaTipe(k.tipe) : k.kategori} • ${rupiah(k.nominal)}',
                          style: TextStyle(color: warna.onSurfaceVariant),
                        ),
                      ),
                      trailing: PopupMenuButton<String>(
                        onSelected: (aksi) async {
                          if (aksi == 'ubah') {
                            await Navigator.pushNamed(
                              context, '/form', arguments: k,
                            );
                          } else {
                            final yakin = await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus kegiatan?'),
                                content: Text('Hapus "${k.judul}"?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, false),
                                    child: const Text('Batal'),
                                  ),
                                  FilledButton(
                                    onPressed: () =>
                                        Navigator.pop(ctx, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                            if (yakin == true && k.id != null) {
                              await DbHelper.hapus(k.id!);
                            }
                          }
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(
                              value: 'ubah', child: Text('Ubah')),
                          PopupMenuItem(
                              value: 'hapus', child: Text('Hapus')),
                        ],
                      ),
                      isThreeLine: false,
                      contentPadding: const EdgeInsets.only(right: 4),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ================= FORM =================

class FormKegiatanPage extends StatefulWidget {
  final Kegiatan? item;
  const FormKegiatanPage({super.key, this.item});

  @override
  State<FormKegiatanPage> createState() => _FormKegiatanPageState();
}

class _FormKegiatanPageState extends State<FormKegiatanPage> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController judul;
  late final TextEditingController nominal;
  late DateTime tanggal;
  late Tipe tipe;
  String kategori = 'Makan';

  final kategoriList = [
    'Makan', 'Transport', 'Belajar', 'Hiburan', 'Lainnya'
  ];

  @override
  void initState() {
    super.initState();
    final k = widget.item;
    judul = TextEditingController(text: k?.judul ?? '');
    nominal = TextEditingController(
      text: k != null && k.nominal > 0 ? '${k.nominal}' : '',
    );
    tanggal = DateTime.tryParse(k?.tanggal ?? '') ?? DateTime.now();
    tipe = k?.tipe ?? Tipe.tanpa;
    kategori = kategoriList.contains(k?.kategori) ? k!.kategori : 'Makan';
  }

  @override
  void dispose() {
    judul.dispose();
    nominal.dispose();
    super.dispose();
  }

  Future<void> simpan() async {
    if (!formKey.currentState!.validate()) return;

    final nilai = tipe == Tipe.tanpa ? 0 : int.parse(nominal.text);
    final k = Kegiatan(
      id: widget.item?.id,
      judul: judul.text.trim(),
      tanggal: tanggalISO(tanggal),
      selesai: widget.item?.selesai ?? false,
      tipe: tipe,
      nominal: nilai,
      kategori: tipe == Tipe.pengeluaran ? kategori : '-',
    );

    if (widget.item == null) {
      await DbHelper.tambah(k);
    } else {
      await DbHelper.ubah(k);
    }

    if (mounted) {
      Navigator.pop(context);
      pesan(context, 'Kegiatan berhasil disimpan');
    }
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.item == null ? 'Kegiatan Baru' : 'Ubah Kegiatan'),
      ),
      body: Form(
        key: formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: warna.primaryContainer,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.edit_calendar_rounded,
                      color: warna.primary, size: 35),
                  const SizedBox(height: 12),
                  Text(
                    'Rencanakan harimu',
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 5),
                  const Text('Catat kegiatan dan kelola uangmu dengan mudah.'),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Nama kegiatan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextFormField(
              controller: judul,
              decoration: const InputDecoration(
                hintText: 'Contoh: Belajar Flutter',
                prefixIcon: Icon(Icons.edit_note_rounded),
              ),
              validator: (v) =>
              v == null || v.trim().isEmpty
                  ? 'Nama kegiatan wajib diisi'
                  : null,
            ),
            const SizedBox(height: 20),
            const Text('Tanggal kegiatan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.calendar_month_rounded),
                title: Text(tanggalIndo(tanggal)),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: tanggal,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                  );
                  if (d != null) setState(() => tanggal = d);
                },
              ),
            ),
            const SizedBox(height: 20),
            const Text('Jenis keuangan',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            DropdownButtonFormField<Tipe>(
              value: tipe,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
              ),
              items: Tipe.values.map((t) => DropdownMenuItem(
                value: t,
                child: Text(namaTipe(t)),
              )).toList(),
              onChanged: (v) {
                if (v != null) setState(() => tipe = v);
              },
            ),
            if (tipe != Tipe.tanpa) ...[
              const SizedBox(height: 20),
              const Text('Nominal rupiah',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextFormField(
                controller: nominal,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Contoh: 15000',
                  prefixIcon: Icon(Icons.payments_outlined),
                  prefixText: 'Rp ',
                ),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) {
                    return 'Masukkan nominal lebih dari 0';
                  }
                  return null;
                },
              ),
            ],
            if (tipe == Tipe.pengeluaran) ...[
              const SizedBox(height: 20),
              const Text('Kategori pengeluaran',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: kategori,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.category_outlined),
                ),
                items: kategoriList.map((k) => DropdownMenuItem(
                  value: k, child: Text(k),
                )).toList(),
                onChanged: (v) {
                  if (v != null) setState(() => kategori = v);
                },
              ),
            ],
            const SizedBox(height: 30),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: simpan,
                icon: const Icon(Icons.check_rounded),
                label: const Text('Simpan Kegiatan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================= LAPORAN =================

class LaporanPage extends StatefulWidget {
  const LaporanPage({super.key});

  @override
  State<LaporanPage> createState() => _LaporanPageState();
}

class _LaporanPageState extends State<LaporanPage> {
  DateTime tanggal = DateTime.now();

  @override
  void initState() {
    super.initState();
    DbHelper.versiData.addListener(refresh);
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    DbHelper.versiData.removeListener(refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tgl = tanggalISO(tanggal);
    final warna = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      children: [
        Text('Laporan',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text('Pantau arus uang dan kebiasaan menabungmu.',
            style: TextStyle(color: warna.onSurfaceVariant)),
        const SizedBox(height: 20),
        Card(
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: warna.primaryContainer,
              child: Icon(Icons.calendar_month, color: warna.primary),
            ),
            title: const Text('Pilih tanggal'),
            subtitle: Text(tanggalIndo(tanggal)),
            trailing: const Icon(Icons.chevron_right),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: tanggal,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (d != null) setState(() => tanggal = d);
            },
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<Ringkasan>(
          future: DbHelper.ringkasan(tgl),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }
            final r = snapshot.data!;
            return Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Tabungan bersih'),
                        const SizedBox(height: 8),
                        Text(
                          rupiah(r.tabungan),
                          style: TextStyle(
                            fontSize: 29,
                            fontWeight: FontWeight.w900,
                            color: r.tabungan < 0 ? merah : hijau,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text('Kegiatan selesai ${r.selesai} dari ${r.jumlah}'),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(child: KartuAngka(
                      judul: 'Pemasukan',
                      angka: r.pemasukan,
                      ikon: Icons.south_west_rounded,
                      warna: hijau,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: KartuAngka(
                      judul: 'Pengeluaran',
                      angka: r.pengeluaran,
                      ikon: Icons.north_east_rounded,
                      warna: merah,
                    )),
                  ],
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 24),
        const JudulBagian('Pengeluaran per kategori'),
        FutureBuilder<Map<String, int>>(
          future: DbHelper.perKategori(tgl),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }
            if (snapshot.data!.isEmpty) {
              return const Card(
                child: ListTile(
                  leading: Icon(Icons.receipt_long_rounded),
                  title: Text('Belum ada pengeluaran'),
                ),
              );
            }
            return Column(
              children: snapshot.data!.entries.map((e) {
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.shopping_bag_outlined),
                    ),
                    title: Text(e.key),
                    trailing: Text(
                      rupiah(e.value),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        const JudulBagian('7 hari terakhir'),
        FutureBuilder<List<Map<String, Object?>>>(
          future: DbHelper.tujuhHari(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const LinearProgressIndicator();
            }
            if (snapshot.data!.isEmpty) {
              return const Card(
                child: ListTile(title: Text('Belum ada data mingguan')),
              );
            }
            return Column(
              children: snapshot.data!.map((r) {
                final masuk = r['masuk'] as int;
                final keluar = r['keluar'] as int;
                return Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_view_week_rounded),
                    title: Text(r['tanggal'] as String),
                    subtitle: Text('Masuk ${rupiah(masuk)} • Keluar ${rupiah(keluar)}'),
                    trailing: Text(
                      rupiah(masuk - keluar),
                      style: TextStyle(
                        color: masuk - keluar < 0 ? merah : hijau,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

// ================= PENGATURAN =================

class PengaturanPage extends StatefulWidget {
  final VoidCallback onChanged;
  const PengaturanPage({super.key, required this.onChanged});

  @override
  State<PengaturanPage> createState() => _PengaturanPageState();
}

class _PengaturanPageState extends State<PengaturanPage> {
  final warnaList = <int, String>{
    0xFF4776E6: 'Biru',
    0xFF219C75: 'Hijau',
    0xFF9461D5: 'Ungu',
    0xFFE69A37: 'Oranye',
    0xFFE46B72: 'Merah muda',
  };

  Future<void> simpan() async {
    await AppSettings.save();
    widget.onChanged();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final warna = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 30),
      children: [
        Text('Pengaturan',
            style: Theme.of(context).textTheme.headlineMedium
                ?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 5),
        Text('Sesuaikan TabungKu dengan kebutuhanmu.',
            style: TextStyle(color: warna.onSurfaceVariant)),
        const SizedBox(height: 22),
        Card(
          child: SwitchListTile(
            secondary: CircleAvatar(
              backgroundColor: warna.primaryContainer,
              child: Icon(Icons.dark_mode_outlined, color: warna.primary),
            ),
            title: const Text('Mode gelap',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('Lebih nyaman di malam hari'),
            value: AppSettings.darkMode,
            onChanged: (v) async {
              setState(() => AppSettings.darkMode = v);
              await simpan();
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: warna.primaryContainer,
                      child: Icon(Icons.palette_outlined, color: warna.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Warna tema',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 14,
                  runSpacing: 14,
                  children: warnaList.entries.map((e) {
                    final selected = AppSettings.seed == e.key;
                    return InkWell(
                      onTap: () async {
                        setState(() => AppSettings.seed = e.key);
                        await simpan();
                      },
                      borderRadius: BorderRadius.circular(30),
                      child: Column(
                        children: [
                          Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              color: Color(e.key),
                              shape: BoxShape.circle,
                              border: selected
                                  ? Border.all(
                                  color: warna.onSurface, width: 3)
                                  : null,
                            ),
                            child: selected
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(height: 5),
                          Text(e.value, style: const TextStyle(fontSize: 11)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: warna.primaryContainer,
                      child: Icon(Icons.savings_outlined, color: warna.primary),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text('Target tabungan harian',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Text(
                  rupiah(AppSettings.target.toInt()),
                  style: TextStyle(
                    color: warna.primary,
                    fontWeight: FontWeight.w900,
                    fontSize: 26,
                  ),
                ),
                Slider(
                  min: 5000,
                  max: 2000000,
                  divisions: 39,
                  label: rupiah(AppSettings.target.toInt()),
                  value: AppSettings.target.clamp(5000, 2000000),
                  onChanged: (v) =>
                      setState(() => AppSettings.target = v),
                  onChangeEnd: (_) => simpan(),
                ),
                const Text('Target dapat diatur dari Rp5.000 hingga Rp2.000.000.'),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: simpan,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Simpan pengaturan'),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Column(
            children: [
              Icon(Icons.savings_rounded, color: warna.primary, size: 35),
              const SizedBox(height: 5),
              const Text('TabungKu',
                  style: TextStyle(fontWeight: FontWeight.w800)),
              Text('Kelola kegiatan, wujudkan tabungan.',
                  style: TextStyle(color: warna.onSurfaceVariant, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}