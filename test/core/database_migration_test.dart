import 'dart:io';

import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kosm/core/database/database.dart';

class _V1ExecutorUser extends QueryExecutorUser {
  @override
  int get schemaVersion => 1;

  @override
  Future<void> beforeOpen(
    QueryExecutor executor,
    OpeningDetails details,
  ) async {}
}

void main() {
  group('Database Migration v1 to v2 Tests', () {
    test('migrates database from v1 to v2 adding id_photo_path column and keeping existing data intact', () async {
      // 1. Create a physical SQLite v1 database file in system temp
      final tempDir = Directory.systemTemp.createTempSync('drift_migration_');
      final dbFile = File('${tempDir.path}/kosm_v1.db');

      // Exact v1 DDL definitions from initial release
      const v1PropertiesDdl = '''
          CREATE TABLE properties (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            address TEXT NOT NULL,
            contact TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER
          );
        ''';

      const v1TenantsDdl = '''
          CREATE TABLE tenants (
            id TEXT NOT NULL PRIMARY KEY,
            name TEXT NOT NULL,
            phone TEXT NOT NULL,
            note TEXT,
            created_at INTEGER NOT NULL,
            updated_at INTEGER NOT NULL,
            deleted_at INTEGER
          );
        ''';

      final rawDb = NativeDatabase(dbFile);
      await rawDb.ensureOpen(_V1ExecutorUser());

      // Initialize v1 schema & data
      await rawDb.runCustom(v1PropertiesDdl);
      await rawDb.runCustom(v1TenantsDdl);
      await rawDb.runCustom('PRAGMA user_version = 1;');

      final now = DateTime.utc(2026, 10, 31, 10, 0, 0);
      final nowSeconds = now.millisecondsSinceEpoch ~/ 1000;

      await rawDb.runCustom(
        "INSERT INTO properties (id, name, address, contact, created_at, updated_at) "
        "VALUES ('prop-1', 'Kos Graha Melati', 'Jl. Melati No. 12', '08123456789', $nowSeconds, $nowSeconds);",
      );

      await rawDb.runCustom(
        "INSERT INTO tenants (id, name, phone, note, created_at, updated_at) "
        "VALUES ('tenant-1', 'Budi Santoso', '+6281234567890', 'Catatan lama', $nowSeconds, $nowSeconds);",
      );

      // Close raw v1 database so connection can be cleanly reopened by AppDatabase
      await rawDb.close();

      // 2. Open this existing v1 database file using AppDatabase (schemaVersion = 2)
      final db = AppDatabase(NativeDatabase(dbFile));
      addTearDown(() async {
        await db.close();
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      });

      // 3. Verify user_version is now 2
      expect(db.schemaVersion, 2);

      // Check PRAGMA user_version directly
      final versionResult = await db
          .customSelect('PRAGMA user_version;')
          .getSingle();
      expect(versionResult.data['user_version'], 2);

      // 4. Verify existing tenant-1 is intact with null idPhotoPath
      final oldTenant = await (db.select(
        db.tenants,
      )..where((t) => t.id.equals('tenant-1'))).getSingle();

      expect(oldTenant.id, 'tenant-1');
      expect(oldTenant.name, 'Budi Santoso');
      expect(oldTenant.phone, '+6281234567890');
      expect(oldTenant.note, 'Catatan lama');
      expect(oldTenant.createdAt.toUtc(), now);
      expect(oldTenant.updatedAt.toUtc(), now);
      expect(oldTenant.deletedAt, isNull);
      expect(oldTenant.idPhotoPath, isNull);

      // 5. Verify inserting new v2 tenant with idPhotoPath succeeds
      await db
          .into(db.tenants)
          .insert(
            TenantsCompanion.insert(
              id: 'tenant-2',
              name: 'Siti Aminah',
              phone: '+6289876543210',
              idPhotoPath: const Value('tenants/photos/ktp_siti.jpg'),
              createdAt: now,
              updatedAt: now,
            ),
          );

      final newTenant = await (db.select(
        db.tenants,
      )..where((t) => t.id.equals('tenant-2'))).getSingle();

      expect(newTenant.id, 'tenant-2');
      expect(newTenant.name, 'Siti Aminah');
      expect(newTenant.phone, '+6289876543210');
      expect(newTenant.idPhotoPath, 'tenants/photos/ktp_siti.jpg');
    });
  });
}
