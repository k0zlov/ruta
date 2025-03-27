part of '_internal.dart';

/// A function which creates a new [Handler]
/// by wrapping a [Handler].
typedef MiddlewareFunc = Handler Function(Handler handler);

/// Middleware something
class Middleware {
  Middleware({
    MiddlewareFunc? middleware,
  }) : middleware = middleware ?? ((_) => _);

  final MiddlewareFunc middleware;

  Handler call(Handler handler) => middleware(handler);

  static Middleware fromShelfMiddleware(shelf.Middleware middleware) {
    return fromShelfMiddleware(middleware);
  }

  shelf.Middleware toShelf() {
    return toShelfMiddleware(middleware);
  }
}

/// Extension on [Handler] which adds support
/// for applying middleware to the request pipeline.
extension HandlerUse on Handler {
  /// Apply [middleware] to the current handler.
  Handler use(Middleware middleware) {
    const pipeline = Pipeline();
    return pipeline.addMiddleware(middleware).addHandler(this);
  }
}
