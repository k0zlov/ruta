import 'package:injectable/injectable.dart';
import 'package:ruta/annotations.dart';
import 'package:ruta/ruta.dart';

@module
abstract class DependencyContainer {
  @Named('apiVersion')
  String get apiVersion => '0.0.1';
}

@rutaRoute
class InfoRoute extends Route {
  InfoRoute({
    @Named('apiVersion') required this.apiVersion,
  });

  final String apiVersion;

  Endpoint get index {
    return Endpoint.get(
      path: '',
      handler: (req) {
        return Response.json(
          body: {'apiVersion': apiVersion},
        );
      },
    );
  }
}
