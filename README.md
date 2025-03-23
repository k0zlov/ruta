# Ruta Framework

Ruta is a lightweight and flexible backend framework for Dart, inspired
by [dart_frog](https://github.com/VeryGoodOpenSource/dart_frog). It provides a simple and intuitive way to build RESTful
APIs and web servers with a focus on developer productivity and performance.

## Features

- **Simple Routing**: Define routes with ease using a clean and expressive syntax.
- **Middleware Support**: Add middleware to handle cross-cutting concerns like logging, authentication, and more.
- **Lightweight**: Minimal overhead for fast and efficient server-side applications.
- **Dart-Powered**: Leverage the power of Dart for type safety and modern language features.

## Getting Started

1. Add `ruta` to your `pubspec.yaml`:
   ```yaml
   dependencies:
     ruta: ^0.1.0
   dev_dependencies:
     ruta_generator: ^0.1.0

2. Create a route using Ruta's annotation-based system:
   ```dart
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

3. Activate Ruta CLI:
   ```bash
   dart pub global activate ruta_cli

4. Generate and run your server using the Ruta CLI:
   ```bash
   ruta run
   
Your server will start, and you can test the endpoint at http://localhost:8080/test/123?name=42


