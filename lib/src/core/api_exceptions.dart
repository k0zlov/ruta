import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

class ApiException implements Exception {
  const ApiException(
    this.message, {
    required this.statusCode,
    this.errors = const [],
  });

  final int statusCode;
  final String message;
  final List<String> errors;

  // Constructors
  const ApiException.badRequest(
    this.message, {
    this.errors = const [],
  }) : statusCode = HttpStatus.badRequest;

  const ApiException.unauthorized([
    this.message = 'Unauthorized',
  ])  : statusCode = HttpStatus.unauthorized,
        errors = const [];

  const ApiException.internalServerError(
    this.message, {
    this.errors = const [],
  }) : statusCode = HttpStatus.internalServerError;

  const ApiException.forbidden(
    this.message, {
    this.errors = const [],
  }) : statusCode = HttpStatus.forbidden;

  const ApiException.notFound([this.message = 'Resource was not found'])
      : statusCode = HttpStatus.notFound,
        errors = const [];

  Map<String, dynamic> toMap() => {
        'message': message,
        if (errors.isNotEmpty) 'errors': errors,
      };

  Response toResponse() => Response(
        statusCode,
        body: jsonEncode(toMap()),
      );

  @override
  String toString() {
    return 'ApiException{statusCode: $statusCode, message: $message, errors: $errors}';
  }
}
