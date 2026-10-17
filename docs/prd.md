# PRD — KosM (Aplikasi Manajemen Kos)

| | |
|---|---|
| **Nama Produk** | KosM |
| **Versi Dokumen** | 0.2 (Draft) |
| **Status** | Perencanaan |
| **Platform** | Mobile (Android), offline-first |
| **Bahasa Aplikasi** | Bahasa Indonesia |

---

## 1. Ringkasan

KosM adalah aplikasi manajemen kos untuk pemilik kos skala kecil–menengah. Aplikasi membantu mencatat penyewa, kamar, keluar-masuk penghuni, dan pembayaran sewa, tanpa perlu buku catatan atau spreadsheet manual.

Prinsip utama: **offline-first**. Semua fitur inti bisa dipakai tanpa internet. Data disimpan di perangkat, lalu dikirim otomatis ke Google Drive saat online sebagai cadangan.

## 2. Latar Belakang & Masalah

Banyak pemilik kos masih mencatat secara manual (buku tulis, Excel, atau chat WhatsApp). Akibatnya:

- Data penyewa dan kamar tersebar dan sulit dicari.
- Sulit melihat kamar mana yang kosong dan siapa yang belum bayar.
- Tagihan jatuh tempo sering terlewat.
- Data hilang jika buku atau HP rusak/hilang.
- Sinyal di area kos tidak selalu stabil, sehingga aplikasi yang wajib online merepotkan.

## 3. Tujuan & Non-Tujuan

### Tujuan
1. Pemilik kos dapat melihat kondisi kos (penyewa, kamar, pembayaran) dalam satu aplikasi.
2. Pencatatan penyewa, kamar, masuk/keluar, dan pembayaran bisa dilakukan penuh tanpa internet.
3. Pemilik mendapat pengingat otomatis untuk tagihan dan penyewa yang akan keluar.
4. Data aman lewat cadangan otomatis ke Google Drive pemilik.

### Non-Tujuan (di luar cakupan versi awal)
- Portal/aplikasi khusus untuk penyewa.
- Pembayaran online (payment gateway).
- Fitur multi-pengguna/staf dengan hak akses berbeda.
- Iklan kos / pencarian kos untuk publik.

## 4. Target Pengguna

**Persona utama: Pemilik kos**
- Mengelola 5–50 kamar di satu atau lebih lokasi kos, biasanya sendiri atau dibantu keluarga.
- Menggunakan smartphone Android sehari-hari.
- Literasi teknologi dasar–menengah; butuh antarmuka sederhana.
- Kadang berada di area dengan sinyal lemah.

## 5. Ruang Lingkup Fitur & Fase Rilis

| Fase | Modul | Prioritas |
|---|---|---|
| 1 | Kelola Kos (multi-lokasi) | Wajib (MVP) |
| 1 | Daftar Penyewa | Wajib (MVP) |
| 2 | Data Kamar & Kos | Wajib |
| 2 | Catat Masuk & Keluar | Wajib |
| 2 | Catat Bayar Sewa | Wajib |
| 3 | Pengingat Penyewa | Penting |
| 3 | Pakai Tanpa Internet | Penting |
| 3 | Cadangan Google Drive | Penting |
| 4 | Akun & Pengaturan | Pelengkap |
| 4 | Ekspor Laporan Excel | Pelengkap |

> Catatan: karena prinsip offline-first, penyimpanan lokal di perangkat menjadi fondasi sejak Fase 1. Modul "Pakai Tanpa Internet" di Fase 3 mencakup penyempurnaan sinkronisasi, bukan menambahkan kemampuan offline dari nol.

---

## 6. Kebutuhan Fungsional

### 6.1 Daftar Penyewa (Fase 1)

**Tujuan:** pusat data seluruh penyewa kos.

| ID | Sub Fitur | Deskripsi |
|---|---|---|
| F1.1 | Daftar Semua Penyewa | Menampilkan semua penyewa (aktif dan sudah keluar) dalam bentuk daftar. |
| F1.2 | Ringkasan Kos Sekilas | Kartu ringkasan di atas: jumlah penyewa aktif, kamar kosong/tersedia, tagihan belum lunas, untuk kos terpilih atau gabungan semua kos. |
| F1.3 | Cari & Saring Penyewa | Pencarian berdasarkan nama/nomor kamar; filter status (aktif, keluar, menunggak). |
| F1.4 | Detail & Kelola Penyewa* | Tambah, ubah, hapus penyewa; lihat profil (nama, nomor HP, kamar, tanggal masuk, catatan). |

**Kriteria penerimaan:**
- Penyewa baru dapat ditambahkan kurang dari 1 menit tanpa internet.
- Pencarian menampilkan hasil seketika saat mengetik.

### 6.2 Data Kamar & Kos (Fase 2)

| ID | Sub Fitur | Deskripsi |
|---|---|---|
| F2.1 | Daftar Kamar | Daftar semua kamar beserta kapasitas, sisa slot, tarif acuan, dan fasilitas singkat. |
| F2.2 | Status Kamar | Status per kamar: kosong, terisi sebagian (masih ada slot), penuh, perbaikan. |
| F2.3 | Lihat Kamar Tersedia | Tampilan cepat kamar kosong dan kamar yang masih punya slot, beserta sisa slot. |
| F2.4 | Kelola Kamar | Tambah, ubah, hapus kamar; atur nomor, **kapasitas** (jumlah penghuni maksimal), tarif acuan (harian/mingguan/bulanan), fasilitas. |

**Kriteria penerimaan:**
- Status kamar otomatis berubah saat penyewa dicatat masuk atau keluar.
- Kamar yang masih berpenghuni tidak dapat dihapus.
- Penyewa baru tidak dapat dimasukkan ke kamar yang sudah penuh atau sedang diperbaiki.
- Satu kamar dapat dihuni lebih dari satu penyewa sesuai kapasitasnya.

### 6.3 Catat Masuk & Keluar (Fase 2)

| ID | Sub Fitur | Deskripsi |
|---|---|---|
| F3.1 | Catat Penyewa Masuk | Hubungkan penyewa ke kamar (selama slot tersedia); isi tanggal masuk, jenis tarif (harian/mingguan/bulanan), harga per satuan sesuai kesepakatan, lama sewa, dan jatuh tempo. |
| F3.2 | Catat Penyewa Keluar | Catat tanggal keluar; kamar otomatis menjadi kosong. |
| F3.3 | Riwayat Masuk & Keluar | Log kronologis semua kejadian masuk/keluar per penyewa dan per kamar. |
| F3.4 | Pindah Kamar / Perpanjang Sewa* | Memindahkan penyewa ke kamar lain atau memperpanjang masa sewa (perpanjangan membuat tagihan sewa baru). |

**Aturan tarif fleksibel:**
- Setiap hunian punya jenis tarif sendiri: harian, mingguan, atau bulanan.
- Harga per satuan ditentukan pemilik untuk tiap penyewa; tidak harus sama dengan tarif acuan kamar.
- Contoh: 3 hari × Rp80.000 = Rp240.000; 2 minggu × Rp450.000 = Rp900.000.
- Sewa harian/mingguan menghasilkan satu tagihan untuk seluruh lama sewa; sewa bulanan menghasilkan tagihan berulang tiap bulan.

### 6.4 Catat Bayar Sewa (Fase 2)

| ID | Sub Fitur | Deskripsi |
|---|---|---|
| F4.1 | Catat Pembayaran | Input pembayaran untuk satu tagihan: penyewa, tagihan, nominal, tanggal, metode (tunai/transfer). |
| F4.2 | Riwayat Pembayaran | Daftar pembayaran per penyewa dan per bulan. |
| F4.3 | Status Lunas / Belum Bayar | Penanda otomatis lunas, belum bayar, atau menunggak per tagihan. |
| F4.4 | Bukti/Kuitansi Pembayaran* | Membuat kuitansi sederhana yang bisa dibagikan (mis. via WhatsApp). |
| F4.5 | Tagihan Sewa Otomatis | Tagihan sewa dibuat otomatis dari jenis tarif hunian (satu tagihan untuk harian/mingguan, berulang tiap bulan untuk bulanan), tanpa internet. |
| F4.6 | Biaya Tambahan | Catat biaya tambahan per penyewa: listrik, air, denda, atau lainnya, lengkap dengan nominal dan jatuh tempo; ikut dihitung dalam status lunas/menunggak. |

**Kriteria penerimaan:**
- Status pembayaran dihitung dari tanggal jatuh tempo dan pembayaran yang tercatat.
- Pembayaran sebagian (cicilan) bisa dicatat dan sisa tagihan terlihat.

### 6.5 Pengingat Penyewa (Fase 3)

| ID | Sub Fitur | Deskripsi |
|---|---|---|
| F5.1 | Pengingat Sebelum Keluar | Notifikasi ke pemilik sebelum masa sewa penyewa berakhir. |
| F5.2 | Pengingat Tagihan Jatuh Tempo | Notifikasi saat tagihan mendekati/melewati jatuh tempo. |
| F5.3 | Daftar Pengingat Mendatang | Halaman berisi seluruh pengingat yang akan datang. |

**Kriteria penerimaan:**
- Notifikasi berjalan lewat penjadwalan lokal, sehingga tetap muncul tanpa internet.
- Pemilik dapat mengatur waktu pengingat (mis. H-3, H-1).

### 6.6 Pakai Tanpa Internet (Fase 3)

| ID | Sub Fitur | Deskripsi |
|---|---|---|
| F6.1 | Tetap Bisa Dipakai Offline | Seluruh fitur inti berfungsi tanpa koneksi. |
| F6.2 | Simpan di Perangkat | Semua data disimpan di database lokal perangkat. |
| F6.3 | Kirim Otomatis Saat Online | Perubahan yang dibuat saat offline otomatis dikirim/disinkronkan begitu koneksi tersedia. |

**Kriteria penerimaan:**
- Tidak ada fitur inti yang menampilkan error karena tidak ada internet.
- Indikator status sinkronisasi terlihat (mis. "Menunggu sinkron", "Tersinkron").
- Sinkronisasi dapat dilanjutkan jika terputus di tengah jalan.

### 6.7 Cadangan Google Drive (Fase 3)

| ID | Sub Fitur | Deskripsi |
|---|---|---|
| F7.1 | Sambungkan Google Drive | Pemilik menghubungkan akun Google miliknya. |
| F7.2 | Simpan Cadangan Otomatis | Cadangan berkala otomatis saat online (mis. harian/mingguan). |
| F7.3 | Hapus Ikut Terhapus | Penghapusan data di aplikasi ikut dihapus dari cadangan agar konsisten (perlu konfirmasi pengguna). |
| F7.4 | Pulihkan dari Cadangan* | Mengembalikan data dari cadangan terakhir di perangkat baru. |

**Kriteria penerimaan:**
- Hanya data milik pemilik yang disimpan di Drive pemilik sendiri (akses minimal).
- Pengguna bisa memutus koneksi Google Drive kapan saja.

### 6.8 Akun & Pengaturan (Fase 4)

| ID | Sub Fitur | Deskripsi |
|---|---|---|
| F8.1 | Masuk & Daftar Akun | Autentikasi pemilik (mis. Google Sign-In); aplikasi tetap bisa dibuka offline setelah login pertama. |
| F8.2 | Profil Pemilik Kos | Nama pemilik, nama kos, alamat, nomor kontak. |
| F8.3 | Preferensi Aplikasi | Tema, format mata uang/tanggal, waktu pengingat, frekuensi cadangan. |

### 6.9 Kelola Kos / Multi-Lokasi (Fase 1)

| ID | Sub Fitur | Deskripsi |
|---|---|---|
| F9.1 | Daftar Kos | Pemilik dapat memiliki lebih dari satu kos (lokasi berbeda), masing-masing dengan nama, alamat, kontak. |
| F9.2 | Tambah/Ubah/Hapus Kos | Hapus ditolak jika masih ada penghuni aktif. |
| F9.3 | Pilih Kos Aktif | Pengalih kos di Beranda; daftar kamar, hunian, tagihan, dan pembayaran mengikuti kos terpilih. |
| F9.4 | Tampilan Gabungan | Opsi "Semua Kos" untuk ringkasan di Beranda dan laporan. |

**Kriteria penerimaan:**
- Onboarding membuat kos pertama; kos berikutnya bisa ditambah kapan saja.
- Data antar kos tidak tercampur kecuali pada tampilan "Semua Kos".
- Seluruh kos masuk dalam satu cadangan Google Drive.

### 6.10 Ekspor Laporan Excel (Fase 4)

| ID | Sub Fitur | Deskripsi |
|---|---|---|
| F10.1 | Ekspor ke Excel (.xlsx) | Lembar: Penyewa, Kamar, Hunian, Tagihan, Pembayaran. |
| F10.2 | Filter Laporan | Pilih satu kos atau semua kos, dan rentang tanggal. |
| F10.3 | Ringkasan Keuangan | Pemasukan per bulan dan per kos, serta tunggakan. |
| F10.4 | Bagikan File | Simpan atau bagikan lewat WhatsApp, email, atau Drive (share sheet). |

**Kriteria penerimaan:**
- Ekspor berjalan tanpa internet.
- Angka di Excel sama dengan angka di layar aplikasi.

---

## 7. Kebutuhan Non-Fungsional

| Aspek | Kebutuhan |
|---|---|
| **Offline-first** | Semua operasi baca/tulis dilakukan ke database lokal terlebih dahulu. |
| **Performa** | Buka aplikasi < 3 detik; daftar 100+ penyewa tetap lancar. |
| **Keamanan** | Data lokal tidak dibagikan ke pihak ketiga; cadangan hanya ke Drive pemilik; koneksi memakai HTTPS. |
| **Privasi** | Data penyewa (nama, HP) hanya untuk keperluan pengelolaan kos; mematuhi prinsip perlindungan data pribadi. |
| **Keandalan** | Data tidak hilang saat aplikasi tertutup mendadak; sinkronisasi dapat dilanjutkan. |
| **Kegunaan** | Antarmuka sederhana, teks Bahasa Indonesia, alur utama maksimal 3 ketuk. |
| **Kompatibilitas** | Android 8.0+ (disesuaikan saat implementasi). |

## 8. Alur Pengguna Utama

1. **Onboarding:** pemilik masuk → isi profil pemilik → buat kos pertama → tambah kamar (dengan kapasitas).
2. **Tambah penyewa:** buka Daftar Penyewa → tambah → pilih kamar → catat masuk.
3. **Catat pembayaran:** buka tagihan penyewa → Catat Pembayaran → status tagihan otomatis berubah.
4. **Penyewa keluar:** Catat Penyewa Keluar → kamar menjadi kosong → tercatat di riwayat.
5. **Cadangan:** online → cadangan otomatis ke Google Drive.

## 9. Model Data (Garis Besar)

- **Pemilik** (id, nama, kontak)
- **Kos** (id, nama, alamat, kontak): pemilik bisa punya lebih dari satu
- **Kamar** (id, kos_id, nomor, kapasitas, tarif_acuan, fasilitas, sedang_perbaikan)
- **Penyewa** (id, nama, no_hp, catatan)
- **Hunian** (id, penyewa_id, kamar_id, tanggal_masuk, tanggal_selesai_rencana, tanggal_keluar, jenis_tarif [harian|mingguan|bulanan], harga_per_satuan, lama_sewa, jatuh_tempo, status)
- **Tagihan** (id, hunian_id, jenis [sewa|listrik|air|denda|lainnya], keterangan, nominal, periode_mulai, periode_selesai, jatuh_tempo)
- **Pembayaran** (id, tagihan_id, nominal, tanggal, metode, catatan)
- **Pengingat** (id, jenis, referensi_id, waktu)
- **Pengaturan** (kunci, nilai)

Status kamar, sisa slot, dan status tagihan (lunas/belum bayar/menunggak) **dihitung dari data di atas, tidak disimpan**.

## 10. Usulan Teknologi

> Usulan, bisa disesuaikan.

| Komponen | Usulan |
|---|---|
| Framework | Flutter |
| Database lokal | SQLite (via Drift) atau Isar |
| State management | Riverpod |
| Notifikasi lokal | flutter_local_notifications |
| Cadangan | Google Drive API (appDataFolder atau folder khusus) |
| Ekspor Excel | excel + share_plus |
| Autentikasi | Google Sign-In |
| Deteksi koneksi | connectivity_plus |

## 11. Metrik Keberhasilan

- Pemilik dapat menyelesaikan alur "tambah penyewa + catat masuk + catat bayar" tanpa bantuan.
- 100% fitur inti berjalan tanpa internet.
- Cadangan Google Drive berhasil ≥ 95% saat koneksi tersedia.
- Tidak ada kehilangan data pada uji pemulihan dari cadangan.

## 12. Risiko & Mitigasi

| Risiko | Mitigasi |
|---|---|
| Konflik data saat sinkronisasi/pemulihan | Gunakan penanda waktu ubah dan aturan penyelesaian konflik yang jelas. |
| Notifikasi tidak muncul karena penghemat baterai (OEM Android) | Panduan izin di dalam aplikasi untuk mengecualikan dari penghemat baterai. |
| Data hilang jika HP rusak sebelum sempat cadangan | Pengingat untuk menyambungkan Google Drive saat onboarding. |
| Penghapusan ikut terhapus di cadangan tidak disengaja | Dialog konfirmasi dan opsi hapus lokal saja. |
| Tagihan otomatis ganda atau terlewat | Pembuatan tagihan idempoten (kunci unik per hunian+periode), dijalankan saat aplikasi dibuka dan harian, dengan unit test. |
| Slot kamar dan status tidak konsisten | Status dan sisa slot dihitung dari data hunian (turunan), bukan disimpan. |

## 13. Rencana Rilis

| Fase | Fokus | Hasil |
|---|---|---|
| 1 | Kelola Kos + Daftar Penyewa + fondasi database lokal | MVP awal |
| 2 | Kamar, masuk/keluar, pembayaran | Aplikasi inti lengkap |
| 3 | Pengingat, sinkron offline→online, cadangan Drive | Andal & aman |
| 4 | Akun, pengaturan, ekspor Excel | Rilis publik |

## 14. Keputusan & Pertanyaan Terbuka

### Keputusan yang sudah diambil
| # | Topik | Keputusan |
|---|---|---|
| 1 | Penghuni per kamar | Satu kamar bisa dihuni lebih dari satu orang; kamar punya **kapasitas**. |
| 2 | Tarif | Fleksibel: harian, mingguan, atau bulanan per penyewa; harga ditentukan pemilik. |
| 3 | Biaya tambahan | Ada: listrik, air, denda, dan lainnya. |
| 4 | Ekspor laporan | Excel (.xlsx). |
| 5 | Banyak kos | Didukung; pemilik punya 2 kos di lokasi berbeda. |

### Pertanyaan baru (asumsi sementara dipakai sampai diputuskan)
1. Kamar berpenghuni banyak: tagihan **per penghuni** atau **per kamar**? *(asumsi: per penghuni)*
2. Denda keterlambatan: otomatis atau dicatat manual? *(asumsi: manual)*
3. Listrik/air: nominal diisi manual atau dihitung dari meteran? *(asumsi: manual)*
4. Sewa harian/mingguan: jatuh tempo kapan? *(asumsi: pada tanggal masuk, bayar di muka)*
5. Apakah satu penyewa boleh tinggal di kos berbeda sekaligus? *(asumsi: boleh, lewat hunian terpisah)*

---

*Tanda (\*) pada sub fitur berarti item ke-4 yang tidak terlihat di peta fitur ("Lihat semua") dan merupakan asumsi; sesuaikan dengan rencana sebenarnya.*
