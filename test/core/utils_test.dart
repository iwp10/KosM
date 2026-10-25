import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kosm/core/utils/utils.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID', null);
  });

  group('formatRupiah', () {
    test('formats zero correctly', () {
      expect(formatRupiah(0), 'Rp0');
    });

    test('formats positive amounts with dot as thousands separator', () {
      expect(formatRupiah(1500000), 'Rp1.500.000');
      expect(formatRupiah(75000), 'Rp75.000');
      expect(formatRupiah(100000000), 'Rp100.000.000');
    });

    test('formats negative amounts with minus sign before Rp', () {
      expect(formatRupiah(-50000), '-Rp50.000');
      expect(formatRupiah(-1500000), '-Rp1.500.000');
    });
  });

  group('AppDateFormat', () {
    final date = DateTime(2026, 10, 25, 14, 30);

    test('formats date in full Indonesian format', () {
      expect(AppDateFormat.formatDate(date), '25 Oktober 2026');
    });

    test('formats short date in Indonesian format', () {
      expect(AppDateFormat.formatDateShort(date), '25 Okt 2026');
    });

    test('formats date and time in Indonesian format', () {
      expect(AppDateFormat.formatDateTime(date), '25 Okt 2026, 14:30');
    });

    test('formats month and year in Indonesian format', () {
      expect(AppDateFormat.formatMonthYear(date), 'Oktober 2026');
    });
  });

  group('generateUuid', () {
    test('generates valid non-empty UUID v4 strings', () {
      final uuid1 = generateUuid();
      final uuid2 = generateUuid();

      final uuidRegex = RegExp(
        r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        caseSensitive: false,
      );

      expect(uuidRegex.hasMatch(uuid1), isTrue);
      expect(uuidRegex.hasMatch(uuid2), isTrue);
      expect(uuid1, isNot(equals(uuid2)));
    });
  });
}
