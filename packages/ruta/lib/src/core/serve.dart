part of '_internal.dart';

/// Starts an HTTP server that serves requests using the provided handler.
Future<HttpServer> serve(
  Handler handler,
  Object address,
  int port, {
  /// Optional header for "Powered-By" (default: 'Dart with package:ruta')
  String? poweredByHeader = 'Dart with package:ruta',

  /// Optional security context for HTTPS support
  SecurityContext? securityContext,

  /// Whether the server should share the socket between multiple servers (default: false)
  bool shared = false,
}) {
  return shelf_io.serve(
    (shelf.Request request) async {
      // Handling incoming requests by passing them to the provided handler
      final response = await handler(Request._(request));
      return response._response;
    },
    address,
    port,
    poweredByHeader: poweredByHeader,
    securityContext: securityContext,
    shared: shared,
  );
}
