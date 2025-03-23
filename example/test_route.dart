import 'package:ruta/annotations.dart';
import 'package:ruta/open_api.dart';
import 'package:ruta/ruta.dart';

@RutaRoute()
class TestRoute extends Route {
  const TestRoute();

  @override
  List<Endpoint> get endpoints => [
        Endpoint(
          path: 'test/<id>',
          method: HttpMethod.get,
          summary: 'Summary of the test endpoint',
          description: 'Some test endpoint description',
          authRequired: true,
          body: [
            Field<String>('password', isRequired: false),
            Field<Map<String, dynamic>>(
              'items',
              children: [
                Field<int>('something'),
              ],
            ),
          ],
          responses: [
            OpenApiResponse(
              statusCode: 200,
              description: 'Provides email',
              properties: [
                Field<String>('email', isRequired: false),
              ],
            ),
          ],
          query: [
            Field<int>('name'),
          ],
          handler: (req) {
            print(434);
            return Response.json(body: {'email': 'example@gmail.com'});
          },
        ),
      ];

  @override
  List<Middleware> get middlewares => [
        (Handler handler) {
          return (req) {
            print(req.uri);
            return handler(req);
          };
        },
      ];
}
