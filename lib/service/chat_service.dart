import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:openearth_mobile/model/chat_conversation.dart';
import 'package:openearth_mobile/model/chat_message.dart';
import 'package:openearth_mobile/model/message_attachment.dart';
import '../configuration/environment.dart';
import 'auth_service.dart';

class ChatService {
  final String apiUrl = environment.rootUrl;
  final String chatApiUrl = environment.rootUrl + '/chat';
  final String wsUrl = environment.rootUrl.replaceFirst('http', 'ws') + '/ws/chat';

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  bool _connected = false;

  // Stream controller para mensajes
  final _messageController = StreamController<ChatMessage>.broadcast();
  Stream<ChatMessage> get messageStream => _messageController.stream;

  final AuthService authService = AuthService();

  // Conectar al WebSocket
  Future<void> connect(int userId, String username) async {
    if (_connected) {
      return;
    }

    final token = await authService.retrieveToken();
    if (token.isEmpty) {
      print('Error: Token no encontrado. Inicie sesión primero.');
      return;
    }

    try {
      // Crear la conexión WebSocket con el token de autenticación
      final uri = Uri.parse('$wsUrl?token=$token&userId=$userId&username=$username');
      _channel = IOWebSocketChannel.connect(uri);

      // Escuchar mensajes entrantes
      _subscription = _channel!.stream.listen(
            (dynamic message) {
          try {
            final decodedMessage = jsonDecode(message);
            final chatMessage = ChatMessage.fromJson(decodedMessage);
            _messageController.add(chatMessage);
          } catch (e) {
            print('Error al procesar mensaje: $e');
          }
        },
        onError: (error) {
          print('Error en WebSocket: $error');
          _reconnect(userId, username);
        },
        onDone: () {
          print('Conexión WebSocket cerrada');
          _reconnect(userId, username);
        },
      );

      _connected = true;
      print('WebSocket conectado exitosamente');
    } catch (e) {
      print('Error al conectar WebSocket: $e');
      // Reintentar conexión después de un tiempo
      Future.delayed(Duration(seconds: 5), () => connect(userId, username));
    }
  }

  // Reconectar en caso de desconexión
  void _reconnect(int userId, String username) {
    if (_connected) {
      _connected = false;
      _closeConnection();
      Future.delayed(Duration(seconds: 5), () => connect(userId, username));
    }
  }

  // Desconectar WebSocket
  void disconnect() {
    if (_connected) {
      _connected = false;
      _closeConnection();
    }
  }

  void _closeConnection() {
    _subscription?.cancel();
    _channel?.sink.close();
    _subscription = null;
    _channel = null;
  }

  // Enviar mensaje a través de WebSocket
  void sendWebSocketMessage(Map<String, dynamic> message) {
    if (_connected && _channel != null) {
      try {
        _channel!.sink.add(jsonEncode(message));
      } catch (e) {
        print('Error al enviar mensaje por WebSocket: $e');
      }
    } else {
      print('No se puede enviar mensaje: WebSocket no conectado');
    }
  }

  // Marcar mensaje como leído a través de WebSocket
  void markMessageAsRead(int messageId, int userId) {
    if (_connected) {
      sendWebSocketMessage({
        'type': 'READ',
        'messageId': messageId,
        'userId': userId
      });
    }
  }

  // Enviar mensaje de texto a través de WebSocket
  void sendTextMessageWS(int senderId, int receiverId, String content) {
    if (_connected) {
      sendWebSocketMessage({
        'type': 'TEXT',
        'senderId': senderId,
        'receiverId': receiverId,
        'content': content,
      });
    }
  }

  // ---- Métodos HTTP REST API ----

  Future<List<ChatConversation>> getConversations() async {
    final url = '$chatApiUrl/conversations';
    final token = await authService.retrieveToken();

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatConversation.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load conversations');
    }
  }

  Future<List<ChatMessage>> getMessageHistory(int otherUserId) async {
    final url = '$chatApiUrl/messages/$otherUserId';
    final token = await authService.retrieveToken();

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': token},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ChatMessage.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load message history');
    }
  }

  Future<ChatMessage> sendTextMessage(int receiverId, String textContent) async {
    final url = '$chatApiUrl/send';
    final token = await authService.retrieveToken();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'receiverId': receiverId,
        'content': textContent
      }),
    );

    if (response.statusCode == 200) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message');
    }
  }

  Future<ChatMessage> sendAudioMessage(int receiverId, dynamic audioFile) async {
    final url = '$chatApiUrl/send-audio';
    final token = await authService.retrieveToken();

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = token;

    request.fields['receiverId'] = receiverId.toString();
    request.files.add(await http.MultipartFile.fromPath(
      'audioFile',
      audioFile.path,
    ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send audio message');
    }
  }

  Future<ChatMessage> sendMessageWithAttachments(
      int receiverId, String textContent, List<MessageAttachment> attachments) async {
    final url = '$chatApiUrl/send';
    final token = await authService.retrieveToken();

    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Authorization': token,
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'receiverId': receiverId,
        'textContent': textContent,
        'attachments': attachments.map((a) => a.toJson()).toList()
      }),
    );

    if (response.statusCode == 200) {
      return ChatMessage.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to send message with attachments');
    }
  }

  Future<MessageAttachment> uploadAttachment(dynamic file, String type) async {
    final url = '$chatApiUrl/upload-attachment';
    final token = await authService.retrieveToken();

    final request = http.MultipartRequest('POST', Uri.parse(url));
    request.headers['Authorization'] = token;

    request.files.add(await http.MultipartFile.fromPath(
      'file',
      file.path,
    ));
    request.fields['type'] = type;

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return MessageAttachment.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to upload attachment');
    }
  }

  // Cerrar recursos al destruir el servicio
  void dispose() {
    disconnect();
    _messageController.close();
  }
}