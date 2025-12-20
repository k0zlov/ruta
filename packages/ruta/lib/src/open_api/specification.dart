import 'package:ruta/src/core/validation/field.dart';

/// Imports utility to convert fields to OpenAPI schema.
/// Provides functionality to transform Field objects into OpenAPI format.
import 'package:ruta/src/open_api/field_to_open_api.dart';

/// Represents the OpenAPI specification for an API.
///
/// This class defines the structure of an OpenAPI document,
/// including metadata, external documentation, and server details.
///
/// Example usage:
/// ```dart
/// final spec = OpenApiSpec(
///   info: OpenApiInfo(version: '1.0.0', title: 'My API'),
///   servers: ['https://api.example.com'],
/// );
/// final specMap = spec.toMap();
/// ```
class OpenApiSpec {
  /// Creates an OpenAPI specification instance.
  ///
  /// Parameters:
  /// - [info] contains the metadata of the API (required).
  /// - [externalDocs] provides links to external documentation (optional).
  /// - [servers] lists the servers where the API is available (optional).
  const OpenApiSpec({
    required this.info,
    this.externalDocs,
    this.servers,
  });

  /// Metadata about the API.
  /// Contains essential information like version and title.
  final OpenApiInfo info;

  /// External documentation reference for the API.
  /// Optional field that can link to additional documentation.
  final OpenApiExternalDocs? externalDocs;

  /// List of server URLs where the API is hosted.
  /// Optional list of strings representing server endpoints.
  final List<String>? servers;

  /// Converts the OpenAPI specification into a map for serialization.
  ///
  /// Returns a map representation following OpenAPI 3.0.1 format.
  /// Includes version, info, external docs, and servers in OpenAPI structure.
  Map<String, dynamic> toMap() => {
        'openapi': '3.0.1',
        'info': info.toMap(),
        'externalDocs': externalDocs?.toMap(),
        'servers': servers?.map((e) => {'url': e}).toList(),
      };
}

/// Provides general metadata about the API.
///
/// This includes versioning, title, description, terms of service,
/// contact information, and licensing details.
class OpenApiInfo {
  /// Creates API metadata for OpenAPI documentation.
  ///
  /// Parameters:
  /// - [version] The version of the API (required).
  /// - [title] The name of the API (required).
  /// - [description] Optional description of the API.
  /// - [termsOfService] URL to the API's terms of service (optional).
  /// - [contact] Contact information for the API maintainer (optional).
  /// - [licence] Licensing information for the API (optional).
  const OpenApiInfo({
    required this.version,
    required this.title,
    this.description,
    this.termsOfService,
    this.contact,
    this.licence,
  });

  /// The version number of the API.
  final String version;

  /// The title or name of the API.
  final String title;

  /// A brief description of the API's purpose or functionality.
  final String? description;

  /// URL pointing to the terms of service document.
  final String? termsOfService;

  /// Contact information for the API maintainers.
  final OpenApiContact? contact;

  /// Licensing details for the API usage.
  final OpenApiLicence? licence;

  /// Converts API metadata into a map for OpenAPI serialization.
  ///
  /// Returns a map containing all metadata fields in OpenAPI format.
  Map<String, dynamic> toMap() => {
        'version': version,
        'title': title,
        'termsOfService': termsOfService,
        'description': description,
        'contact': contact?.toMap(),
        'license': licence?.toMap(),
      };
}

/// Represents licensing information for an API.
class OpenApiLicence {
  /// Creates an OpenAPI-compliant license object.
  ///
  /// Parameters:
  /// - [name] The name of the license (required).
  /// - [url] A link to the full license text (required).
  const OpenApiLicence({
    required this.name,
    required this.url,
  });

  /// The name or identifier of the license.
  final String name;

  /// URL to the full license documentation.
  final String url;

  /// Converts license information into a map.
  ///
  /// Returns a map with name and URL in OpenAPI license format.
  Map<String, dynamic> toMap() => {'url': url, 'name': name};
}

/// Represents the contact details of an API maintainer.
class OpenApiContact {
  /// Creates a contact object for OpenAPI documentation.
  ///
  /// Parameters:
  /// - [name] The name of the contact person (optional).
  /// - [email] The email address of the contact person (optional).
  const OpenApiContact({
    this.name,
    this.email,
  });

  /// Name of the contact person or entity.
  final String? name;

  /// Email address for contacting the API maintainers.
  final String? email;

  /// Converts contact details into a map.
  ///
  /// Returns a map with name and email in OpenAPI contact format.
  Map<String, dynamic> toMap() => {'name': name, 'email': email};
}

/// Represents external documentation links in an OpenAPI spec.
class OpenApiExternalDocs {
  /// Creates an external documentation reference.
  ///
  /// Parameters:
  /// - [description] A short description of the documentation (required).
  /// - [url] The URL pointing to the external documentation (required).
  const OpenApiExternalDocs({
    required this.description,
    required this.url,
  });

  /// Brief description of what the external documentation contains.
  final String description;

  /// URL linking to the external documentation resource.
  final String url;

  /// Converts external documentation details into a map.
  ///
  /// Returns a map with URL and description in OpenAPI format.
  Map<String, String> toMap() => {'url': url, 'description': description};
}

/// Represents an HTTP response in an OpenAPI specification.
class OpenApiResponse {
  /// Creates an OpenAPI response object.
  ///
  /// Parameters:
  /// - [statusCode] The HTTP status code of the response (required).
  /// - [description] A description of the response (optional).
  /// - [properties] A list of fields that define the response body (optional).
  const OpenApiResponse({
    required this.statusCode,
    this.description,
    this.properties,
  });

  /// The HTTP status code for this response (e.g., 200, 404).
  final int statusCode;

  /// A human-readable description of what this response means.
  final String? description;

  /// List of fields defining the structure of the response body.
  /// Uses generic Field<Object> to describe response properties.
  final List<Field<Object>>? properties;

  /// Converts the response into an OpenAPI-compliant map.
  ///
  /// Returns a map where the status code is the key and the value
  /// is the detailed response specification.
  Map<String, dynamic> toMap() => {
        '$statusCode': innerMap(),
      };

  /// Generates the detailed OpenAPI schema for the response.
  ///
  /// Creates a nested map structure including description and content schema.
  /// If properties exist, generates a detailed JSON schema; otherwise,
  /// provides a basic object schema.
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
