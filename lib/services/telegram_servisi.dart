import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class TelegramServisi {
  static const String _botToken = "8766637538:AAEBzUtnMwGLIk8m-P1z80urWqk34Qu7_os";
  static const String _chatId = "1361147452";

  // 🚀 ÖZEL MESAJ GÖNDERME (Her Şeyi Buradan Geçiriyoruz)
  static Future<void> mesajGonder(String mesaj) async {
    final url = Uri.parse("https://api.telegram.org/bot$_botToken/sendMessage");
    
    try {
      final response = await http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          // 🛡️ Web CORS Duvarını Sızma Denemesi (Bazı durumlar için yardımı olabilir)
          "Access-Control-Allow-Origin": "*",
        },
        body: json.encode({
          "chat_id": _chatId,
          "text": mesaj,
          "parse_mode": "Markdown",
        }),
      );

      if (response.statusCode == 200) {
        debugPrint("✅ Telegram: Mesaj başarıyla fırlatıldı!");
      } else {
        debugPrint("❌ Telegram Hatası: ${response.statusCode} - ${response.body}");
        // Hata raporunu console'a net basıyoruz ki Sefa Abi oradan görebilsin
      }
    } catch (e) {
      debugPrint("❌ Telegram Servis Hatası (Kritik): $e");
    }
  }

  // 🛡️ YENİ SORU RAPORU
  static Future<void> yeniSoruBildir({
    required String baslik, 
    required String yazar,
    required String kategori,
  }) async {
    final String mesaj = """
🚀 *YENİ SORU GELDİ!* 🔥

👤 *Yazar:* $yazar
🏷️ *Kategori:* $kategori
📝 *Başlık:* $baslik

🦖 _Dino AI şu an bu soruyu inceliyor..._
""";
    await mesajGonder(mesaj);
  }

  // 🔐 ADLİ/SİSTEM BİLGİSİ (Sadece Sen Görebilirsin!)
  static Future<void> adminSistemBildirisi(String olay) async {
    await mesajGonder("🛡️ *SİSTEM BİLDİRİSİ:* $olay");
  }
}
