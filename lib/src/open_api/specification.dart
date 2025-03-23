import 'package:ruta/src/core/validation/field.dart';
import 'package:ruta/src/open_api/field_to_open_api.dart';

class OpenApiSpec {
  const OpenApiSpec({
    required this.info,
    this.externalDocs,
    this.servers,
  });

  final OpenApiInfo info;
  final OpenApiExternalDocs? externalDocs;
  final List<String>? servers;

  Map<String, dynamic> toMap() => {
        'openapi': '3.0.1',
        'info': info.toMap(),
        'externalDocs': externalDocs?.toMap(),
        'servers': servers?.map((e) => {'url': e}).toList(),
      };
}

class OpenApiInfo {
  const OpenApiInfo({
    required this.version,
    required this.title,
    this.description,
    this.termsOfService,
    this.contact,
    this.licence,
  });

  final String version;
  final String title;
  final String? description;
  final String? termsOfService;

  final OpenApiContact? contact;
  final OpenApiLicence? licence;

  Map<String, dynamic> toMap() => {
        'version': version,
        'title': title,
        'termsOfService': termsOfService,
        'description': description,
        'contact': contact?.toMap(),
        'license': licence?.toMap(),
      };
}

class OpenApiLicence {
  const OpenApiLicence({
    required this.name,
    required this.url,
  });

  final String name;
  final String url;

  Map<String, dynamic> toMap() => {'url': url, 'name': name};
}

class OpenApiContact {
  const OpenApiContact({
    this.name,
    this.email,
  });

  final String? name;
  final String? email;

  Map<String, dynamic> toMap() => {'name': name, 'email': email};
}

class OpenApiExternalDocs {
  const OpenApiExternalDocs({
    required this.description,
    required this.url,
  });

  final String description;
  final String url;

  Map<String, String> toMap() => {'url': url, 'description': description};
}

class OpenApiResponse {
  const OpenApiResponse({
    required this.statusCode,
    this.description,
    this.properties,
  });

  final int statusCode;
  final String? description;
  final List<Field<Object>>? properties;

  Map<String, dynamic> toMap() => {
        '$statusCode': innerMap(),
      };

  Map<String, dynamic> innerMap() {
    final responseMap = <String, dynamic>{};

    if (description != null) {
      responseMap['description'] = description;
    }

    // Handle properties if provided
    if (properties != null && properties!.isNotEmpty) {
      responseMap['content'] = {
        'application/json': {
          'schema': {
            'type': 'object',
            'properties': {
              for (final field in properties!) field.name: fieldToSchema(field),
            },
            'required': properties!
                .where((field) => field.isRequired)
                .map((field) => field.name)
                .toList(),
          },
        },
      };
    } else {
      // Default schema if no properties are specified
      responseMap['content'] = {
        'application/json': {
          'schema': {'type': 'object'},
        },
      };
    }

    return responseMap;
  }
}
