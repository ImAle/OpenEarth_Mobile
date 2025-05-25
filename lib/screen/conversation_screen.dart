import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openearth_mobile/model/chat_message.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/service/chat_service.dart';
import 'dart:async';

class ConversationScreen extends StatefulWidget {
  final int conversationId;
  final int otherUserId;
  final String otherUsername;
  final int userId;
  final String username;

  const ConversationScreen({
    Key? key,
    required this.conversationId,
    required this.otherUserId,
    required this.otherUsername,
    required this.userId,
    required this.username,
  }) : super(key: key);

  @override
  State<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends State<ConversationScreen> with WidgetsBindingObserver {
  final ChatService _chatService = ChatService();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<ChatMessage> _messages = [];
  bool _isLoading = true;
  bool _isSending = false;
  StreamSubscription<ChatMessage>? _messageSubscription;
  bool _isScreenVisible = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeChat();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    _isScreenVisible = state == AppLifecycleState.resumed;

    if (_isScreenVisible) {
      _markVisibleMessagesAsRead();
    }
  }

  void _initializeChat() async {
    try {
      await _chatService.connect();
      print('[DEBUG] Chat service connected successfully');

      _loadMessages();
      _listenForMessages();
    } catch (e) {
      print('[ERROR] Failed to initialize chat: $e');
      if (mounted) {
        _showErrorSnackBar('Failed to connect to chat service');
      }
    }
  }

  void _loadMessages() async {
    try {
      final messages = await _chatService.getMessageHistory(widget.otherUserId);

      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });

        _markVisibleMessagesAsRead();

        // Scroll to bottom after loading
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('[ERROR] Error loading messages: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showErrorSnackBar('Error loading messages');
      }
    }
  }

  void _listenForMessages() {
    if (_chatService.messageStream == null) {
      print('[ERROR] MessageStream is null!');
      return;
    }

    _messageSubscription = _chatService.messageStream.listen(
          (message) {

        // Only process messages for current conversation
        bool isCurrentConversation =
            (message.senderId == widget.otherUserId && message.receiverId == widget.userId) ||
                (message.senderId == widget.userId && message.receiverId == widget.otherUserId);

        if (isCurrentConversation && mounted) {
          setState(() {
            // Check if message already exists to avoid duplicates
            bool messageExists = _messages.any((msg) =>
            msg.id == message.id ||
                (msg.senderId == message.senderId &&
                    msg.receiverId == message.receiverId &&
                    msg.textContent == message.textContent &&
                    msg.timestamp.difference(message.timestamp).abs().inSeconds < 2));

            print('[DEBUG] Message already exists: $messageExists');

            if (!messageExists) {
              _messages.add(message);
              // Sort messages by timestamp to ensure correct order
              _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            }
          });

          // Mark as read if message is from other user AND screen is visible || not working currently
          if (message.senderId == widget.otherUserId && message.id != null && _isScreenVisible) {
            _chatService.markMessageAsRead(message.id!, widget.userId);
            print('[DEBUG] Message marked as read immediately');
          }

          // Scroll to bottom after receiving message
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollToBottom();
            Future.delayed(Duration(milliseconds: 500), () {
              _markVisibleMessagesAsRead();
            });
          });
        }
      },
      onError: (error) {
        print('[ERROR] Message stream error: $error');
      },
      onDone: () {
        print('[DEBUG] Message stream closed');
      },
    );

    print('[DEBUG] Message listener set up successfully');
  }

  void _markVisibleMessagesAsRead() {
    if (!_isScreenVisible || !mounted) return;

    for (var message in _messages) {
      if (message.id != null &&
          message.senderId == widget.otherUserId &&
          !message.read) {
        _chatService.markMessageAsRead(message.id!, widget.userId);
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSending = true;
    });

    try {
      _messageController.clear();

      final message = await _chatService.sendTextMessage(widget.otherUserId, text);

      if (mounted) {
        setState(() {
          // Check if message already exists (might come from WebSocket)
          bool messageExists = _messages.any((msg) =>
          msg.id == message.id ||
              (msg.senderId == message.senderId &&
                  msg.receiverId == message.receiverId &&
                  msg.textContent == message.textContent &&
                  msg.timestamp.difference(message.timestamp).abs().inSeconds < 2));

          if (!messageExists) {
            _messages.add(message);
            // Sort messages by timestamp
            _messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
          } else {
            print('[DEBUG] Sent message already exists in list');
          }
        });

        // Scroll to bottom after sending message
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }

    } catch (e) {
      print('[ERROR] Error sending message: $e');
      _showErrorSnackBar('Error sending message');
      // Restore text if there was an error
      if (mounted) {
        _messageController.text = text;
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatMessageTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      // Today
      return DateFormat('HH:mm').format(timestamp);
    } else if (messageDate == today.subtract(Duration(days: 1))) {
      // Yesterday
      return 'Yesterday ${DateFormat('HH:mm').format(timestamp)}';
    } else if (timestamp.year == now.year) {
      // This year
      return DateFormat('dd/MM HH:mm').format(timestamp);
    } else {
      // Any other time
      return DateFormat('dd/MM/yyyy HH:mm').format(timestamp);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _messageSubscription?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _refreshMessages() async {
    print('[DEBUG] Manually refreshing messages...');
    setState(() {
      _isLoading = true;
    });

    try {
      final messages = await _chatService.getMessageHistory(widget.otherUserId);
      if (mounted) {
        setState(() {
          _messages = messages;
          _isLoading = false;
        });
        _markVisibleMessagesAsRead();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      }
    } catch (e) {
      print('[ERROR] Error refreshing messages: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        _markVisibleMessagesAsRead();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              // Mark all messages as read before leaving || not working currently
              _markVisibleMessagesAsRead();
              Navigator.pop(context);
            },
          ),
          title: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: environment.primaryColor.withOpacity(0.2),
                child: Text(
                  widget.otherUsername.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: environment.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.otherUsername,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: [
            // Messages
            Expanded(
              child: _isLoading
                  ? const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(environment.primaryColor),
                ),
              )
                  : _messages.isEmpty
                  ? _buildEmptyChat()
                  : _buildMessageList(),
            ),
            // Message input
            _buildMessageInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyChat() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Send a message to start chatting',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return NotificationListener<ScrollNotification>(
      onNotification: (ScrollNotification scrollInfo) {
        // Mark messages as read as scrolling
        if (scrollInfo is ScrollEndNotification) {
          Future.delayed(Duration(milliseconds: 300), () {
            _markVisibleMessagesAsRead();
          });
        }
        return false;
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          return _buildMessageItem(message);
        },
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message) {
    final bool isMe = message.senderId == widget.userId;
    final formattedTime = _formatMessageTime(message.timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: environment.primaryColor.withOpacity(0.2),
              child: Text(
                widget.otherUsername.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: environment.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.65,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? environment.primaryColor : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.textContent ?? '',
                  style: TextStyle(
                    color: isMe ? Colors.white : Colors.black,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  formattedTime,
                  style: TextStyle(
                    color: isMe ? Colors.white.withOpacity(0.7) : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            Icon(
              message.read ? Icons.done_all : Icons.done,
              size: 16,
              color: message.read ? Colors.blue : Colors.grey,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          // Message text field
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Write a message...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: (_) => _sendMessage(),
                onTap: () {
                  _markVisibleMessagesAsRead();
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Send button
          IconButton(
            icon: _isSending
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(environment.primaryColor),
              ),
            )
                : const Icon(
              Icons.send,
              color: environment.primaryColor,
            ),
            onPressed: _isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}