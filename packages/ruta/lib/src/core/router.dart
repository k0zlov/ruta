// Copyright 2019 Google LLC
// Copyright 2022 Very Good Ventures
// Copyright 2025 kozlov
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     https://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Original Source: https://github.com/dart-lang/shelf/blob/master/pkgs/shelf_router/lib/src/router.dart
// Modified: For interoperability with package:dart_frog

part of '_internal.dart';

/// A router that routes requests to handlers based on HTTP verb and route pattern.
///
/// Example:
/// ```dart
/// import 'package:ruta/ruta.dart';
///
/// var app = Router();
///
/// app.get('/users/<userName>/whoami', (Request request) async {
///   var userName = request.params['userName'];
///   return Response(body: 'You are ${userName}');
/// });
///
/// app.get('/users/<userName>/say-hello', (Request request) async {
///   var userName = request.params['userName'];
///   return Response(body: 'Hello ${userName}');
/// });
///
/// app.get('/users/<userName>/messages/<msgId|\\d+>', (Request request) async {
///   var msgId = int.parse(request.params['msgId']!);
///   return Response(body: 'Message $msgId');
/// });
/// ```
class Router {
  /// Creates a new [Router] routing requests to handlers.
  ///
  /// The [notFoundHandler] will be invoked for requests where no matching route
  /// was found. By default, a simple 404 response will be used.
  Router({Handler? notFoundHandler})
      : _notFoundHandler = notFoundHandler ?? _defaultNotFound;
  final List<RouterEntry> _routes = [];
  final Handler _notFoundHandler;

  /// Add [handler] for [verb] requests to [route].
  ///
  /// If [verb] is `GET`, the [handler] will also be called for `HEAD` requests
  /// matching [route]. To explicitly implement a `HEAD` handler, register it
  /// before the `GET` handler.
  void add(String verb, String route, Handler handler) {
    final String modifiedVerb = verb.toUpperCase();

    final bool isHttpMethod =
        HttpMethod.values.firstWhereOrNull((e) => e.value == modifiedVerb) !=
            null;

    if (!isHttpMethod) {
      throw ArgumentError.value(verb, 'verb', 'expected a valid HTTP method');
    }

    if (modifiedVerb == 'GET') {
      _routes.add(RouterEntry('HEAD', route, handler));
    }
    _routes.add(RouterEntry(verb, route, handler));
  }

  /// Handle all requests to [route] using [handler].
  void all(String route, Handler handler) {
    _routes.add(RouterEntry('ALL', route, handler));
  }

  /// Mount a handler below a prefix.
  void mount(String prefix, Handler handler) {
    if (!prefix.startsWith('/')) {
      throw ArgumentError.value(prefix, 'prefix', 'must start with a slash');
    }

    final path = prefix.substring(1);
    if (prefix.endsWith('/')) {
      all('$prefix<path|[^]*>', (Request request) {
        return handler(request.copyWith(path: path));
      });
    } else {
      all(prefix, (Request request) {
        return handler(request.copyWith(path: path));
      });
      all('$prefix/<path|[^]*>', (Request request) {
        return handler(request.copyWith(path: '$path/'));
      });
    }
  }

  /// Route incoming requests to registered handlers.
  Future<Response> call(Request request) async {
    for (final route in _routes) {
      if (route.verb != request.method.name.toUpperCase() &&
          route.verb != 'ALL') {
        continue;
      }
      final params = route.match('/${request.url.path}');
      if (params != null) {
        final response = await route.invoke(request, params);
        if (response != routeNotFound) {
          return response;
        }
      }
    }
    return _notFoundHandler(request);
  }

  /// Handle `GET` request to [route] using [handler].
  void get(String route, Handler handler) => add('GET', route, handler);

  /// Handle `HEAD` request to [route] using [handler].
  void head(String route, Handler handler) => add('HEAD', route, handler);

  /// Handle `POST` request to [route] using [handler].
  void post(String route, Handler handler) => add('POST', route, handler);

  /// Handle `PUT` request to [route] using [handler].
  void put(String route, Handler handler) => add('PUT', route, handler);

  /// Handle `DELETE` request to [route] using [handler].
  void delete(String route, Handler handler) => add('DELETE', route, handler);

  /// Handle `CONNECT` request to [route] using [handler].
  void connect(String route, Handler handler) => add('CONNECT', route, handler);

  /// Handle `OPTIONS` request to [route] using [handler].
  void options(String route, Handler handler) => add('OPTIONS', route, handler);

  /// Handle `TRACE` request to [route] using [handler].
  void trace(String route, Handler handler) => add('TRACE', route, handler);

  /// Handle `PATCH` request to [route] using [handler].
  void patch(String route, Handler handler) => add('PATCH', route, handler);

  static Future<Response> _defaultNotFound(Request request) async =>
      Response(statusCode: HttpStatus.notFound, body: 'Route not found');

  /// Sentinel [Response] object indicating that no matching route was found.
  static final Response routeNotFound = _RouteNotFoundResponse();
}

/// Extends [Response] to allow it to be used multiple times.
class _RouteNotFoundResponse extends Response {
  _RouteNotFoundResponse() : super(statusCode: 404, body: _message);
  static const _message = 'Route not found';
  static final _messageBytes = utf8.encode(_message);

  @override
  Stream<List<int>> bytes() => Stream.value(_messageBytes);

  @override
  Future<String> body() async => _message;

  @override
  Response copyWith({Map<String, Object?>? headers, Object? body}) {
    return super.copyWith(headers: headers, body: body ?? _message);
  }
}

/// Extension on [Request] which provides access to URL parameters captured by the [Router].
extension RouterParams on Request {
  /// Get URL parameters captured by the [Router].
  Map<String, String> get params {
    final p = context['params'];
    if (p is Map<String, String>) {
      return UnmodifiableMapView(p);
    }
    return UnmodifiableMapView(<String, String>{});
  }
}

/// Represents a route entry in the router.
///
/// This class encapsulates an HTTP route definition, including its HTTP method,
/// path pattern, request handler, optional middleware, and parameter extraction.
///
/// - Supports dynamic route parameters using named placeholders.
/// - Ensures valid route definitions.
/// - Provides methods for matching and invoking routes.
class RouterEntry {
  /// Factory constructor for [RouterEntry], which creates and validates a new route entry.
  ///
  /// - [verb]: The HTTP method (e.g., GET, POST).
  /// - [route]: The route pattern, which must start with `/`.
  /// - [handler]: The function that handles requests matching the route.
  /// - [middleware]: Optional middleware to wrap the handler.
  /// - [mounted]: Whether this route is part of a mounted sub-router.
  factory RouterEntry(
    String verb,
    String route,
    Handler handler, {
    MiddlewareFunc? middleware,
    bool mounted = false,
  }) {
    // Default middleware to a pass-through function if none is provided.
    middleware ??= (Handler fn) => fn;

    // Ensure that the route starts with a `/` to enforce proper URL structure.
    if (!route.startsWith('/')) {
      throw ArgumentError.value(
        route,
        'route',
        'expected route to start with a slash',
      );
    }

    final params = <String>[];
    var pattern = '';

    // Parse route pattern and extract named parameters.
    for (final m in _parser.allMatches(route)) {
      // ignore: use_string_buffers
      pattern += RegExp.escape(m[1]!);
      if (m[2] != null) {
        params.add(m[2]!);
        if (m[3] != null && !_isNoCapture(m[3]!)) {
          throw ArgumentError.value(
            route,
            'route',
            'expression for "${m[2]}" is capturing',
          );
        }
        pattern += '(${m[3] ?? '[^/]+'})';
      }
    }
    final routePattern = RegExp('^$pattern\$');

    return RouterEntry._(
      verb,
      route,
      handler,
      middleware,
      routePattern,
      params,
      mounted,
    );
  }

  /// Private constructor used by the factory method.
  RouterEntry._(
    this.verb,
    this.route,
    this._handler,
    this._middleware,
    this._routePattern,
    this._params,
    this._mounted,
  );

  /// Regular expression parser for extracting route parameters.
  static final RegExp _parser =
      RegExp(r'([^<]*)(?:<([^>|]+)(?:\|([^>]*)?)?>)?');

  /// HTTP method
  final String verb;

  /// Route pattern
  final String route;
  final Function _handler; // Handler function
  final MiddlewareFunc _middleware; // Middleware applied to the handler
  final RegExp _routePattern; // Compiled regex for route matching
  final List<String> _params; // Extracted parameter names
  final bool _mounted; // Whether the route is part of a mounted router

  /// Matches the given [path] against this route's pattern.
  /// Returns a map of extracted parameters if matched, otherwise `null`.
  Map<String, String>? match(String path) {
    final m = _routePattern.firstMatch(path);
    if (m == null) return null;
    final params = <String, String>{};
    for (var i = 0; i < _params.length; i++) {
      params[_params[i]] = m[i + 1]!;
    }
    return params;
  }

  /// Invokes the registered handler for this route.
  /// Applies middleware and extracts parameters before executing the handler.
  Future<Response> invoke(Request request, Map<String, String> params) async {
    final shelf.Request shelfRequest = request._request.change(
      context: {'shelf_router/params': params},
    );

    final updatedRequest = Request._(shelfRequest);

    return await _middleware((request) async {
      if (_mounted) {
        // Pass parameters for mounted routes.
        // ignore: avoid_dynamic_calls
        return await _handler(updatedRequest, _params) as Response;
      }

      if (_handler is Handler || _params.isEmpty) {
        // ignore: avoid_dynamic_calls
        return await _handler(updatedRequest) as Response;
      }

      // Invoke the handler with extracted parameters.
      final dynamic result = await Function.apply(_handler, <dynamic>[
        updatedRequest,
        ..._params.map((n) => params[n]),
      ]);
      return result as Response;
    })(updatedRequest);
  }
}

/// Determines if a regex pattern does not capture values.
bool _isNoCapture(String regexp) {
  return RegExp('^(?:$regexp)|.*\$').firstMatch('')!.groupCount == 0;
}
