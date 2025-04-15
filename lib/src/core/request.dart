part of '_internal.dart';

/// An HTTP request for the Ruta framework.
class Request {
  /// Default constructor
  Request(
    String method,
    Uri uri, {
    Map<String, Object>? headers,
    Object? body,
    Encoding? encoding,
    Map<String, dynamic>? data,
  }) : this._(
          shelf.Request(
            method,
            uri,
            headers: headers,
            body: body,
            encoding: encoding,
          ),
          data,
        );

  /// An HTTP DELETE request.
  Request.delete(
    Uri uri, {
    Map<String, Object>? headers,
    Object? body,
    Encoding? encoding,
  }) : this(
          HttpMethod.delete.name.toUpperCase(),
          uri,
          headers: headers,
          body: body,
          encoding: encoding,
        );

  /// An HTTP GET request.
  Request.get(
    Uri uri, {
    Map<String, Object>? headers,
    Object? body,
    Encoding? encoding,
  }) : this(
          HttpMethod.get.name.toUpperCase(),
          uri,
          headers: headers,
          body: body,
          encoding: encoding,
        );

  /// An HTTP POST request.
  Request.post(
    Uri uri, {
    Map<String, Object>? headers,
    Object? body,
    Encoding? encoding,
  }) : this(
          HttpMethod.post.name.toUpperCase(),
          uri,
          headers: headers,
          body: body,
          encoding: encoding,
        );

  /// An HTTP PUT request.
  Request.put(
    Uri uri, {
    Map<String, Object>? headers,
    Object? body,
    Encoding? encoding,
  }) : this(
          HttpMethod.put.name.toUpperCase(),
          uri,
          headers: headers,
          body: body,
          encoding: encoding,
        );

  Request._(this._request, [Map<String, dynamic>? data]) : data = data ?? {};

  shelf.Request _request;

  //
  /// Connection information for the associated HTTP request.
  HttpConnectionInfo get connectionInfo {
    return _request.context['shelf.io.connection_info']! as HttpConnectionInfo;
  }

  /// The requested URL relative to the current handler path.
  Uri get url => _request.url;

  /// The original requested [Uri].
  Uri get uri => _request.requestedUri;

  /// The context from [shelf] request
  Map<String, Object> get context => _request.context;

  /// The HTTP headers with case-insensitive keys.
  /// The returned map is unmodifiable.
  Map<String, String> get headers => _request.headers;

  /// The User Agent of request
  String? get userAgent => headers['User-Agent'];

  /// The [HttpMethod] associated with the request.
  HttpMethod get method {
    return HttpMethod.values.firstWhere(
      (m) => m.name.toUpperCase() == _request.method,
    );
  }

  /// Returns a [Stream] representing the body.
  Stream<List<int>> bytes() => _request.read();

  /// Returns a [Future] containing the body as a [String].
  Future<String> body() async {
    const requestBodyKey = 'ruta.request.body';
    final bodyFromContext =
        _request.context[requestBodyKey] as Completer<String>?;
    if (bodyFromContext != null) return bodyFromContext.future;

    final completer = Completer<String>();
    try {
      _request = _request.change(
        context: {..._request.context, requestBodyKey: completer},
      );
      completer.complete(await _request.readAsString());
    } catch (error, stackTrace) {
      completer.completeError(error, stackTrace);
    }

    return completer.future;
  }

  /// Returns a [Future] containing the body text parsed as a JSON object.
  /// This object could be anything that can be represented by JSON
  /// (e.g., a map, a list, a string, a number, a bool).
  Future<dynamic> json() async => jsonDecode(await body());

  /// Returns a [Future] containing the form data as a [Map].
  Future<FormData> formData() {
    return parseFormData(headers: headers, body: body, bytes: bytes);
  }

  /// Creates a new [Request] by copying existing values and applying specified
  /// changes.
  Request copyWith({
    Map<String, Object?>? headers,
    Map<String, Object?>? context,
    Map<String, dynamic>? newData,
    String? path,
    Object? body,
  }) {
    return Request._(
      _request.change(
        headers: headers,
        path: path,
        body: body,
        context: context,
      ),
      data,
    );
  }

  /// Request Data after validation
  final Map<String, dynamic> data;

  /// Validates the request body and query parameters against the provided schemas.
  Future<ValidationResult> validate({
    List<Field<Object>> body = const [],
    List<Field<Object>> query = const [],
  }) async {
    if (body.isEmpty && query.isEmpty) return ValidationResult.valid();

    final errors = <String>[];
    final Set<String> checkedParams = {};

    void validateParams({
      required String name,
      required Map<String, dynamic> target,
      required List<Field<Object>> params,
    }) {
      for (final Field<Object> field in params) {
        if (checkedParams.contains(field.name)) {
          throw ArgumentError(
            'Duplicate parameter "${field.name}" found in $name validation.',
          );
        }

        final dynamic value = target[field.name];

        if (value == null && field.isRequired) {
          errors.add('$name parameter "${field.name}" was not provided.');
          continue;
        }

        final result = field.validate(value);
        if (!result.isValid) {
          errors.addAll(
            result.errors.map((e) => '$name parameter "${field.name}": $e'),
          );
        }

        data[field.name] = field.value;
        checkedParams.add(field.name);
      }
    }

    if (body.isNotEmpty) {
      Map<String, dynamic> map;
      try {
        map = await json() as Map<String, dynamic>;
      } catch (e) {
        return ValidationResult.invalid(['Request body type is invalid']);
      }

      validateParams(
        name: 'Body',
        target: map,
        params: body,
      );
    }

    if (query.isNotEmpty) {
      validateParams(
        name: 'Query',
        target: uri.queryParameters,
        params: query,
      );
    }

    return errors.isEmpty
        ? ValidationResult.valid()
        : ValidationResult.invalid(errors);
  }
}
