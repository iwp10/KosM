import 'package:drift/drift.dart';

import 'charges_table.dart';
import 'occupancies_table.dart';

@DataClassName('ReminderData')
class Reminders extends Table {
  @override
  String get tableName => 'reminders';

  TextColumn get id => text()();
  TextColumn get type => text()(); // before_checkout | charge_due
  TextColumn get occupancyId =>
      text().named('occupancy_id').references(Occupancies, #id)();
  TextColumn get chargeId =>
      text().nullable().named('charge_id').references(Charges, #id)();
  DateTimeColumn get remindAt => dateTime().named('remind_at')();
  BoolColumn get isDone =>
      boolean().named('is_done').withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {id};
}
