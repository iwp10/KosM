# LANGKAH_PENGERJAAN.md — Dari Nol Sampai Aplikasi KosM + GitHub

Ikuti berurutan. Lewati langkah yang sudah kamu lakukan.

## Tahap 0 — Persiapan Alat (Windows 11)
1. Pasang **Git**: https://git-scm.com/download/win
2. Pasang **GitHub CLI**: `winget install GitHub.cli`
3. Pastikan Flutter siap: jalankan `flutter doctor`, semua centang hijau (SDK, Android toolchain, VS Code/Android Studio).
4. Aktifkan **Developer options → USB debugging** di HP Android, sambungkan ke PC, cek `flutter devices`.
5. Siapkan Antigravity dan akun Stitch (https://stitch.withgoogle.com).

## Tahap 1 — Repo Lokal + GitHub
1. Atur identitas Git (sekali saja):
   ```bash
   git config --global user.name "Nama Kamu"
   git config --global user.email "emailgithub@contoh.com"
   git config --global init.defaultBranch main
   ```
2. Login GitHub: `gh auth login` (pilih GitHub.com → HTTPS → login lewat browser).
3. Buat proyek Flutter:
   ```bash
   flutter create --org com.namakamu --project-name kosm --platforms android kosm
   cd kosm
   ```
   Ganti `namakamu` dengan nama unikmu (menjadi package ID, sulit diubah nanti).
4. Tambahkan baris ini ke `.gitignore`:
   ```
   *.g.dart
   *.freezed.dart
   android/key.properties
   *.jks
   *.keystore
   .env
   ```
5. Commit pertama lalu buat repo di GitHub dan unggah:
   ```bash
   git init
   git add .
   git commit -m "chore: inisialisasi proyek Flutter"
   gh repo create kosm --private --source=. --remote=origin --push
   ```
6. Buat cabang kerja:
   ```bash
   git switch -c dev
   git push -u origin dev
   ```
7. Di GitHub → Settings → Branches, lindungi `main` (wajib PR, wajib CI lulus). Opsional tapi disarankan.

## Tahap 2 — Pasang Dokumen Panduan
1. Salin file hasil unduhan ke repo:
   ```
   kosm/
   ├─ AGENTS.md
   └─ docs/
      ├─ prd.md
      ├─ ARCHITECTURE.md
      ├─ DESIGN.md
      ├─ TASKS.md
      ├─ PROMPTS.md
      ├─ LANGKAH_PENGERJAAN.md
      └─ design/          ← buat folder kosong (isi nanti dengan screenshot Stitch)
   ```
2. Commit:
   ```bash
   git add .
   git commit -m "docs: tambah PRD, arsitektur, desain, dan aturan agent"
   git push
   ```

## Tahap 3 — Desain di Stitch
1. Buka Stitch, pilih mode **Mobile**.
2. Jalankan **Prompt A0** dari `docs/PROMPTS.md` (jangan lupa menempel blok "Aturan Gaya").
3. Periksa hasil: warna, font, radius, navigasi 5 tab. Perbaiki dengan prompt edit sampai pas.
4. Lanjut A1 → A9, satu layar per prompt. Selalu awali dengan "Gunakan gaya yang sama persis…".
5. Simpan screenshot tiap layar ke `docs/design/` (`home.png`, `tenants.png`, dst.).
6. Jika ada nilai gaya yang berubah dari draf, perbarui `docs/DESIGN.md`.
7. Commit: `git add docs/design && git commit -m "docs(design): tambah desain layar dari Stitch" && git push`.

## Tahap 4 — Fondasi Kode di Antigravity
1. Buka folder `kosm` di Antigravity.
2. Mulai percakapan baru, jalankan **B0** (pemanasan konteks).
3. Buat cabang: `git switch -c feat/t0-fondasi` (dari `dev`).
4. Jalankan **B1** → **B2** → **B3** (satu percakapan per prompt). Setelah tiap prompt:
   - `flutter analyze` dan `flutter test` harus bersih,
   - `flutter run` di HP untuk cek visual,
   - commit dengan **B9**.
5. Tambahkan CI (T0.8): buat file `.github/workflows/ci.yml`:
   ```yaml
   name: CI
   on:
     push:
       branches: [main, dev]
     pull_request:
   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v4
         - uses: subosito/flutter-action@v2
           with:
             channel: stable
             cache: true
         - run: flutter pub get
         - run: dart run build_runner build --delete-conflicting-outputs
         - run: dart format --output=none --set-exit-if-changed .
         - run: flutter analyze
         - run: flutter test
   ```
6. Push cabang, buka Pull Request ke `dev`, tunggu CI hijau, merge:
   ```bash
   git push -u origin feat/t0-fondasi
   gh pr create --base dev --title "feat: fondasi proyek" --fill
   gh pr merge --squash --delete-branch
   git switch dev && git pull
   ```

## Tahap 5 — Siklus Per Fitur (ulangi untuk setiap tugas di TASKS.md)
1. `git switch dev && git pull`
2. `git switch -c feat/f1-daftar-penyewa`
3. Percakapan Antigravity baru → **B0** singkat → **B4** (template fitur) atau **B5** (menerjemahkan desain).
4. Setujui rencana agent, biarkan bekerja.
5. Uji di HP: normal, **mode pesawat**, data kosong, data banyak.
6. Pastikan `dart format .`, `flutter analyze`, `flutter test` bersih.
7. Commit (**B9**), push, PR ke `dev`, merge setelah CI hijau.
8. Di akhir setiap fase, jalankan **B6** (audit konsistensi) dan perbaiki sebelum lanjut.
9. Gabungkan `dev` ke `main` hanya saat satu fase stabil (PR `dev → main`), lalu beri tag, mis. `git tag v0.1.0 && git push --tags`.

Urutan fase: **0 Fondasi → 1 Penyewa → 2 Kamar/Masuk-Keluar/Bayar → 3 Pengingat+Offline+Cadangan → 4 Akun/Pengaturan → 5 Rilis**.

## Tahap 6 — Persiapan Khusus Fase 3

### Notifikasi
- Android 13+: izin notifikasi dimintakan saat runtime.
- Uji dengan menjadwalkan pengingat 1–2 menit ke depan, tutup aplikasi, tunggu notifikasi.
- Pada beberapa merek HP, penghemat baterai bisa menghalangi notifikasi; tes di HP-mu dan sediakan panduan di aplikasi.

### Google Drive (F7.0, manual, sekali saja)
1. Buka https://console.cloud.google.com → buat proyek baru "KosM".
2. **APIs & Services → Library** → aktifkan **Google Drive API**.
3. **OAuth consent screen**: tipe External, isi nama aplikasi dan email; tambahkan **scope** `.../auth/drive.appdata`; tambahkan akun Google-mu sebagai **Test user**.
4. Ambil SHA-1 debug:
   ```bash
   cd android
   ./gradlew signingReport
   ```
   (di Windows PowerShell: `.\gradlew signingReport`). Salin SHA-1 variant `debug`.
5. **Credentials → Create credentials → OAuth client ID → Android**: isi package name (`com.namakamu.kosm`) dan SHA-1 tadi.
6. Ulangi langkah 5 untuk SHA-1 keystore rilis nanti (Tahap 7).
7. Jangan commit file rahasia. Client ID Android tidak berisi secret, tapi tetap hindari menaruh kredensial lain di repo.
8. Lanjutkan ke prompt **B8**.

## Tahap 7 — Rilis
1. Buat keystore (simpan di luar repo dan **cadangkan**, jika hilang kamu tidak bisa memperbarui aplikasi):
   ```bash
   keytool -genkey -v -keystore %USERPROFILE%\kosm-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias kosm
   ```
2. Buat `android/key.properties` (sudah di `.gitignore`):
   ```
   storePassword=...
   keyPassword=...
   keyAlias=kosm
   storeFile=C:\\Users\\NAMA\\kosm-release.jks
   ```
3. Minta Antigravity menghubungkan signing rilis di `android/app/build.gradle` (baca dari `key.properties`).
4. Tambahkan SHA-1 keystore rilis ke OAuth client Google (Tahap 6).
5. Naikkan versi di `pubspec.yaml` (mis. `1.0.0+1`).
6. Build:
   ```bash
   flutter build apk --release
   ```
   Hasil: `build/app/outputs/flutter-apk/app-release.apk`.
7. Uji APK rilis di HP: offline, notifikasi, cadangan, pulihkan.
8. Rilis di GitHub:
   ```bash
   git switch main && git pull
   git tag v1.0.0 && git push --tags
   gh release create v1.0.0 build/app/outputs/flutter-apk/app-release.apk --title "KosM v1.0.0" --notes "Rilis pertama"
   ```

## Tahap 8 — Kebiasaan Agar Tetap Konsisten
- Satu percakapan Antigravity = satu tugas.
- Selalu mulai dari `docs/TASKS.md`; jangan minta "buatkan semuanya".
- Setiap keputusan baru (mis. satu kamar boleh banyak penghuni) **ditulis dulu** ke `prd.md` dan `ARCHITECTURE.md`, baru dikodekan.
- Jika desain berubah, ubah di Stitch → perbarui `docs/DESIGN.md` + token di `lib/core/theme` → baru layar.
- Jalankan audit **B6** di akhir tiap fase.
- Jika keputusan produk berubah, jalankan **B11** (sinkronkan dokumen) sebelum menulis kode.
- Urutan fondasi data: kos (F9) → kamar → penyewa → hunian → tagihan → pembayaran.
- Cadangkan keystore dan jangan pernah commit rahasia.

## Perkiraan Urutan Waktu (fleksibel)
| Tahap | Perkiraan |
|---|---|
| 0–2 Persiapan & dokumen | 1 hari |
| 3 Desain Stitch | 1–2 hari |
| 4 Fondasi kode | 2–3 hari |
| Fase 1 | 2–3 hari |
| Fase 2 | 1–2 minggu |
| Fase 3 | 1 minggu |
| Fase 4–5 | 3–5 hari |

Angka di atas hanya gambaran kasar; sesuaikan dengan waktu luangmu di sela kuliah.

## Jika Macet
- `flutter doctor` merah → perbaiki dulu sebelum lanjut.
- Agent melenceng dari desain → tempel ulang bagian relevan `DESIGN.md` dan minta audit **B6** pada file itu.
- Hasil Drift error → jalankan `dart run build_runner build --delete-conflicting-outputs`.
- Konflik Git → minta agent menjelaskan konfliknya dulu sebelum menyelesaikan.
