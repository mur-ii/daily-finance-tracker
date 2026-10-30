# Alur Kerja Repository

Repository ini privat dan bersifat proprietary (lihat [LICENSE](LICENSE)).
Panduan setup dan konvensi kode ada di
[Development Guide](docs/06_Development_Guide.md).

## Branch
| Branch | Fungsi | Sumber | Tujuan merge |
| --- | --- | --- | --- |
| `main` | Kode rilis, setiap rilis diberi tag `v<versi>` | `develop`, `hotfix/*` | — |
| `develop` | Integrasi pengembangan | `feat/*`, `fix/*`, `chore/*` | `main` |
| `feat/<nama>` | Fitur baru | `develop` | `develop` |
| `fix/<nama>` | Perbaikan bug | `develop` | `develop` |
| `chore/<nama>` | Dokumentasi, dependensi, konfigurasi | `develop` | `develop` |
| `hotfix/<nama>` | Perbaikan mendesak untuk rilis | `main` | `main`, lalu `develop` |

## Pull Request
1. Buat branch dari sumber di atas, satu topik per branch.
2. Pastikan `flutter analyze` dan `flutter test` lulus.
3. Catat perubahan yang terlihat pengguna di [CHANGELOG.md](CHANGELOG.md).
4. Buka PR ke branch tujuan.
5. Merge ke `develop` dengan **squash**. Merge `develop` ke `main` dengan
   **merge commit** agar riwayat kedua branch tetap tersambung.

## Pesan Commit
Bahasa Indonesia, bentuk perintah, baris pertama maksimal 72 karakter.
Contoh: `Tambah pengingat harian`.

## Rilis
Ikuti [Release Guide](docs/07_Release_Guide.md) dari `main` setelah `develop`
di-merge.
