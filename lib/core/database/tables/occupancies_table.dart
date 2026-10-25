import 'package:drift/drift.dart';

import 'rooms_table.dart';
import 'tenants_table.dart';

@DataClassName('OccupancyData')
class Occupancies extends Table {
  @override
  String get tableName => 'occupancies';

  TextColumn get id => text()();
  TextColumn get tenantId =>
      text().named('tenant_id').references(Tenants, #id)();
  TextColumn get roomId => text().named('room_id').references(Rooms, #id)();
  DateTimeColumn get startDate => dateTime().named('start_date')();
  DateTimeColumn get plannedEndDate =>
      dateTime().nullable().named('planned_end_date')();
  DateTimeColumn get actualEndDate =>
      dateTime().nullable().named('actual_end_date')();
  TextColumn get rateType => text().named('rate_type')();
  IntColumn get rateAmount => integer().named('rate_amount')();
  IntColumn get durationUnits => integer().nullable().named('duration_units')();
  IntColumn get dueDay => integer().nullable().named('due_day')();
  TextColumn get status => text()(); // active | ended
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {id};
}
