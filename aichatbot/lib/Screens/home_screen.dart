import 'package:aichatbot/widgets/chat_bubble.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

const String _apiKey =
    "AIzaSyAYp77bui9Jw2Wf0C7znKfhQPIxjnbPzQY"; //HERE CHANGE YOUR API KEY

class _HomeScreenState extends State<HomeScreen> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: _apiKey);
    _chat = _model.startChat();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  Future<void> _sendChatMessage(String message) async {
    if (_isSending || message.trim().isEmpty) return;

    setState(() {
      _isSending = true;
      _messages.add(ChatMessage(text: message, isUser: true));
    });

    try {
      final response = await _chat.sendMessage(Content.text(message));
      final text = response.text;
      setState(() {
        _messages.add(ChatMessage(text: text ?? "No response", isUser: false));
        _scrollDown();
      });
    } catch (e) {
      setState(() {
        _messages.add(ChatMessage(text: "Error Occurred", isUser: false));
      });
    } finally {
      setState(() {
        _isSending = false;
      });
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Asim's Ai",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ChatBubble(message: _messages[index]);
              },
            ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(
                color: Colors.black,
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onSubmitted: (message) {
                      _sendChatMessage(message);
                    },
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Enter a Message",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color: Colors.black), // Default border color
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                            color:
                                Color(0xFf25D366)), // Border color when focused
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _sendChatMessage(_textController.text),
                  icon: const Icon(
                    Icons.send,
                    color: Colors.black,
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
