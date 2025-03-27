/// for ruta_generator
library ruta;

import 'package:ruta/open_api.dart';
import 'package:ruta/ruta.dart';
import 'package:ruta/src/core/api_exceptions.dart';

/// Represents an API endpoint in the Ruta framework.
///
/// This class defines an API endpoint, including its path, HTTP method,
/// request validation, authentication requirements, and OpenAPI metadata.
///
/// Example usage:
/// ```dart
/// final endpoint = Endpoint(
///   path: '/users',
///   method: HttpMethod.get,
///   handler: (Request request) async => Response.ok('User List'),
///   authRequired: true,
///   summary: 'Retrieve a list of users',
///   responses: [OpenApiResponse(statusCode: 200, description: 'OK')],
/// );
/// ```
class Endpoint {
  /// Creates an API endpoint.
  ///
  /// - [path] The URL path of the endpoint.
  /// - [method] The HTTP method (GET, POST, etc.).
  /// - [handler] The request handler function.
  /// - [authRequired] Whether authentication is required (default: `false`).
  /// - [middlewares] A list of middleware functions (default: empty).
  /// - [summary] A short summary for OpenAPI documentation (optional).
  /// - [description] A detailed description for OpenAPI documentation (optional).
  /// - [responses] Expected responses for OpenAPI documentation (default: empty list).
  /// - [body] A list of expected request body fields for validation (optional).
  /// - [query] A list of expected query parameters for validation (optional).
  const Endpoint({
    required this.path,
    required this.method,
    required this.handler,
    this.authRequired = false,
    this.middlewares = const [],
    this.summary,
    this.description,
    this.responses = const [],
    this.body,
    this.query,
  });

  // ─────────────────────────────────────────────────────────────
  // Core Endpoint Properties
  // ─────────────────────────────────────────────────────────────

  /// The URL path of the endpoint (e.g., `'/users'`).
  final String path;

  /// The HTTP method of the endpoint (e.g., `HttpMethod.get`).
  final HttpMethod method;

  /// The list of middleware functions applied to this endpoint.
  final List<Middleware> middlewares;

  /// The main handler function that processes incoming requests.
  final Handler handler;

  // ─────────────────────────────────────────────────────────────
  // OpenAPI Documentation Properties
  // ─────────────────────────────────────────────────────────────

  /// Indicates whether authentication is required for this endpoint.
  ///
  /// If `true`, the endpoint requires a valid authentication token.
  final bool authRequired;

  /// A short summary of the endpoint for OpenAPI documentation.
  final String? summary;

  /// A detailed description of the endpoint for OpenAPI documentation.
  final String? description;

  /// The expected responses for OpenAPI documentation.
  final List<OpenApiResponse> responses;

  // ─────────────────────────────────────────────────────────────
  // Request Validation Properties
  // ─────────────────────────────────────────────────────────────

  /// Defines the expected fields in the request body.
  ///
  /// This is used for request validation.
  final List<Field<Object>>? body;

  /// Defines the expected query parameters.
  ///
  /// This is used for request validation.
  final List<Field<Object>>? query;

  // ─────────────────────────────────────────────────────────────
  // Endpoint Builder
  // ─────────────────────────────────────────────────────────────

  /// Builds the endpoint handler with validation.
  ///
  /// This method wraps the handler function with request validation.
  /// If the validation fails, an `ApiException.badRequest` is thrown.
  ///
  /// Example:
  /// ```dart
  /// final endpoint = Endpoint(
  ///   path: '/users',
  ///   method: HttpMethod.post,
  ///   handler: (request) async => Response.ok('User created'),
  ///   body: [Field<String>(name: 'username', isRequired: true)],
  /// ).build();
  /// ```
  ///
  /// - Returns a `Handler` function that validates the request before processing it.
  Handler build() {
    return (Request request) async {
      // Validate the request body and query parameters
      final result = await request.validate(
        body: body ?? [],
        query: query ?? [],
      );

      Handler handlerWithMiddleware = handler;

      for (final Middleware mw in middlewares) {
        handlerWithMiddleware = handlerWithMiddleware.use(mw);
      }

      // If validation fails, return a 400 Bad Request response
      if (!result.isValid) {
        throw ApiException.badRequest(
          'Request validation failed.',
          errors: result.errors,
        );
      }

      // Proceed with the original request handler
      return handlerWithMiddleware(request);
    };
  }
}
