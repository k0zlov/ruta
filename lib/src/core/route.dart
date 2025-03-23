/// for generation
library ruta;

import 'package:ruta/ruta.dart';
import 'package:ruta/src/open_api/specification.dart';

import '_internal.dart';

abstract class Route {
  const Route();

  String get name {
    final className = runtimeType.toString();
    final firstWord = className.split(RegExp('(?=[A-Z])')).first.toLowerCase();
    return firstWord;
  }

  String? get description => null;

  OpenApiExternalDocs? get externalDocs => null;

  List<Middleware> get middlewares;

  List<Endpoint> get endpoints;

  Handler build() {
    Pipeline pipeline = const Pipeline();

    for (final Middleware middleware in middlewares) {
      pipeline = pipeline.addMiddleware(middleware);
    }

    final router = Router();

    for (final Endpoint endpoint in endpoints) {
      router.add(
        endpoint.method.value,
        '/${endpoint.path}',
        endpoint.build(),
      );
    }

    return pipeline.addHandler(router.call);
  }
}
