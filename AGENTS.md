# AGENTS.md — Aturan Kerja AI Agent untuk KosM

> Baca file ini PERTAMA di setiap sesi. Jika ada konflik antar dokumen, urutan prioritas:
> `AGENTS.md` > `docs/ARCHITECTURE.md` > `docs/DESIGN.md` > `docs/prd.md`.
> Keputusan produk terbaru ada di `docs/prd.md` bagian 14.

## 1. Tentang Proyek
KosM adalah aplikasi Android manajemen kos untuk pemilik kos. **Offline-first**: database lokal adalah sumber kebenaran, Google Drive hanya untuk cadangan. Tidak ada backend sendiri.

Dokumen acuan:
- `docs/prd.md` — apa yang dibangun
- `docs/ARCHITECTURE.md` — bagaimana dibangun (struktur, database, alur offline)
- `docs/DESIGN.md` — tampilan (warna, font, komponen)
- `docs/TASKS.md` — daftar tugas dan status

## 2. Stack (jangan diganti tanpa izin)
| Kebutuhan | Pilihan |
|---|---|
| Framework | Flutter (stable), Dart 3 |
| State management | flutter_riverpod (tanpa code generator) |
| Navigasi | go_router |
| Database lokal | drift (SQLite) |
| Notifikasi | flutter_local_notifications + timezone |
| Tugas latar belakang | workmanager |
| Cadangan | google_sign_in + googleapis (Drive, scope appdata) |
| Format | intl (locale `id_ID`) |
| Ekspor | excel + share_plus |

Menambah package baru: tanyakan dulu, jelaskan alasannya.

## 3. Perintah Wajib
```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # setelah ubah tabel drift
dart format .
flutter analyze        # harus 0 masalah
flutter test           # harus lulus
flutter run            # uji di HP/emulator
```

## 4. Aturan Kode
1. **Arsitektur feature-first** (lihat `docs/ARCHITECTURE.md`). Satu fitur = satu folder di `lib/features/`.
2. Alur layer: `presentation → domain (repository interface) → data`. UI **dilarang** mengakses database langsung.
3. **Semua data lewat repository**. Tulis ke database lokal dulu; jangan pernah memblokir UI karena internet.
4. Identifier kode memakai **bahasa Inggris**, teks tampilan ke pengguna memakai **Bahasa Indonesia**.
5. Teks UI tidak boleh di-hardcode di widget; taruh di `lib/l10n/` (ARB) atau `lib/core/strings/`.
6. Uang disimpan sebagai **integer Rupiah** (bukan double). Tampilkan lewat `formatRupiah()`.
7. Semua ID memakai UUID v4. Waktu disimpan UTC (ISO 8601); tampilkan waktu lokal.
8. Penghapusan data memakai **soft delete** (`deleted_at`), kecuali pembersihan eksplisit.
9. Satu file satu tanggung jawab; target < 300 baris per file. Widget besar dipecah.
10. Tidak ada `print`; pakai `debugPrint` atau logger. Tidak ada `!` (null-assert) tanpa alasan.
11. Setiap logika bisnis (status kamar, slot, status tagihan, pembuatan tagihan) wajib punya unit test.
12. Semua query data kos (kamar, hunian, tagihan, pembayaran) wajib memfilter **kos aktif** (`property_id`), kecuali mode "Semua Kos".
13. Status kamar, sisa slot, dan status tagihan adalah **nilai turunan**: dihitung, tidak disimpan.
14. Pembuatan tagihan otomatis harus **idempoten** (tidak boleh membuat tagihan ganda).

## 5. Aturan Tampilan
- **Wajib** memakai token dari `lib/core/theme/` (`AppColors`, `AppSpacing`, `AppRadius`, `AppTextStyles`). Dilarang menulis warna hex, ukuran font, atau padding angka mentah di widget fitur.
- Gunakan widget bersama di `lib/core/widgets/` (mis. `AppCard`, `StatusChip`, `EmptyState`, `SyncIndicator`). Jika komponen belum ada dan akan dipakai ≥ 2 kali, buat di sana.
- Ikuti `docs/DESIGN.md` untuk tata letak, status warna, dan gaya teks.
- Setiap layar wajib punya 4 kondisi: **loading, kosong, error, berisi data**.
- Area sentuh minimal 48×48 dp.

## 6. Aturan Offline (jangan dilanggar)
- Fitur inti harus berfungsi dengan mode pesawat.
- Jangan ada error "tidak ada koneksi" pada fitur inti.
- Operasi jaringan (Drive) hanya boleh berjalan di latar belakang dan gagal dengan tenang (coba lagi nanti).

## 7. Alur Kerja Setiap Tugas
1. Baca `docs/TASKS.md`, pilih tugas yang diminta.
2. **Buat rencana singkat dulu** (file yang akan dibuat/diubah) dan tunggu persetujuan.
3. Kerjakan **satu tugas** per sesi; jangan menyentuh fitur lain.
4. Jalankan `dart format .`, `flutter analyze`, `flutter test`.
5. Perbarui centang di `docs/TASKS.md`.
6. Beri ringkasan: apa yang dibuat, file yang berubah, cara mengujinya.

## 8. Git
- Cabang: `main` (stabil) ← `dev` ← `feat/<id>-<nama>` (mis. `feat/f1-daftar-penyewa`).
- Pesan commit: Conventional Commits, mis. `feat(tenant): tambah daftar penyewa`.
  Jenis: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`.
- Satu commit = satu perubahan logis. Jangan commit langsung ke `main`.
- Jangan pernah commit: `key.properties`, `*.jks`, `google-services.json` berisi rahasia, token, atau file `.env`.

## 9. Glosarium (konsistensi penamaan)
| Indonesia | Kode (Inggris) |
|---|---|
| Penyewa | `tenant` |
| Kamar | `room` |
| Hunian (penyewa menempati kamar) | `occupancy` |
| Pembayaran | `payment` |
| Pengingat | `reminder` |
| Cadangan | `backup` |
| Pemilik | `ownerProfile` |
| Kos / lokasi | `property` |
| Kapasitas kamar | `capacity` |
| Tagihan (sewa & biaya tambahan) | `charge` |
| Jenis tarif harian / mingguan / bulanan | `rateType`: `daily` / `weekly` / `monthly` |
| Listrik / Air / Denda | `electricity` / `water` / `penalty` |
| Jatuh tempo | `dueDay` / `dueDate` |
| Kosong / Terisi Sebagian / Penuh / Perbaikan | `vacant` / `partial` / `full` / `maintenance` |
| Lunas / Belum bayar / Menunggak | `paid` / `unpaid` / `overdue` |

## 10. Yang DILARANG
- Mengubah stack, struktur folder, atau skema database tanpa izin.
- Menambah fitur di luar `docs/prd.md`.
- Menulis ulang file yang tidak berkaitan dengan tugas.
- Menghapus atau melewati test supaya build lulus.
- Mengarang data/hasil; jika tidak yakin, **tanya**.
