import 'package:drift/drift.dart';

@DataClassName('OwnerProfileData')
class OwnerProfiles extends Table {
  @override
  String get tableName => 'owner_profile';

  TextColumn get id => text()();
  TextColumn get ownerName => text().named('owner_name')();
  TextColumn get contact => text()();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {id};
}
