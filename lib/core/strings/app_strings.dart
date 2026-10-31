/// Centralized Indonesian UI strings for KosM.
/// Ensures consistent copy and avoids hardcoding in widgets.
/// Reference: docs/DESIGN.md & AGENTS.md section 4.
abstract class AppStrings {
  // Common
  static const String appName = 'KosM';
  static const String save = 'Simpan';
  static const String cancel = 'Batal';
  static const String delete = 'Hapus';
  static const String edit = 'Ubah';
  static const String retry = 'Coba Lagi';
  static const String loading = 'Memuat...';

  // Onboarding
  static const String onboardingTitle = 'Selamat Datang di KosM';
  static const String onboardingSubtitle =
      'Mulai kelola kos Anda secara rapi dan offline-first. Daftarkan properti kos pertama Anda.';
  static const String onboardingSaveButton = 'Simpan & Mulai Kelola';

  // Property (Kelola Kos)
  static const String manageProperties = 'Kelola Kos';
  static const String allProperties = 'Semua Kos';
  static const String selectProperty = 'Pilih Kos';
  static const String addProperty = 'Tambah Kos';
  static const String editProperty = 'Ubah Data Kos';
  static const String propertyNameLabel = 'Nama Kos';
  static const String propertyNameHint = 'Contoh: Kos Graha Melati';
  static const String propertyNameRequired = 'Nama kos wajib diisi';
  static const String propertyAddressLabel = 'Alamat Lengkap';
  static const String propertyAddressHint =
      'Contoh: Jl. Kaliurang KM 5, Gang Asri No. 12, Sleman';
  static const String propertyContactLabel =
      'Kontak Pengelola / Nomor WhatsApp';
  static const String propertyContactHint = 'Contoh: 081234567890';
  static const String emptyPropertiesTitle = 'Belum Ada Kos';
  static const String emptyPropertiesDesc =
      'Tambahkan properti kos pertama Anda untuk mulai mengelola portofolio dan kamar kos.';
  static const String deletePropertyTitle = 'Hapus Kos?';
  static const String deletePropertyConfirmMessage =
      'Menghapus kos ini akan menghapus data kamar yang terkait. Kos yang masih memiliki penghuni aktif tidak dapat dihapus. Tindakan ini tidak dapat dibatalkan.';
  static const String propertyCreatedSuccess = 'Kos berhasil ditambahkan.';
  static const String propertyUpdatedSuccess = 'Data kos berhasil diperbarui.';
  static const String propertyDeletedSuccess = 'Kos berhasil dihapus.';
  static const String activePropertyBadge = 'Kos Aktif';

  // More Menu (Tab Lainnya)
  static const String moreMenuTitle = 'Menu Lainnya';
  static const String moreMenuDesc =
      'Kelola kos, pengingat, cadangan, laporan, dan preferensi akun.';
  static const String comingSoon = 'Segera hadir';
  static const String menuManagePropertiesDesc =
      'Daftar properti, lokasi kos, dan informasi kontak';
  static const String menuReminders = 'Pengingat';
  static const String menuRemindersDesc =
      'Jadwal pengingat sewa dan tagihan jatuh tempo';
  static const String menuExport = 'Ekspor Laporan Excel';
  static const String menuExportDesc =
      'Unduh atau bagikan laporan keuangan dan penyewa';
  static const String menuBackup = 'Cadangan Google Drive';
  static const String menuBackupDesc =
      'Sinkronisasi snapshot database ke Google Drive';
  static const String menuProfile = 'Profil Pemilik';
  static const String menuProfileDesc =
      'Informasi nama, rekening penerima kuitansi, dan kontak';
  static const String menuPreferences = 'Preferensi';
  static const String menuPreferencesDesc =
      'Pengaturan tema, notifikasi, dan bahasa aplikasi';
}
