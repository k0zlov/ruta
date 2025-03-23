class ValidationResult {
  const ValidationResult._(this.isValid, this.errors);

  factory ValidationResult.valid() => const ValidationResult._(true, []);

  factory ValidationResult.invalid(List<String> errors) =>
      ValidationResult._(false, errors);

  final bool isValid;
  final List<String> errors;
}
