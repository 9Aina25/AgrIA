import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import '../utils/theme.dart';
import '../widgets/bottom_nav_bar.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  ChatMessage({required this.text, required this.isUser, required this.timestamp});
}

class Conversation {
  final String id;
  final String title;
  final DateTime updatedAt;
  final String lastMessage;
  Conversation({required this.id, required this.title, required this.updatedAt, required this.lastMessage});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<ChatMessage> _messages = [];
  final List<Conversation> _conversations = [];
  bool _isLoading = false;
  bool _isLoadingConversations = false;
  String? _currentConversationId;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    setState(() => _isLoadingConversations = true);
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/chat/conversations'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['conversations'] ?? [];
        final List<Conversation> loaded = [];
        for (var item in items) {
          loaded.add(Conversation(
            id: item['id'],
            title: item['title'],
            updatedAt: DateTime.parse(item['updated_at']),
            lastMessage: item['last_message'],
          ));
        }
        setState(() {
          _conversations.clear();
          _conversations.addAll(loaded);
        });
        if (loaded.isNotEmpty && _currentConversationId == null) {
          await _loadConversation(loaded.first.id);
        }
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() => _isLoadingConversations = false);
    }
  }

  Future<void> _loadConversation(String convId) async {
    setState(() {
      _currentConversationId = convId;
      _messages.clear();
      _isLoading = true;
    });
    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;
    try {
      final response = await http.get(
        Uri.parse('${Constants.apiBaseUrl}/chat/history/$convId'),
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(const Duration(seconds: 5));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> items = data['history'] ?? [];
        final List<ChatMessage> loaded = [];
        for (var item in items) {
          loaded.add(ChatMessage(text: item['user_message'], isUser: true, timestamp: DateTime.parse(item['timestamp'])));
          loaded.add(ChatMessage(text: item['bot_message'], isUser: false, timestamp: DateTime.parse(item['timestamp'])));
        }
        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(loaded);
          });
          _scrollToBottom();
        }
      }
    } catch (e) {
      print(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final message = _controller.text.trim();
    if (message.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: message, isUser: true, timestamp: DateTime.now()));
      _controller.clear();
      _isLoading = true;
    });
    _scrollToBottom();

    final token = Provider.of<AuthService>(context, listen: false).token;
    if (token == null) return;

    try {
      final response = await http.post(
        Uri.parse('${Constants.apiBaseUrl}/chat'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'message': message,
          'conversation_id': _currentConversationId,
        }),
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final reply = data['reply'];
        final newConvId = data['conversation_id'];
        setState(() {
          if (_currentConversationId == null && newConvId != null) {
            _currentConversationId = newConvId;
          }
          _messages.add(ChatMessage(text: reply, isUser: false, timestamp: DateTime.now()));
        });
      } else {
        setState(() {
          _messages.add(ChatMessage(text: 'Erreur serveur (${response.statusCode})', isUser: false, timestamp: DateTime.now()));
        });
      }
    } on TimeoutException {
      setState(() {
        _messages.add(ChatMessage(text: '⚠️ Le service IA met trop de temps. Réessayez.', isUser: false, timestamp: DateTime.now()));
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: 'Erreur réseau: $e', isUser: false, timestamp: DateTime.now()));
      });
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
      _loadConversations();
    }
  }

  Future<void> _newConversation() async {
    setState(() {
      _currentConversationId = null;
      _messages.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Nouvelle conversation. Envoyez un message pour commencer.'), duration: Duration(seconds: 2)),
    );
  }

  Future<void> _renameConversation(Conversation conv) async {
    final TextEditingController renameController = TextEditingController(text: conv.title);
    final newTitle = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Renommer'),
        content: TextField(controller: renameController, autofocus: true, decoration: const InputDecoration(hintText: 'Nouveau titre')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(context, renameController.text), child: const Text('OK')),
        ],
      ),
    );
    if (newTitle != null && newTitle.isNotEmpty) {
      final token = Provider.of<AuthService>(context, listen: false).token;
      await http.post(
        Uri.parse('${Constants.apiBaseUrl}/chat/conversations/${conv.id}/rename'),
        headers: {'Authorization': 'Bearer $token', 'Content-Type': 'application/json'},
        body: jsonEncode({'title': newTitle}),
      );
      await _loadConversations();
    }
  }

  Future<void> _deleteConversation(Conversation conv) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer'),
        content: Text('Supprimer "${conv.title}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Non')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Oui')),
        ],
      ),
    );
    if (confirm == true) {
      final token = Provider.of<AuthService>(context, listen: false).token;
      await http.delete(
        Uri.parse('${Constants.apiBaseUrl}/chat/conversations/${conv.id}'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (_currentConversationId == conv.id) {
        await _newConversation();
      }
      await _loadConversations();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant AgrIA'),
        backgroundColor: AppTheme.greenPrimary,
        actions: [
          IconButton(icon: const Icon(Icons.add_comment), onPressed: _newConversation, tooltip: 'Nouvelle conversation'),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: isDark ? AppTheme.darkSurface : Colors.white,
          child: Column(
            children: [
              Container(
                height: 120,
                color: AppTheme.greenPrimary,
                child: const Center(child: Text('Conversations', style: TextStyle(color: Colors.white, fontSize: 20))),
              ),
              Expanded(
                child: _isLoadingConversations
                    ? const Center(child: CircularProgressIndicator())
                    : _conversations.isEmpty
                        ? const Center(child: Text('Aucune conversation'))
                        : ListView.builder(
                            itemCount: _conversations.length,
                            itemBuilder: (context, index) {
                              final conv = _conversations[index];
                              return ListTile(
                                title: Text(conv.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                                subtitle: Text(conv.lastMessage, maxLines: 1, overflow: TextOverflow.ellipsis),
                                trailing: PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  onSelected: (value) {
                                    if (value == 'rename') _renameConversation(conv);
                                    if (value == 'delete') _deleteConversation(conv);
                                  },
                                  itemBuilder: (_) => [
                                    const PopupMenuItem(value: 'rename', child: Text('Renommer')),
                                    const PopupMenuItem(value: 'delete', child: Text('Supprimer')),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  if (_currentConversationId != conv.id) {
                                    _loadConversation(conv.id);
                                  }
                                },
                              );
                            },
                          ),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.add_comment),
                title: const Text('Nouvelle conversation'),
                onTap: () {
                  Navigator.pop(context);
                  _newConversation();
                },
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const Text('Aucun message. Commencez à discuter !'),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length && _isLoading) {
                        return _buildTypingIndicator(isDark);
                      }
                      final msg = _messages[index];
                      return _buildMessageBubble(msg.text, msg.isUser, isDark);
                    },
                  ),
          ),
          _buildInputArea(isDark),
        ],
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser, bool isDark) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.greenPrimary : (isDark ? AppTheme.darkCard : Colors.grey.shade200),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(text, style: TextStyle(
          color: isUser ? Colors.white : (isDark ? AppTheme.darkText : Colors.black87),
          fontSize: 14,
        )),
      ),
    );
  }

  Widget _buildTypingIndicator(bool isDark) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.darkCard : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.greenPrimary)),
            const SizedBox(width: 8),
            Text('L\'assistant réfléchit...', style: TextStyle(fontSize: 12, color: AppTheme.textLight)),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.darkSurface : Colors.white,
        border: Border(top: BorderSide(color: isDark ? AppTheme.darkBorder : Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Posez votre question...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                filled: true,
                fillColor: isDark ? AppTheme.darkCard : Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(icon: const Icon(Icons.send, color: AppTheme.greenPrimary), onPressed: _sendMessage),
        ],
      ),
    );
  }
}