# Design System: Neo-Brutalism

**App:** Daily Finance Tracker

Token desain ada di [`lib/core/theme/`](../lib/core/theme/): `app_colors.dart`,
`app_dimens.dart`, `app_semantic_colors.dart`, `app_theme.dart`. Komponen
reusable ada di [`lib/core/widgets/`](../lib/core/widgets/). Jika dokumen ini
dan kode berbeda, **kode yang benar** — perbarui dokumen ini.

## 1. Core Principles
- **Thick Outlines:** semua elemen utama (Card, Button, Input) memiliki garis
  tepi hitam tebal.
- **Hard Shadows:** tidak ada bayangan blur. Bayangan solid hitam dengan offset
  ke kanan-bawah.
- **High Contrast:** latar kuning terang dengan elemen putih bergaris hitam.

## 2. Color Palette (`AppColors`)
| Token | Warna | Penggunaan |
| --- | --- | --- |
| `ink` | `#000000` | Border, hard shadow, teks utama |
| `surface` | `#FFFFFF` | Latar card, form, daftar transaksi |
| `background` / `yellow` | `#FFDE00` | Latar utama aplikasi; state aktif |
| `blue` | `#1D4ED8` | Warna `secondary` pada tema Material |
| `green` (`success`) | `#22C55E` | Dalam anggaran (`withinBudgetColor`) |
| `red` (`danger`) | `#EF4444` | Overbudget (`overBudgetColor`), aksi berbahaya |
| `textSecondary` | `#3F3F46` | Teks sekunder (tetap gelap demi kontras) |
| `disabled` | `#E4E4E7` | Elemen nonaktif |

## 3. Typography
Font di-bundel di `assets/google_fonts/` (lisensi OFL), tidak diunduh saat runtime.
- **Heading** (angka limit, judul): Space Grotesk Bold.
- **Body & detail:** Inter Medium/SemiBold/Bold. Hindari abu-abu terang.

## 4. Dimensions (`app_dimens.dart`)
| Token | Nilai |
| --- | --- |
| Spacing (`AppSpacing`) | xs 4 · sm 8 · md 16 · lg 24 · xl 32 (skala 8pt) |
| Radius (`AppRadius.sm`) | 4px — kaku, maksimal 4px |
| Border (`AppNeo.borderWidth`) | 2px; saat fokus 3px |
| Shadow (`AppNeo.shadowOffset`) | Offset (4, 4), blur 0, warna `ink` |

## 5. UI Components
### A. Cards & Containers (`NeoBox`)
Border 2px hitam, radius 4px, hard shadow 4×4. Pembatas internal: garis hitam 1–2px.

### B. Buttons (`PrimaryButton`, `NeoButton`, FAB)
- Background putih atau hitam (untuk tombol utama).
- Border & shadow sama dengan card.
- **Ditekan:** shadow hilang dan tombol turun sejauh `shadowOffset`.

### C. Input Fields
Kotak putih, border hitam 2px; saat fokus border 3px.

### D. Komponen Lain
| Widget | Fungsi |
| --- | --- |
| `HeroDailyLimitCard` | Kartu utama "Limit Jajan Hari Ini" + status warna |
| `StatusBanner` | Banner status (overbudget, periode berakhir) |
| `TransactionListTile` | Baris transaksi dengan ikon kategori |
| `DangerConfirmDialog` | Konfirmasi aksi destruktif (hapus data) |
| `AppDatePicker` | Pemilih tanggal (`CalendarDatePicker` bawaan Flutter) bergaya neo |
| `NeoBackground` | Latar kuning pembungkus setiap layar; menjaga konten di atas navigation bar |
| `SectionHeader`, `DetailRow` | Judul seksi & baris label–nilai |
