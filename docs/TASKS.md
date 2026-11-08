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
- [x] F9.1 Daftar kos + onboarding membuat kos pertama
- [x] F9.2 Tambah/ubah/hapus kos (tolak hapus jika masih ada penghuni aktif)
- [x] F9.3 Pilih kos aktif (`PropertySwitcher`, simpan `active_property_id`)
- [x] F9.4 Tampilan gabungan "Semua Kos"

**Daftar Penyewa**
- [x] F1.1 Daftar semua penyewa (data + UI + 4 kondisi layar)
- [x] F1.3 Cari & saring penyewa
- [x] F1.4 Tambah/ubah/hapus penyewa + detail penyewa
- [x] F1.4a Kolom id_photo_path di tabel tenants (schemaVersion 2 + migrasi + test)
- [~] F1.4b Ambil/pilih foto, kompres, simpan, hapus
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
- 2026-10-31: F1.4a Kolom id_photo_path di tabel tenants (schemaVersion 2 + migrasi + data layer tenant) [~].
  - Deskripsi Tugas: Implementasi tahap data penyewa (tanpa UI). Penambahan kolom `id_photo_path` (nullable) pada tabel `tenants`, penaikan `schemaVersion` ke 2 dengan strategi migrasi `onUpgrade` (`m.addColumn`), entitas `Tenant`, validasi nama & normalisasi nomor HP ke format `+628...`, status turunan penyewa (`TenantStatus`: overdue > active > ended > unassigned) dengan tanggal acuan `Asia/Jakarta`, visibilitas per kos, `TenantDao` dengan query batch bebas N+1 & reaktif stream (`watchAllWithStatus`), `TenantRepositoryImpl`, serta `tenantRepositoryProvider`.
  - File yang berubah:
    - `lib/core/database/tables/tenants_table.dart`
    - `lib/core/database/app_database.dart` & `lib/core/database/app_database.g.dart`
    - `lib/core/errors/app_exception.dart`
    - `lib/features/tenant/domain/tenant.dart`
    - `lib/features/tenant/domain/tenant_validators.dart`
    - `lib/features/tenant/domain/tenant_repository.dart`
    - `lib/features/tenant/data/tenant_dao.dart`
    - `lib/features/tenant/data/tenant_repository_impl.dart`
    - `lib/features/tenant/presentation/providers/tenant_providers.dart`
    - `docs/ARCHITECTURE.md`
    - `test/core/database_migration_test.dart`
    - `test/core/database_test.dart`
    - `test/features/tenant/tenant_repository_test.dart`
    - `test/features/tenant/tenant_status_test.dart`
    - `docs/TASKS.md`
  - Hasil Uji Otomatis:
    - `dart format .`: Bersih.
    - `flutter analyze`: 0 issues (bersih).
    - `flutter test`: 62/62 tests passed (seluruh test suite proyek lulus 100%).
  - Batasan Implementasi:
    - Nomor HP luar negeri ditolak untuk saat ini (hanya menerima nomor Indonesia berawalan `08`, `+62`, atau `62` dengan panjang 9-13 digit setelah kode negara).
    - TODO(F1.4b): File foto KTP ikut dihapus dari penyimpanan lokal saat `softDelete` penyewa dieksekusi (akan dihubungkan pada modul foto F1.4b).
  - Status [~]: Menunggu pengujian migrasi di HP nyata oleh pemilik proyek (uji pembaruan versi tanpa uninstall untuk memastikan data kos & penyewa lama tetap utuh dan kolom baru bernilai null).
- 2026-11-07: F1.1 (Daftar semua penyewa) dan F1.3 (Cari & saring penyewa) [~].
  - Deskripsi Tugas:
    - Menambahkan `hasActiveOccupancy` (bool) dan `currentRoomNumber` (String?, nomor kamar aktif atau kamar terakhir; null bila belum pernah menghuni; mempertahankan nomor kamar jika kamar di-soft-delete) pada `TenantWithStatus`.
    - Komponen UI `ListTileCard` (`lib/core/widgets/list_tile_card.dart`) per `docs/DESIGN.md` bagian 7: avatar inisial 40dp, heading nama, subtitle nomor kamar & HP, trailing chip tunggal `StatusChip`, teks catatan bawah, aman textScale 1.3 tanpa overflow.
    - Menambahkan `StatusType.neutral` pada `StatusChip` untuk status "Aktif", "Keluar", dan "Belum Menghuni"; serta merah untuk "Menunggak".
    - Layar `TenantListPage` (`lib/features/tenant/presentation/pages/tenant_list_page.dart`): 4 kondisi (loading static skeleton tanpa timer/animasi, kosong belum ada penyewa, error dengan tombol coba lagi, data), serta kondisi hasil cari/filter kosong terpisah dengan tombol "Hapus Pencarian".
    - Pencarian teks dengan debounce 250ms (nama case-insensitive substring, nomor kamar substring, nomor HP dinormalisasi jika query >= 4 digit angka; query "03" tidak mencocokkan nomor HP tapi mencocokkan nomor kamar).
    - Filter chip: Semua, Aktif, Menunggak, Keluar. Hitung angka pada chip dihitung sebelum pencarian diterapkan.
    - Pengaitan rute di `app_router.dart`: tab `/tenants` membuka `TenantListPage` dengan dropdown `PropertyAwareAppBarTitle` di AppBar; sub-rute `/tenants/new` diarahkan ke root navigator.
    - Bagian pratinjau visual di `lib/core/theme/theme_preview_page.dart` (6 kartu contoh `ListTileCard`).
  - File yang berubah:
    - `lib/core/widgets/list_tile_card.dart`
    - `lib/core/widgets/widgets.dart`
    - `lib/core/widgets/status_chip.dart`
    - `lib/core/strings/app_strings.dart`
    - `lib/core/router/app_router.dart`
    - `lib/core/theme/theme_preview_page.dart`
    - `lib/features/tenant/domain/tenant.dart`
    - `lib/features/tenant/data/tenant_dao.dart`
    - `lib/features/tenant/data/tenant_repository_impl.dart`
    - `lib/features/tenant/presentation/providers/tenant_providers.dart`
    - `lib/features/tenant/presentation/pages/tenant_list_page.dart`
    - `test/core/widgets_test.dart`
    - `test/core/router_test.dart`
    - `test/features/tenant/tenant_status_test.dart`
    - `test/features/tenant/tenant_providers_test.dart`
    - `test/features/tenant/tenant_list_page_test.dart`
    - `docs/TASKS.md`
  - Hasil Uji Otomatis:
    - `dart format .`: Bersih.
    - `flutter analyze`: 0 issues (bersih).
    - `flutter test`: 93/93 tests passed (seluruh test suite proyek lulus 100%).
  - Langkah Uji Manual di HP (untuk verifikasi pemilik proyek sebelum mengubah [~] menjadi [x]):
    1. Buka tab Penyewa saat kos belum ada penyewa: pastikan layar menampilkan EmptyState "Belum Ada Penyewa" dan tombol "Tambah Penyewa".
    2. Tap FAB atau tombol "Tambah Penyewa": pastikan membuka form placeholder tambah penyewa di `/tenants/new`.
    3. Tampilan kartu penyewa: verifikasi avatar inisial 40dp, nama penyewa, nomor kamar dan no. HP di subjudul, dan tepat 1 status chip ("Aktif", "Menunggak", "Keluar", atau "Belum Menghuni").
    4. Saring status chip: tap chip "Aktif", "Menunggak", "Keluar", "Semua", pastikan daftar tersaring sesuai kategori dan angka pada chip tetap stabil.
    5. Pencarian nama / kamar: ketik nama atau nomor kamar, pastikan daftar tersaring dengan debounce 250ms.
    6. Pencarian no. HP: ketik 4 digit nomor HP (mis. "0812" atau "+62812"), pastikan cocok; ketik 2 digit (mis. "03"), pastikan hanya mencocokkan nomor kamar dan tidak mencocokkan no. HP.
    7. Hasil pencarian kosong: ketik teks acak yang tidak cocok, pastikan muncul EmptyState "Tidak Ada Penyewa yang Cocok", lalu tap "Hapus Pencarian" untuk mengembalikan filter dan input pencarian.
    8. Ganti kos di PropertySwitcher: pastikan daftar penyewa otomatis terfilter mengikuti kos yang dipilih (atau menampilkan gabungan di "Semua Kos").
    9. Mode pesawat (Offline): matikan koneksi internet, pastikan seluruh tampilan daftar, filter, pencarian, dan pergantian kos tetap berfungsi normal tanpa kendala jaringan.

- 2026-11-07: F1.4 (Tambah, ubah, hapus penyewa + halaman detail) [~].
  - Deskripsi Tugas:
    - Form Tambah & Ubah Penyewa (`lib/features/tenant/presentation/pages/tenant_form_page.dart`):
      - Rute `/tenants/new` (tambah) dan `/tenants/:id/edit` (ubah).
      - Validasi inline: Nama wajib & maks 100 karakter (`TenantValidators.validateName`); Nomor HP wajib dengan awalan visual `+62 `, menerima input `08...`, `8...`, atau `+628...` lalu dinormalisasi ke `+628...` (`TenantValidators.normalizePhone`); Catatan opsional & maks 300 karakter.
      - Pada mode ubah: Data penyewa dimuat, nomor HP ditampilkan tanpa awalan `+62` agar pengguna nyaman mengedit.
      - Pencegahan duplikasi submit: Tombol simpan dinonaktifkan (`isLoading: true`) selama proses simpan dan guard `_isSaving` mencegah submit ganda akibat double tap cepat.
      - Navigasi & umpan balik: Setelah simpan tambah -> kembali ke daftar dengan snackbar "Penyewa disimpan"; setelah simpan ubah -> kembali ke detail dengan snackbar "Penyewa disimpan".
      - Tata letak responsif dalam `SingleChildScrollView` + `SafeArea`, aman overflow pada viewport kecil 400x500 dan textScale 1.3.
    - Halaman Detail Penyewa (`lib/features/tenant/presentation/pages/tenant_detail_page.dart`):
      - Rute `/tenants/:id` (dihubungkan dari ketukan kartu di `TenantListPage`).
      - 4 kondisi layar: loading skeleton statis tanpa timer, 404 not found ramah pengguna dengan tombol kembali, error dengan tombol coba lagi, dan tampilan data lengkap.
      - Komponen data: Header avatar inisial 48dp + nama + `TenantStatusChip` tunggal, kartu informasi nomor HP (dengan tombol cepat WhatsApp) & catatan, serta placeholder "Kamar & Hunian" dan "Riwayat Pembayaran" (TODO Fase 2).
      - Reaktivitas stream: Menggunakan `tenantDetailProvider(id)` via `watchByIdWithStatus(id)` di `TenantRepository` yang re-emit otomatis saat data penyewa, hunian, kamar, tagihan, atau pembayaran berubah.
      - Alur hapus aman: Dialog konfirmasi `ConfirmDialog` dengan teks dampak penghapusan. Jika penyewa memiliki hunian aktif (`TenantHasActiveOccupancyException`), dialog berubah menjadi peringatan satu tombol ("Mengerti") tanpa opsi hapus. Jika berhasil dihapus: soft-delete di database, penjaga state `_isDeleting` mencegah kedipan error "Penyewa tidak ditemukan", lalu kembali ke daftar penyewa dengan snackbar "Penyewa dihapus".
    - Pemisahan lapisan arsitektur:
      - Komponen `TenantStatusChip` dan pemetaan status diletakkan murni di lapisan presentasi (`lib/features/tenant/presentation/widgets/tenant_status_chip.dart`); folder `lib/features/tenant/domain/` tetap bersih tanpa import `material.dart` atau `core/widgets`.
      - Penambahan parameter `maxLengthEnforcement` pada `AppTextField` dan `showCancel` pada `ConfirmDialog` untuk mendukung dialog peringatan tunggal.
  - File yang berubah:
    - `lib/core/router/app_router.dart`
    - `lib/core/strings/app_strings.dart`
    - `lib/core/widgets/app_text_field.dart`
    - `lib/core/widgets/confirm_dialog.dart`
    - `lib/features/tenant/domain/tenant_repository.dart`
    - `lib/features/tenant/data/tenant_repository_impl.dart`
    - `lib/features/tenant/presentation/providers/tenant_providers.dart`
    - `lib/features/tenant/presentation/widgets/tenant_status_chip.dart`
    - `lib/features/tenant/presentation/pages/tenant_list_page.dart`
    - `lib/features/tenant/presentation/pages/tenant_form_page.dart`
    - `lib/features/tenant/presentation/pages/tenant_detail_page.dart`
    - `test/core/router_test.dart`
    - `test/core/widgets_test.dart`
    - `test/features/tenant/tenant_status_test.dart`
    - `test/features/tenant/tenant_list_page_test.dart`
    - `test/features/tenant/tenant_form_page_test.dart`
    - `test/features/tenant/tenant_detail_page_test.dart`
    - `docs/TASKS.md`
  - Hasil Uji Otomatis:
    - `dart format .`: Bersih.
    - `flutter analyze`: 0 issues (bersih).
    - `flutter test`: 117/117 tests passed (seluruh test suite proyek lulus 100%).
  - Batasan yang diketahui:
    - Nomor telepon rumah dan kontak non-seluler ditolak (aturan normalisasi nomor HP mewajibkan awalan 8 setelah +62 dengan 9-13 digit).
    - Modul foto KTP (ambil/pilih foto, kompresi, penyimpanan, penghapusan file) ditangguhkan ke F1.4b sesuai rencana bertahap.
  - Langkah Uji Manual di HP (untuk verifikasi pemilik proyek sebelum mengubah [~] menjadi [x]):
    1. Tambah Penyewa: Buka tab Penyewa, tekan FAB "+", masukkan nama "Budi Santoso", nomor HP "081234567890", catatan "Penyewa baru". Tekan tombol "Simpan Penyewa", pastikan aplikasi kembali ke daftar dan menampilkan snackbar "Penyewa disimpan".
    2. Validasi Form: Coba simpan form kosong -> pastikan muncul pesan error merah di nama & HP. Coba masukkan nama > 100 karakter atau catatan > 300 karakter -> pastikan muncul pesan batas maksimal. Coba masukkan nomor non-seluler (mis. 021...) -> pastikan ditolak.
    3. Detail Penyewa: Ketuk kartu penyewa di daftar -> pastikan masuk ke `/tenants/:id`. Periksa avatar inisial, nama, chip status ("Belum Menghuni" jika belum ada hunian), nomor HP, catatan, serta placeholder hunian & pembayaran.
    4. Ubah Penyewa: Dari halaman detail, buka menu opsi (tiga titik) -> pilih "Ubah Data". Pastikan form terisi data lama, dan nomor HP ditampilkan tanpa awalan `+62`. Ubah nama/catatan lalu simpan -> pastikan kembali ke halaman detail dan data terbarui seketika (reaktivitas stream).
    5. Hapus Penyewa Tanpa Hunian: Dari menu opsi di detail, pilih "Hapus Penyewa". Konfirmasi dialog -> pastikan penyewa terhapus, tidak ada kedipan "Penyewa tidak ditemukan", kembali ke daftar dengan snackbar "Penyewa dihapus".
    6. Hapus Penyewa Berpenghuni Aktif (jika ada data hunian): Dialog peringatan "Tidak Dapat Menghapus Penyewa" hanya menampilkan tombol "Mengerti", dan data penyewa tidak terhapus.
    7. Double-Tap Prevention: Tekan tombol Simpan dua kali dengan sangat cepat; pastikan tidak ada duplikasi data penyewa di database.
    8. Mode Pesawat (Offline): Matikan internet; lakukan seluruh alur tambah, buka detail, ubah, dan hapus penyewa tanpa hambatan jaringan.

- 2026-11-08: F1.4b (Foto KTP/identitas penyewa: ambil/pilih, kompresi, penyimpanan privat, pratinjau zoom, isolasi backup, & perbaikan test hang) [~].
  - Deskripsi Tugas:
    - Penambahan dependensi resmi: `image_picker: ^1.2.4` dan `path: ^1.9.1`.
    - Isolasi backup Android: konfigurasi `data_extraction_rules.xml` dan `backup_rules.xml` mengecualikan direktori `app_flutter/id_photos` (root) dan `id_photos` (file) agar data sensitif foto KTP tidak pernah dicadangkan ke Google Drive atau transfer perangkat.
    - Abstraksi domain & data: `IdPhotoPicker` & `IdPhotoStorage` (savePhoto, deletePhoto, discardTemp, resolveAbsolutePath, fileExists, cleanupOrphans).
    - Failure-safe orchestration di `TenantRepository.saveTenant`: penyalinan berkas terkompresi ke storage privat, rollback file jika database gagal, pembersihan file lama dan file sementara lewat `discardTemp`.
    - Pratinjau & Form UI (`TenantFormPage` & `TenantDetailPage`): kartu foto KTP dengan tombol "Ambil Foto" & "Pilih dari Galeri", status terisi dengan tombol "Ganti Foto" & "Hapus Foto", dialog layar penuh interaktif pinch-to-zoom (`IdPhotoViewerDialog`), dan fallback ramah pengguna bila berkas rusak/hilang.
    - Pemisahan lapisan presentasi: seluruh pembersihan berkas sementara didelegasikan ke `IdPhotoStorage.discardTemp` (tidak ada pemanggilan `dart:io` `exists`, `delete`, `copy`, `writeAs` di lapisan presentasi selain `Image.file`).
    - Stabilisasi Pengujian & CI:
      - Penambahan `timeout-minutes: 15` pada job `build` di `.github/workflows/ci.yml`.
      - Penghapusan ketergantungan I/O nyata di widget tests dengan `FakeIdPhotoStorage` dan PNG 1x1 valid (`kTransparent1x1Png`).
      - Penggantian `pumpAndSettle()` tanpa batas dengan bounded pump pada pratinjau `Image.file` serta penetapan `timeout: Timeout(30s)`.
      - Pembersihan panggilan `Future.delayed` di seluruh pengujian, digantikan dengan `await pumpEventQueue()`.
  - File yang berubah:
    - `.github/workflows/ci.yml`
    - `pubspec.yaml` & `pubspec.lock`
    - `android/app/src/main/AndroidManifest.xml`
    - `android/app/src/main/res/xml/backup_rules.xml`
    - `android/app/src/main/res/xml/data_extraction_rules.xml`
    - `lib/features/tenant/domain/id_photo_picker.dart`
    - `lib/features/tenant/domain/id_photo_storage.dart`
    - `lib/features/tenant/data/id_photo_picker_impl.dart`
    - `lib/features/tenant/data/id_photo_storage_impl.dart`
    - `lib/features/tenant/data/tenant_dao.dart`
    - `lib/features/tenant/data/tenant_repository_impl.dart`
    - `lib/features/tenant/presentation/providers/tenant_providers.dart`
    - `lib/features/tenant/presentation/pages/tenant_form_page.dart`
    - `lib/features/tenant/presentation/pages/tenant_detail_page.dart`
    - `lib/features/tenant/presentation/widgets/id_photo_viewer_dialog.dart`
    - `test/features/tenant/id_photo_storage_test.dart`
    - `test/features/tenant/tenant_repository_test.dart`
    - `test/features/tenant/tenant_form_page_test.dart`
    - `test/features/tenant/tenant_status_test.dart`
    - `docs/TASKS.md`
  - Hasil Uji Otomatis:
    - `dart format .`: Bersih.
    - `flutter analyze`: 0 issues (bersih).
    - `flutter test`: 135/135 tests passed (seluruh test suite proyek lulus 100%).
    - Uji stabilitas `tenant_form_page_test.dart`: 5 kali berturut-turut lulus 100% tanpa hang (~2 detik per eksekusi).
  - Langkah Uji Manual di HP (untuk verifikasi pemilik proyek sebelum mengubah [~] menjadi [x]):
    1. Tambah Penyewa dengan Foto via Kamera: Buka form tambah penyewa, ketuk "Ambil Foto", beri izin kamera, ambil foto KTP. Verifikasi pratinjau muncul dengan tombol "Ganti Foto" dan "Hapus Foto". Simpan penyewa, pastikan tersimpan dan pratinjau tampil di halaman detail.
    2. Buka & Perbesar Foto: Dari halaman detail, ketuk pratinjau foto KTP. Pastikan dialog full-screen terbuka (`IdPhotoViewerDialog`) dan foto dapat di-pinch to zoom / pan dengan halus.
    3. Ubah Foto via Galeri: Buka form ubah data penyewa, ketuk "Ganti Foto" -> "Pilih dari Galeri", pilih foto baru. Simpan, pastikan foto terbarui dan file foto lama dihapus dari storage privat.
    4. Hapus Foto Saja: Buka form ubah, ketuk "Hapus Foto". Simpan, pastikan foto terhapus dari detail dan kolom `id_photo_path` di database bernilai null.
    5. Hapus Penyewa: Hapus penyewa yang memiliki foto, pastikan file foto terhapus dari storage privat aplikasi.
    6. Pembatalan / Pop Form: Pilih foto sementara di form lalu tekan tombol kembali tanpa menyimpan; pastikan file sementara dibersihkan dan tidak bocor sebagai file yatim.
    7. Mode Pesawat (Offline): Pastikan alur kamera/galeri dan penyimpanan lokal berfungsi penuh tanpa koneksi internet.
  - Sisa Pekerjaan: F1.2 (Ringkasan kos sekilas di Beranda) sebelum memasuki Fase 2.
