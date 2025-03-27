import 'dart:io';

import 'package:ruta/ruta.dart';

Future<HttpServer> defaultRutaRun(
  Handler Function() handlerCallback,
  InternetAddress address,
  int port,
) {
  return serve(handlerCallback(), address, port);
}
