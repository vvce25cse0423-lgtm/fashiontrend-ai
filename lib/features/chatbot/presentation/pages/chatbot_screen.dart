import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../../../../themes/app_theme.dart';
import '../../../../services/ai_service.dart';
import '../../../../services/profile_service.dart';

class ChatbotScreen extends ConsumerStatefulWidget {
  const ChatbotScreen({super.key});
  @override
  ConsumerState<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends ConsumerState<ChatbotScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _uuid = const Uuid();

  final List<_Msg> _messages = [];
  bool _isTyping = false;
  String _language = 'en';

  // Quick suggestion chips — Indian context
  final _suggestions = [
    'What should I wear for office today?',
    'Best kurti for wheatish skin tone?',
    'Outfit ideas for Diwali party',
    'What perfume is good under ₹500?',
    'Best hairstyle for round face shape?',
    'What to wear for college farewell?',
    'Summer outfits for Indian weather',
    'Wedding guest outfit ideas',
  ];

  @override
  void initState() {
    super.initState();
    _loadLanguage();
    _addWelcome();
  }

  Future<void> _loadLanguage() async {
    // Language preference would be stored in profile in full implementation
    // For now default to English with support for others
  }

  void _addWelcome() {
    _messages.add(_Msg(
      id: _uuid.v4(),
      text: '''👋 Hello! I am your FashionTrend AI Stylist!

I can help you with:
• 👗 Outfit ideas for any occasion
• 🎨 Colours that suit your skin tone
• 💄 Grooming and hairstyle tips
• 👟 Shoe and watch recommendations
• 🌸 Perfume suggestions
• 💰 Budget-friendly fashion in India

Just ask me anything — in English or your local language! 😊''',
      isUser: false,
      time: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send(String text) async {
    if (text.trim().isEmpty) return;
    _controller.clear();

    final userMsg = _Msg(id: _uuid.v4(), text: text.trim(), isUser: true, time: DateTime.now());
    setState(() { _messages.add(userMsg); _isTyping = true; });
    _scrollToBottom();

    try {
      final history = _messages
          .where((m) => m.id != userMsg.id)
          .take(10)
          .map((m) => {'role': m.isUser ? 'user' : 'assistant', 'content': m.text})
          .toList();

      final reply = await aiService.chat(history, text.trim(), language: _language);
      if (mounted) {
        setState(() {
          _messages.add(_Msg(id: _uuid.v4(), text: reply, isUser: false, time: DateTime.now()));
          _isTyping = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _messages.add(_Msg(
            id: _uuid.v4(),
            text: 'Sorry, I could not connect right now. Please check your internet and try again. 🙏',
            isUser: false,
            time: DateTime.now(),
          ));
          _isTyping = false;
        });
      }
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.darkGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                decoration: BoxDecoration(color: AppTheme.cardBg, border: Border(bottom: BorderSide(color: AppTheme.borderGlass))),
                child: Row(
                  children: [
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.goldGradient),
                      child: const Icon(Icons.auto_awesome, color: Colors.black, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('AI Fashion Stylist', style: Theme.of(context).textTheme.titleMedium),
                          Row(
                            children: [
                              Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.successGreen)),
                              const SizedBox(width: 6),
                              Text('Online · Replies instantly', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.successGreen)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Language quick switch
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.language, color: AppTheme.primaryGold),
                      color: AppTheme.cardBg,
                      onSelected: (lang) => setState(() => _language = lang),
                      itemBuilder: (_) => [
                        const PopupMenuItem(value: 'en', child: Text('English')),
                        const PopupMenuItem(value: 'hi', child: Text('Hindi (हिंदी)')),
                        const PopupMenuItem(value: 'ta', child: Text('Tamil (தமிழ்)')),
                        const PopupMenuItem(value: 'te', child: Text('Telugu (తెలుగు)')),
                        const PopupMenuItem(value: 'kn', child: Text('Kannada (ಕನ್ನಡ)')),
                        const PopupMenuItem(value: 'ml', child: Text('Malayalam (മലയാളം)')),
                        const PopupMenuItem(value: 'mr', child: Text('Marathi (मराठी)')),
                        const PopupMenuItem(value: 'bn', child: Text('Bengali (বাংলা)')),
                      ],
                    ),
                  ],
                ),
              ),

              // Messages
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i == _messages.length && _isTyping) return _buildTyping();
                    return _buildBubble(_messages[i]);
                  },
                ),
              ),

              // Suggestions (only show when few messages)
              if (_messages.length < 3)
                SizedBox(
                  height: 44,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) => GestureDetector(
                      onTap: () => _send(_suggestions[i]),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryGold.withOpacity(0.4)),
                        ),
                        child: Text(_suggestions[i], style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.primaryGold)),
                      ),
                    ),
                  ),
                ),

              // Input bar
              Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(color: AppTheme.cardBg, border: Border(top: BorderSide(color: AppTheme.borderGlass))),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: null,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: 'Ask about fashion, outfits, style...',
                          hintStyle: Theme.of(context).textTheme.bodySmall,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          filled: true,
                          fillColor: AppTheme.surfaceBg,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onSubmitted: _send,
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () => _send(_controller.text),
                      child: Container(
                        width: 46, height: 46,
                        decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.goldGradient),
                        child: const Icon(Icons.send_rounded, color: Colors.black, size: 20),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBubble(_Msg msg) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: 12,
        left: msg.isUser ? 60 : 0,
        right: msg.isUser ? 0 : 60,
      ),
      child: Column(
        crossAxisAlignment: msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: msg.isUser ? AppTheme.goldGradient : null,
              color: msg.isUser ? null : AppTheme.cardBg,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(msg.isUser ? 18 : 4),
                bottomRight: Radius.circular(msg.isUser ? 4 : 18),
              ),
              border: msg.isUser ? null : Border.all(color: AppTheme.borderGlass),
            ),
            child: Text(
              msg.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: msg.isUser ? Colors.black : AppTheme.textPrimary,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3, duration: 300.ms).fade(duration: 300.ms);
  }

  Widget _buildTyping() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, right: 60),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(18), topRight: Radius.circular(18), bottomRight: Radius.circular(18), bottomLeft: Radius.circular(4)),
          border: Border.all(color: AppTheme.borderGlass),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('AI is thinking', style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(width: 8),
            const SizedBox(
              width: 30, height: 12,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryGold),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: AppTheme.primaryGold.withOpacity(0.2));
  }
}

class _Msg {
  final String id, text;
  final bool isUser;
  final DateTime time;
  const _Msg({required this.id, required this.text, required this.isUser, required this.time});
}
