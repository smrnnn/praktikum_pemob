
import 'package:flutter/material.dart';

import '../state/pengaturan.dart';
import '../utils/format.dart';

class PengaturanPage extends StatelessWidget {
  const PengaturanPage({super.key});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        themeMode,
        seedColor,
        targetHarian,
      ]),
      builder: (context, _) {
        // Menyesuaikan nilai agar selalu berada dalam batas Slider.
        final targetSlider = targetHarian.value
            .clamp(0, 100000)
            .toDouble();

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'Target tabungan harian',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              rupiah(targetHarian.value),
              style: tema.textTheme.headlineSmall,
            ),
            Slider(
              value: targetSlider,
              min: 0,
              max: 100000,
              divisions: 20,
              label: rupiah(targetSlider.round()),
              onChanged: (v) {
                targetHarian.value = v.round();
              },
              onChangeEnd: (v) {
                simpanTarget(v.round());
              },
            ),
            const Divider(height: 32),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mode gelap'),
              value: themeMode.value == ThemeMode.dark,
              onChanged: simpanGelap,
            ),
            const SizedBox(height: 8),
            Text(
              'Warna tema',
              style: tema.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 12,
              children: [
                for (var i = 0; i < pilihanWarna.length; i++)
                  GestureDetector(
                    onTap: () => simpanWarna(i),
                    child: CircleAvatar(
                      backgroundColor: pilihanWarna[i],
                      child: seedColor.value == pilihanWarna[i]
                          ? const Icon(
                        Icons.check,
                        color: Colors.white,
                      )
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}