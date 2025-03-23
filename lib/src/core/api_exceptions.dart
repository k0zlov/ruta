import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';

/// Represents an API exception that can be converted into an HTTP response.
///
/// This class provides a structured way to handle API errors in a
/// `Shelf`-based web server by encapsulating status codes, error messages,
/// and optional additional errors.
///
/// Example usage:
/// ```dart
/// throw ApiException.badRequest('Invalid input', errors: ['Email is required']);
/// ```
///
/// The exception can also be converted into an HTTP response:
/// ```dart
/// final response = ApiException.notFound().toResponse();
/// ```
class ApiException implements Exception {
  /// Creates a general API exception.
  ///
  /// - [message] A human-readable description of the error.
  /// - [statusCode] The associated HTTP status code.
  /// - [errors] A list of detailed error messages (optional).
  const ApiException(
    this.message, {
    required this.statusCode,
    this.errors = const [],
  });

  // ─────────────────────────────────────────────────────────────
  // Named Constructors for Common HTTP Errors
  // ─────────────────────────────────────────────────────────────

  /// Creates a `400 Bad Request` exception.
  ///
  /// Used when the client sends an invalid request.
  /// Example:
  /// ```dart
  /// throw ApiException.badRequest('Invalid input', errors: ['Email is required']);
  /// ```
  const ApiException.badRequest(
    this.message, {
    this.errors = const [],
  }) : statusCode = HttpStatus.badRequest;

  /// Creates a `401 Unauthorized` exception.
  ///
  /// Used when authentication is required but missing or invalid.
  /// Example:
  /// ```dart
  /// throw ApiException.unauthorized();
  /// ```
  const ApiException.unauthorized([
    this.message = 'Unauthorized',
  ])  : statusCode = HttpStatus.unauthorized,
        errors = const [];

  /// Creates a `403 Forbidden` exception.
  ///
  /// Used when the user is authenticated but lacks necessary permissions.
  const ApiException.forbidden(
    this.message, {
    this.errors = const [],
  }) : statusCode = HttpStatus.forbidden;

  /// Creates a `404 Not Found` exception.
  ///
  /// Used when a requested resource does not exist.
  /// Example:
  /// ```dart
  /// throw ApiException.notFound();
  /// ```
  const ApiException.notFound([
    this.message = 'Resource was not found',
  ])  : statusCode = HttpStatus.notFound,
        errors = const [];

  /// Creates a `500 Internal Server Error` exception.
  ///
  /// Used when an unexpected server-side error occurs.
  const ApiException.internalServerError(
    this.message, {
    this.errors = const [],
  }) : statusCode = HttpStatus.internalServerError;

  /// The HTTP status code of the exception.
  final int statusCode;

  /// The main error message describing the issue.
  final String message;

  /// An optional list of additional error details.
  final List<String> errors;

  // ─────────────────────────────────────────────────────────────
  // Utility Methods
  // ─────────────────────────────────────────────────────────────

  /// Converts the exception into a JSON-serializable map.
  ///
  /// Example output:
  /// ```json
  /// {
  ///   "message": "Invalid input",
  ///   "errors": ["Email is required"]
  /// }
  /// ```
  Map<String, dynamic> toMap() => {
        'message': message,
        if (errors.isNotEmpty) 'errors': errors,
      };

  /// Converts the exception into a `Shelf` HTTP response.
  ///
  /// Example:
  /// ```dart
  /// final response = ApiException.badRequest('Invalid data').toResponse();
  /// ```
  Response toResponse() => Response(
        statusCode,
        body: jsonEncode(toMap()),
        headers: {'Content-Type': 'application/json'},
      );

  /// Returns a string representation of the exception.
  @override
  String toString() {
    return 'ApiException{statusCode: $statusCode, message: $message, errors: $errors}';
  }
}
