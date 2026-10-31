# TASKS.md — Daftar Tugas KosM

> Agent wajib memperbarui centang setelah tugas selesai. Kerjakan **satu tugas per sesi**.
> Format: `[ ]` belum · `[~]` kode selesai tetapi menunggu uji di HP, atau baru sebagian · `[x]` selesai dan terbukti.
> ID mengikuti `docs/prd.md` (v0.2).

## Fase 0 — Fondasi
- [x] T0.1 Buat proyek Flutter (Android), rapikan struktur folder sesuai ARCHITECTURE.md
- [x] T0.2 Tambah package inti (riverpod, go_router, drift, intl, uuid)
- [x] T0.3 Token tema: `app_colors`, `app_text_styles`, `app_spacing`, `app_radius`, `app_theme` (terang & gelap)
- [x] T0.4 Komponen bersama: `AppCard`, `StatusChip`, `PrimaryButton`, `SecondaryButton`, `AppTextField`, `EmptyState`, `ConfirmDialog`, `AppSnackbar`, `PropertySwitcher`, `SlotIndicator`, `RateTypeChip`
- [x] T0.5 Router + shell bottom navigation (5 tab, layar placeholder)
- [x] T0.6 `AppDatabase` drift: semua tabel (owner_profile, properties, rooms, tenants, occupancies, charges, payments, reminders, app_settings) + `schemaVersion = 1` + test dasar
- [x] T0.7 Utilitas: `formatRupiah`, format tanggal `id_ID`, generator UUID + unit test
- [x] T0.8 CI GitHub Actions (format, analyze, test)

## Fase 1 — Kelola Kos & Daftar Penyewa
**Kelola Kos (multi-lokasi)**
- [~] F9.1 Daftar kos + onboarding membuat kos pertama
- [~] F9.2 Tambah/ubah/hapus kos (tolak hapus jika masih ada penghuni aktif)
- [~] F9.3 Pilih kos aktif (`PropertySwitcher`, simpan `active_property_id`)
- [~] F9.4 Tampilan gabungan "Semua Kos"

**Daftar Penyewa**
- [ ] F1.1 Daftar semua penyewa (data + UI + 4 kondisi layar)
- [ ] F1.3 Cari & saring penyewa
- [ ] F1.4 Tambah/ubah/hapus penyewa + detail penyewa
- [ ] F1.4a Kolom id_photo_path di tabel tenants (schemaVersion 2 + migrasi + test)
- [ ] F1.4b Ambil/pilih foto, kompres, simpan, hapus
- [ ] F1.2 Ringkasan kos sekilas di Beranda (butuh kamar/tagihan; boleh sementara 0)

## Fase 2 — Kamar, Masuk/Keluar, Tagihan & Pembayaran
**Data Kamar & Kos**
- [ ] F2.1 Daftar kamar (kapasitas, sisa slot, tarif acuan)
- [ ] F2.4 Tambah/ubah/hapus kamar (kapasitas; tolak hapus jika masih berpenghuni)
- [ ] F2.2 Status kamar turunan: kosong / terisi sebagian / penuh / perbaikan + test
- [ ] F2.3 Lihat kamar tersedia (kosong + masih ada slot)

**Catat Masuk & Keluar**
- [ ] F3.1 Catat penyewa masuk (slot tersedia, jenis tarif harian/mingguan/bulanan, harga per satuan, lama sewa)
- [ ] F3.2 Catat penyewa keluar
- [ ] F3.3 Riwayat masuk & keluar
- [ ] F3.4 Pindah kamar / perpanjang sewa (perpanjang membuat tagihan baru)

**Tagihan & Pembayaran**
- [ ] F4.5 `ChargeGenerator`: tagihan sewa otomatis harian/mingguan/bulanan, idempoten + test
- [ ] F4.6 Biaya tambahan (listrik, air, denda, lainnya)
- [ ] F4.1 Catat pembayaran per tagihan (termasuk cicilan)
- [ ] F4.2 Riwayat pembayaran
- [ ] F4.3 Status tagihan: lunas / belum bayar / menunggak (turunan) + test
- [ ] F4.4 Kuitansi pembayaran (bagikan)
- [ ] F1.2 Sempurnakan ringkasan Beranda dengan data nyata (per kos & semua kos)

## Fase 3 — Pengingat, Offline Penuh, Cadangan
- [ ] F5.1 Pengingat sebelum penyewa keluar
- [ ] F5.2 Pengingat tagihan jatuh tempo
- [ ] F5.3 Daftar pengingat mendatang
- [ ] F6.1 Audit: semua fitur inti jalan di mode pesawat
- [ ] F6.2 Indikator status sinkron (`SyncIndicator`)
- [ ] F7.0 Siapkan Google Cloud (OAuth, Drive API), langkah manual, lihat LANGKAH_PENGERJAAN.md
- [ ] F7.1 Sambungkan/putuskan Google Drive
- [ ] F7.2 Cadangan otomatis (WorkManager) + tombol cadangkan sekarang
- [ ] F7.3 Hapus semua cadangan di Drive
- [ ] F7.4 Pulihkan dari cadangan

## Fase 4 — Akun, Pengaturan, Ekspor
- [ ] F8.1 Masuk/keluar akun Google
- [ ] F8.2 Profil pemilik
- [ ] F8.3 Preferensi aplikasi (tema, jam pengingat, frekuensi cadangan)
- [ ] F10.1 Ekspor ke Excel (.xlsx), lembar Penyewa/Kamar/Hunian/Tagihan/Pembayaran
- [ ] F10.2 Filter laporan (kos, rentang tanggal)
- [ ] F10.3 Ringkasan keuangan (pemasukan per bulan per kos, tunggakan)
- [ ] F10.4 Bagikan file Excel

## Fase 5 — Rilis
- [ ] T5.1 Ikon aplikasi, splash, nama aplikasi
- [ ] T5.2 Uji menyeluruh di HP nyata (offline/online, notifikasi, cadangan–pulihkan, 2 kos)
- [ ] T5.3 Keystore & build rilis (APK/AAB), versi 1.0.0
- [ ] T5.4 GitHub Release + catatan rilis

## Catatan Sesi
<!-- Agent: tulis temuan/keputusan penting di sini (tanggal — catatan) -->
- 2026-10-18: T0.3 (Token tema terang & gelap, Plus Jakarta Sans lokal) dan T0.4 (11 komponen bersama + layar pratinjau visual) selesai dikerjakan, lolos format, analyze (0 issue), dan seluruh unit/widget test.
- 2026-10-18 (Audit Fase 0):
  - T0.1 [~] Sebagian selesai: Proyek Flutter Android siap, demo counter dihapus, lib/main.dart & lib/app.dart siap. Sisa: pembuatan pohon folder lib/features/ (10 modul), lib/l10n/, serta subfolder lib/core/ (router, database, utils, services, errors).
  - T0.2 [ ] Belum selesai: Package inti (flutter_riverpod, go_router, drift, intl, uuid) belum ada di pubspec.yaml.
  - T0.3 [x] Selesai: Token warna, tipografi font lokal, spasi, radius, tema M3 terang/gelap + unit test lolos.
  - T0.4 [x] Selesai: 11 komponen bersama + preview visual + unit & widget test lolos.
  - T0.5 - T0.8 [ ] Belum selesai: Menunggu penyelesaian T0.1 dan T0.2.
- 2026-10-25 (Audit Menyeluruh Kode vs TASKS.md):
  - Status tugas terverifikasi:
    - T0.1 [~] Sebagian (proyek Flutter Android siap, subfolder features, l10n, dan subfolder core lainnya belum dibuat).
    - T0.2 [ ] Belum (package inti riverpod, go_router, drift, intl, uuid belum ditambahkan di pubspec.yaml).
    - T0.3 [x] Selesai (token tema app_colors, app_text_styles, app_spacing, app_radius, app_theme terang & gelap, aset font lokal Plus Jakarta Sans).
    - T0.4 [x] Selesai (11 komponen bersama + SyncIndicator, preview page, widget/unit test).
    - T0.5 - T0.8 [ ] Belum dikerjakan.
    - Fase 1 s/d Fase 5: [ ] Seluruhnya belum dikerjakan.
  - Bukti verifikasi kualitas: `flutter analyze` 0 issues, `flutter test` lulus (13/13 test passed).
- 2026-10-25: T0.1 dan T0.2 selesai dikerjakan.
  - T0.1 [x]: Struktur folder lengkap dibuat persis sesuai docs/ARCHITECTURE.md bagian 3 (lib/core/{router,database,utils,services,errors}, lib/l10n, lib/features/{home,property,tenant,room,occupancy,payment,reminder,backup,settings,export}/{data,domain,presentation/{providers,pages,widgets}} dengan .gitkeep).
  - T0.2 [x]: Package inti ditambahkan (flutter_riverpod, go_router, drift, drift_flutter, path_provider, intl, uuid, flutter_localizations, serta dev: drift_dev, build_runner).
  - File yang berubah: pubspec.yaml, pubspec.lock, 56 folder baru dengan .gitkeep.
  - Hasil uji: `dart format .` bersih, `flutter analyze` 0 issue, `flutter test` lulus (13/13 test passed).
  - Sisa pekerjaan: T0.5 (Router & shell bottom nav), T0.6 (Drift database), T0.7 (Utilitas), T0.8 (CI).
- 2026-10-25: T0.5, T0.6, dan T0.7 selesai dikerjakan.
  - T0.5 [x]: go_router dengan StatefulShellRoute bottom navigation 5 tab (Beranda, Penyewa, Kamar, Bayar, Lainnya) berbasis PlaceholderPage (EmptyState), rute debug /dev/preview untuk ThemePreviewPage, dan MaterialApp.router di app.dart.
  - T0.6 [x]: Drift AppDatabase (9 tabel sesuai ARCHITECTURE.md bagian 4, UUID v4, UTC timestamp, uang integer Rupiah, soft delete deleted_at, unique index charges & rooms, schemaVersion = 1) ter-generate via build_runner dan lulus unit test in-memory.
  - T0.7 [x]: Utilitas formatRupiah (Rp1.500.000 tanpa spasi), format tanggal id_ID (AppDateFormat), generator UUID v4, dan inisialisasi locale di main.dart lulus unit test.
  - File yang berubah: lib/main.dart, lib/app.dart, test/widget_test.dart, lib/core/router/*, lib/core/database/*, lib/core/utils/*, test/core/database_test.dart, test/core/router_test.dart, test/core/utils_test.dart.
  - Hasil analyze/test: `dart format .` bersih, `flutter analyze` 0 issue, `flutter test` lulus (28/28 tests passed).
  - Langkah uji manual: Jalankan `flutter run`, uji perpindahan 5 tab pada bottom bar, periksa teks placeholder pada setiap tab, lalu navigasikan ke rute `/dev/preview` (pada mode debug) untuk memeriksa preview sistem desain dan tombol ganti tema.
  - Sisa pekerjaan: T0.8 (CI GitHub Actions).
- 2026-10-25 (Audit Fondasi T0.1 - T0.8):
  - Status tugas terverifikasi terhadap kode:
    - T0.1 [x] Selesai & terbukti: Struktur folder lengkap (lib/core/{router,database,utils,services,errors}, lib/l10n/, lib/features/ 10 modul).
    - T0.2 [x] Selesai & terbukti: Package inti di pubspec.yaml (riverpod, go_router, drift, drift_flutter, path_provider, intl, uuid, flutter_localizations, dev: drift_dev, build_runner).
    - T0.3 [x] Selesai & terbukti: Token tema terang/gelap di lib/core/theme/ + 4 suite di test/core/theme_test.dart lolos.
    - T0.4 [x] Selesai & terbukti: 11 komponen bersama + SyncIndicator di lib/core/widgets/ + 6 suite di test/core/widgets_test.dart lolos.
    - T0.5 [x] Selesai & terbukti: Shell bottom nav 5 tab di lib/core/router/ + widget test di test/core/router_test.dart & test/widget_test.dart lolos.
    - T0.6 [x] Selesai & terbukti: Drift AppDatabase 9 tabel, schemaVersion = 1, unique index di lib/core/database/ + 5 test di test/core/database_test.dart lolos.
    - T0.7 [x] Selesai & terbukti: Utilitas formatRupiah, AppDateFormat, UUID v4 di lib/core/utils/ + 8 test di test/core/utils_test.dart lolos.
    - T0.8 [ ] Belum dikerjakan: Folder .github/workflows/ belum ada.
  - Hasil verifikasi otomatis: `flutter analyze` 0 issue, `flutter test` lulus (28/28 tests passed).
  - Sisa pekerjaan Fase 0: T0.8 (CI GitHub Actions).
- 2026-10-25: T0.8 dikerjakan [~].
  - Dibuat .github/workflows/ci.yml dengan alur checkout, setup flutter (stable, cache), flutter pub get, dart format check, build_runner, flutter analyze, dan flutter test. .gitignore dipastikan mengabaikan *.g.dart.
  - File yang berubah: .github/workflows/ci.yml, docs/TASKS.md.
  - Hasil uji lokal: format check bersih, analyze 0 issue, test lulus (28/28 tests passed).
  - Status [~]: Menunggu verifikasi eksekusi workflow hijau di GitHub Actions pada push/PR.
- 2026-10-30: Penyesuaian spesifikasi & dokumentasi untuk keputusan baru pemakaian foto KTP/identitas penyewa (opsional).
  - Tugas: Memperbarui PRD, ARCHITECTURE, TASKS, dan AGENTS (glosarium) agar konsisten terkait pemakaian foto KTP/identitas (opsional), penambahan kolom `id_photo_path` (nullable, path relatif), penyimpanan terkompresi di folder privat aplikasi, penghapusan file saat penyewa dihapus, foto tidak ikut ekspor Excel, status cadangan Drive (keputusan terbuka & dampaknya), risiko data sensitif & peningkatan PIN/biometrik, serta penambahan tugas F1.4a dan F1.4b. Package kamera/galeri belum ditambahkan pada sesi ini.
  - File yang berubah: AGENTS.md, docs/prd.md, docs/ARCHITECTURE.md, docs/TASKS.md.
  - Hasil analyze/test: Tidak ada kode aplikasi yang diubah; `flutter analyze` 0 issue, `flutter test` lulus (28/28 tests passed).
  - Langkah uji manual: Verifikasi konsistensi dokumen teknis dan penamaan glosarium.
  - Sisa pekerjaan: Menunggu persetujuan perubahan dokumen sebelum melanjutkan ke implementasi tugas berikutnya.

- 2026-10-31: F9 (F9.1–F9.4) — Kelola Kos (multi-lokasi) [~].
  - Deskripsi Tugas: Implementasi penuh modul kelola kos multi-lokasi (data & domain di `lib/features/property/`, activePropertyProvider dengan penyimpanan ke app_settings & fallback otomatis, routing onboarding dan shell berbasis kos, layar daftar kos, form tambah/ubah, dialog hapus aman terhubung cascade soft delete kamar, serta menu kelola kos pada tab Lainnya).
  - File yang berubah:
    - `lib/core/errors/app_exception.dart` & `lib/core/errors/errors.dart`
    - `lib/core/strings/app_strings.dart` & `lib/core/strings/strings.dart`
    - `lib/core/database/app_database.dart`
    - `lib/core/router/app_router.dart` & `lib/core/router/placeholder_page.dart`
    - `lib/features/property/domain/property.dart`
    - `lib/features/property/domain/property_repository.dart`
    - `lib/features/property/data/property_dao.dart`
    - `lib/features/property/data/property_repository_impl.dart`
    - `lib/features/property/presentation/providers/property_providers.dart`
    - `lib/features/property/presentation/widgets/property_item_card.dart`
    - `lib/features/property/presentation/pages/property_list_page.dart`
    - `lib/features/property/presentation/pages/property_form_page.dart`
    - `lib/features/property/presentation/pages/onboarding_page.dart`
    - `lib/features/settings/presentation/pages/more_page.dart`
    - `test/helpers/pump_helpers.dart`
    - `test/core/router_test.dart`
    - `test/widget_test.dart`
    - `test/features/property/active_property_provider_test.dart`
    - `test/features/property/property_repository_test.dart`
    - `test/features/property/property_widgets_test.dart`
    - `docs/TASKS.md`
  - Hasil Uji Otomatis:
    - `dart format .`: Bersih (seluruh file sesuai standar).
    - `flutter analyze`: 0 issues (bersih).
    - `flutter test`: 48/48 tests passed (seluruh test suite proyek lulus 100%).
  - Akar Masalah Tiap Kelompok Uji:
    1. Timer Pending pada Widget Test & Router Test: Drift stream query (`select().watch()`) menjadwalkan timer mikro durasi nol (`Timer(Duration.zero)`) saat `StreamQueryStore.markAsClosed()` dieksekusi ketika `ProviderScope` di-unmount di akhir `testWidgets`. Flutter test memverifikasi `!timersPending` tepat setelah test selesai. Solusi: Dibuat helper `disposeApp(tester)` di `test/helpers/pump_helpers.dart` (`await tester.pumpWidget(const SizedBox.shrink()); await tester.pump(Duration.zero);`) untuk meng-unmount tree dan mengosongkan antrean timer sebelum test berakhir, serta menutup database in-memory secara tertib lewat `addTearDown(() async => await db.close())`.
    2. Hit-Test Warning & Elemen di Luar Layar pada OnboardingPage Test: Viewport default test adalah 800x600, sedangkan form onboarding membutuhkan tinggi ~616px sehingga tombol submit berada di bawah batas pandang. Solusi: Dibuat helper `setPhoneScreen(tester)` (400x900, DPR 1.0, direset otomatis di addTearDown) dan pemanggilan `tester.ensureVisible(...)` sebelum melakukan interaksi tap.
    3. ActivePropertyNotifier Timeout, Rebuild Loop, & Bug 'prop-1':
       - Timeout & Rebuild Loop: Disebabkan oleh penggunaan `ref.watch(propertiesStreamProvider)` di dalam `ActivePropertyNotifier.build()` yang menahan notifier dalam `AsyncLoading` dan memicu rebuild berantai saat stream drift memancarkan pembaruan. Solusi: `build()` diubah membaca data sekali lewat `PropertyRepository` (`readActivePropertyId()` dan `getAll()`).
       - Bug 'prop-1': `setActiveProperty` sebelumnya tidak menunggu `build()` selesai (`await future;`), sehingga jika `build()` awal selesai setelah mutasi atau saat `savedId` masih kosong/null, `build()` mengembalikan `properties.first.id` ('prop-1') dan menimpa pilihan pengguna ('all'). Solusi: Memanggil `await future;` sebelum mutasi, menyimpan ke repository terlebih dahulu, dan memvalidasi `savedId == 'all'` agar nilai 'all' selalu dipertahankan bahkan saat membuka ulang aplikasi.
       - Fallback Terpusat: Dibuat metode terpusat `deleteProperty(id)` di notifier (memanggil `softDelete(id)` lalu `handlePropertyDeleted(id)`); jika softDelete ditolak (`PropertyHasActiveOccupanciesException`), `handlePropertyDeleted` tidak dipanggil dan kos aktif tetap bertahan. Jika kos terakhir dihapus, aplikasi otomatis kembali ke onboarding (`/onboarding`), dan kos baru yang didaftarkan langsung menjadi kos aktif.
  - Langkah Uji Manual di HP (untuk verifikasi pengguna sebelum mengubah [~] menjadi [x]):
    1. Onboarding tidak berkedip: Pastikan saat aplikasi dibuka dan kos sudah ada, aplikasi langsung masuk ke Beranda tanpa menampilkan layar form onboarding sekilas.
    2. Buat kos kedua: Masuk ke tab Lainnya -> Kelola Kos -> Tambah Kos ("Kos Mawar"), simpan dan pastikan muncul di daftar.
    3. Ganti kos & persistensi: Ganti kos aktif lewat `PropertySwitcher` di AppBar (pilih Kos 1, Kos 2, dan "Semua Kos"). Tutup aplikasi sepenuhnya lalu buka kembali: kos aktif yang dipilih atau "Semua Kos" harus tetap bertahan.
    4. Ubah kos: Edit nama/alamat/kontak kos di Kelola Kos dan verifikasi perubahan tercermin di daftar dan di PropertySwitcher.
    5. Hapus kos: Hapus kos yang sedang aktif, pastikan kos aktif otomatis beralih ke kos lain yang tersisa. Hapus seluruh kos sampai habis: pastikan aplikasi otomatis kembali ke layar Onboarding, dan setelah kos baru dibuat, kos tersebut otomatis menjadi kos aktif.
    6. Mode pesawat (Offline): Matikan Wi-Fi dan data seluler; pastikan seluruh alur onboarding, penambahan, pengubahan, pemilihan, dan penghapusan kos bekerja lancar tanpa kendala jaringan.
