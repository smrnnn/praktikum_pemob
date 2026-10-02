import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarangBelanja {
  String nama;
  int jumlah;
  String kategori;
  bool sudahDibeli;

  BarangBelanja({
    required this.nama,
    required this.jumlah,
    required this.kategori,
    this.sudahDibeli = false,
  });
}

class BelanjaModel extends ChangeNotifier {
  final List<BarangBelanja> _items = [];

  List<BarangBelanja> get items => List.unmodifiable(_items);
  int get jumlahBelumDibeli => _items.where((b) => !b.sudahDibeli).length;

  void tambahBarang(String nama, int jumlah, String kategori) {
    _items.add(BarangBelanja(nama: nama, jumlah: jumlah, kategori: kategori));
    notifyListeners();
  }

  void toggleStatus(int index) {
    _items[index].sudahDibeli = !_items[index].sudahDibeli;
    notifyListeners();
  }

  void hapusBarang(int index) {
    _items.removeAt(index);
    notifyListeners();
  }
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => BelanjaModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Daftar Belanja',
      theme: ThemeData(colorSchemeSeed: Colors.green, useMaterial3: true),
      home: const DaftarBelanjaPage(),
    );
  }
}

class DaftarBelanjaPage extends StatelessWidget {
  const DaftarBelanjaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<BelanjaModel>();

    return Scaffold(
      appBar: AppBar(
        title: Text('Belanjaan Belum Dibeli: ${model.jumlahBelumDibeli}'),
        backgroundColor: Colors.green.shade100,
      ),
      body: model.items.isEmpty
          ? const Center(
        child: Text(
          'Keranjang belanja masih kosong',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      )
          : ListView.builder(
        itemCount: model.items.length,
        itemBuilder: (context, index) {
          final barang = model.items[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              leading: Checkbox(
                value: barang.sudahDibeli,
                onChanged: (_) => context.read<BelanjaModel>().toggleStatus(index),
              ),
              title: Text(
                barang.nama,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  decoration: barang.sudahDibeli ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text('Jumlah: ${barang.jumlah} | Kategori: ${barang.kategori}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => context.read<BelanjaModel>().hapusBarang(index),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FormTambahBelanjaPage()),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class FormTambahBelanjaPage extends StatefulWidget {
  const FormTambahBelanjaPage({super.key});

  @override
  State<FormTambahBelanjaPage> createState() => _FormTambahBelanjaPageState();
}

class _FormTambahBelanjaPageState extends State<FormTambahBelanjaPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _jumlahController = TextEditingController();
  String? _kategoriTerpilih;

  @override
  void dispose() {
    _namaController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  void _simpanBarang() {
    if (_formKey.currentState!.validate()) {
      final nama = _namaController.text.trim();
      final jumlah = int.parse(_jumlahController.text.trim());
      final kategori = _kategoriTerpilih!;

      context.read<BelanjaModel>().tambahBarang(nama, jumlah, kategori);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$nama berhasil ditambahkan ke daftar!')),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Barang Belanja')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _namaController,
              decoration: const InputDecoration(
                labelText: 'Nama Barang',
                border: OutlineInputBorder(),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama barang wajib diisi' : null,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _jumlahController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Jumlah',
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Jumlah wajib diisi';
                final angka = int.tryParse(v);
                if (angka == null || angka <= 0) return 'Jumlah harus berupa angka lebih dari 0';
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: 'Kategori',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'Makanan', child: Text('Makanan')),
                DropdownMenuItem(value: 'Minuman', child: Text('Minuman')),
                DropdownMenuItem(value: 'Kebutuhan Rumah', child: Text('Kebutuhan Rumah')),
                DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
              ],
              onChanged: (value) => setState(() => _kategoriTerpilih = value),
              validator: (v) => v == null ? 'Silakan pilih kategori barang' : null,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _simpanBarang,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              child: const Text('Simpan ke Daftar'),
            ),
          ],
        ),
      ),
    );
  }
}
