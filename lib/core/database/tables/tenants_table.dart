import 'package:drift/drift.dart';

@DataClassName('TenantData')
class Tenants extends Table {
  @override
  String get tableName => 'tenants';

  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text()();
  TextColumn get note => text().nullable()();
  TextColumn get idPhotoPath => text().nullable().named('id_photo_path')();
  DateTimeColumn get createdAt => dateTime().named('created_at')();
  DateTimeColumn get updatedAt => dateTime().named('updated_at')();
  DateTimeColumn get deletedAt => dateTime().nullable().named('deleted_at')();

  @override
  Set<Column> get primaryKey => {id};
}
