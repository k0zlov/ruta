import 'dart:typed_data';
import 'package:ruta/src/core/validation/validation_result.dart';
import 'package:ruta/src/core/validation/validator.dart';

/// A class representing a data field with validation capabilities.
class Field<T> {
  /// Constructor for the `Field` class.
  ///
  /// - `name` – the name of the field.
  /// - `validators` – a list of validators to check the value.
  /// - `isRequired` – a flag indicating whether the field is required (default is `true`).
  /// - `children` – child fields (only allowed if `T` is `Map<String, dynamic>`).
  Field(
    this.name, {
    this.validators = const [],
    this.isRequired = true,
    this.children = const [],
  }) : type = T {
    // Validation: Child fields are only allowed for `Field<Map<String, dynamic>>`
    if (children.isNotEmpty && T != Map<String, dynamic>) {
      throw ArgumentError(
        'Children can only be specified for Field<Map<String, dynamic>>',
      );
    }
  }

  /// The name of the field.
  final String name;

  /// A list of validators to be applied to the field's value.
  final List<Validator<T>> validators;

  /// Indicates whether the field is required.
  final bool isRequired;

  /// The data type of the field.
  final Type type;

  /// A list of child fields (only applicable for `Map<String, dynamic>` fields).
  final List<Field<Object>> children;

  /// Value of field after validation
  T? value;

  /// Converts a raw JSON value into the expected type `T`.
  T _fromJson(dynamic json) {
    if (json == null) {
      return null as T;
    }

    // Handle conversion of integer to boolean (nonzero -> true, zero -> false)
    if (type == bool && json is int) {
      return (json != 0) as T;
    }

    // Handle string representations of booleans
    if (type == bool && json is String) {
      if (json != 'true' && json != 'false') {
        throw Exception('Invalid boolean value: $json');
      }
      return (json == 'true') as T;
    }

    // Convert string to integer, throwing an exception if invalid
    if (type == int && json is String) {
      return int.tryParse(json) as T? ??
          (throw Exception('Invalid int: $json'));
    }

    // Convert integer to string
    if (type == String && json is int) {
      return json.toString() as T;
    }

    // Temporary list for checking type compatibility
    final typeList = <T>[];

    // Handle conversion to `DateTime`
    if (typeList is List<DateTime?>) {
      if (json is int) {
        return DateTime.fromMillisecondsSinceEpoch(json) as T;
      } else {
        return DateTime.parse(json.toString()) as T;
      }
    }

    // Convert integer to double if expected type is `double`
    if (typeList is List<double?> && json is int) {
      return json.toDouble() as T;
    }

    // Convert list of integers to `Uint8List`
    if (typeList is List<Uint8List?> && json is! Uint8List) {
      final asList = (json as List).cast<int>();
      return Uint8List.fromList(asList) as T;
    }

    // Ensure the value is a properly casted `Map<String, dynamic>` if expected
    if (type == Map && json is Map) {
      return json.cast<String, dynamic>() as T;
    }

    // Default case: return the value as-is
    return json as T;
  }

  /// Validates the given value against the field's rules.
  ValidationResult validate(dynamic value) {
    // If the value is null and the field is optional, it's valid.
    if (value == null && !isRequired) {
      return ValidationResult.valid();
    }

    try {
      // Convert the raw value to the expected type `T`
      final T typedValue = _fromJson(value);

      // Run all validators and collect error messages
      final errors = validators
          .map((validator) => validator(typedValue))
          .where((result) => !result.isValid)
          .expand((result) => result.errors)
          .toList();

      // If there are child fields and the value is a map, validate child fields recursively
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

      // Return valid result if no errors were found
      if (errors.isEmpty) {
        this.value = typedValue;
        return ValidationResult.valid();
      }

      // Otherwise, return an invalid result with collected errors
      return ValidationResult.invalid(errors);
    } catch (e) {
      return ValidationResult.invalid(['Invalid type provided for $name']);
    }
  }
}
