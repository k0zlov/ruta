/// Represents the result of a validation process.
class ValidationResult {
  /// Private constructor to enforce the use of factory methods.
  const ValidationResult._(this.isValid, this.errors);

  /// Factory constructor for a successful validation result (no errors).
  factory ValidationResult.valid() => const ValidationResult._(true, []);

  /// Factory constructor for an invalid validation result with a list of error messages.
  factory ValidationResult.invalid(List<String> errors) =>
      ValidationResult._(false, errors);

  /// Indicates whether the validation was successful.
  final bool isValid;

  /// A list of error messages if the validation failed.
  final List<String> errors;
}
