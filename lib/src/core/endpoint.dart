import 'package:ruta/open_api.dart';
import 'package:ruta/ruta.dart';
import 'package:ruta/src/core/api_exceptions.dart';

class Endpoint {
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

  /// Endpoint core
  final String path;
  final HttpMethod method;
  final List<Middleware> middlewares;
  final Handler handler;

  /// For Open Api documentation
  final bool authRequired;
  final String? summary;
  final String? description;
  final List<OpenApiResponse> responses;

  /// Validation
  final List<Field<Object>>? body;
  final List<Field<Object>>? query;

  Handler build() {
    return (Request request) async {
      final result = await request.validate(
        body: body ?? [],
        query: query ?? [],
      );

      if (!result.isValid) {
        throw ApiException.badRequest(
          'Request validation failed.',
          errors: result.errors,
        );
      }

      return handler(request);
    };
  }
}
