---
name: push
description: Commit, push, dan buka pull request sesuai alur branch di CONTRIBUTING.md. Gunakan saat pengguna meminta push, misalnya "/push", "push ke repo", atau "push perubahan ini".
argument-hint: "[nama-branch]"
---

# Push sesuai alur repository

Argumen opsional: `$ARGUMENTS` (nama branch, contoh `riwayat-grafik` atau `feat/riwayat-grafik`).

## Batasan
- Jangan pernah push langsung ke `main` atau `dev`, dan jangan force push.
- Jangan merge pull request. Merge dilakukan pengguna.
- Jangan membuat rilis atau PR `dev` → `main` dari skill ini.
- Bila sebuah langkah gagal, berhenti dan laporkan. Jangan melewati hook atau
  pemeriksaan untuk memaksanya lulus.

## Langkah

### 1. Periksa kondisi
Jalankan `git status -sb`, `git diff`, `git diff --staged`, dan
`git log --oneline origin/dev..HEAD`. Bila tidak ada perubahan dan tidak ada commit
yang belum di-push, berhenti dan sampaikan ke pengguna.

### 2. Tentukan branch
- Di `dev`: buat branch baru dengan `git switch -c <branch>`; perubahan ikut terbawa.
- Di `main`: bila ada commit lokal yang belum di-push, berhenti dan tanyakan ke
  pengguna. Bila tidak, jalankan `git fetch origin`, lalu
  `git switch -c <branch> origin/dev`. Bila perubahan bentrok, berhenti dan laporkan.
- Di `feat/*`, `fix/*`, `chore/*`, atau `hotfix/*`: lanjut di branch itu.

Nama branch diambil dari argumen, atau disimpulkan dari isi perubahan dalam
kebab-case. Bila argumen belum berawalan, pilih awalan dari isi perubahan:
- `feat/` untuk fitur baru
- `fix/` untuk perbaikan bug
- `chore/` untuk dokumentasi, dependensi, atau konfigurasi

`hotfix/*` hanya dipakai bila pengguna memintanya secara eksplisit.

### 3. Stage dan cek file
Stage file yang termasuk perubahan ini dengan menyebut path-nya satu per satu, bukan
`git add -A`. Bila ada file yang tampak tidak terkait, biarkan dan sebutkan di laporan.

Periksa `git diff --staged --name-only`. Berhenti bila ada `key.properties`, `*.jks`,
`*.keystore`, `*.env`, `*.apk`, atau `*.aab`, lalu keluarkan file itu dari stage.

### 4. Uji
Jalankan `flutter analyze` dan `flutter test`. Keduanya harus lulus. Bila gagal, jangan
commit atau push; laporkan hasilnya.

### 5. CHANGELOG
Bila perubahan terlihat pengguna dan `CHANGELOG.md` belum memuatnya, tambahkan catatan
di bagian `## [Belum Dirilis]` paling atas (buat bila belum ada), lalu stage.

### 6. Commit
Pesan commit dalam bahasa Indonesia, bentuk perintah, baris pertama maksimal 72
karakter. Contoh: `Tambah pengingat harian`.

### 7. Push dan pull request
Jalankan `git push -u origin <branch>`, lalu periksa PR dengan
`gh pr view --json url,state,baseRefName`.
- PR masih terbuka: push sudah memperbaruinya, jangan buat PR baru.
- Belum ada PR, atau PR lama sudah ditutup atau di-merge: buka PR baru dengan
  `gh pr create`. Basisnya `dev`; untuk `hotfix/*`, basisnya `main`.

Isi PR mengikuti `.github/pull_request_template.md`: isi Ringkasan dan Cara Menguji,
hapus Issue Terkait bila tidak ada, dan centang checklist hanya untuk hal yang benar
sudah dilakukan.

### 8. Laporkan
Sampaikan link PR, branch, hasil `flutter analyze` dan `flutter test`, serta file yang
sengaja tidak di-stage. Tutup dengan pengingat cara merge: **squash** ke `dev`. Untuk
`hotfix/*`, ingatkan juga untuk membawa perubahannya ke `dev` setelah merge ke `main`.
