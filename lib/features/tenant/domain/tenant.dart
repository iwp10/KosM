/// Derived status of a tenant based on current occupancies, charges, and payments.
/// Priority: overdue > active > ended > unassigned.
enum TenantStatus {
  /// Has a non-deleted charge with due_date before today (Asia/Jakarta) and payments < amount.
  overdue,

  /// Has an active non-deleted occupancy and no overdue charges.
  active,

  /// Has had occupancies in the past, but none is currently active, and no overdue charges.
  ended,

  /// Has never had any occupancy assigned.
  unassigned,
}

/// Domain entity representing a tenant (penyewa kos).
/// Reference: docs/prd.md section 6.1 & docs/ARCHITECTURE.md section 3.
class Tenant {
  final String id;
  final String name;
  final String phone;
  final String? note;
  final String? idPhotoPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Tenant({
    required this.id,
    required this.name,
    required this.phone,
    this.note,
    this.idPhotoPath,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Tenant copyWith({
    String? id,
    String? name,
    String? phone,
    String? note,
    String? idPhotoPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Tenant(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      note: note ?? this.note,
      idPhotoPath: idPhotoPath ?? this.idPhotoPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tenant &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          phone == other.phone &&
          note == other.note &&
          idPhotoPath == other.idPhotoPath &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    note,
    idPhotoPath,
    createdAt,
    updatedAt,
    deletedAt,
  );

  @override
  String toString() =>
      'Tenant(id: $id, name: $name, phone: $phone, photo: $idPhotoPath)';
}

/// Domain model combining a [Tenant] with their derived [TenantStatus].
class TenantWithStatus {
  final Tenant tenant;
  final TenantStatus status;

  const TenantWithStatus({required this.tenant, required this.status});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TenantWithStatus &&
          runtimeType == other.runtimeType &&
          tenant == other.tenant &&
          status == other.status;

  @override
  int get hashCode => Object.hash(tenant, status);

  @override
  String toString() =>
      'TenantWithStatus(tenant: ${tenant.name}, status: $status)';
}
