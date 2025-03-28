// ignore_for_file: inference_failure_on_collection_literal
import 'dart:convert';
import 'dart:io';
import 'package:ruta/open_api.dart';
import 'package:ruta/ruta.dart';
import 'package:ruta/src/open_api/field_to_open_api.dart';

/// Generates an OpenAPI specification based on Ruta routes.
///
/// This class creates a JSON OpenAPI specification using the given [OpenApiSpec]
/// and a list of routes.
/// The generated specification is saved as a file in the specified output path.
class OpenApiGenerator {
  /// Generates an OpenAPI specification and writes it to a file.
  ///
  /// - [spec] — The OpenAPI specification object containing basic metadata.
  /// - [routes] — A list of application routes used to build the API schema.
  /// - [outputPath] — The path where the JSON file will be saved
  ///   (defaults to `.ruta/openapi.json`).
  static void generate(
    OpenApiSpec spec,
    List<Route> routes, {
    String outputPath = '.ruta/openapi.json',
  }) {
    final specMap = spec.toMap();

    // Define security schemes using Bearer token (JWT)
    specMap['components'] = {
      'securitySchemes': {
        'bearerAuth': {
          'type': 'http',
          'scheme': 'bearer',
          'bearerFormat': 'JWT', // Optional: specifies the JWT format
        },
      },
    };

    // Generate tags for API routes
    final tags = routes
        .map(
          (route) => {
            'name': route.name,
            'description': route.description ?? 'Operations for ${route.name}',
            if (route.externalDocs != null)
              'externalDocs': route.externalDocs!.toMap(),
          },
        )
        .toList();

    final paths = <String, dynamic>{};

    // Process each route and its endpoints
    for (final route in routes) {
      final basePath = '/${route.name}';
      for (final endpoint in route.endpoints) {
        String fullPath = '$basePath/${endpoint.path}';
        final pathParams = _extractPathParams(fullPath);
        fullPath = _convertPathParams(fullPath);

        final operation = <String, dynamic>{
          'tags': [route.name],
        };

        // Add request description
        if (endpoint.summary != null) {
          operation['summary'] = endpoint.summary;
        }
        if (endpoint.description != null) {
          operation['description'] = endpoint.description;
        }

        // Add path parameters
        if (pathParams.isNotEmpty) {
          operation['parameters'] = pathParams
              .map(
                (param) => {
                  'name': param,
                  'in': 'path',
                  'required': true,
                  'schema': {'type': 'string'},
                },
              )
              .toList();
        }

        // Add query parameters
        if (endpoint.query != null && endpoint.query!.isNotEmpty) {
          operation['parameters'] ??= [];
          // ignore: avoid_dynamic_calls
          operation['parameters'].addAll(
            endpoint.query!.map(
              (field) => {
                'name': field.name,
                'in': 'query',
                'required': field.isRequired,
                'schema': fieldToSchema(field),
              },
            ),
          );
        }

        // Add request body if applicable
        if (endpoint.body != null && endpoint.body!.isNotEmpty) {
          operation['requestBody'] = {
            'content': {
              'application/json': {
                'schema': {
                  'type': 'object',
                  'properties': {
                    for (final field in endpoint.body!)
                      field.name: fieldToSchema(field),
                  },
                  'required': endpoint.body!
                      .where((field) => field.isRequired)
                      .map((field) => field.name)
                      .toList(),
                },
              },
            },
          };
        }

        // Add authentication if required
        if (endpoint.authRequired) {
          operation['security'] = [
            {'bearerAuth': []},
          ];
        }

        // Add possible API responses
        operation['responses'] = {
          for (final response in endpoint.responses)
            response.statusCode.toString(): response.innerMap(),
        };

        // Initialize the path entry if it doesn't exist
        paths[fullPath] ??= <String, dynamic>{};

        // Add or update the method for this path
        // ignore: avoid_dynamic_calls
        paths[fullPath]![endpoint.method.name.toLowerCase()] = operation;
      }
    }

    // Add tags and paths to the final specification
    specMap['tags'] = tags;
    specMap['paths'] = paths;

    // Format JSON with indentation
    const jsonEncoder = JsonEncoder.withIndent('  ');
    final jsonString = jsonEncoder.convert(specMap);

    // Create directory if it does not exist
    final directory = Directory('.ruta');
    if (!directory.existsSync()) {
      directory.createSync();
    }

    // Write JSON to file
    File(outputPath).writeAsStringSync(jsonString);
  }

  /// Extracts path parameters from a given route path.
  ///
  /// For example, given the path `/users/<id>`, this method returns `['id']`.
  ///
  /// - [path] — The route path containing parameters in `<param>` format.
  /// - Returns a list of path parameter names.
  static List<String> _extractPathParams(String path) {
    final paramRegExp = RegExp('<([^>]+)>');
    return paramRegExp
        .allMatches(path)
        .map((match) => match.group(1)!)
        .toList();
  }

  /// Converts path parameters from `<param>` format to `{param}` format.
  ///
  /// For example, `'/users/<id>'` will be converted to `'/users/{id}'`,
  /// which is compatible with OpenAPI standards.
  ///
  /// - [path] — The route path containing parameters in `<param>` format.
  /// - Returns a path string with parameters in `{param}` format.
  static String _convertPathParams(String path) {
    return path.replaceAllMapped(
      RegExp('<([^>]+)>'),
      (match) => '{${match.group(1)}}',
    );
  }
}
