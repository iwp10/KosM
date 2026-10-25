import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// Generates a random UUID v4 string.
String generateUuid() => _uuid.v4();
