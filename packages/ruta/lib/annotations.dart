/// Annotation used to mark a class as a Ruta route.
///
/// This annotation is typically used to indicate that a class represents
/// a route in the Ruta framework.
class RutaRoute {
  /// Creates a new instance of the [RutaRoute] annotation.
  const RutaRoute();
}

/// A reusable instance of [RutaRoute] annotation.
///
/// This can be used to annotate route classes without creating multiple instances.
/// Example:
///
/// ```dart
/// @rutaRoute
/// class MyRoute {
///   // Route logic
/// }
/// ```
const rutaRoute = RutaRoute();
