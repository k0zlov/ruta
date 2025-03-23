import 'package:ruta/src/core/validation/validation_result.dart';

typedef Validator<T> = ValidationResult Function(T value);
