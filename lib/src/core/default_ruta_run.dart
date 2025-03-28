import 'dart:io';

import 'package:ruta/ruta.dart';

/// Default function for running server
Future<HttpServer> defaultRutaRun(
  Future<Handler> Function() handlerCallback,
  InternetAddress address,
  int port,
) async {
  return serve(await handlerCallback(), address, port);
}
