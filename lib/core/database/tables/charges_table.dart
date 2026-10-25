import 'package:drift/drift.dart';

import 'occupancies_table.dart';

@DataClassName('ChargeData')
class Charges extends Table {
  @override
  String get tableName => 'charges';

  TextColumn get id => text()();
  TextColumn get occupancyId =>
      text().named('occupancy_id').references(Occupancies, #id)();
  TextColumn get type =>
      text()(); // rent | electricity | water | penalty | other
  TextColumn get description => text()();
  IntColumn get amount => integer()();
  DateTimeColumn get periodStart => dateTime().named('period_start')();
  DateTimeColumn get periodEnd => dateTime().named('period_end')();
  DateTimeColumn get dueDate => dateTime().named('due_date')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {occupancyId, type, periodStart},
  ];
}
