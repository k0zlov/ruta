import 'package:ruta/src/core/validation/field.dart';

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
  return {'type': 'object'};
}
