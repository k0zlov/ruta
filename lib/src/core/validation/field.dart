import 'dart:typed_data';
import 'package:ruta/src/core/validation/validation_result.dart';
import 'package:ruta/src/core/validation/validator.dart';

class Field<T> {
  Field(
    this.name, {
    this.validators = const [],
    this.isRequired = true,
    this.children = const [],
  }) : type = T {
    if (children.isNotEmpty && T != Map<String, dynamic>) {
      throw ArgumentError(
        'Children can only be specified for Field<Map<String, dynamic>>',
      );
    }
  }

  final String name;
  final List<Validator<T>> validators;
  final bool isRequired;
  final Type type;
  final List<Field<Object>> children;

  T _fromJson(dynamic json) {
    if (json == null) {
      return null as T;
    }

    if (type == bool && json is int) {
      return (json != 0) as T;
    }

    if (type == bool && json is String) {
      if (json != 'true' && json != 'false') {
        throw Exception('Invalid boolean value: $json');
      }
      return (json == 'true') as T;
    }

    if (type == int && json is String) {
      return int.tryParse(json) as T? ??
          (throw Exception('Invalid int: $json'));
    }

    if (type == String && json is int) {
      return json.toString() as T;
    }

    final typeList = <T>[];

    if (typeList is List<DateTime?>) {
      if (json is int) {
        return DateTime.fromMillisecondsSinceEpoch(json) as T;
      } else {
        return DateTime.parse(json.toString()) as T;
      }
    }

    if (typeList is List<double?> && json is int) {
      return json.toDouble() as T;
    }

    if (typeList is List<Uint8List?> && json is! Uint8List) {
      final asList = (json as List).cast<int>();
      return Uint8List.fromList(asList) as T;
    }

    if (type == Map && json is Map) {
      return json.cast<String, dynamic>() as T;
    }

    return json as T;
  }

  ValidationResult validate(dynamic value) {
    if (value == null && !isRequired) {
      return ValidationResult.valid();
    }

    try {
      final T typedValue = _fromJson(value);

      final errors = validators
          .map((validator) => validator(typedValue))
          .where((result) => !result.isValid)
          .expand((result) => result.errors)
          .toList();

      if (children.isNotEmpty && typedValue is Map<String, dynamic>) {
        final mapValue = typedValue;
        for (final child in children) {
          final childValue = mapValue[child.name];
          final childResult = child.validate(childValue);
          if (!childResult.isValid) {
            errors.addAll(childResult.errors.map((e) => '$name.$e'));
          }
        }
      }

      if (errors.isEmpty) {
        return ValidationResult.valid();
      }

      return ValidationResult.invalid(errors);
    } catch (e) {
      return ValidationResult.invalid(['Invalid type provided for $name']);
    }
  }
}
