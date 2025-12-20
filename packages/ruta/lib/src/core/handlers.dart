import 'dart:async';
import 'package:ruta/ruta.dart';

/// A function type that represents an HTTP request handler in the Ruta framework.
///
/// This typedef defines the expected signature for request handlers
/// used in routing and middleware processing.
/// A handler takes a [Request] as input and returns a [Response],
/// either synchronously or asynchronously.
///
/// Example usage:
/// ```dart
/// FutureOr<Response> myHandler(Request request) {
///   return Response.ok('Hello, world!');
/// }
///
/// final handler = Handler(myHandler);
/// ```
///
/// The `Handler` function is commonly used in route definitions:
/// ```dart
/// final endpoint = Endpoint(
///   path: '/greet',
///   method: HttpMethod.get,
///   handler: (Request request) => Response.ok('Welcome!'),
/// );
/// ```
typedef Handler = FutureOr<Response> Function(Request request);
