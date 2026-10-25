import 'package:drift/drift.dart';

import 'charges_table.dart';

@DataClassName('PaymentData')
class Payments extends Table {
  @override
  String get tableName => 'payments';

  TextColumn get id => text()();
  TextColumn get chargeId =>
      text().named('charge_id').references(Charges, #id)();
  IntColumn get amount => integer()();
  DateTimeColumn get paidAt => dateTime().named('paid_at')();
  TextColumn get method => text()(); // cash | transfer
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {id};
}
