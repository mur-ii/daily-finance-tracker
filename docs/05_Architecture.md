# Arsitektur

## 1. Struktur Folder (Feature-First)
```
lib/
├── main.dart                 # Entry point: buka DB, siapkan pengingat, ProviderScope
├── app/
│   ├── app.dart              # MaterialApp.router + tema
│   ├── router.dart           # Satu-satunya definisi route (GoRouter) + redirect
│   └── routes.dart           # Konstanta path
├── core/                     # Dipakai lintas fitur, tidak bergantung pada fitur
│   ├── database/             # openAppDatabase(), appDatabaseProvider
│   ├── notifications/        # ReminderService (flutter_local_notifications)
│   ├── theme/                # Token warna, dimensi, tema Material
│   ├── utils/                # date_utils, money, validators
│   └── widgets/              # Komponen UI neo-brutalism reusable
└── features/
    ├── daily_tracking/       # Inti: entity, kalkulasi, repository, home
    │   ├── domain/           # Entity, interface repository, kalkulator murni
    │   ├── data/             # Implementasi sqflite, mapper, prefs no-spend
    │   └── presentation/     # Providers Riverpod, HomeScreen, sheet transaksi
    ├── budget_period/        # Setup, periode baru, riwayat & detail
    ├── onboarding/           # Splash, onboarding, prefs onboarding
    ├── settings/             # Pengaturan pengingat, hapus semua data
    └── about/                # Tentang aplikasi
```

## 2. Layer
| Layer | Isi | Aturan |
| --- | --- | --- |
| **domain** | `entities.dart`, `repositories.dart` (interface), `BudgetCalculator`, `StreakCalculator`, `transaction_rules.dart` | Dart murni: tanpa Flutter, tanpa sqflite. Mudah diuji. |
| **data** | `Sqflite*Repository`, `mappers.dart`, `*_prefs.dart` | Implementasi interface domain; satu-satunya tempat SQL & SharedPreferences. |
| **presentation** | Screen, widget, `providers.dart` | Membaca data hanya lewat provider; tidak memanggil DB langsung. |

Fitur `budget_period` memakai entity, repository, dan provider dari
`daily_tracking` (keduanya berbagi model data yang sama).

## 3. Dependency Injection (Riverpod)
- `appDatabaseProvider` dan `reminderServiceProvider` di-*override* di
  `main.dart` dengan instance nyata; di test diganti database in-memory
  (`sqflite_common_ffi`) atau fake.
- Repository provider (`budgetPeriodRepositoryProvider`, dst.) membungkus
  implementasi sqflite di belakang interface domain.
- `todayProvider` menyediakan "hari ini" sehingga test bisa memalsukan tanggal.

### Provider utama ([`providers.dart`](../lib/features/daily_tracking/presentation/providers.dart))
| Provider | Jenis | Isi |
| --- | --- | --- |
| `activePeriodProvider` | AsyncNotifier | Periode aktif; aksi `startNew`, `deleteArchived`, `resetAll` |
| `fixedExpensesProvider` | AsyncNotifier | Tagihan periode aktif; CRUD |
| `transactionsProvider` | AsyncNotifier | Transaksi periode aktif; CRUD |
| `noSpendDaysProvider` | AsyncNotifier | Hari "Tidak jajan" |
| `streakProvider` | FutureProvider | Streak pencatatan |
| `dashboardProvider` | FutureProvider | Periode + `BudgetSummary` + transaksi untuk home |
| `periodHistoryProvider` | FutureProvider.autoDispose | Semua periode + ringkasan |
| `periodDetailProvider` | FutureProvider.autoDispose.family | Detail satu periode |

Mutasi dilakukan lewat method notifier, lalu notifier meng-*invalidate* dirinya
sehingga provider turunan (dashboard) menghitung ulang otomatis.

## 4. Routing & Redirect
Definisi di [`router.dart`](../lib/app/router.dart).

```
/splash ──(sudah onboarding?)──► /           (redirect ke /setup jika belum ada periode)
        └───────(belum)────────► /onboarding ──► /setup
```
- `/splash` dan `/onboarding` mengatur navigasinya sendiri (tidak kena redirect).
- Route lain: jika `activePeriodProvider` sudah termuat dan bernilai `null`,
  diarahkan ke `/setup`.
- Router mendengarkan `activePeriodProvider` (`refreshListenable`), jadi setelah
  setup atau "Hapus semua data" navigasi menyesuaikan otomatis.
- Setiap layar dibungkus `NeoBackground` agar transisi antarhalaman tetap
  berlatar kuning penuh.

## 5. Startup (`main.dart`)
1. `initializeDateFormatting` untuk format tanggal Indonesia.
2. `GoogleFonts.config.allowRuntimeFetching = false` dan daftarkan lisensi OFL.
3. `openAppDatabase()`.
4. Inisialisasi `LocalReminderService` (zona waktu lokal) dan jadwalkan ulang
   pengingat bila aktif. Kegagalan di langkah ini hanya di-log — pengingat
   bukan fitur inti dan tidak boleh menahan aplikasi.
5. `runApp(ProviderScope(overrides: [...], child: App()))`.

## 6. Pengingat Harian
`LocalReminderService.scheduleDaily` membatalkan jadwal lama lalu memakai
`zonedSchedule` dengan `matchDateTimeComponents: time` (berulang tiap hari) dan
`AndroidScheduleMode.inexactAllowWhileIdle` (tidak butuh izin exact alarm).
Izin: `POST_NOTIFICATIONS` (Android 13+) diminta saat user mengaktifkan
pengingat; `RECEIVE_BOOT_COMPLETED` agar jadwal dipulihkan setelah reboot.
