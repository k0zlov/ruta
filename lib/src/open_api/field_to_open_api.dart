import 'package:ruta/src/core/validation/field.dart';

/// Converts a Dart [Type] into an equivalent OpenAPI type.
///
/// This function maps common Dart types to OpenAPI schema types:
/// - `String` → `'string'`
/// - `int` → `'integer'`
/// - `double` → `'number'`
/// - `bool` → `'boolean'`
/// - `List<T>` → `'array'`
/// - `Map<String, dynamic>` → `'object'`
///
/// If the type is not explicitly recognized, it defaults to `'object'`.
///
/// - [dartType] The Dart type to be converted.
/// - Returns the corresponding OpenAPI type as a string.
String typeToOpenApiType(Type dartType) {
  if (dartType == String) {
    return 'string';
  } else if (dartType == int) {
    return 'integer';
  } else if (dartType == double) {
    return 'number';
  } else if (dartType == bool) {
    return 'boolean';
  } else if (dartType.toString().startsWith('List<')) {
    return 'array';
  } else if (dartType.toString().startsWith('Map<') ||
      dartType == Map<String, dynamic>) {
    return 'object';
  }
  return 'object'; // Fallback for unknown types
}

/// Converts a [Field] object into an OpenAPI schema representation.
///
/// This function takes a `Field<Object>` instance and generates a
/// corresponding OpenAPI schema definition.
/// - Handles primitive types (`String`, `int`, `double`, `bool`).
/// - Converts `Map<String, dynamic>` into an OpenAPI object schema.
/// - Recursively processes child fields if the field is an object.
///
/// Example:
/// ```dart
/// final field = Field<String>(name: 'username', type: String, isRequired: true);
/// final schema = fieldToSchema(field);
/// print(schema); // Outputs: { "type": "string" }
/// ```
///
/// - [field] The field to be converted into an OpenAPI schema.
/// - Returns a map representing the OpenAPI schema.
Map<String, dynamic> fieldToSchema(Field<Object> field) {
  final type = field.type;

  if (type == String) {
    return {'type': 'string'};
  } else if (type == int) {
    return {'type': 'integer'};
  } else if (type == double) {
    return {'type': 'number'};
  } else if (type == bool) {
    return {'type': 'boolean'};
  } else if (type == Map<String, dynamic>) {
    return {
      'type': 'object',
      'properties': {
        for (final child in field.children) child.name: fieldToSchema(child),
      },
      'required': field.children
          .where((child) => child.isRequired)
          .map((child) => child.name)
          .toList(),
    };
  }

  return {'type': 'object'}; // Default fallback
}
