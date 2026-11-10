# Morse

Aplikasi penerjemah kode Morse berbasis Flutter yang berjalan 100% offline. Dibangun dengan Clean Architecture, state management Provider, dan pendekatan TDD.

## Fitur

- Splash screen animasi lampu sinyal dan onboarding 3 langkah (hanya muncul sekali)
- Terjemah dua arah: teks ke Morse dan Morse ke teks, langsung saat mengetik
- Putar sinyal sebagai suara (WAV dibuat di perangkat), lampu sinyal di layar, dan getaran
- Pengaturan kecepatan 5 sampai 40 WPM (standar PARIS) dan pilihan output, tersimpan lokal
- Mode Ketuk: tekan singkat untuk titik, tahan untuk garis, huruf tersimpan otomatis setelah jeda
- Tabel abjad Morse (huruf, angka, simbol) dengan pemutaran per karakter
- Riwayat tersimpan lokal dengan pencarian, filter, favorit, dan geser untuk hapus

## Menjalankan

```bash
flutter pub get
flutter test
flutter run
```

Font Inter, Space Grotesk, dan JetBrains Mono sudah dibundel di `assets/fonts` (lisensi OFL disertakan), jadi tidak ada unduhan font saat runtime.

## Struktur

```
lib/
  app/                     MaterialApp, routes, HomeShell dengan bottom tab
  core/
    error/                 Exception dan Failure
    morse/                 Tabel alfabet dan MorseCodec (encode, decode, normalize)
    theme/                 Warna, tipografi, ThemeData
    usecase/               Kontrak UseCase dan NoParams
    widgets/               Komponen UI bersama
  features/
    onboarding/            Status onboarding, splash, halaman onboarding
    translator/            Use case Translate dan TranslatorProvider
    playback/              Timeline sinyal, WAV encoder, audio, getar, pengaturan output
    tap_keyer/             Klasifikasi tekanan dan TapProvider
    reference/             Data abjad dan ReferenceProvider
    history/               Model, local data source, repository, use case, HistoryProvider
  injection_container.dart Wiring dependency ke MultiProvider
  main.dart
test/                      Unit test domain, data, provider, dan widget test alur aplikasi
```

Setiap fitur mengikuti pembagian `domain` (entity, repository abstrak, use case), `data` (data source, model, implementasi repository), dan `presentation` (provider, page, widget). Data persisten disimpan lewat `shared_preferences`.
