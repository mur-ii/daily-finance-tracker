# Daily Finance Tracker

Pencatat keuangan harian dengan limit belanja per hari. Data tersimpan lokal
di perangkat (SQLite), tanpa akun dan tanpa internet.

> Kode ditampilkan untuk portfolio, **bukan open source** — lihat [LICENSE](LICENSE).

- Application ID: `my.id.sadri.dailytracking`
- Versi: lihat `version` di [pubspec.yaml](pubspec.yaml) dan [CHANGELOG.md](CHANGELOG.md)

## Unduh
- Website resmi: https://sadri.my.id
- Langsung: [daily-finance-tracker.apk](https://github.com/mur-ii/daily-finance-tracker/releases/latest/download/daily-finance-tracker.apk)
  (Android 7.0+). SHA-256 setiap versi tercantum di halaman
  [Releases](https://github.com/mur-ii/daily-finance-tracker/releases).

Unduh hanya dari dua sumber di atas. APK dari tempat lain tidak ditandatangani
oleh pengembang dan tidak bisa meng-update versi resmi.

## Privasi
- Semua data tersimpan **hanya di perangkat** (SQLite). Tidak ada akun,
  analitik, iklan, atau server.
- Aplikasi tidak meminta izin internet. Izin yang dipakai hanya notifikasi
  & getar (pengingat harian) dan boot (memulihkan jadwal pengingat setelah HP
  restart).
- Data dapat ikut tercadang otomatis oleh Android (backup Google milik
  pengguna) sehingga bisa dipulihkan saat ganti perangkat.
- Menghapus aplikasi atau "Hapus semua data" di Pengaturan menghapus seluruh data.

## Fitur
- **Limit jajan hari ini** dengan rollover — sisa hari ini menambah jatah besok,
  kelebihan belanja mengurangi jatah besok.
- **Pengeluaran wajib** (kos, listrik, internet) dipotong di awal periode.
- **Catat pengeluaran** per kategori (Makan, Transport, Belanja, Lainnya).
- **Status overbudget** berwarna merah dan proyeksi limit besok.
- **Streak pencatatan** + tombol "Tidak jajan".
- **Riwayat periode** gajian beserta ringkasannya.
- **Pengingat harian** lewat notifikasi lokal.
- **Offline penuh**: tanpa akun, tanpa izin internet.

## Tech Stack
Flutter · Riverpod 3 · GoRouter · sqflite · shared_preferences ·
flutter_local_notifications · Material 3 (gaya Neo-Brutalism)

## Mulai Cepat
```
flutter pub get
flutter analyze
flutter test
flutter run
```

## Struktur Proyek
```
lib/
├── app/         # App, router, daftar route
├── core/        # database, notifikasi, tema, utils, widget reusable
└── features/    # daily_tracking, budget_period, onboarding, settings, about
test/            # unit & widget test (mengikuti struktur lib/)
docs/            # dokumentasi produk & teknis
assets/          # gambar, font yang di-bundel
```

## Dokumentasi
| Dokumen | Isi |
| --- | --- |
| [01 — PRD](docs/01_Product_Requirements_Document.md) | Tujuan produk, alur pengguna, daftar fitur |
| [02 — Database Schema](docs/02_Database_Schema.md) | Tabel SQLite, constraint, SharedPreferences |
| [03 — Calculation Logic](docs/03_Calculation_Logic.md) | Rumus limit harian, rollover, streak |
| [04 — Design System](docs/04_design.md) | Token warna, tipografi, komponen Neo-Brutalism |
| [05 — Architecture](docs/05_Architecture.md) | Layer, provider Riverpod, routing, startup |
| [06 — Development Guide](docs/06_Development_Guide.md) | Setup, testing, konvensi, migrasi DB |
| [07 — Release Guide](docs/07_Release_Guide.md) | Keystore, versi, build & publikasi APK |
| [08 — Git Workflow](docs/08_Git_Workflow.md) | Alur branch, pull request, commit, rilis |
| [CHANGELOG](CHANGELOG.md) | Riwayat versi |
| [SECURITY](SECURITY.md) | Cara melaporkan celah keamanan |

## Catatan
- Font Inter & Space Grotesk di-bundel di `assets/google_fonts/` (lisensi OFL),
  runtime fetching dimatikan di `lib/main.dart`.
- `android/key.properties` dan keystore **tidak** disimpan di repository.
