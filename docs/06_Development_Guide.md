# Panduan Pengembangan

## 1. Prasyarat
- Flutter 3.47 (stable) dengan Dart `^3.13.7` (lihat `environment` di `pubspec.yaml`).
- Android Studio (Android SDK + JDK bawaan `jbr`) untuk build Android.
- Perangkat/emulator Android.

## 2. Menjalankan Proyek
```
flutter pub get
flutter analyze
flutter test
flutter run
```
Konfigurasi VS Code (debug/profile/release) ada di `.vscode/launch.json`.

## 3. Testing
| Folder | Cakupan |
| --- | --- |
| `test/features/daily_tracking/domain/` | `BudgetCalculator`, `StreakCalculator` (unit, murni) |
| `test/features/daily_tracking/data/` | Repository sqflite memakai DB in-memory `sqflite_common_ffi` |
| `test/features/daily_tracking/presentation/` | Providers, HomeScreen, alur transaksi (widget test) |
| `test/features/budget_period/`, `onboarding/`, `settings/`, `about/` | Widget test layar |
| `test/core/` | Format tanggal, validators & widget reusable |
| `test/support/fake_repositories.dart` | Fake repository untuk widget test |
| `test/flutter_test_config.dart` | Konfigurasi global yang berlaku untuk semua test |

Pola: override `appDatabaseProvider`/repository provider dan `todayProvider`
di `ProviderScope` test; `reminderServiceProvider` diganti fake. Test memakai
fake buatan sendiri, tanpa library mocking.

## 4. Konvensi Kode
- Lint: `flutter_lints` (`analysis_options.yaml`). `flutter analyze` harus bersih.
- Komentar & teks UI dalam bahasa Indonesia; identifier dalam bahasa Inggris.
- Uang selalu `int` Rupiah; format tampilan lewat `formatRupiah`, parsing input
  lewat `parseRupiah` ([`money.dart`](../lib/core/utils/money.dart)).
- Bandingkan tanggal dengan `dateOnly`/`daysBetween`, jangan `DateTime` mentah.
- Tampilkan tanggal lewat `formatDate`/`formatDayMonth`/`formatFullDate`
  ([`date_utils.dart`](../lib/core/utils/date_utils.dart)).
- Logika bisnis baru masuk `domain/` sebagai fungsi murni + unit test.
- Warna & ukuran hanya dari token `AppColors`/`AppSpacing`/`AppNeo`.

## 5. Menambah Layar / Route
1. Tambah konstanta path di [`routes.dart`](../lib/app/routes.dart).
2. Daftarkan `GoRoute` di [`router.dart`](../lib/app/router.dart), bungkus
   dengan `NeoBackground` (latar dan jarak aman navigation bar).
3. Navigasi memakai `context.go(...)`/`context.push(...)` dengan konstanta path.

## 6. Menambah Fitur
Buat folder `lib/features/<fitur>/{domain,data,presentation}` sesuai kebutuhan.
Interface repository di `domain/`, implementasi di `data/`, provider yang
mengekspos repository di `presentation/`.

## Migrasi Database
1. Naikkan `_schemaVersion` di [`app_database.dart`](../lib/core/database/app_database.dart).
2. Tambahkan `onUpgrade: (db, oldVersion, newVersion)` di `OpenDatabaseOptions`
   yang menjalankan perubahan per versi (`if (oldVersion < 2) {...}`).
3. Perbarui `_onCreate` agar instalasi baru langsung memakai skema terbaru.
4. Tambah test upgrade di `sqflite_repositories_test.dart` dan perbarui
   [02_Database_Schema.md](02_Database_Schema.md).

## 7. Aset
- Ikon launcher: `dart run flutter_launcher_icons` (sumber `assets/images/logo_app.png`).
- Ikon notifikasi: `android/app/src/main/res/drawable/ic_notification.xml`.
- Font: tambah file `Family-Weight.ttf` di `assets/google_fonts/` agar dikenali
  `google_fonts` tanpa internet.

## 8. Alur Git
- `main` untuk rilis, `dev` untuk integrasi. Kerjakan fitur di branch
  `feat/<nama>` atau `fix/<nama>` dari `dev` (detail di
  [Alur Kerja Git](08_Git_Workflow.md)).
- Sebelum commit: `flutter analyze` dan `flutter test` lulus.
- Catat perubahan yang terlihat user di [`CHANGELOG.md`](../CHANGELOG.md).
- **Jangan pernah commit** `android/key.properties`, file `.jks`/`.keystore`,
  atau APK hasil build.
