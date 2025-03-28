part of '_internal.dart';

/// A function which creates a new [Handler]
/// by wrapping a [Handler].
typedef MiddlewareFunc = Handler Function(Handler handler);

/// Middleware class that wraps simple middleware function
class Middleware {
  /// Middleware constructor, defaults middleware
  Middleware({
    MiddlewareFunc? middleware,
  }) : middleware = middleware ?? ((_) => _);

  /// Default Middleware that will be used in call function
  final MiddlewareFunc middleware;

  /// Middleware function that will be executed, just as basic middleware function
  Handler call(Handler handler) => middleware(handler);

  /// Factory function to create middleware instance from shelf middleware
  static Middleware fromShelfMiddleware(shelf.Middleware middleware) {
    return fromShelfMiddleware(middleware);
  }

  /// Convert middleware to shelf middleware
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
