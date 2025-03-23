part of '_internal.dart';

Future<HttpServer> serve(
  Handler handler,
  Object address,
  int port, {
  String? poweredByHeader = 'Dart with package:ruta',
  SecurityContext? securityContext,
  bool shared = false,
}) {
  return shelf_io.serve(
    (shelf.Request request) async {
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
