# DESIGN.md — Design System KosM

> Sumber kebenaran tampilan. Dipakai oleh Stitch (desain) dan Antigravity (kode).
> Semua nilai di sini harus menjadi token di `lib/core/theme/`. Jangan menulis nilai mentah di widget fitur.

## 1. Karakter Desain
- **Bersih, tenang, terpercaya**, seperti aplikasi keuangan sederhana.
- Mudah dipakai pemilik kos non-teknis: teks jelas, tombol besar, sedikit langkah.
- Material 3, mode terang sebagai utama, mode gelap didukung.
- Kepadatan: lega (banyak ruang kosong), kartu dengan garis tepi tipis, bayangan sangat halus.

## 2. Warna

### Mode Terang
| Token | Hex | Pemakaian |
|---|---|---|
| `primary` | `#005C55` | Tombol utama, tab aktif, tautan |
| `onPrimary` | `#FFFFFF` | Teks di atas primary |
| `primaryContainer` | `#CCFBF1` | Latar chip/aksen lembut |
| `onPrimaryContainer` | `#134E4A` | Teks di atas primaryContainer |
| `accent` | `#F59E0B` | Sorotan kecil, badge penting |
| `background` | `#F8FAFC` | Latar layar |
| `surface` | `#FFFFFF` | Kartu, sheet, input |
| `outline` | `#E2E8F0` | Garis tepi kartu, pemisah |
| `textPrimary` | `#0F172A` | Teks utama |
| `textSecondary` | `#475569` | Teks pendukung |
| `textTertiary` | `#94A3B8` | Placeholder, label non-aktif |
| surfaceMuted| #F1F5F9 | Wadah dalam kartu, area input |
| surfaceMuted| #18233A |


### Mode Gelap
| Token | Hex |
|---|---|
| `primary` | `#2DD4BF` |
| `onPrimary` | `#042F2E` |
| `primaryContainer` | `#134E4A` |
| `background` | `#0B1220` |
| `surface` | `#111A2C` |
| `outline` | `#1F2A44` |
| `textPrimary` | `#F1F5F9` |
| `textSecondary` | `#CBD5E1` |
| `textTertiary` | `#64748B` |

### Warna Status (semantik, dipakai konsisten di seluruh aplikasi)
| Status | Teks/ikon | Latar chip |
|---|---|---|
| Penuh (`full`) | `#2563EB` | `#DBEAFE` |
| Terisi Sebagian (`partial`) | `#0891B2` | `#CFFAFE` |
| Kosong (`vacant`) | `#16A34A` | `#DCFCE7` |
| Perbaikan (`maintenance`) | `#64748B` | `#E2E8F0` |
| Lunas (`paid`) | `#16A34A` | `#DCFCE7` |
| Belum bayar (`unpaid`) | `#D97706` | `#FEF3C7` |
| Menunggak (`overdue`) | `#DC2626` | `#FEE2E2` |
| Error / hapus | `#DC2626` | `#FEE2E2` |

Aturan: status **tidak boleh hanya dibedakan warna**; selalu sertakan teks (dan ikon bila perlu).

## 3. Tipografi
Font: **Plus Jakarta Sans** (via `dibundel sebagai aset lokal di assets/fonts/`). Angka uang memakai tabular figures.

| Gaya | Ukuran/Berat | Pemakaian |
|---|---|---|
| `display` | 28 / 700 | Angka besar di ringkasan |
| `title` | 20 / 600 | Judul layar |
| `heading` | 16 / 600 | Judul kartu, nama penyewa |
| `body` | 14 / 400 | Isi teks |
| `bodyStrong` | 14 / 600 | Nilai penting |
| `label` | 12 / 500 | Chip, caption, label input |

Format teks:
- Uang: `Rp1.500.000` (titik pemisah ribuan, tanpa desimal).
- Tanggal: `15 Okt 2026`; periode: `Oktober 2026`.
- Nomor kamar: `Kamar 03`.

## 4. Spasi, Sudut, Elevasi
- Skala spasi (4pt): `xs 4`, `sm 8`, `md 12`, `lg 16`, `xl 24`, `xxl 32`.
- Padding layar: 16 horizontal. Jarak antar kartu: 12.
- Radius: kartu **16**, tombol/input **12**, chip **999** (pill), bottom sheet atas **24**.
- Elevasi: kartu tanpa bayangan, pakai garis `outline` 1 dp. Bayangan hanya pada FAB dan bottom sheet.

## 5. Ikon
- Material Symbols **Rounded**, ketebalan 400, ukuran 20 (dalam teks) / 24 (standar).
- Satu gaya ikon di seluruh aplikasi; jangan campur set ikon.

| Modul | Ikon |
|---|---|
| Beranda | `home` |
| Penyewa | `group` |
| Kamar | `meeting_room` |
| Pembayaran | `payments` |
| Pengingat | `notifications` |
| Cadangan | `cloud_upload` |
| Pengaturan | `settings` |
| Kelola Kos | `apartment` |
| Ekspor Excel | `table_view` |

## 6. Navigasi & Tata Letak
Bottom navigation (5 tab): **Beranda · Penyewa · Kamar · Bayar · Lainnya**
- *Beranda*: **pengalih kos** di AppBar (pilih kos tertentu atau "Semua Kos"), ringkasan (F1.2), pengingat terdekat, pintasan aksi cepat.
- *Penyewa*: daftar, cari/filter, detail (F1.x), catat masuk/keluar.
- *Kamar*: daftar kamar, status, kamar kosong (F2.x).
- *Bayar*: daftar tagihan (sewa & biaya tambahan), catat pembayaran, riwayat, status (F4.x).
- *Lainnya*: Pengingat, Kelola Kos, Ekspor Excel, Cadangan Google Drive, Profil Pemilik, Preferensi, Akun.

Pola layar:
- **AppBar** sederhana: judul kiri, aksi (cari/filter) kanan.
- **FAB** (`+`) untuk aksi tambah utama per tab (tambah penyewa/kamar/pembayaran).
- **Form** memakai layar penuh atau bottom sheet; tombol simpan menempel di bawah.
- **Indikator sinkron** kecil di AppBar Beranda dan di halaman Cadangan.

## 7. Komponen Standar (`lib/core/widgets/`)
| Komponen | Spesifikasi |
|---|---|
| `AppCard` | surface, radius 16, border outline 1dp, padding 16 |
| `StatusChip` | pill, latar & teks sesuai tabel status, label 12/500 |
| `PrimaryButton` | tinggi 52, radius 12, penuh lebar, primary |
| `SecondaryButton` | tinggi 52, outline primary, teks primary |
| `AppTextField` | radius 12, label di atas, error merah di bawah |
| `ListTileCard` | avatar inisial 40dp, judul heading, subjudul body secondary, chip di kanan |
| `SummaryTile` | angka `display`, label `label`, ikon di pojok |
| `EmptyState` | ikon besar 48 abu, judul, 1 kalimat, tombol aksi |
| `SyncIndicator` | ikon awan + teks: "Tersinkron", "Menunggu sinkron", "Offline" |
| `PropertySwitcher` | dropdown di AppBar: nama kos aktif + chevron; daftar kos + "Semua Kos"; bottom sheet di HP |
| `SlotIndicator` | teks "2/3 penghuni" + titik kecil terisi/kosong sebanyak kapasitas |
| `RateTypeChip` | chip netral (outline) "Harian" / "Mingguan" / "Bulanan" |
| `ChargeTile` | judul jenis tagihan (Sewa, Listrik, Air, Denda), nominal, sisa tagihan, `StatusChip`, jatuh tempo |
| `ConfirmDialog` | judul jelas, tombol destruktif merah, tombol batal netral |
| `AppSnackbar` | mengambang, sudut 12, durasi 3 detik |

## 8. Status Sinkron (offline/online)
| Kondisi | Ikon | Teks | Warna |
|---|---|---|---|
| Tersinkron | `cloud_done` | Tersinkron | `#16A34A` |
| Menunggu | `cloud_upload` | Menunggu sinkron | `#D97706` |
| Offline | `cloud_off` | Offline | `#64748B` |
| Gagal | `cloud_sync` + `!` | Gagal, coba lagi | `#DC2626` |

Mode offline **bukan error**: tampilkan hanya lencana kecil, jangan blokir layar.

## 9. Gaya Bahasa (UI Copy)
- Bahasa Indonesia sehari-hari, sopan, singkat. Gunakan "Anda" jarang; lebih sering kalimat perintah langsung.
- Tombol berupa kata kerja: **Simpan**, **Tambah Penyewa**, **Catat Pembayaran**.
- Pesan kosong ramah: "Belum ada penyewa. Tambahkan penyewa pertama Anda."
- Pesan error menjelaskan solusi, bukan kode: "Data belum tersimpan. Coba lagi."
- Konfirmasi hapus menyebut dampaknya.

## 10. Aksesibilitas
- Kontras teks minimal 4.5:1.
- Area sentuh minimal 48×48 dp.
- Mendukung ukuran font sistem hingga 130% tanpa teks terpotong.
- Semua ikon tombol punya `tooltip`/`semanticLabel`.

## 11. Gerak
- Transisi 200–250 ms, kurva `easeOutCubic`. Tanpa animasi berlebihan.
- Skeleton shimmer ringan untuk loading; hindari spinner layar penuh.

## 12. Pemetaan ke Kode
```
lib/core/theme/
├─ app_colors.dart       # token warna (terang/gelap/status)
├─ app_text_styles.dart  # gaya teks
├─ app_spacing.dart      # spasi
├─ app_radius.dart       # radius
└─ app_theme.dart        # ThemeData terang & gelap (Material 3)
lib/core/widgets/        # komponen standar bagian 7
```
