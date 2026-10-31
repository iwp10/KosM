import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/database.dart';
import '../../data/tenant_dao.dart';
import '../../data/tenant_repository_impl.dart';
import '../../domain/tenant_repository.dart';

/// Provider for [TenantDao].
final tenantDaoProvider = Provider<TenantDao>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return TenantDao(db);
});

/// Provider for [TenantRepository].
final tenantRepositoryProvider = Provider<TenantRepository>((ref) {
  final dao = ref.watch(tenantDaoProvider);
  return TenantRepositoryImpl(dao);
});
