import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:openearth_mobile/model/chat_conversation.dart';
import 'package:openearth_mobile/model/chat_message.dart';
import '../configuration/environment.dart';
import 'auth_service.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  final AuthService _authService = new AuthService();
  factory ChatService() => _instance;
  ChatService._internal();

  final String apiUrl = environment.rootUrl;
  final String chatApiUrl = environment.rootUrl + '/chat';
  final String wsUrl = environment.rootUrl.replaceFirst('/api', '').replaceFirst("http", "ws") + '/ws/chat-native';

  StompClient? _stompClient;
  Timer? _reconnectTimer;

  // Estado de conexión
  bool _isConnected = false;
  int _reconnectAttempts = 0;
  static const Duration _reconnectDelay = Duration(seconds: 5);

  // Stream controllers
  final _messageController = StreamController<ChatMessage>.broadcast();

  // Getters públicos
  Stream<ChatMessage> get messageStream => _messageController.stream;
  bool get isConnected => _isConnected;

  final AuthService authService = AuthService();
  int? _currentUserId;
  String? _currentUsername;

  Future<void> connect() async {
    if (_isConnected || _stompClient != null) {
      print('ChatService: Ya conectado o conexión en progreso');
      return;
    }

    final token = await authService.retrieveToken();
    if (token.isEmpty) {
      print('ChatService: Error - Token no disponible');
      _scheduleReconnect();
      return;
    }

    await _getCurrentUserId();
    await _getCurrentUsername();

    try {
      await _establishConnection(token);
    } catch (e) {
      print('ChatService: Error en conexión inicial: $e');
      _handleConnectionError(e);
    }
  }

  Future<void> _getCurrentUserId() async {
    if (_currentUserId != null) return;
    _currentUserId = await _authService.getMyId();
  }

  Future<void> _getCurrentUsername() async {
    if (_currentUsername != null) return;
    _currentUsername = await _authService.getMyUsername();
  }

  // Establece la conexión STOMP WebSocket
  Future<void> _establishConnection(String token) async {
    // Cerrar conexión existente si la hay
    await _closeConnection();

    final wsUri = wsUrl + '?token=' + Uri.encodeComponent(token);
    print('ChatService: Conectando a $wsUri');

    _stompClient = StompClient(
      config: StompConfig(
        url: wsUri,
        onConnect: _onConnect,
        onWebSocketError: _handleConnectionError,
        onStompError: _handleStompError,
        onDisconnect: _onDisconnect,
        heartbeatIncoming: Duration(seconds: 20),
        heartbeatOutgoing: Duration(seconds: 20),
        connectionTimeout: Duration(seconds: 10),
      ),
    );

    _stompClient!.activate();
  }

  // Callback cuando se establece la conexión STOMP
  void _onConnect(StompFrame frame) {
    print('ChatService: Conectado exitosamente');
    _isConnected = true;
    _reconnectAttempts = 0;

    // Suscribirse a mensajes privados para el usuario actual
    if (_currentUserId != null) {
      _subscribeToUserMessages(_currentUserId!);
    } else {
      print('ChatService: Warning - No se pudo suscribir, userId es null');
      // Intentar obtener el userId de nuevo
      _getCurrentUserId().then((_) {
        if (_currentUserId != null) {
          _subscribeToUserMessages(_currentUserId!);
        }
      });
    }
  }

  // Suscribirse a mensajes del usuario
  void _subscribeToUserMessages(int userId) {
    if (_stompClient == null || !_isConnected) {
      print('ChatService: No se puede suscribir - cliente no conectado');
      return;
    }

    try {
      _stompClient!.subscribe(
        destination: '/user/${this._currentUsername}/queue/messages',
        callback: (StompFrame frame) {
          print('ChatService: Frame recibido: ${frame.body}');
          _handleMessage(frame.body);
        },
      );

      print('ChatService: Suscrito exitosamente a mensajes del usuario $userId');
    } catch (e) {
      print('ChatService: Error suscribiéndose: $e');
    }
  }

  // Maneja mensajes recibidos del WebSocket
  void _handleMessage(String? messageBody) {
    print('ChatService: Procesando mensaje: $messageBody');

    if (messageBody == null) {
      print('ChatService: MessageBody es null');
      return;
    }

    try {
      final decodedMessage = jsonDecode(messageBody);
      print('ChatService: Mensaje decodificado: $decodedMessage');

      if (decodedMessage is Map<String, dynamic>) {
        final chatMessage = ChatMessage.fromJson(decodedMessage);
        print('ChatService: ChatMessage creado - De: ${chatMessage.senderId}, Para: ${chatMessage.receiverId}, Contenido: ${chatMessage.textContent}');

        _messageController.add(chatMessage);
        print('ChatService: Mensaje añadido al stream');
      } else {
        print('ChatService: Mensaje decodificado no es un Map');
      }
    } catch (e) {
      print('ChatService: Error procesando mensaje: $e');
    }
  }

  // Maneja errores STOMP
  void _handleStompError(StompFrame frame) {
    print('ChatService: Error STOMP: ${frame.body}');
    _handleConnectionError(frame.body);
  }

  // Callback cuando se desconecta
  void _onDisconnect(StompFrame frame) {
    print('ChatService: Desconectado del servidor');
    _isConnected = false;
    _handleConnectionError(frame.body);
  }

  // Maneja errores de conexión
  void _handleConnectionError(dynamic error) {
    print('ChatService: Error de conexión: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  // Programa reintentoa de reconexión
  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    // Calcular delay
    final delaySeconds = (_reconnectDelay.inSeconds * _reconnectAttempts).clamp(5, 30);
    final delay = Duration(seconds: delaySeconds);

    print('ChatService: Reintentando conexión en ${delay.inSeconds}s (intento $_reconnectAttempts)');

    _reconnectTimer = Timer(delay, () {
      connect();
    });
  }

  // Desconecta del WebSocket
  Future<void> disconnect() async {
    print('ChatService: Desconectando...');
    _reconnectTimer?.cancel();
    await _closeConnection();
    _isConnected = false;
  }

  // Cierra la conexión STOMP
  Future<void> _closeConnection() async {
    try {
      _stompClient?.deactivate();
    } catch (e) {
      print('ChatService: Error cerrando conexión: $e');
    } finally {
      _stompClient = null;
    }
  }

  // Envía un mensaje por STOMP WebSocket
  void _sendStompMessage(String destination, Map<String, dynamic> message) {
    if (!isConnected || _stompClient == null) {
      print('ChatService: No se puede enviar mensaje - STOMP no conectado');
      return;
    }

    try {
      _stompClient!.send(
        destination: destination,
        body: jsonEncode(message),
      );
      print('ChatService: Mensaje enviado a $destination');
    } catch (e) {
      print('ChatService: Error enviando mensaje: $e');
      _handleConnectionError(e);
    }
  }

  // Marca un mensaje como leído
  void markMessageAsRead(int messageId, int userId) {
    _sendStompMessage('/app/message.read', {
      'messageId': messageId,
      'userId': userId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // Envía mensaje de texto por WebSocket
  void sendTextMessageWS(int senderId, int receiverId, String content) {
    if (content.trim().isEmpty) {
      print('ChatService: No se puede enviar mensaje vacío');
      return;
    }

    _currentUserId = senderId; // Guardar ID del usuario actual

    _sendStompMessage('/app/message.send', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content.trim(),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  // ---- Métodos HTTP REST API ----

  // Obtiene lista de conversaciones
  Future<List<ChatConversation>> getConversations() async {
    final url = '$chatApiUrl/conversations';
    final token = await authService.retrieveToken();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatConversation.fromJson(json)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('ChatService: Error obteniendo conversaciones: $e');
      rethrow;
    }
  }

  // Obtiene historial de mensajes
  Future<List<ChatMessage>> getMessageHistory(int otherUserId) async {
    final url = '$chatApiUrl/messages/$otherUserId';
    final token = await authService.retrieveToken();

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('ChatService: Error obteniendo historial: $e');
      rethrow;
    }
  }

  // Envía mensaje de texto por HTTP
  Future<ChatMessage> sendTextMessage(int receiverId, String textContent) async {
    if (textContent.trim().isEmpty) {
      throw Exception('El contenido del mensaje no puede estar vacío');
    }

    final url = '$chatApiUrl/send';
    final token = await authService.retrieveToken();

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': token,
          'Content-Type': 'application/json'
        },
        body: jsonEncode({
          'receiverId': receiverId,
          'content': textContent.trim()
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        final chatMessage = ChatMessage.fromJson(jsonDecode(response.body));

        // Asegurar que tenemos el userId actual
        if (_currentUserId == null) {
          _currentUserId = chatMessage.senderId;
        }

        return chatMessage;
      } else {
        throw Exception('Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('ChatService: Error enviando mensaje: $e');
      rethrow;
    }
  }

  // Método para forzar la suscripción (útil para debugging)
  void forceSubscription() {
    if (_currentUserId != null && _isConnected) {
      _subscribeToUserMessages(_currentUserId!);
    } else {
      print('ChatService: No se puede forzar suscripción - userId: $_currentUserId, connected: $_isConnected');
    }
  }

  void dispose() {
    disconnect();
    _reconnectTimer?.cancel();
    _messageController.close();
  }
}