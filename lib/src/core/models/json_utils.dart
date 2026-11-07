/// Small, defensive helpers for reading the 42 API's loosely typed JSON.
///
/// The API occasionally returns `null`, numbers as doubles, or omits fields,
/// so every read is tolerant instead of using hard `as int` casts that crash.
library;

int asInt(Object? value, [int fallback = 0]) =>
    value is num ? value.toInt() : int.tryParse('$value') ?? fallback;

int? asIntOrNull(Object? value) => value is num
    ? value.toInt()
    : (value == null ? null : int.tryParse('$value'));

double asDouble(Object? value, [double fallback = 0]) =>
    value is num ? value.toDouble() : double.tryParse('$value') ?? fallback;

String asString(Object? value, [String fallback = '']) =>
    value == null ? fallback : value.toString();

String? asStringOrNull(Object? value) => value?.toString();

DateTime? asDate(Object? value) =>
    value == null ? null : DateTime.tryParse(value.toString());

List<Map<String, dynamic>> asMapList(Object? value) => value is List
    ? value.whereType<Map<String, dynamic>>().toList(growable: false)
    : const [];

Map<String, dynamic>? asMap(Object? value) =>
    value is Map<String, dynamic> ? value : null;
