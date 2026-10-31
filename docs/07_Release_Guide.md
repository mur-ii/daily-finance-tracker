# Panduan Rilis (APK untuk website)

- Application ID: `my.id.sadri.dailytracking`
- Distribusi: APK di-host di GitHub Releases, tombol unduh ada di
  https://sadri.my.id (bukan Play Store).

## 1. Keystore (sekali saja)
`keytool` ada di JDK bawaan Android Studio (`<Android Studio>\jbr\bin\`).
Dari PowerShell:

```
& "<Android Studio>\jbr\bin\keytool.exe" -genkey -v -keystore <folder-aman>\daily-tracking-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias dailytracking
```

Simpan keystore **di luar** folder project dan backup di minimal dua tempat.
Jika keystore hilang, update tidak bisa lagi dipasang di atas versi lama.

Buat `android/key.properties` (di-ignore git, jangan dibagikan):

```
storePassword=<password keystore>
keyPassword=<password key>
keyAlias=dailytracking
storeFile=<folder-aman>/daily-tracking-release.jks
```

Tanpa file ini, build release jatuh ke debug key dan Gradle menampilkan
peringatan. APK seperti itu jangan disebar.

## 2. Versi
Naikkan `version` di `pubspec.yaml` setiap rilis, minimal angka setelah `+`
(build number). Android menolak update dengan build number yang sama atau
lebih kecil. Catat perubahan di [`CHANGELOG.md`](../CHANGELOG.md).

## 3. Build
```
flutter clean
flutter pub get
flutter analyze
flutter test
flutter build apk --release --target-platform android-arm,android-arm64
```

`x86_64` sengaja tidak disertakan: hampir hanya dipakai emulator dan menambah
sekitar 8,6 MB. `android/app/build.gradle.kts` membuang library x86_64 milik plugin
dari varian release. Untuk mencoba di emulator x86_64, pakai `flutter run`.

Hasil: `build/app/outputs/flutter-apk/app-release.apk`. Salin dengan nama
tetap `daily-finance-tracker.apk` — nama yang sama setiap rilis membuat link
unduhan di website tidak perlu diganti.

Pastikan APK ditandatangani keystore release, bukan debug key. APK ini hanya
memakai skema v2, jadi `keytool -printcert -jarfile` tidak bisa dipakai karena
selalu menjawab `Not a signed jar file`. Gunakan `apksigner`:

```
$env:JAVA_HOME = "<Android Studio>\jbr"
& "<Android SDK>\build-tools\<versi>\apksigner.bat" verify --print-certs daily-finance-tracker.apk
```

Certificate DN harus `CN=...` milik Anda, bukan `CN=Android Debug`.

### Build uji untuk satu perangkat
Untuk mencoba di HP sendiri dengan file lebih kecil (sekitar 10 MB, contoh `arm64`):

```
flutter build apk --release --split-per-abi --target-platform android-arm64 --android-project-arg=force-version-code-ignoring-abi=true
```

Hasil: `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`. Flag terakhir
menjaga build number sama dengan `pubspec.yaml`; tanpa flag itu build number
bertambah 2000 dan rilis resmi akan ditolak di HP tersebut. **Jangan sebarkan
file ini** karena tidak bisa dipasang di perangkat 32-bit.

## 4. Publikasi
1. Hitung hash: `certutil -hashfile daily-finance-tracker.apk SHA256`.
2. Buat release (tag dibuat otomatis):
   ```
   gh release create v<versi> daily-finance-tracker.apk --title "v<versi>" --notes "<ringkasan CHANGELOG + SHA-256>"
   ```
3. Tombol unduh di website memakai link permanen ke rilis terbaru:
   ```
   https://github.com/mur-ii/daily-finance-tracker/releases/latest/download/daily-finance-tracker.apk
   ```
   Tampilkan SHA-256 di halaman unduhan.

## 5. Checklist
- [ ] `version` di `pubspec.yaml` naik
- [ ] `CHANGELOG.md` diperbarui
- [ ] `flutter analyze` & `flutter test` lulus
- [ ] Build ditandatangani keystore release (bukan debug)
- [ ] Uji install di atas versi sebelumnya (data lama tetap ada)
- [ ] SHA-256 dipublikasikan bersama APK
