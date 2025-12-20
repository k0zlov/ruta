import 'package:ruta/src/core/validation/validation_result.dart';

/// Defines a type alias named Validator that takes a generic type T
/// It represents a function that:
/// - Takes a parameter 'value' of type T
/// - Returns a ValidationResult object
/// The function signature describes a validator that checks a value and returns its validation status
typedef Validator<T> = ValidationResult Function(T value);
