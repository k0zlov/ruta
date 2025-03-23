import 'package:ruta/src/core/_internal.dart';

void main() async {
  final router = Router()
    ..get('/test', (Request request) async {
      return Response(body: 'Test route');
    });

  final server = await serve(router.call, 'localhost', 8080);
  print('Server running on localhost:${server.port}');
}
