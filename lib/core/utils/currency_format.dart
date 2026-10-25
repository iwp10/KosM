import 'package:intl/intl.dart';

/// Formats an integer amount in Rupiah without decimals and without space,
/// e.g. 1500000 -> "Rp1.500.000", 0 -> "Rp0", -50000 -> "-Rp50.000".
String formatRupiah(int amount) {
  final formatter = NumberFormat('#,###', 'id_ID');
  if (amount < 0) {
    return '-Rp${formatter.format(amount.abs())}';
  }
  return 'Rp${formatter.format(amount)}';
}
