# Product Requirements Document (PRD): Daily Finance Tracker

## 1. Konteks Aplikasi
Aplikasi *mobile offline-first* (Flutter, Android) untuk melacak anggaran jajan
harian. Menggunakan sistem "Top-Down Budgeting" dengan fitur "Rollover": sisa
uang harian yang tidak terpakai digulung ke hari berikutnya, dan kelebihan
belanja mengurangi jatah hari berikutnya.

Prinsip produk:
- **Tanpa akun, tanpa internet.** Semua data tersimpan lokal (SQLite +
  SharedPreferences). Build release tidak meminta izin `INTERNET`.
- **Satu angka utama.** Layar utama selalu menjawab "berapa yang boleh saya
  pakai hari ini?".
- **Nominal Rupiah bulat.** Tidak ada desimal; disimpan sebagai `int`.

## 2. Alur Pengguna (User Flow)
1. **Splash** (`/splash`) — cek apakah onboarding sudah pernah dilihat.
2. **Onboarding** (`/onboarding`) — hanya pada pembukaan pertama; bisa dilewati.
3. **Setup Awal** (`/setup`) — user memasukkan Saldo Awal (gaji), tanggal mulai,
   dan jumlah hari menuju gajian berikutnya (1–366 hari). Selama belum ada
   periode aktif, semua route diarahkan ke sini.
4. **Pengeluaran Wajib** — user mendaftar tagihan wajib (Kos, Listrik,
   Internet). Total tagihan dipotong dari Saldo Awal menjadi Sisa Dana Bersih.
   Bisa ditambah/diubah/dihapus kapan saja dari menu home.
5. **Daily Tracking / Home** (`/`) — menampilkan "Limit Jajan Hari Ini",
   proyeksi limit besok, streak, dan daftar transaksi. Tombol "+" membuka sheet
   pencatatan pengeluaran (nominal, kategori, tanggal, catatan).
6. **Auto-Calculation** — setiap perubahan transaksi/tagihan langsung
   menghitung ulang limit hari ini dan hari-hari berikutnya.
7. **Tidak Jajan** — bila hari ini tidak ada pengeluaran, user bisa menandai
   "Tidak jajan" agar streak pencatatan tetap berlanjut.
8. **Periode Baru** (`/new-period`) — saat gajian berikutnya, user memulai
   periode baru. Periode lama diarsipkan; tagihan wajib bisa disalin.
9. **Riwayat Periode** (`/history`, `/history/:id`) — daftar semua periode
   beserta ringkasan; detail bersifat read-only. Periode arsip bisa dihapus.
10. **Pengaturan** (`/settings`) — pengingat harian (on/off, jam; default
    20:00) dan "Hapus semua data".
11. **Tentang Pengembang** (`/about`) — profil dan tautan pengembang.

## 3. Daftar Fitur
| Fitur | Keterangan |
| --- | --- |
| Periode anggaran | Satu periode aktif; periode lama menjadi arsip |
| Pengeluaran wajib | CRUD; opsional disalin ke periode baru |
| Transaksi harian | CRUD; kategori Makan, Transport, Belanja, Lainnya; tanggal harus di dalam periode |
| Limit harian + rollover | Lihat [03_Calculation_Logic.md](03_Calculation_Logic.md) |
| Status overbudget | Limit < 0 ditampilkan merah |
| Streak pencatatan | Hari berturut-turut ada transaksi atau ditandai "Tidak jajan" |
| Pengingat harian | Notifikasi lokal terjadwal (inexact), tetap aktif setelah reboot |
| Riwayat periode | Ringkasan & detail read-only, hapus arsip |
| Reset data | Menghapus semua periode, tagihan, transaksi, dan hari tidak jajan |

## 4. Di Luar Cakupan (v1)
- Sinkronisasi cloud, multi-perangkat, akun.
- Pemasukan tambahan di tengah periode.
- Ekspor/impor data.
- iOS dan desktop (proyek hanya menyiapkan Android).

## 5. Tech Stack
- **Framework:** Flutter (Dart SDK ^3.13)
- **State Management:** Riverpod 3 (Feature-First Architecture)
- **Local Storage:** sqflite (data utama), shared_preferences (preferensi)
- **Routing:** GoRouter
- **Notifikasi:** flutter_local_notifications + timezone
- **UI:** Material 3, gaya Neo-Brutalism (lihat [04_design.md](04_design.md))
