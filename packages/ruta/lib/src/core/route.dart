/// for ruta_generator
library ruta;

import 'package:ruta/ruta.dart';
import 'package:ruta/src/open_api/specification.dart';

/// Abstract class for routes. Every route will inherit from this class
abstract class Route {
  /// Constructor
  Route();

  /// Returns the route name by extracting it from the class name
  String get name {
    final className = runtimeType.toString();
    final firstWord = className.split(RegExp('(?=[A-Z])')).first.toLowerCase();
    return firstWord;
  }

  /// Description of the route, defaults to null
  String? get description => null;

  /// External documentation for the route, defaults to null
  OpenApiExternalDocs? get externalDocs => null;

  /// List of middleware for request processing
  List<Middleware> get middlewares => [];

  /// List of endpoints for the route
  List<Endpoint> endpoints = [];

  /// Builds and returns a route handler with added middleware and endpoints
  Handler build() {
    // Initial empty pipeline
    Pipeline pipeline = const Pipeline();

    // Add middleware layers
    for (final Middleware middleware in middlewares) {
      pipeline = pipeline.addMiddleware(middleware);
    }

    final router = Router();

    // Add endpoints to the router
    for (final Endpoint endpoint in endpoints) {
      router.add(
        endpoint.method.value,
        '/${endpoint.path}',
        endpoint.build(),
      );
    }

    // Return the final handler
    return pipeline.addHandler(router.call);
  }
}
