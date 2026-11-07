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

  // Tenant (Penyewa)
  static const String tenantsTitle = 'Penyewa';
  static const String searchTenantHint = 'Cari nama, kamar, no. HP...';
  static const String filterAll = 'Semua';
  static const String filterActive = 'Aktif';
  static const String filterOverdue = 'Menunggak';
  static const String filterEnded = 'Keluar';
  static const String statusOverdue = 'Menunggak';
  static const String statusActive = 'Aktif';
  static const String statusEnded = 'Keluar';
  static const String statusUnassigned = 'Belum Menghuni';
  static const String emptyTenantsTitle = 'Belum Ada Penyewa';
  static const String emptyTenantsDesc =
      'Tambahkan penyewa pertama untuk mulai mengelola hunian kos.';
  static const String noMatchingTenantsTitle = 'Tidak Ada Penyewa yang Cocok';
  static const String noMatchingTenantsDesc =
      'Coba ubah kata kunci pencarian atau ganti filter status.';
  static const String clearSearch = 'Hapus Pencarian';
  static const String addTenant = 'Tambah Penyewa';
  static const String loadTenantsError =
      'Gagal memuat data penyewa. Silakan coba lagi.';
  static const String roomPrefix = 'Kamar';
  static const String noRoomAssigned = 'Belum ada kamar';
  static const String addTenantTitle = 'Tambah Penyewa';
  static const String editTenantTitle = 'Ubah Data Penyewa';
  static const String tenantDetailTitle = 'Detail Penyewa';
  static const String tenantNameLabel = 'Nama Lengkap';
  static const String tenantNameHint = 'Contoh: Budi Santoso';
  static const String tenantPhoneLabel = 'Nomor WhatsApp / HP';
  static const String tenantPhoneHint = '81234567890';
  static const String tenantNoteLabel = 'Catatan';
  static const String tenantNoteHint =
      'Catatan tambahan tentang penyewa (opsional)';
  static const String tenantSavedSuccess = 'Penyewa disimpan';
  static const String tenantDeletedSuccess = 'Penyewa berhasil dihapus';
  static const String saveTenant = 'Simpan Penyewa';
  static const String deleteTenantTitle = 'Hapus Penyewa?';
  static const String deleteTenantConfirmMessage =
      'Penyewa akan dihapus dari daftar. Riwayat hunian dan pembayarannya tetap tersimpan.';
  static const String cannotDeleteTenantTitle = 'Penyewa Tidak Bisa Dihapus';
  static const String cannotDeleteTenantMessage =
      'Penyewa ini masih menempati kamar aktif. Catat keluar terlebih dahulu sebelum menghapus.';
  static const String tenantNotFoundTitle = 'Penyewa Tidak Ditemukan';
  static const String tenantNotFoundDesc =
      'Data penyewa tidak ditemukan atau sudah dihapus.';
  static const String backToTenantList = 'Kembali ke Daftar';
  static const String infoSectionTitle = 'Informasi Kontak';
  static const String occupancySectionTitle = 'Riwayat Hunian';
  static const String paymentSectionTitle = 'Riwayat Pembayaran';
  static const String noOccupancyTitle = 'Belum Ada Riwayat Hunian';
  static const String noOccupancyDesc =
      'Pencatatan kamar dan hunian akan tersedia di Fase 2.';
  static const String noPaymentTitle = 'Belum Ada Riwayat Pembayaran';
  static const String noPaymentDesc =
      'Pencatatan tagihan dan pembayaran akan tersedia di Fase 2.';
  static const String understandAction = 'Mengerti';
  static const String noteMaxLengthExceeded = 'Catatan maksimal 300 karakter.';

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
