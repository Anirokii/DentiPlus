import 'package:flutter/material.dart';
import 'package:denti_plus/modals/chat_messageModal.dart';
import 'package:denti_plus/services/api_service.dart';

import '../modals/consultationModal.dart';

class ChatProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ChatMessage> _chatHistory = [];
  bool _isLoading = false;
  bool _isSending = false;
  bool _isEnding = false;
  String? _errorMessage;

  // Getters
  List<ChatMessage> get chatHistory => _chatHistory;
  bool get isLoading => _isLoading;
  bool get isSending => _isSending;
  bool get isEnding => _isEnding;
  String? get errorMessage => _errorMessage;

  /// Fetch the entire chat history for a consultation.
  Future<void> fetchChatHistory(int consultationId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final messages = await _apiService.getConsultationChatHistory(consultationId);
      _chatHistory = messages;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Send a new user message, then reload the chat history.
  Future<void> sendMessage(int consultationId, String message) async {
    if (message.isEmpty) return;

    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Call backend; it will persist both user + assistant messages.
      await _apiService.sendChatMessage(consultationId, {'message': message});

      // Re-fetch entire history to pick up both sides.
      await fetchChatHistory(consultationId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  Future<Consultation> endConversation(int consultationId) async {
    _isEnding = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await ApiService().finishConsultationChat(consultationId);
      // if you keep a local Consultation object, update it here:
      // _currentConsultation = updated;
      // you may also clear chat history or set a flag:
      // _isClosed = true;

      return updated;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isEnding = false;
      notifyListeners();
    }
  }
}
