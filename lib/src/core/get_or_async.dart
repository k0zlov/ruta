import 'package:get_it/get_it.dart';

/// Extension on GetIt to provide a convenience method
/// for resolving dependencies synchronously with fall-back
/// to asynchronous resolution if the instance is not ready yet.
extension GetOrAsync on GetIt {
  /// Tries to synchronously retrieve an instance of type [T].
  /// If the instance isn't yet available synchronously,
  /// it falls back to asynchronously retrieving it.
  ///
  /// Params:
  /// [instanceName]: Optional named instance identifier.
  /// [param1] and [param2]: Optional dynamic parameters for instance creation.
  /// [type]: Optional to specify a different type to retrieve than the inferred one.
  Future<T> getOrAsync<T extends Object>({
    String? instanceName,
    dynamic param1,
    dynamic param2,
    Type? type,
  }) async {
    T result;

    try {
      // First, try to synchronously retrieve an instance of type T
      result = get<T>(
        instanceName: instanceName,
        param1: param1,
        param2: param2,
        type: type,
      );
    } catch (_) {
      try {
        // If synchronous retrieval fails (likely because object is not ready yet),
        // attempt asynchronous retrieval.
        result = await getAsync<T>(
          instanceName: instanceName,
          param1: param1,
          param2: param2,
          type: type,
        );
      } catch (e) {
        // Re-throw the error if asynchronous retrieval also fails.
        rethrow;
      }
    }

    // Finally, return the instance retrieved either synchronously or asynchronously.
    return result;
  }
}
