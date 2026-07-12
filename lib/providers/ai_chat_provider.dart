import 'package:flutter/foundation.dart';
import '../services/ai_chat_service.dart';

class AIChatProvider extends ChangeNotifier {
  final AIChatService _chatService = AIChatService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isTyping = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isTyping => _isTyping;
  String get errorMessage => _errorMessage ?? '';

  void sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(role: 'user', content: text);
    _messages.add(userMessage);
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fullResponse = await _chatService.getChatResponse(_messages);
      
      _isLoading = false;
      _isTyping = true;
      notifyListeners();

      // Simulate streaming effect
      final aiMessage = ChatMessage(role: 'assistant', content: '');
      _messages.add(aiMessage);
      
      String currentText = '';
      final words = fullResponse.split(' ');
      
      for (var word in words) {
        currentText += '$word ';
        _messages[_messages.length - 1] = ChatMessage(
          role: 'assistant', 
          content: currentText.trim(),
        );
        notifyListeners();
        await Future.delayed(const Duration(milliseconds: 30));
      }
      
    } catch (e) {
      _errorMessage = e.toString().replaceFirst('Exception: ', '');
      debugPrint('AIChatProvider Error: $_errorMessage');
    } finally {
      _isLoading = false;
      _isTyping = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _errorMessage = null;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
