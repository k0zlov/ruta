import 'dart:async';

import 'package:ruta/ruta.dart';

typedef Handler = FutureOr<Response> Function(Request request);
