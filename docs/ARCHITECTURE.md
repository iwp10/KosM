# ARCHITECTURE.md — Kerangka Sistem KosM

## 1. Prinsip
1. **Offline-first**: database lokal (SQLite) adalah sumber kebenaran. UI hanya membaca/menulis ke sana.
2. **Tanpa backend sendiri**: cadangan ke Google Drive milik pemilik. Murah, privat, sederhana.
3. **Feature-first**: kode dikelompokkan per fitur, bukan per jenis file.
4. **Satu arah**: UI → state (Riverpod) → repository → database. Tidak ada jalan pintas.

## 2. Diagram Besar
```
┌──────────────────────── Aplikasi Android ────────────────────────┐
│  Presentation (Widget)                                           │
│      │ watch/read                                                │
│  State (Riverpod Notifier/AsyncNotifier)                         │
│      │                                                           │
│  Domain (entity, repository interface, use case sederhana)      │
│      │                                                           │
│  Data (repository impl, Drift DAO)                               │
│      │                                                           │
│  SQLite lokal  ◄── sumber kebenaran                              │
│      │                                                           │
│  BackupService ──(online, latar belakang)──► Google Drive        │
│  ReminderService ──► Notifikasi lokal (tanpa internet)           │
└──────────────────────────────────────────────────────────────────┘
```

## 3. Struktur Folder
```
lib/
├─ main.dart
├─ app.dart                      # MaterialApp.router + tema
├─ core/
│  ├─ theme/                     # token desain (lihat DESIGN.md)
│  ├─ widgets/                   # komponen bersama
│  ├─ router/                    # go_router
│  ├─ database/                  # AppDatabase (drift), tabel, migrasi
│  ├─ utils/                     # formatRupiah, tanggal, uuid
│  ├─ services/                  # backup, reminder, connectivity
│  └─ errors/                    # tipe error & Result
├─ features/
│  ├─ tenant/                    # Daftar Penyewa (F1)
│  ├─ property/                  # Kelola Kos / multi-lokasi (F9)
│  ├─ room/                      # Data Kamar & Kos (F2)
│  ├─ occupancy/                 # Catat Masuk & Keluar (F3)
│  ├─ payment/                   # Tagihan, biaya tambahan, pembayaran (F4)
│  ├─ reminder/                  # Pengingat (F5)
│  ├─ backup/                    # Cadangan Google Drive & sinkron (F6, F7)
│  ├─ settings/                  # Akun & Pengaturan (F8)
│  ├─ export/                    # Ekspor Excel (F10)
│  └─ home/                      # Beranda / ringkasan
└─ l10n/                         # teks Bahasa Indonesia
```
Struktur di dalam setiap fitur:
```
features/<nama>/
├─ data/
│  ├─ <nama>_dao.dart            # query drift
│  └─ <nama>_repository_impl.dart
├─ domain/
│  ├─ <nama>.dart                # entity
│  └─ <nama>_repository.dart     # interface
└─ presentation/
   ├─ providers/                 # Riverpod
   ├─ pages/                     # layar
   └─ widgets/                   # widget khusus fitur
```

## 4. Skema Database (Drift)
Aturan umum: `id` = UUID v4 (text), waktu = UTC, uang = integer Rupiah, semua tabel punya `created_at`, `updated_at`, `deleted_at` (nullable, soft delete).

**owner_profile** (1 baris)
`id, owner_name, contact`

**properties** (kos / lokasi, pemilik bisa punya lebih dari satu)
`id, name, address, contact`

**rooms**
`id, property_id → properties, number (unik per property), capacity (int ≥ 1), reference_rate_type, reference_rate (int, opsional), facilities, is_under_maintenance (bool)`

**tenants** (global, tidak terikat satu kos)
`id, name, phone, id_photo_path (nullable), note`

**occupancies** (penyewa menempati kamar; satu kamar bisa punya beberapa yang aktif)
`id, tenant_id → tenants, room_id → rooms, start_date, planned_end_date (nullable), actual_end_date (null = masih tinggal), rate_type (daily | weekly | monthly), rate_amount (int, harga per satuan, ditetapkan pemilik), duration_units (int, nullable; lama sewa untuk harian/mingguan), due_day (1–31, hanya bulanan), status (active | ended)`

**charges** (tagihan: sewa maupun biaya tambahan)
`id, occupancy_id → occupancies, type (rent | electricity | water | penalty | other), description, amount (int), period_start, period_end, due_date`
Indeks unik `(occupancy_id, type, period_start)` untuk `type = rent` agar pembuatan tagihan idempoten.

**payments**
`id, charge_id → charges, amount (int), paid_at, method (cash | transfer), note`
Cicilan = beberapa pembayaran pada tagihan yang sama.

**reminders**
`id, type (before_checkout | charge_due), occupancy_id, charge_id (nullable), remind_at, is_done`

**app_settings** (key–value)
`key, value`: tema, jam pengingat, hari sebelum jatuh tempo, frekuensi cadangan, status koneksi Drive, `last_backup_at`, `dirty`, `active_property_id` (id kos atau `all` untuk gabungan).

### Aturan turunan (JANGAN disimpan, hitung dari data)
- **Slot kamar**: `active_count` = jumlah occupancy `active` pada kamar; `remaining = capacity - active_count`.
- **Status kamar**: `maintenance` jika `is_under_maintenance`; selain itu `vacant` jika `active_count = 0`; `partial` jika `active_count < capacity`; selain itu `full`.
- **Validasi occupancy baru**: ditolak jika `remaining ≤ 0` atau kamar `maintenance`; penyewa yang sama tidak boleh punya dua occupancy aktif di kamar yang sama.
- **Total sewa harian/mingguan** = `rate_amount × duration_units`. **Bulanan** = `rate_amount` per bulan.
- **Status tagihan**: `paid` jika total pembayaran ≥ `amount`; `unpaid` jika kurang dan `due_date` belum lewat; `overdue` jika kurang dan `due_date` sudah lewat. Penyewa "menunggak" jika punya tagihan `overdue`.
- **Filter kos**: semua query kamar/hunian/tagihan/pembayaran difilter lewat `rooms.property_id = active_property_id`, kecuali nilainya `all`.

### Visibilitas Penyewa per Kos (`propertyFilter`)
- **Mode Semua Kos (`'all'` atau `null`)**: Menampilkan seluruh penyewa yang belum di-soft-delete.
- **Filter Kos Tertentu (`property_id`)**:
  - **Penyewa tanpa hunian**: Tampil di **SEMUA kos** (agar pemilik dapat memilih penyewa ini saat mencatat hunian baru di kos mana pun).
  - **Penyewa dengan hunian**: Tampil di kos tempat kamarnya berada, baik status huniannya **aktif maupun selesai** (`status == 'active'` atau `status == 'ended'`), asalkan hunian dan kamar belum di-soft-delete.
  - **Penyewa dengan hunian di beberapa kos**: Tampil di masing-masing kos tersebut.
  - **Kamar/Kos yang di-soft-delete**: Penyewa yang HANYA memiliki riwayat hunian pada kamar/kos yang telah di-soft-delete tidak tampil pada filter kos tertentu, namun tetap tampil pada mode Semua Kos (`'all'`).
- **Urutan**: Daftar penyewa selalu diurutkan secara stabil berdasarkan `name ASC`, lalu `id ASC`.

### Status Turunan Penyewa (`TenantStatus`)
Status penyewa adalah nilai murni turunan (tidak disimpan di database) dengan urutan prioritas ketat:
`overdue > active > ended > unassigned`
1. **`overdue`** (Menunggak): Memiliki setidaknya satu tagihan (`charges` non-deleted) pada huniannya yang tanggal jatuh temponya (`due_date`) **lebih awal dari tanggal hari ini** di zona waktu lokal (`Asia/Jakarta`) DAN total pembayaran yang tercatat (`payments` non-deleted) **kurang dari jumlah tagihan** (`amount`). Tagihan yang jatuh tempo hari ini *belum* dianggap overdue.
2. **`active`** (Aktif): Tidak memiliki tagihan overdue, dan memiliki setidaknya satu hunian aktif (`occupancies.status == 'active'` non-deleted).
3. **`ended`** (Selesai): Tidak memiliki tagihan overdue maupun hunian aktif, tetapi memiliki riwayat hunian di masa lalu (`occupancies` non-deleted).
4. **`unassigned`** (Belum Ada Kamar): Belum pernah memiliki riwayat hunian sama sekali.

### Pembuatan Tagihan Sewa Otomatis (`ChargeGenerator`)
- Berjalan lokal (tanpa internet): saat aplikasi dibuka, saat occupancy dibuat/diperpanjang, dan lewat tugas harian.
- **Harian/mingguan**: satu tagihan `rent` untuk seluruh lama sewa; `due_date` default = `start_date`.
- **Bulanan**: satu tagihan per bulan; dibuat untuk periode berjalan dan periode berikutnya; `due_date` mengikuti `due_day`.
- **Perpanjang sewa**: menambah `duration_units`/`planned_end_date` dan membuat tagihan baru.
- **Pindah kamar**: occupancy lama diakhiri, occupancy baru dibuat; tagihan belum lunas tetap menempel di occupancy lama.
- Harus **idempoten**: dijalankan berulang tidak boleh membuat tagihan ganda (dijaga indeks unik + test).

### Penyimpanan Foto Identitas / KTP
- Foto KTP/identitas bersifat **opsional**.
- Disimpan di **folder privat aplikasi** (bukan galeri publik perangkat), sehingga terisolasi dan tidak muncul di aplikasi galeri umum.
- **Kompresi**: sisi terpanjang maksimal 1280 px, JPEG kualitas 80, target ukuran di bawah 500 KB.
- Database **hanya menyimpan path relatif** (mis. `tenants/photos/<uuid>.jpg`), bukan path absolut, agar tidak rusak jika path direktori internal aplikasi berubah.
- **Siklus hidup file**: saat penyewa dihapus, file fotonya ikut dihapus dari penyimpanan.

## 5. State Management (Riverpod)
- `Provider` untuk repository & database.
- `StreamProvider`/`AsyncNotifier` untuk daftar data (Drift `watch()` agar UI otomatis ter-update).
- Satu `Notifier` per layar yang punya aksi (tambah/ubah/hapus).
- Error dipetakan ke tipe `AppError` dan ditampilkan lewat `AppSnackbar`.

## 6. Navigasi (go_router)
```
/                  → shell dengan bottom nav
 ├─ /home
 ├─ /tenants       → /tenants/new, /tenants/:id, /tenants/:id/edit
 ├─ /rooms         → /rooms/new, /rooms/:id
 ├─ /payments      → /payments/new?chargeId=, /payments/charges/new?occupancyId=
 └─ /more          → /more/reminders, /more/properties, /more/export, /more/backup, /more/profile, /more/preferences
/login             → hanya jika pengguna ingin menyambungkan akun
```
Aplikasi **tidak mewajibkan login untuk dipakai**; akun Google hanya dibutuhkan untuk cadangan.

## 7. Alur Offline → Online (Cadangan)
Karena aplikasi untuk satu pemilik tanpa backend, **jangan** membuat sinkronisasi per baris yang rumit. Pakai **cadangan snapshot**:

1. Setiap perubahan data menandai `dirty = true` di `app_settings`.
2. `WorkManager` menjalankan tugas berkala (mis. tiap 24 jam) dengan syarat `NetworkType.connected`.
3. Jika `dirty = true` dan Drive tersambung:
   1. Jalankan WAL checkpoint, salin file database.
   2. Kompres (`gzip`) → `kosm_backup_<yyyyMMdd_HHmm>.db.gz`.
   3. Unggah ke Drive **`appDataFolder`** (scope `drive.appdata`, tidak menyentuh file Drive lain).
   4. Simpan 5 cadangan terakhir, hapus yang lebih lama.
   5. Set `dirty = false`, simpan `last_backup_at`.
4. Gagal (offline/error) → diam-diam coba lagi di jadwal berikutnya; indikator tampil "Menunggu sinkron".
5. **Pulihkan**: unduh cadangan terbaru → tutup database → ganti file → mulai ulang aplikasi. Selalu minta konfirmasi.
6. **Hapus ikut terhapus**: karena cadangan berupa snapshot, penghapusan data otomatis tercermin di cadangan berikutnya. Sediakan tombol terpisah "Hapus semua cadangan di Drive" bila pengguna ingin data lama juga hilang.

Tombol "Cadangkan sekarang" memicu langkah 3 secara manual.

> [!NOTE] Keputusan Terbuka: Cadangan Foto Identitas
> Cadangan snapshot saat ini hanya mencakup database SQLite (`.db.gz`). Apakah foto ikut cadangan Drive ditandai sebagai **keputusan terbuka (sementara tidak ikut)**.
> **Dampak:** foto hilang saat pulihkan di HP baru.

## 8. Pengingat (Notifikasi Lokal)
- `flutter_local_notifications` + `timezone` (zona `Asia/Jakarta` atau zona perangkat).
- Jadwal dibuat/diperbarui setiap kali ada occupancy/pembayaran berubah (hapus jadwal lama, buat ulang).
- Jenis: *sebelum keluar* (H-N dari `end_date`) dan *tagihan jatuh tempo* (H-N dari `due_day`).
- Android 13+: minta izin notifikasi. Android 12+: izin alarm tepat bila perlu.
- Berikan halaman panduan "Matikan penghemat baterai untuk KosM" (pada beberapa merek HP, notifikasi latar belakang bisa dibatasi).

## 8A. Ekspor Excel
- Package `excel` (Dart murni) + `share_plus`; berjalan penuh offline.
- Lembar: **Penyewa, Kamar, Hunian, Tagihan, Pembayaran, Ringkasan** (pemasukan per bulan per kos, tunggakan).
- Filter: kos (satu/semua) dan rentang tanggal. Angka harus sama dengan angka di layar (pakai query/use case yang sama).
- Berkas ditulis ke direktori sementara lalu dibagikan lewat share sheet.
- Proses pembuatan file besar dijalankan di isolate agar UI tidak macet.
- Foto TIDAK ikut ekspor Excel.

## 9. Penanganan Error
- Repository mengembalikan `Result<T>` (sukses/gagal) atau melempar `AppException` terpetakan.
- UI tidak pernah menampilkan stack trace.
- Operasi tulis dibungkus transaksi Drift (mis. catat masuk = buat occupancy + validasi kamar).

## 10. Keamanan & Privasi
- Data hanya di perangkat dan di Drive milik pengguna.
- Data identitas sensitif; foto KTP disimpan di folder privat aplikasi (bukan galeri); pertimbangkan kunci aplikasi (PIN/biometrik) sebagai peningkatan.
- Tidak ada analitik pihak ketiga.
- Rahasia (keystore, kunci) tidak masuk Git.
- Pertimbangkan penguncian aplikasi (PIN/biometrik) sebagai peningkatan setelah Fase 4.

## 11. Pengujian
| Jenis | Cakupan wajib |
|---|---|
| Unit | kapasitas & slot kamar, status kamar (kosong/sebagian/penuh/perbaikan), validasi occupancy baru, pembuatan tagihan otomatis (harian/mingguan/bulanan, idempoten), status tagihan, filter per kos, format Rupiah |
| Repository | CRUD dengan database Drift in-memory |
| Widget | layar utama tiap fitur (loading/kosong/error/data) |
| Manual | uji mode pesawat, matikan/hidupkan internet saat cadangan |

## 12. Migrasi Database
- `schemaVersion` dinaikkan setiap perubahan tabel; tulis `onUpgrade` dan test migrasi.
- Jangan ubah tabel yang sudah dirilis tanpa migrasi.
- Versi 1: skema awal 9 tabel.
- Versi 2: penambahan kolom `id_photo_path` (nullable) pada tabel `tenants` (tugas F1.4a).

## 13. Keputusan Produk
Sudah diputuskan (lihat `docs/prd.md` bagian 14):
- [x] Satu kamar boleh lebih dari satu penghuni (kapasitas per kamar)
- [x] Tarif fleksibel harian/mingguan/bulanan per penyewa, harga ditentukan pemilik
- [x] Biaya tambahan (listrik, air, denda, lainnya) lewat tabel `charges`
- [x] Ekspor Excel (.xlsx)
- [x] Multi-kos (`properties`)
- [x] Foto KTP/identitas penyewa tetap dipakai (opsional): kolom `id_photo_path` (nullable, path relatif), disimpan di folder privat aplikasi (bukan galeri), dikompres (maks 1280 px, JPEG kualitas 80, < 500 KB), file foto dihapus saat penyewa dihapus, foto TIDAK ikut ekspor Excel

Masih terbuka (asumsi sementara dipakai):
- [ ] Tagihan per penghuni atau per kamar? *(asumsi: per penghuni)*
- [ ] Denda otomatis atau manual? *(asumsi: manual)*
- [ ] Listrik/air manual atau dari meteran? *(asumsi: manual)*
- [ ] Jatuh tempo sewa harian/mingguan? *(asumsi: tanggal masuk)*
- [ ] Apakah foto ikut cadangan Drive? *(keputusan terbuka; sementara tidak ikut; dampak: foto hilang saat pulihkan di HP baru)*
