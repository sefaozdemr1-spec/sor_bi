import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class DinoServisi {
  // 🦕 DINO'NUN KİMLİK BİLGİLERİ (Özel Bir Bot Hesabı)
  static const String dinoId = "DINO_AI_BOT_007";
  static const String dinoAdi = "Dino AI 🦖";
  static const String dinoFoto = "https://cdn-icons-png.flaticon.com/512/2816/2816281.png"; // Tatlı bir dinozor ikonu

  // 🚀 DINO CEVAP VERSİN (Akıllı Filtrelemeli)
  Future<void> ilkCevabiPatlat(String soruId, String baslik) async {
    // Dino biraz "düşünüyor" gibi yapsın (Apple UX!)
    await Future.delayed(const Duration(seconds: 3));

    try {
      final String txt = baslik.toLowerCase();
      String cevap = "";

      // 🧠 DINO ANALİZ MOTORU (Anahtar Kelime Bazı)
      if (txt.contains("dino")) {
        cevap = "Geldim dostum! İsmimi duyunca hemen koştum geldim, nerelerdesin sen ya? Özlettin kendini! 🦖🤝❤️";
      } else if (txt.contains("para") || txt.contains("ekonomi") || txt.contains("maliyet")) {
        cevap = "Hocam maliyet/ekonomi konuları bu aralar cidden can sıkıcı ama SorBi ile bu yükü hafifleteceğiz, stratejiyi bozma! 💰📉🏁";
      } else if (txt.contains("aşk") || txt.contains("sevgi") || txt.contains("ilişki")) {
        cevap = "Vov! Aşk işleri kalbi biraz yorar ama bence doğru yoldasın, hislerine güvenmeyi denedin mi dostum? 💘💌✨";
      } else if (txt.contains("teknoloji") || txt.contains("apple") || txt.contains("kod")) {
        cevap = "İşte benim alanım! Teknoloji vizyonuna bayıldım, SorBi projesi de bu vizyonun en asil ürünü olacak. 🍎💎🛰️";
      } else if (txt.contains("nasıl") || txt.contains("neden")) {
        cevap = "Bu 'Nasıl' sorusu çok kritik bir pencere açmış. Bence cevabı buralarda beraber bulacağız, sakin kal ve akışa bırak! 🕵️‍♂️🔍💎";
      } else if (txt.contains("vizyon") || txt.contains("gelecek")) {
        cevap = "Geleceğin parlayan yıldızı SorBi'deyken, bu vizyoner soru tam da şanına yakışır olmuş! 🚀✨🐉";
      } else {
        // Genel Cevaplar (Daha derin)
        final List<String> fallbackCevaplar = [
          "Dostum bu noktaya parmak basman gerçekten muazzam. Sistemin kalitesini senin bu vizyonun artıracak! 💎🚀",
          "Geldim buradayım! Şahane bir soru, bence bunun etrafında SorBi camiası çok sağlam dertleşir. 🏁🔥",
          "İnce bir detay ama çok değerli. Senden böyle derin sorular gelince her seferinde bir kez daha heyecanlanıyorum! 🕵️‍♂️🍏",
        ];
        cevap = fallbackCevaplar[Random().nextInt(fallbackCevaplar.length)];
      }

      await FirebaseFirestore.instance
          .collection('sorular')
          .doc(soruId)
          .collection('yorumlar')
          .add({
        'kullaniciId': dinoId,
        'kullaniciAdi': dinoAdi,
        'kullaniciFoto': dinoFoto,
        'icerik': cevap,
        'zaman': FieldValue.serverTimestamp(),
      });

      // Yorum sayısını güncelle
      await FirebaseFirestore.instance.collection('sorular').doc(soruId).update({
        'yorumSayisi': FieldValue.increment(1),
      });

      print("🦖 Dino AI: Soruya başarıyla cevap verdi! ($soruId)");
    } catch (e) {
      print("❌ Dino AI Hatası: $e");
    }
  }
}
