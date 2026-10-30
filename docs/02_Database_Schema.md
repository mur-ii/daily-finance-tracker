# Database Schema & Data Models

Sumber kebenaran: [`lib/core/database/app_database.dart`](../lib/core/database/app_database.dart)
(skema) dan [`lib/features/daily_tracking/data/mappers.dart`](../lib/features/daily_tracking/data/mappers.dart)
(konversi entity ↔ row).

- File database: `daily_tracking.db` di folder database bawaan platform.
- Versi skema: `1` (`_schemaVersion`).
- `PRAGMA foreign_keys = ON` diaktifkan di setiap koneksi (`onConfigure`).
- **Uang** disimpan sebagai `INTEGER` Rupiah bulat (bukan `double`).
- **Tanggal** disimpan sebagai `TEXT` berformat `yyyy-MM-dd` tanpa jam,
  sehingga bisa diurutkan dan dibandingkan sebagai string.

## 1. `budget_period` (Periode Anggaran)
Siklus gajian. Entity: `BudgetPeriod`.

| Kolom | Tipe | Constraint | Field Dart |
| --- | --- | --- | --- |
| `id` | INTEGER | PK AUTOINCREMENT | `id` |
| `total_income` | INTEGER | NOT NULL | `totalIncome` |
| `start_date` | TEXT | NOT NULL, `yyyy-MM-dd` | `startDate` |
| `days_count` | INTEGER | NOT NULL, `> 0` | `daysCount` |
| `is_active` | INTEGER | NOT NULL DEFAULT 1 (0/1) | `isActive` |

Index:
- `idx_budget_period_single_active` — UNIQUE partial index
  `(is_active) WHERE is_active = 1`. Database menjamin **hanya ada satu periode
  aktif**.

Field turunan: `endDate = startDate + daysCount - 1` (inklusif).

## 2. `fixed_expense` (Pengeluaran Wajib)
Tagihan yang dipotong di awal sebelum menjadi jatah harian. Entity: `FixedExpense`.

| Kolom | Tipe | Constraint | Field Dart |
| --- | --- | --- | --- |
| `id` | INTEGER | PK AUTOINCREMENT | `id` |
| `period_id` | INTEGER | NOT NULL, FK → `budget_period(id)` ON DELETE CASCADE | `periodId` |
| `name` | TEXT | NOT NULL | `name` |
| `amount` | INTEGER | NOT NULL, `>= 0` | `amount` |

Index: `idx_fixed_expense_period (period_id)`.

## 3. `daily_transaction` (Transaksi Jajan Harian)
Entity: `DailyTransaction`.

| Kolom | Tipe | Constraint | Field Dart |
| --- | --- | --- | --- |
| `id` | INTEGER | PK AUTOINCREMENT | `id` |
| `period_id` | INTEGER | NOT NULL, FK → `budget_period(id)` ON DELETE CASCADE | `periodId` |
| `date` | TEXT | NOT NULL, `yyyy-MM-dd` | `date` |
| `amount` | INTEGER | NOT NULL, `> 0` | `amount` |
| `category` | TEXT | NOT NULL | `category` (`TransactionCategory.name`) |
| `note` | TEXT | NOT NULL DEFAULT `''` | `note` |

Nilai `category`: `food`, `transport`, `shopping`, `other`
(label UI: Makan, Transport, Belanja, Lainnya —
[`category_labels.dart`](../lib/features/daily_tracking/presentation/category_labels.dart)).

Index: `idx_daily_transaction_period_date (period_id, date)`.

## 4. Relasi & Operasi Penting
```
budget_period 1 ──< fixed_expense
              1 ──< daily_transaction
```
- **Mulai periode baru** (`startNew`): dalam satu transaksi SQL, semua periode
  di-set `is_active = 0`, lalu periode baru di-insert dengan `is_active = 1`.
- **Hapus periode** (`delete`): hanya periode arsip (`is_active = 0`); tagihan
  dan transaksinya ikut terhapus lewat CASCADE.
- **Hapus semua** (`deleteAll`): menghapus isi ketiga tabel dalam satu transaksi.

## 5. SharedPreferences
Data kecil non-relasional disimpan di SharedPreferences.

| Key | Tipe | Isi | Sumber |
| --- | --- | --- | --- |
| `has_seen_onboarding` | bool | Onboarding sudah dilihat | `onboarding_prefs.dart` |
| `reminder_enabled` | bool | Pengingat aktif (default `false`) | `reminder_prefs.dart` |
| `reminder_minutes` | int | Jam pengingat dalam menit sejak 00:00 (default 1200 = 20:00) | `reminder_prefs.dart` |
| `no_spend_days` | List\<String\> | Tanggal `yyyy-MM-dd` yang ditandai "Tidak jajan", terbaru dulu, maks. 400 entri | `no_spend_days_prefs.dart` |

## 6. Migrasi Skema
Belum ada migrasi (skema v1). Untuk perubahan skema berikutnya: naikkan
`_schemaVersion`, tambahkan `onUpgrade` yang menjalankan `ALTER TABLE`/tabel
baru per versi, dan perbarui dokumen ini. Lihat
[06_Development_Guide.md](06_Development_Guide.md#migrasi-database).
