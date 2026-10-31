# Alur Kerja Git

Repository: https://github.com/mur-ii/daily-finance-tracker. Dokumen ini panduan
untuk pengelola; masukan dari luar mengikuti [CONTRIBUTING](../CONTRIBUTING.md).

## 1. Branch
| Branch | Fungsi | Dibuat dari | Merge ke | Cara merge |
| --- | --- | --- | --- | --- |
| `main` | Kode rilis, setiap rilis diberi tag `v<versi>` | — | — | — |
| `dev` | Integrasi pengembangan | `main` | `main` | Merge commit |
| `feat/<nama>` | Fitur baru | `dev` | `dev` | Squash |
| `fix/<nama>` | Perbaikan bug | `dev` | `dev` | Squash |
| `chore/<nama>` | Dokumentasi, dependensi, konfigurasi | `dev` | `dev` | Squash |
| `hotfix/<nama>` | Perbaikan mendesak untuk rilis | `main` | `main`, lalu `dev` | Squash |

`main` dan `dev` diproteksi: perubahan wajib lewat pull request, tanpa force push,
dan branch tidak bisa dihapus. Branch lain terhapus otomatis di GitHub setelah di-merge.

## 2. Mengerjakan Fitur
Mulai dari `dev` terbaru, satu topik per branch:

```
git switch dev
git pull
git switch -c feat/<nama>
```

Sebelum push, jalankan pemeriksaan berikut karena repository ini tidak memakai CI:

```
flutter analyze
flutter test
```

Catat perubahan yang terlihat pengguna di [`CHANGELOG.md`](../CHANGELOG.md), lalu:

```
git add <file>
git commit -m "Tambah pengingat harian"
git push -u origin feat/<nama>
gh pr create --base dev --fill
```

Setelah ditinjau, merge PR dengan **Squash and merge**, lalu bersihkan lokal:

```
git switch dev
git pull
git branch -D feat/<nama>
```

`-D` diperlukan karena squash merge membuat git menganggap branch lokal belum ter-merge.

## 3. Pesan Commit
Bahasa Indonesia, bentuk perintah, baris pertama maksimal 72 karakter.
Contoh: `Tambah pengingat harian`.

Jangan pernah commit `android/key.properties`, file `.jks`/`.keystore`, atau APK.

## 4. Rilis
1. Buka PR dari `dev` ke `main`:
   ```
   gh pr create --base main --head dev --title "Rilis v<versi>" --body "<ringkasan CHANGELOG>"
   ```
2. Merge dengan **Create a merge commit**, bukan squash, agar riwayat kedua branch
   tetap tersambung.
3. Lanjutkan build dan publikasi dari `main` sesuai
   [Panduan Rilis](07_Release_Guide.md).

## 5. Hotfix
Untuk bug pada versi rilis yang tidak bisa menunggu `dev`:

```
git switch main
git pull
git switch -c hotfix/<nama>
```

Buka PR ke `main`, merge, lalu rilis. Setelah itu buka PR dari `main` ke `dev` dengan
merge commit agar perbaikannya ikut masuk ke `dev`.
