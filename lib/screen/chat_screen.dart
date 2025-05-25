import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:openearth_mobile/model/chat_conversation.dart';
import 'package:openearth_mobile/routes/routes.dart';
import 'package:openearth_mobile/configuration/environment.dart';
import 'package:openearth_mobile/screen/conversation_screen.dart';
import 'package:openearth_mobile/service/auth_service.dart';
import 'package:openearth_mobile/service/chat_service.dart';
import 'package:openearth_mobile/widget/navegation_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  List<ChatConversation> _conversations = [];
  bool _isLoading = true;
  int _userId = 0;
  String _username = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    final userId = await _getUserId();
    final username = await _getUsername() ?? '';

    if (userId != null && userId > 0 && username.isNotEmpty) {
      setState(() {
        _userId = userId;
        _username = username;
      });

      _chatService.connect();
      _loadConversations();
      _listenForMessages();

    } else {
      Navigator.pushReplacementNamed(context, Routes.login);
    }
  }

  Future<int?> _getUserId() async {
    return _authService.getMyId();
  }

  Future<String?> _getUsername() async {
    return _authService.getMyUsername();
  }

  void _loadConversations() async {
    try {
      final conversations = await _chatService.getConversations();
      setState(() {
        _conversations = conversations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Error at loading conversations');
    }
  }

  void _listenForMessages() {
    _chatService.messageStream.listen((message) {
      // Update conversation list when receiving a new message
      _loadConversations();
    });
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  void dispose() {
    _chatService.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chats',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(environment.primaryColor),
        ),
      )
          : _conversations.isEmpty
          ? _buildEmptyState()
          : _buildConversationsList(),
      bottomNavigationBar: const NavigationWidget(currentIndex: 1),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No active conversations',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationsList() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadConversations();
      },
      color: environment.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 8),
        itemCount: _conversations.length,
        itemBuilder: (context, index) {
          final conversation = _conversations[index];
          return _buildConversationItem(conversation);
        },
      ),
    );
  }

  Widget _buildConversationItem(ChatConversation conversation) {
    final otherUserId = conversation.user1Id == _userId
        ? conversation.user2Id
        : conversation.user1Id;

    final otherUsername = conversation.user1Id == _userId
        ? conversation.user2Username
        : conversation.user1Username;

    final lastMessage = conversation.lastMessage?.textContent ?? '';
    final formattedTime = DateFormat('HH:mm').format(conversation.lastActivity);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ConversationScreen(
              conversationId: conversation.id,
              otherUserId: otherUserId,
              otherUsername: otherUsername,
              userId: _userId,
              username: _username,
            ),
          ),
        ).then((_) {
          _loadConversations();
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            CircleAvatar(
              radius: 28,
              backgroundColor: environment.primaryColor.withOpacity(0.2),
              child: Text(
                otherUsername.substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: environment.primaryColor,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Conversation information -> last message and unread count
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        otherUsername,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (conversation.unreadCount > 0)
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: environment.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${conversation.unreadCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}