# Kebijakan Keamanan

## Versi yang didukung
Hanya versi terbaru di [Releases](https://github.com/mur-ii/daily-finance-tracker/releases)
yang menerima perbaikan keamanan.

## Melaporkan celah keamanan
Jangan laporkan celah keamanan lewat issue publik. Gunakan
[Private vulnerability reporting](https://github.com/mur-ii/daily-finance-tracker/security/advisories/new)
di tab **Security** repository ini. Sertakan versi aplikasi, perangkat/Android,
langkah reproduksi, dan dampaknya. Laporan akan ditanggapi secepatnya.

## Keaslian APK
APK resmi hanya tersedia di https://sadri.my.id dan GitHub Releases repository
ini, ditandatangani dengan kunci milik pengembang. Cocokkan SHA-256 file yang
diunduh dengan yang tercantum di halaman rilis:

```
certutil -hashfile daily-finance-tracker.apk SHA256   # Windows
sha256sum daily-finance-tracker.apk                   # Linux/macOS
```
