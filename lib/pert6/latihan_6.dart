import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ======================================================
// TEMA GLOBAL
// ======================================================

final themeMode = ValueNotifier<ThemeMode>(
  ThemeMode.light,
);

final seedColor = ValueNotifier<Color>(
  Colors.indigo,
);

const pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

// ======================================================
// DATA ITEM
// ======================================================

class Item {
  final String nama;
  final IconData ikon;
  final Color warna;

  const Item(
      this.nama,
      this.ikon,
      this.warna,
      );
}

const daftarItem = [
  Item(
    'Flutter',
    Icons.flutter_dash,
    Colors.blue,
  ),
  Item(
    'Musik',
    Icons.music_note,
    Colors.pink,
  ),
  Item(
    'Kamera',
    Icons.camera_alt,
    Colors.orange,
  ),
  Item(
    'Peta',
    Icons.map,
    Colors.green,
  ),
];

// ======================================================
// MEMBUAT TEMA
// ======================================================

ThemeData buatTema(
    Color seed,
    Brightness brightness,
    ) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,

    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
  );
}

// ======================================================
// MAIN
// ======================================================

Future<void> main() async {
  // Wajib sebelum SharedPreferences
  WidgetsFlutterBinding.ensureInitialized();

  // Membuka SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // ====================================================
  // MEMUAT MODE GELAP
  // ====================================================

  final modeGelap =
      prefs.getBool('modeGelap') ?? false;

  themeMode.value = modeGelap
      ? ThemeMode.dark
      : ThemeMode.light;

  // ====================================================
  // MEMUAT WARNA TEMA
  // ====================================================

  final warnaTersimpan =
  prefs.getInt('warnaTema');

  if (warnaTersimpan != null) {
    seedColor.value = Color(warnaTersimpan);
  }

  runApp(const MyApp());
}

// ======================================================
// MY APP
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        themeMode,
        seedColor,
      ]),

      builder: (context, child) {
        return MaterialApp(
          title: 'Latihan Mandiri Pertemuan 6',
          debugShowCheckedModeBanner: false,

          // ==================================================
          // TEMA TERANG
          // ==================================================

          theme: buatTema(
            seedColor.value,
            Brightness.light,
          ),

          // ==================================================
          // TEMA GELAP
          // ==================================================

          darkTheme: buatTema(
            seedColor.value,
            Brightness.dark,
          ),

          themeMode: themeMode.value,

          // ==================================================
          // ROUTE UTAMA
          // ==================================================

          initialRoute: '/',

          routes: {
            '/': (context) => const ShellPage(),
          },

          // ==================================================
          // ON GENERATE ROUTE
          // ==================================================

          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final item =
              settings.arguments as Item;

              // ==================================================
              // LATIHAN 3
              // PageRouteBuilder + FadeTransition
              // ==================================================

              return PageRouteBuilder(
                pageBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    ) {
                  return DetailPage(
                    item: item,
                  );
                },

                transitionsBuilder: (
                    context,
                    animation,
                    secondaryAnimation,
                    child,
                    ) {
                  return FadeTransition(
                    opacity: animation,
                    child: child,
                  );
                },

                transitionDuration:
                const Duration(
                  milliseconds: 500,
                ),
              );
            }

            return null;
          },

          // ==================================================
          // LATIHAN 4
          // UNKNOWN ROUTE / 404
          // ==================================================

          onUnknownRoute: (settings) {
            return MaterialPageRoute(
              builder: (context) {
                return const Halaman404();
              },
            );
          },
        );
      },
    );
  }
}

// ======================================================
// SHELL PAGE
// ======================================================

class ShellPage extends StatefulWidget {
  const ShellPage({super.key});

  @override
  State<ShellPage> createState() =>
      _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;

  // Halaman
  static const _halaman = [
    BerandaTab(),
    AnimasiTab(),
    PengaturanTab(),
  ];

  // Judul
  static const _judul = [
    'Beranda',
    'Animasi',
    'Pengaturan',
  ];

  // ====================================================
  // GANTI TAB
  // ====================================================

  void pindahTab(int index) {
    setState(() {
      _index = index;
    });

    // Menutup Drawer
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _judul[_index],
        ),
      ),

      // ==================================================
      // LATIHAN 2
      // DRAWER
      // ==================================================

      drawer: Drawer(
        child: SafeArea(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              // ==================================================
              // HEADER DRAWER
              // ==================================================

              DrawerHeader(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.flutter_dash,
                      size: 50,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Praktikum 6',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall,
                    ),

                    Text(
                      'Latihan Mandiri',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ],
                ),
              ),

              // ==================================================
              // MENU BERANDA
              // ==================================================

              ListTile(
                leading: const Icon(
                  Icons.home,
                ),

                title: const Text(
                  'Beranda',
                ),

                selected: _index == 0,

                onTap: () {
                  pindahTab(0);
                },
              ),

              // ==================================================
              // MENU ANIMASI
              // ==================================================

              ListTile(
                leading: const Icon(
                  Icons.animation,
                ),

                title: const Text(
                  'Animasi',
                ),

                selected: _index == 1,

                onTap: () {
                  pindahTab(1);
                },
              ),

              // ==================================================
              // MENU PENGATURAN
              // ==================================================

              ListTile(
                leading: const Icon(
                  Icons.settings,
                ),

                title: const Text(
                  'Pengaturan',
                ),

                selected: _index == 2,

                onTap: () {
                  pindahTab(2);
                },
              ),
            ],
          ),
        ),
      ),

      // ==================================================
      // INDEXED STACK
      // ==================================================

      body: IndexedStack(
        index: _index,
        children: _halaman,
      ),

      // ==================================================
      // NAVIGATION BAR
      // ==================================================

      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,

        onDestinationSelected: (index) {
          setState(() {
            _index = index;
          });
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Beranda',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.animation_outlined,
            ),
            selectedIcon: Icon(
              Icons.animation,
            ),
            label: 'Animasi',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.settings_outlined,
            ),
            selectedIcon: Icon(
              Icons.settings,
            ),
            label: 'Pengaturan',
          ),
        ],
      ),
    );
  }
}

// ======================================================
// BERANDA TAB
// ======================================================

class BerandaTab extends StatelessWidget {
  const BerandaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView.builder(
      padding: const EdgeInsets.all(16),

      itemCount: daftarItem.length,

      itemBuilder: (context, index) {
        final item = daftarItem[index];

        return Card(
          margin: const EdgeInsets.only(
            bottom: 12,
          ),

          child: ListTile(
            // ==================================================
            // HERO
            // ==================================================

            leading: Hero(
              tag: 'ikon-${item.nama}',

              child: CircleAvatar(
                backgroundColor: item.warna,

                child: Icon(
                  item.ikon,
                  color: tema.colorScheme.onPrimary,
                ),
              ),
            ),

            // ==================================================
            // NAMA
            // ==================================================

            title: Text(
              item.nama,
              style: tema.textTheme.titleMedium,
            ),

            // ==================================================
            // KETERANGAN
            // ==================================================

            subtitle: const Text(
              'Tekan untuk melihat detail',
            ),

            trailing: const Icon(
              Icons.arrow_forward_ios,
              size: 18,
            ),

            // ==================================================
            // NAVIGASI DETAIL
            // ==================================================

            onTap: () {
              Navigator.pushNamed(
                context,
                '/detail',
                arguments: item,
              );
            },
          ),
        );
      },
    );
  }
}

// ======================================================
// DETAIL PAGE
// ======================================================

class DetailPage extends StatelessWidget {
  final Item item;

  const DetailPage({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          item.nama,
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,

          children: [
            // ==================================================
            // HERO
            // ==================================================

            Hero(
              tag: 'ikon-${item.nama}',

              child: CircleAvatar(
                radius: 60,

                backgroundColor: item.warna,

                child: Icon(
                  item.ikon,
                  size: 60,
                  color: tema.colorScheme.onPrimary,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ==================================================
            // NAMA
            // ==================================================

            Text(
              item.nama,
              style: tema.textTheme.headlineMedium,
            ),

            const SizedBox(height: 12),

            Text(
              'Ini adalah halaman detail ${item.nama}.',
              style: tema.textTheme.bodyLarge,
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },

              icon: const Icon(
                Icons.arrow_back,
              ),

              label: const Text(
                'Kembali',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ======================================================
// ANIMASI TAB
// ======================================================

class AnimasiTab extends StatefulWidget {
  const AnimasiTab({super.key});

  @override
  State<AnimasiTab> createState() =>
      _AnimasiTabState();
}

class _AnimasiTabState
    extends State<AnimasiTab>
    with SingleTickerProviderStateMixin {
  // AnimatedContainer
  bool _besar = false;

  // AnimatedSwitcher
  int _hitung = 0;

  // AnimationController
  late final AnimationController _putar;

  // ====================================================
  // LATIHAN 5
  // AnimatedOpacity
  // ====================================================

  bool _terlihat = true;

  @override
  void initState() {
    super.initState();

    // AnimationController
    _putar = AnimationController(
      vsync: this,

      duration: const Duration(
        seconds: 2,
      ),
    )..repeat();
  }

  @override
  void dispose() {
    _putar.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),

      children: [
        // ==================================================
        // ANIMATED CONTAINER
        // ==================================================

        Text(
          'AnimatedContainer',
          style: tema.textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        Center(
          child: AnimatedContainer(
            duration: const Duration(
              milliseconds: 500,
            ),

            width: _besar ? 220 : 120,

            height: _besar ? 220 : 120,

            decoration: BoxDecoration(
              color: _besar
                  ? tema.colorScheme.primary
                  : tema.colorScheme.secondary,

              borderRadius:
              BorderRadius.circular(
                _besar ? 40 : 12,
              ),
            ),

            child: Icon(
              Icons.flutter_dash,

              size: _besar ? 90 : 60,

              color:
              tema.colorScheme.onPrimary,
            ),
          ),
        ),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: () {
            setState(() {
              _besar = !_besar;
            });
          },

          child: const Text(
            'Ubah Ukuran',
          ),
        ),

        const SizedBox(height: 32),

        // ==================================================
        // ANIMATED SWITCHER
        // ==================================================

        Text(
          'AnimatedSwitcher',
          style: tema.textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        Center(
          child: AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 500,
            ),

            transitionBuilder: (
                child,
                animation,
                ) {
              return ScaleTransition(
                scale: animation,
                child: child,
              );
            },

            child: Text(
              '$_hitung',

              key: ValueKey(
                _hitung,
              ),

              style:
              tema.textTheme.displayLarge,
            ),
          ),
        ),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: () {
            setState(() {
              _hitung++;
            });
          },

          child: const Text(
            'Tambah',
          ),
        ),

        const SizedBox(height: 32),

        // ==================================================
        // ROTATION TRANSITION
        // ==================================================

        Text(
          'RotationTransition',
          style: tema.textTheme.titleLarge,
        ),

        const SizedBox(height: 24),

        Center(
          child: RotationTransition(
            turns: _putar,

            child: Icon(
              Icons.settings,

              size: 100,

              color:
              tema.colorScheme.primary,
            ),
          ),
        ),

        const SizedBox(height: 24),

        FilledButton(
          onPressed: () {
            if (_putar.isAnimating) {
              _putar.stop();
            } else {
              _putar.repeat();
            }

            setState(() {});
          },

          child: Text(
            _putar.isAnimating
                ? 'Berhenti'
                : 'Putar Lagi',
          ),
        ),

        const SizedBox(height: 32),

        // ==================================================
        // LATIHAN 5
        // ANIMATED OPACITY
        // ==================================================

        Text(
          'AnimatedOpacity',
          style: tema.textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        Center(
          child: AnimatedOpacity(
            duration: const Duration(
              milliseconds: 500,
            ),

            opacity:
            _terlihat ? 1.0 : 0.0,

            child: Card(
              child: Padding(
                padding:
                const EdgeInsets.all(24),

                child: Column(
                  children: [
                    Icon(
                      Icons.star,

                      size: 60,

                      color:
                      tema.colorScheme.primary,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Kartu Animasi',
                      style: tema
                          .textTheme
                          .titleMedium,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      'Kartu ini dapat '
                          'dimunculkan dan '
                          'disembunyikan.',
                      textAlign:
                      TextAlign.center,

                      style: tema
                          .textTheme
                          .bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        const SizedBox(height: 16),

        FilledButton(
          onPressed: () {
            setState(() {
              _terlihat = !_terlihat;
            });
          },

          child: Text(
            _terlihat
                ? 'Sembunyikan Kartu'
                : 'Tampilkan Kartu',
          ),
        ),
      ],
    );
  }
}

// ======================================================
// PENGATURAN TAB
// ======================================================

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  // ====================================================
  // SIMPAN MODE GELAP
  // ====================================================

  Future<void> simpanModeGelap(
      bool value,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setBool(
      'modeGelap',
      value,
    );
  }

  // ====================================================
  // SIMPAN WARNA
  // ====================================================

  Future<void> simpanWarna(
      Color warna,
      ) async {
    final prefs =
    await SharedPreferences.getInstance();

    await prefs.setInt(
      'warnaTema',
      warna.value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        themeMode,
        seedColor,
      ]),

      builder: (context, child) {
        return ListView(
          padding: const EdgeInsets.all(16),

          children: [
            // ==================================================
            // MODE GELAP
            // ==================================================

            SwitchListTile(
              title: const Text(
                'Mode gelap',
              ),

              subtitle: const Text(
                'Simpan pengaturan tema',
              ),

              value:
              themeMode.value ==
                  ThemeMode.dark,

              onChanged: (value) async {
                themeMode.value = value
                    ? ThemeMode.dark
                    : ThemeMode.light;

                await simpanModeGelap(
                  value,
                );
              },
            ),

            const SizedBox(height: 24),

            // ==================================================
            // WARNA TEMA
            // ==================================================

            Text(
              'Warna tema',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium,
            ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 12,
              runSpacing: 12,

              children: [
                for (final warna
                in pilihanWarna)
                  GestureDetector(
                    onTap: () async {
                      seedColor.value =
                          warna;

                      await simpanWarna(
                        warna,
                      );
                    },

                    child: CircleAvatar(
                      backgroundColor:
                      warna,

                      child:
                      seedColor.value ==
                          warna
                          ? Icon(
                        Icons.check,

                        color: Theme
                            .of(
                          context,
                        )
                            .colorScheme
                            .onPrimary,
                      )
                          : null,
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 32),

            Card(
              child: Padding(
                padding:
                const EdgeInsets.all(16),

                child: Text(
                  'Mode gelap dan warna tema '
                      'akan tetap tersimpan '
                      'setelah aplikasi ditutup.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ======================================================
// LATIHAN 4
// HALAMAN 404
// ======================================================

class Halaman404 extends StatelessWidget {
  const Halaman404({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '404',
        ),
      ),

      body: Center(
        child: Padding(
          padding:
          const EdgeInsets.all(24),

          child: Column(
            mainAxisAlignment:
            MainAxisAlignment.center,

            children: [
              Icon(
                Icons.error_outline,

                size: 100,

                color:
                tema.colorScheme.error,
              ),

              const SizedBox(height: 24),

              Text(
                '404',
                style: tema
                    .textTheme
                    .displayLarge,
              ),

              const SizedBox(height: 8),

              Text(
                'Halaman tidak ditemukan',
                style: tema
                    .textTheme
                    .headlineSmall,
                textAlign:
                TextAlign.center,
              ),

              const SizedBox(height: 24),

              FilledButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/',
                        (route) => false,
                  );
                },

                child: const Text(
                  'Kembali ke Beranda',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}