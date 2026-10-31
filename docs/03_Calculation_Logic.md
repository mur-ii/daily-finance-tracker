# Core Calculation Logic (Business Rules)

Implementasi: [`budget_calculator.dart`](../lib/features/daily_tracking/domain/budget_calculator.dart),
[`streak_calculator.dart`](../lib/features/daily_tracking/domain/streak_calculator.dart),
[`transaction_rules.dart`](../lib/features/daily_tracking/domain/transaction_rules.dart).
Semua kalkulasi adalah fungsi murni (tanpa Flutter/DB) dan diuji di
`test/features/daily_tracking/domain/`.

Semua nominal berupa `int` Rupiah; pembagian memakai pembagian bulat (`~/`).

## 1. Sisa Dana Bersih
Uang yang benar-benar bisa dibagi untuk jatah harian.

`netFunds = BudgetPeriod.totalIncome - SUM(FixedExpense.amount)`

## 2. Jatah Harian Basis
Nominal flat harian jika tidak ada rollover.

`dailyBase = netFunds ~/ BudgetPeriod.daysCount`

Sisa pembagian bulat **tidak hilang**: dimasukkan ke hari terakhir periode
(lihat `allowanceFor` di bawah).

## 3. Hari Ke-X
```
rawDay    = daysBetween(startDate, today) + 1
dayNumber = clamp(rawDay, 1, daysCount)
isPeriodEnded = rawDay > daysCount
```
`daysBetween` menghitung selisih hari kalender lewat UTC agar tidak terpengaruh
DST ([`date_utils.dart`](../lib/core/utils/date_utils.dart)).

## 4. Rollover Logic (Limit Jajan Hari Ini)
1. **Akumulasi jatah** sampai hari ke-X:
   ```
   allowanceFor(day) = day == daysCount ? netFunds : dailyBase * day
   accumulatedAllowance = allowanceFor(dayNumber)
   ```
2. **Total pengeluaran** = `SUM(DailyTransaction.amount)` untuk tanggal
   `<= cutoff`, dengan `cutoff` = hari ini, atau hari terakhir periode bila
   periode sudah lewat.
3. **Limit hari ini**:
   `todayLimit = accumulatedAllowance - totalSpent`
4. **Proyeksi limit besok** (jika hari ini tidak ada pengeluaran tambahan):
   `tomorrowLimit = allowanceFor(dayNumber + 1) - totalSpent`,
   bernilai `null` bila hari ini hari terakhir atau periode sudah berakhir.

### Contoh
Saldo 3.100.000, tagihan 1.000.000, 30 hari →
`netFunds = 2.100.000`, `dailyBase = 70.000`.
Hari ke-3, total belanja 150.000 → `todayLimit = 210.000 - 150.000 = 60.000`,
`tomorrowLimit = 280.000 - 150.000 = 130.000`.

### Tampilan di Home
Dihitung di [`home_screen.dart`](../lib/features/daily_tracking/presentation/home_screen.dart)
dan [`hero_daily_limit_card.dart`](../lib/core/widgets/hero_daily_limit_card.dart):

```
spentRatio = spentToday / (todayLimit + spentToday)
             (setelah periode berakhir: totalSpent / accumulatedAllowance;
              bernilai 1 bila penyebutnya <= 0)
rollover   = todayLimit + spentToday - dailyBase
```

| Kondisi | Tampilan |
| --- | --- |
| `todayLimit < 0` | Tag "Overbudget", angka dan progress bar merah |
| `spentRatio >= 0.8` | Tag "Hampir habis", progress bar kuning |
| Selain itu | Tanpa tag, progress bar hitam |
| `rollover > 0` | Banner "Hemat" (selama periode berjalan) |

## 5. Aturan Transaksi
- Tanggal transaksi harus berada di dalam periode:
  `startDate <= date <= endDate` (`isDateWithinPeriod`).
- Nominal > 0 dan ≤ 1.000.000.000.000 (`maxMoney`); jumlah hari periode 1–366
  (`maxPeriodDays`) — [`validators.dart`](../lib/core/utils/validators.dart).
- Input nominal menerima pemisah ribuan ("1.200.000" → 1200000, `parseRupiah`).

## 6. Streak Pencatatan
Hari "tercatat" = tanggal yang punya transaksi (semua periode, maks. 400 tanggal
terbaru) ∪ tanggal yang ditandai "Tidak jajan".

Streak dihitung mundur dari **hari ini**; jika hari ini belum tercatat, mulai
dari **kemarin** supaya streak tidak langsung putus sebelum user sempat
mencatat. Hitung hari berturut-turut sampai menemukan hari yang tidak tercatat.
