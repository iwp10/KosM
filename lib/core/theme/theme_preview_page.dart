import 'package:flutter/material.dart';

import '../widgets/widgets.dart';
import 'theme.dart';

/// Temporary visual preview screen (debug mode) for KosM Design System.
/// Showcases all tokens, typography, colors, and components.
class ThemePreviewPage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const ThemePreviewPage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<ThemePreviewPage> createState() => _ThemePreviewPageState();
}

class _ThemePreviewPageState extends State<ThemePreviewPage> {
  String _activePropertyId = 'all';
  RateType _selectedRateType = RateType.monthly;
  bool _isLoading = false;
  final TextEditingController _textController = TextEditingController(
    text: 'Budi Santoso',
  );

  final List<PropertyItem> _dummyProperties = const [
    PropertyItem(
      id: 'kos_1',
      name: 'Kos Melati',
      address: 'Jl. Melati No. 12, Sleman',
    ),
    PropertyItem(
      id: 'kos_2',
      name: 'Kos Mawar Indah',
      address: 'Jl. Mawar No. 45, Bantul',
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final kosM = context.kosMColors;

    return Scaffold(
      appBar: AppBar(
        title: PropertySwitcher(
          activePropertyId: _activePropertyId,
          properties: _dummyProperties,
          onSelected: (id) => setState(() => _activePropertyId = id),
        ),
        actions: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm),
            child: SyncIndicator(state: SyncState.synced),
          ),
          IconButton(
            icon: Icon(
              widget.isDarkMode
                  ? Icons.light_mode_rounded
                  : Icons.dark_mode_rounded,
            ),
            tooltip: 'Ubah Tema',
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.screenHorizontal,
          vertical: AppSpacing.lg,
        ),
        children: [
          // 1. Tipografi Section
          _buildSectionHeader(title: '1. Tipografi (Plus Jakarta Sans)'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Display 28: Rp1.500.000',
                  style: AppTextStyles.display.copyWith(
                    color: kosM.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Title 20: Ringkasan Kos',
                  style: AppTextStyles.title.copyWith(color: kosM.textPrimary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Heading 16: Kamar 03 — Lantai 1',
                  style: AppTextStyles.heading.copyWith(
                    color: kosM.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Body 14: Pencatatan sewa kamar dan tagihan bulanan.',
                  style: AppTextStyles.body.copyWith(color: kosM.textSecondary),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'BodyStrong 14: Jatuh Tempo 15 Okt 2026',
                  style: AppTextStyles.bodyStrong.copyWith(
                    color: kosM.textPrimary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Label 12: INFORMASI HUNIAN',
                  style: AppTextStyles.label.copyWith(color: kosM.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 2. Status Chips Section
          _buildSectionHeader(title: '2. Status Chip Semantik'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Status Kamar:',
                  style: AppTextStyles.label.copyWith(
                    color: kosM.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StatusChip.fromType(StatusType.vacant),
                    StatusChip.fromType(StatusType.partial),
                    StatusChip.fromType(StatusType.full),
                    StatusChip.fromType(StatusType.maintenance),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Status Tagihan & Pembayaran:',
                  style: AppTextStyles.label.copyWith(
                    color: kosM.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    StatusChip.fromType(StatusType.paid),
                    StatusChip.fromType(StatusType.unpaid),
                    StatusChip.fromType(StatusType.overdue),
                    StatusChip.fromType(StatusType.error),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Status Sinkronisasi:',
                  style: AppTextStyles.label.copyWith(
                    color: kosM.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const Wrap(
                  spacing: AppSpacing.md,
                  runSpacing: AppSpacing.sm,
                  children: [
                    SyncIndicator(state: SyncState.synced),
                    SyncIndicator(state: SyncState.waiting),
                    SyncIndicator(state: SyncState.offline),
                    SyncIndicator(state: SyncState.failed),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 3. Tombol Section
          _buildSectionHeader(title: '3. Tombol (Tinggi 52dp)'),
          AppCard(
            child: Column(
              children: [
                PrimaryButton(
                  label: 'Simpan Data Penyewa',
                  icon: Icons.save_rounded,
                  isLoading: _isLoading,
                  onPressed: () {
                    setState(() => _isLoading = true);
                    Future.delayed(const Duration(seconds: 2), () {
                      if (mounted) setState(() => _isLoading = false);
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                SecondaryButton(
                  label: 'Ubah Data Kamar',
                  icon: Icons.edit_rounded,
                  onPressed: () {
                    AppSnackbar.show(
                      context,
                      message: 'Tombol ubah data ditekan',
                      type: SnackbarType.info,
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(label: 'Batal', onPressed: () {}),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: PrimaryButton(label: 'Lanjut', onPressed: () {}),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 4. Form & Input Section
          _buildSectionHeader(title: '4. Form & AppTextField'),
          AppCard(
            child: Column(
              children: [
                AppTextField(
                  label: 'Nama Lengkap Penyewa',
                  hintText: 'Contoh: Budi Santoso',
                  controller: _textController,
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppTextField(
                  label: 'Nomor WhatsApp / HP',
                  hintText: '0812xxxxxxxx',
                  keyboardType: TextInputType.phone,
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                const SizedBox(height: AppSpacing.lg),
                const AppTextField(
                  label: 'Harga Sewa Kesepakatan',
                  hintText: 'Rp0',
                  keyboardType: TextInputType.number,
                  errorText: 'Nominal wajib diisi',
                  prefixIcon: Icon(Icons.payments_outlined),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 5. Indikator Slot & Jenis Tarif
          _buildSectionHeader(title: '5. SlotIndicator & RateTypeChip'),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kapasitas & Penghuni Kamar:',
                  style: AppTextStyles.label.copyWith(
                    color: kosM.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                const SlotIndicator(occupied: 0, capacity: 3),
                const SizedBox(height: AppSpacing.sm),
                const SlotIndicator(occupied: 2, capacity: 3),
                const SizedBox(height: AppSpacing.sm),
                const SlotIndicator(occupied: 3, capacity: 3),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Pilihan Jenis Tarif:',
                  style: AppTextStyles.label.copyWith(
                    color: kosM.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: AppSpacing.sm,
                  children: [
                    RateTypeChip(
                      rateType: RateType.daily,
                      isSelected: _selectedRateType == RateType.daily,
                      onSelected: (type) =>
                          setState(() => _selectedRateType = type),
                    ),
                    RateTypeChip(
                      rateType: RateType.weekly,
                      isSelected: _selectedRateType == RateType.weekly,
                      onSelected: (type) =>
                          setState(() => _selectedRateType = type),
                    ),
                    RateTypeChip(
                      rateType: RateType.monthly,
                      isSelected: _selectedRateType == RateType.monthly,
                      onSelected: (type) =>
                          setState(() => _selectedRateType = type),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 6. Dialog & Notifikasi SnackBar
          _buildSectionHeader(title: '6. Dialog & SnackBar'),
          AppCard(
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Dialog Biasa',
                        onPressed: () {
                          ConfirmDialog.show(
                            context: context,
                            title: 'Simpan Perubahan?',
                            message:
                                'Data kamar akan diperbarui ke database lokal.',
                            confirmLabel: 'Simpan',
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Dialog Hapus',
                        onPressed: () {
                          ConfirmDialog.show(
                            context: context,
                            title: 'Hapus Penyewa?',
                            message: 'Penyewa yang dihapus tidak dapat dipulihkan kembali.',
                            confirmLabel: 'Hapus',
                            isDestructive: true,
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: SecondaryButton(
                        label: 'Snack Sukses',
                        onPressed: () {
                          AppSnackbar.show(
                            context,
                            message: 'Data penyewa berhasil disimpan!',
                            type: SnackbarType.success,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: SecondaryButton(
                        label: 'Snack Error',
                        onPressed: () {
                          AppSnackbar.show(
                            context,
                            message: 'Terjadi kesalahan saat menyimpan.',
                            type: SnackbarType.error,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // 7. Empty State Component
          _buildSectionHeader(title: '7. EmptyState'),
          AppCard(
            child: EmptyState(
              icon: Icons.people_outline_rounded,
              title: 'Belum Ada Penyewa',
              description: 'Tambahkan penyewa pertama Anda untuk mulai mengelola hunian kos.',
              actionLabel: 'Tambah Penyewa',
              onAction: () {
                AppSnackbar.show(
                  context,
                  message: 'Aksi Tambah Penyewa diklik',
                  type: SnackbarType.info,
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title}) {
    final kosM = context.kosMColors;

    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.sm,
        left: AppSpacing.xs,
      ),
      child: Text(
        title,
        style: AppTextStyles.heading.copyWith(color: kosM.textPrimary),
      ),
    );
  }
}
