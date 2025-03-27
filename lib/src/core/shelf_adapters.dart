part of '_internal.dart';

/// Convert from [shelf.Middleware] into [Middleware].
MiddlewareFunc fromShelfMiddleware(shelf.Middleware middleware) {
  return (handler) {
    return (request) async {
      final response = await middleware(
        (request) async {
          final response = await handler(Request._(request));
          return response._response;
        },
      )(request._request);
      return Response._(response);
    };
  };
}

/// Convert from [Middleware] into [shelf.Middleware].
shelf.Middleware toShelfMiddleware(MiddlewareFunc middleware) {
  return (innerHandler) {
    return (request) async {
      final response = await middleware((request) async {
        final response = await innerHandler(request._request);
        return Response._(response);
      })(Request._(request));
      return response._response;
    };
  };
}

/// Convert from a [shelf.Handler] into a [Handler].
Handler fromShelfHandler(shelf.Handler handler) {
  return (request) async {
    final response = await handler(request._request);
    return Response._(response);
  };
}

/// Convert from a [Handler] into a [shelf.Handler].
shelf.Handler toShelfHandler(Handler handler) {
  return (request) async {
    final context = Request._(request);
    final response = await handler.call(context);
    return response._response;
  };
}

/// Converted from [shelf]
class LogRequestsMiddleware extends Middleware {
  LogRequestsMiddleware({
    super.middleware,
    required this.logger,
  });

  final void Function(
    String message,
    // ignore: avoid_positional_boolean_parameters
    bool isError,
  ) logger;

  @override
  MiddlewareFunc get middleware => fromShelfMiddleware(
        shelf.logRequests(logger: logger),
      );
}

class CorsHeadersMiddleware extends Middleware {
  @override
  MiddlewareFunc get middleware => fromShelfMiddleware(
        shelf_cors_headers.corsHeaders(),
      );
}

/// Converted from [shelf]
Handler createStaticFileHandler({String path = 'public'}) {
  return fromShelfHandler(createStaticHandler(path));
}
