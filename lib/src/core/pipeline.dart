import 'package:ruta/ruta.dart';

/// A helper that makes it easy to compose a set of [Middleware] and a
/// [Handler].
class Pipeline {
  /// Constructor for pipeline
  const Pipeline();

  /// Returns a new [Pipeline] with [middleware] added to the existing set of
  /// [Middleware].
  ///
  /// [middleware] will be the last [Middleware] to process a request and
  /// the first to process a response.
  Pipeline addMiddleware(Middleware middleware) =>
      _Pipeline(middleware.call, addHandler);

  /// Returns a new [Handler] with [handler] as the final processor of a
  /// [Request] if all of the middleware in the pipeline have passed the request
  /// through.
  Handler addHandler(Handler handler) => handler;
}

class _Pipeline extends Pipeline {
  _Pipeline(this._middleware, this._parent);

  final MiddlewareFunc _middleware;
  final MiddlewareFunc _parent;

  @override
  Handler addHandler(Handler handler) => _parent(_middleware(handler));
}
