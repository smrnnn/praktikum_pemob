
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Pengaturan global sederhana.
// Nilainya disimpan dengan SharedPreferences
// agar tetap ada setelah aplikasi ditutup.
final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);

final seedColor = ValueNotifier<Color>(Colors.teal);

final targetHarian = ValueNotifier<int>(20000);

// Pilihan warna tema aplikasi.
const pilihanWarna = [
  Colors.teal,
  Colors.indigo,
  Colors.deepOrange,
  Colors.pink,
];

// Memuat pengaturan yang tersimpan.
Future<void> muatPengaturan() async {
  final prefs = await SharedPreferences.getInstance();

  // Memuat pengaturan tema gelap.
  final gelap = prefs.getBool('gelap') ?? false;

  // Memuat pilihan warna.
  final warna = (prefs.getInt('warna') ?? 0)
      .clamp(0, pilihanWarna.length - 1)
      .toInt();

  // Membaca target harian.
  // Mendukung data lama bertipe int maupun double.
  final target = prefs.get('target');

  final int nilaiTarget;

  if (target is int) {
    nilaiTarget = target;
  } else if (target is double) {
    nilaiTarget = target.toInt();
  } else {
    nilaiTarget = 20000;
  }

  // Memperbarui pengaturan aplikasi.
  themeMode.value = gelap ? ThemeMode.dark : ThemeMode.light;
  seedColor.value = pilihanWarna[warna];
  targetHarian.value = nilaiTarget;

  // Menyimpan ulang target sebagai int agar konsisten.
  await prefs.setInt('target', nilaiTarget);
}

// Menyimpan pengaturan tema gelap.
Future<void> simpanGelap(bool nilai) async {
  themeMode.value = nilai ? ThemeMode.dark : ThemeMode.light;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('gelap', nilai);
}

// Menyimpan pilihan warna tema.
Future<void> simpanWarna(int index) async {
  if (index < 0 || index >= pilihanWarna.length) {
    return;
  }

  seedColor.value = pilihanWarna[index];

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('warna', index);
}

// Menyimpan target harian.
Future<void> simpanTarget(int nilai) async {
  targetHarian.value = nilai;

  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt('target', nilai);
}