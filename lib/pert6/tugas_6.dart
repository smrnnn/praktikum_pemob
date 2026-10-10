import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.blue);
const pilihanWarna = [Colors.blue, Colors.purple, Colors.orange];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(centerTitle: true),
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  themeMode.value = (prefs.getBool('isDark') ?? false) ? ThemeMode.dark : ThemeMode.light;
  seedColor.value = Color(prefs.getInt('seedColor') ?? Colors.blue.value);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([themeMode, seedColor]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Katalog Gadget Interaktif',
          debugShowCheckedModeBanner: false,
          theme: buatTema(seedColor.value, Brightness.light),
          darkTheme: buatTema(seedColor.value, Brightness.dark),
          themeMode: themeMode.value,
          initialRoute: '/',
          routes: {
            '/': (_) => const ShellPage(),
          },
          onGenerateRoute: (settings) {
            if (settings.name == '/detail') {
              final item = settings.arguments as Gadget;
              return MaterialPageRoute(builder: (_) => DetailPage(gadget: item));
            }
            return null;
          },
        );
      },
    );
  }
}

// --- MODEL DATA ---
class Gadget {
  final String nama;
  final String deskripsi;
  final String harga;
  final IconData ikon;
  final Color warnaKhas;
  const Gadget(this.nama, this.deskripsi, this.harga, this.ikon, this.warnaKhas);
}

const daftarGadget = [
  Gadget('Smartphone X', 'Layar AMOLED 120Hz & Kamera 108MP.', 'Rp 8.999.000', Icons.phone_android, Colors.blue),
  Gadget('Laptop Pro', 'Prosesor Generasi Terbaru & RAM 16GB.', 'Rp 15.499.000', Icons.laptop, Colors.purple),
  Gadget('Smartwatch S', 'Pelacak Kesehatan & Baterai Tahan 7 Hari.', 'Rp 2.499.000', Icons.watch, Colors.orange),
];

// --- NAVIGATION SHELL PAGE (3 TAB) ---
class ShellPage extends StatefulWidget {
  const ShellPage({super.key});
  @override
  State<ShellPage> createState() => _ShellPageState();
}

class _ShellPageState extends State<ShellPage> {
  int _index = 0;
  static const _halaman = [KatalogTab(), InfoAnimasiTab(), PengaturanTab()];
  static const _judul = ['Katalog Gadget', 'Demo Fitur', 'Pengaturan'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_judul[_index])),
      body: IndexedStack(index: _index, children: _halaman),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Katalog'),
          NavigationDestination(icon: Icon(Icons.bolt_outlined), selectedIcon: Icon(Icons.bolt), label: 'Animasi'),
          NavigationDestination(icon: Icon(Icons.settings_outlined), selectedIcon: Icon(Icons.settings), label: 'Tema'),
        ],
      ),
    );
  }
}

// --- TAB 1: DAFTAR KATALOG ---
class KatalogTab extends StatelessWidget {
  const KatalogTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: daftarGadget.length,
      padding: const EdgeInsets.all(12),
      itemBuilder: (context, i) {
        final item = daftarGadget[i];
        return Card(
          child: ListTile(
            leading: Hero(
              tag: 'gadget-${item.nama}',
              child: CircleAvatar(backgroundColor: item.warnaKhas, child: Icon(item.ikon, color: Colors.white)),
            ),
            title: Text(item.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(item.harga),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.pushNamed(context, '/detail', arguments: item),
          ),
        );
      },
    );
  }
}

// --- HALAMAN DETAIL (HERO TRANSITION & FIX AUTO UPDATE WARNA) ---
class DetailPage extends StatelessWidget {
  final Gadget gadget;
  const DetailPage({super.key, required this.gadget});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([themeMode, seedColor]),
        builder: (context, _) {
          final tema = Theme.of(context);
          return Scaffold(
            appBar: AppBar(title: Text(gadget.nama)),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Hero(
                    tag: 'gadget-${gadget.nama}',
                    child: CircleAvatar(
                        radius: 64,
                        backgroundColor: gadget.warnaKhas,
                        child: Icon(gadget.ikon, size: 64, color: Colors.white)
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(gadget.nama, style: tema.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(gadget.harga, style: tema.textTheme.titleLarge?.copyWith(color: tema.colorScheme.primary)),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(gadget.deskripsi, textAlign: TextAlign.center, style: tema.textTheme.bodyMedium),
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}

// --- TAB 2: DEMO ANIMASI (IMPLISIT & EKSPLISIT) ---
class InfoAnimasiTab extends StatefulWidget {
  const InfoAnimasiTab({super.key});
  @override
  State<InfoAnimasiTab> createState() => _InfoAnimasiTabState();
}

class _InfoAnimasiTabState extends State<InfoAnimasiTab> with SingleTickerProviderStateMixin {
  bool _diskonBesar = false;
  late final AnimationController _putarBaut;

  @override
  void initState() {
    super.initState();
    _putarBaut = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat();
  }

  @override
  void dispose() {
    _putarBaut.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('1. Animasi Implisit (Promo Card)', style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _diskonBesar ? tema.colorScheme.primaryContainer : tema.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(_diskonBesar ? 24 : 8),
            ),
            child: Text(_diskonBesar ? '🔥 DISKON BESAR 50% 🔥' : 'Diskon Standar 10%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ),
        ),
        ElevatedButton(onPressed: () => setState(() => _diskonBesar = !_diskonBesar), child: const Text('Ubah Status Promo')),
        const Divider(height: 32),
        Text('2. Animasi Eksplisit (Loading Gear)', style: tema.textTheme.titleMedium),
        const SizedBox(height: 16),
        Center(child: RotationTransition(turns: _putarBaut, child: Icon(Icons.sync, size: 64, color: tema.colorScheme.primary))),
      ],
    );
  }
}

// --- TAB 3: PENGATURAN TEMA ---
class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
        listenable: Listenable.merge([themeMode, seedColor]),
        builder: (context, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SwitchListTile(
                title: const Text('Mode Gelap Aplikasi'),
                value: themeMode.value == ThemeMode.dark,
                onChanged: (v) async {
                  themeMode.value = v ? ThemeMode.dark : ThemeMode.light;
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isDark', v);
                },
              ),
              const SizedBox(height: 16),
              Text('Pilihan Warna Utama', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 16,
                children: [
                  for (final warna in pilihanWarna)
                    GestureDetector(
                      onTap: () async {
                        seedColor.value = warna;
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.setInt('seedColor', warna.value);
                      },
                      child: CircleAvatar(
                          backgroundColor: warna,
                          child: seedColor.value == warna ? const Icon(Icons.check, color: Colors.white) : null
                      ),
                    ),
                ],
              )
            ],
          );
        }
    );
  }
}
