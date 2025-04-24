import 'package:ruta/ruta.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart' as shelf_web_socket;
import 'package:web_socket_channel/web_socket_channel.dart';

/// Creates a WebSocket handler that delegates connections to the provided `onConnection` callback.
///
/// The handler uses the `webSocketHandler` from the `shelf_web_socket` package.
///
/// - [onConnection]: Callback function called when a new WebSocket connection is established.
///   It receives:
///     - `webSocket`: The `WebSocketChannel` representing the current WebSocket connection.
///     - `subprotocol`: An optional string specifying the selected subprotocol (if any).
///
/// - [protocols]: An optional list of WebSocket protocols the server will accept.
/// - [allowedOrigins]: An optional list of the allowed origins for WebSocket connections.
/// - [pingInterval]: An optional duration for the interval at which ping frames should be sent
///   to the client to keep the connection alive.

Handler webSocketHandler(
  void Function(WebSocketChannel webSocket, String? subprotocol) onConnection, {
  Iterable<String>? protocols,
  Iterable<String>? allowedOrigins,
  Duration? pingInterval,
}) =>
    fromShelfHandler(shelf_web_socket.webSocketHandler(onConnection));
