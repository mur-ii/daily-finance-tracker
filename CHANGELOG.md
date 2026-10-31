# Changelog

Format mengikuti [Keep a Changelog](https://keepachangelog.com/id-ID/1.1.0/);
versi mengikuti `version` di `pubspec.yaml`.

## [Belum dirilis]

## [1.0.1+2] — Sabtu, 31 Oktober 2026

### Diubah
- Halaman Tentang Pengembang menjadi Tentang Aplikasi, dengan versi, fitur,
  privasi, lisensi, dan profil singkat pengembang.
- Data tidak lagi ikut Auto Backup Android, sehingga hanya tersimpan di perangkat.
  Data tidak ikut pulih saat ganti perangkat atau memasang ulang aplikasi.
- APK tidak lagi menyertakan `x86_64`, sehingga ukurannya lebih kecil.
- Pemilih tanggal memakai kalender bawaan Flutter dengan tampilan yang sama.

### Diperbaiki
- Tanggal tampil dalam format Indonesia, mis. 31 Oktober 2026.
- Konten semua halaman tidak lagi tertimpa navigation bar Android.
- Border progress bar limit harian kini terlihat.
- Tombol kembali di Pengeluaran wajib tidak lagi menutup aplikasi, dan meminta
  konfirmasi jika ada perubahan. Perubahan baru tersimpan saat menekan Selesai.

## [1.0.0+1] — Jumat, 30 Oktober 2026

### Ditambahkan
- Setup periode anggaran: saldo awal, tanggal mulai, jumlah hari.
- Pengeluaran wajib per periode (tambah, ubah, hapus).
- Pencatatan transaksi harian dengan kategori dan catatan.
- Limit jajan hari ini dengan rollover, proyeksi limit besok, status overbudget.
- Streak pencatatan dan penanda "Tidak jajan".
- Mulai periode baru dengan opsi menyalin pengeluaran wajib.
- Riwayat periode dan detail read-only; hapus periode arsip.
- Pengingat harian (notifikasi lokal) dengan jam yang bisa diatur.
- Hapus semua data.
- Splash, onboarding, dan halaman Tentang Pengembang.
- Tema Neo-Brutalism dengan font Inter & Space Grotesk yang di-bundel.
