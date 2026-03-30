import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/services/mesaj_servisi.dart';

class ChatController extends ChangeNotifier {
  final MesajServisi _mesajServisi = MesajServisi();
  Timer? _typingTimer;
  bool _isTyping = false;

  void typingDurumuGuncelle(String chatId, String metin) {
    if (metin.isEmpty && _isTyping) {
      _finishTyping(chatId);
      return;
    }

    if (!_isTyping && metin.isNotEmpty) {
      _isTyping = true;
      _mesajServisi.yaziyorDurumuGuncelle(chatId, true);
    }

    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _finishTyping(chatId);
    });
  }

  void _finishTyping(String chatId) {
    _isTyping = false;
    _mesajServisi.yaziyorDurumuGuncelle(chatId, false);
  }

  void sohbetAcildi(String chatId) {
    _mesajServisi.mesajOkunduisaretle(chatId);
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    super.dispose();
  }
}
