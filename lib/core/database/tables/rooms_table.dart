import 'package:drift/drift.dart';

import 'properties_table.dart';

@DataClassName('RoomData')
class Rooms extends Table {
  @override
  String get tableName => 'rooms';

  TextColumn get id => text()();
  TextColumn get propertyId =>
      text().named('property_id').references(Properties, #id)();
  TextColumn get number => text()();
  IntColumn get capacity => integer().withDefault(const Constant(1))();
  TextColumn get referenceRateType => text().named('reference_rate_type')();
  IntColumn get referenceRate => integer().nullable().named('reference_rate')();
  TextColumn get facilities => text().nullable()();
  BoolColumn get isUnderMaintenance => boolean()
      .named('is_under_maintenance')
      .withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {propertyId, number},
  ];
}
