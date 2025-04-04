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
     ruta: ^0.1.9
     getIt: ^8.0.3
     injectable: ^2.3.2
   dev_dependencies:
     build_runner: ^2.4.13
     injectable_generator: ^2.6.2
     ruta_generator: ^0.1.8

2. Create a route using Ruta's annotation-based system with dependency injection:
   ```dart
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

3. Activate Ruta CLI:
   ```bash
   dart pub global activate ruta_cli

4. Generate code for server using ruta_cli:
   ```bash
   ruta build
   ```
   or use build_runner
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```

5. Run your server using the Ruta CLI:
   ```bash
   ruta run
   ```

Your server will start, and you can test the endpoint at http://localhost:8080/info


