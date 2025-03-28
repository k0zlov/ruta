import 'dart:io';

import 'package:ruta/ruta.dart';

/// Default function for running server
Future<HttpServer> defaultRutaRun(
  Handler Function() handlerCallback,
  InternetAddress address,
  int port,
) {
  return serve(handlerCallback(), address, port);
}
