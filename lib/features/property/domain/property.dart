/// Domain entity representing a boarding house property (kos / lokasi).
/// Reference: docs/ARCHITECTURE.md & docs/prd.md section 6.9.
class Property {
  final String id;
  final String name;
  final String address;
  final String contact;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  const Property({
    required this.id,
    required this.name,
    this.address = '',
    this.contact = '',
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  Property copyWith({
    String? id,
    String? name,
    String? address,
    String? contact,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Property(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      contact: contact ?? this.contact,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Property &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          address == other.address &&
          contact == other.contact &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          deletedAt == other.deletedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      address.hashCode ^
      contact.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode ^
      deletedAt.hashCode;
}
