<div align="center">
  <img src="assets/images/logo_app.png" alt="Logo Daily Finance Tracker" width="112">

  <h1>Daily Finance Tracker</h1>

  <p><strong>Tahu berapa yang aman dibelanjakan hari ini, sampai gajian berikutnya.</strong></p>

  <p>
    <a href="https://github.com/mur-ii/daily-finance-tracker/releases/latest"><img src="https://img.shields.io/github/v/release/mur-ii/daily-finance-tracker?label=rilis" alt="Rilis terbaru"></a>
    <img src="https://img.shields.io/badge/platform-Android%207.0%2B-3DDC84?logo=android&logoColor=white" alt="Android 7.0+">
    <img src="https://img.shields.io/badge/Flutter-Dart%203-02569B?logo=flutter&logoColor=white" alt="Flutter">
    <img src="https://img.shields.io/badge/data-100%25%20lokal-000000" alt="Data 100% lokal">
    <img src="https://img.shields.io/badge/lisensi-proprietary-lightgrey" alt="Lisensi proprietary">
  </p>
</div>

Aplikasi Android untuk mengatur uang harian tanpa akun dan tanpa internet.
Masukkan saldo, tagihan wajib, dan jumlah hari sampai gajian; aplikasi menghitung
limit belanja hari ini dan menyesuaikannya setiap kali Anda mencatat pengeluaran.

## Fitur
- **Limit jajan hari ini** dengan rollover: sisa hari ini menambah jatah besok,
  kelebihan belanja mengurangi jatah besok.
- **Pengeluaran wajib** seperti kos, listrik, dan internet dipotong di awal periode.
- **Catat pengeluaran** per kategori: Makan, Transport, Belanja, dan Lainnya.
- **Status limit**: tag "Hampir habis" saat 80% dana hari ini terpakai, tag
  "Overbudget" dan angka merah saat limit minus, disertai proyeksi limit besok.
- **Streak pencatatan** dan tombol "Tidak jajan".
- **Periode baru** saat gajian, dengan opsi menyalin pengeluaran wajib.
- **Riwayat periode** gajian beserta ringkasannya.
- **Pengingat harian** lewat notifikasi lokal, dengan jam yang bisa diatur.

## Cara Menghitung Limit
Contoh: saldo Rp3.100.000, tagihan Rp1.000.000, periode 30 hari.

| Langkah | Perhitungan | Hasil |
| --- | --- | ---: |
| Sisa dana bersih | 3.100.000 − 1.000.000 | Rp2.100.000 |
| Jatah per hari | 2.100.000 ÷ 30 | Rp70.000 |
| Akumulasi jatah di hari ke-3 | 70.000 × 3 | Rp210.000 |
| Limit hari ini, setelah belanja Rp150.000 | 210.000 − 150.000 | **Rp60.000** |

Aturan lengkapnya ada di [Calculation Logic](docs/03_Calculation_Logic.md).

## Unduh
- Website resmi: https://sadri.my.id
- Langsung: [daily-finance-tracker.apk](https://github.com/mur-ii/daily-finance-tracker/releases/latest/download/daily-finance-tracker.apk)
  (Android 7.0+, perangkat ARM). SHA-256 setiap versi tercantum di halaman
  [Releases](https://github.com/mur-ii/daily-finance-tracker/releases).

Unduh hanya dari dua sumber di atas. APK dari tempat lain tidak ditandatangani
oleh pengembang dan tidak bisa meng-update versi resmi.

Saat memasang pertama kali, Android akan meminta izin memasang aplikasi dari
browser atau pengelola file yang dipakai. Untuk update, pasang APK versi baru di
atas versi lama; data tetap ada.

## Privasi
- Semua data tersimpan **hanya di perangkat** (SQLite). Tidak ada akun, analitik,
  iklan, atau server.
- Aplikasi tidak meminta izin internet. Izin yang dipakai hanya notifikasi dan
  getar (pengingat harian) serta boot (memulihkan jadwal pengingat setelah HP
  restart). Tautan di halaman Tentang Aplikasi dibuka di browser perangkat.
- Data tidak ikut Auto Backup Android, sehingga tidak bisa dipulihkan saat ganti
  perangkat atau memasang ulang aplikasi.
- Menghapus aplikasi atau "Hapus semua data" di Pengaturan menghapus seluruh data.

## Tech Stack
| Kebutuhan | Teknologi |
| --- | --- |
| Framework | Flutter (Android) |
| State management | Riverpod 3 |
| Routing | GoRouter |
| Penyimpanan | sqflite, shared_preferences |
| Notifikasi | flutter_local_notifications |
| Antarmuka | Material 3 dengan gaya Neo-Brutalism |
| Pengujian | flutter_test, sqflite_common_ffi |

## Menjalankan Proyek
Butuh Flutter 3.47 (stable) dengan Dart `^3.13.7` dan Android SDK.

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
| [CONTRIBUTING](CONTRIBUTING.md) | Cara melaporkan bug, mengusulkan fitur, dan berdiskusi |
| [SECURITY](SECURITY.md) | Cara melaporkan celah keamanan |

## Masukan
Pull request dari luar tidak diterima, tetapi bug dan usulan fitur bisa disampaikan
lewat [issue](https://github.com/mur-ii/daily-finance-tracker/issues/new/choose),
dan ide pengembangan lewat
[Discussions](https://github.com/mur-ii/daily-finance-tracker/discussions).

## Lisensi
Aplikasi ini gratis dipakai untuk mengatur keuangan pribadi. Repository ini publik
untuk distribusi APK lewat GitHub Releases dan sebagai portfolio, tetapi kodenya
**bukan open source**. Lihat [LICENSE](LICENSE).

Komponen pihak ketiga mengikuti lisensinya masing-masing, termasuk font Inter dan
Space Grotesk yang memakai SIL Open Font License 1.1
([`assets/google_fonts/`](assets/google_fonts/)).

## Pengembang
**Muhammad Sadri** · [sadri.my.id](https://sadri.my.id) · [GitHub](https://github.com/mur-ii)
