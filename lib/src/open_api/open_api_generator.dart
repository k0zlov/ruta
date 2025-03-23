import 'dart:convert';
import 'dart:io';
import 'package:ruta/open_api.dart';
import 'package:ruta/ruta.dart';
import 'package:ruta/src/open_api/field_to_open_api.dart';

class OpenApiGenerator {
  static void generate(
    OpenApiSpec spec,
    List<Route> routes, {
    String outputPath = '.ruta/openapi.json',
  }) {
    final specMap = spec.toMap();

    // Define security schemes for Bearer authentication
    specMap['components'] = {
      'securitySchemes': {
        'bearerAuth': {
          'type': 'http',
          'scheme': 'bearer',
          'bearerFormat': 'JWT', // Optional: specifies JWT as the format
        },
      },
    };

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
    for (final route in routes) {
      final basePath = '/${route.name}';
      for (final endpoint in route.endpoints) {
        String fullPath = '$basePath/${endpoint.path}';
        final pathParams = _extractPathParams(fullPath);
        fullPath = _convertPathParams(fullPath);

        final operation = <String, dynamic>{
          'tags': [route.name],
        };

        if (endpoint.summary != null) {
          operation['summary'] = endpoint.summary;
        }
        if (endpoint.description != null) {
          operation['description'] = endpoint.description;
        }

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

        if (endpoint.query != null && endpoint.query!.isNotEmpty) {
          operation['parameters'] ??= [];
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

        // Add Bearer authentication if authRequired is true
        if (endpoint.authRequired) {
          operation['security'] = [
            {'bearerAuth': []},
          ];
        }

        // Handle List<OpenApiResponse> for responses
        operation['responses'] = {
          for (final response in endpoint.responses)
            response.statusCode.toString(): response.innerMap(),
        };

        paths[fullPath] = {
          endpoint.method.name.toLowerCase(): operation,
        };
      }
    }

    specMap['tags'] = tags;
    specMap['paths'] = paths;

    const jsonEncoder = JsonEncoder.withIndent('  ');
    final jsonString = jsonEncoder.convert(specMap);

    final directory = Directory('.ruta');
    if (!directory.existsSync()) {
      directory.createSync();
    }

    File(outputPath).writeAsStringSync(jsonString);
    print('Generated OpenAPI spec at $outputPath');
  }

  static List<String> _extractPathParams(String path) {
    final paramRegExp = RegExp('<([^>]+)>');
    return paramRegExp
        .allMatches(path)
        .map((match) => match.group(1)!)
        .toList();
  }

  static String _convertPathParams(String path) {
    return path.replaceAllMapped(
      RegExp('<([^>]+)>'),
      (match) => '{${match.group(1)}}',
    );
  }
}
