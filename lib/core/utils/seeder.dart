import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SorBiSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<void> ornekVerileriYukle() async {
    // 👤 1. ÖRNEK KULLANICILAR (Kullanıcı Dokümanları)
    final kullanicilar = [
      {
        'uid': 'user_murat_sorbi',
        'kullaniciAdi': 'Murat Uzman',
        'kullaniciFoto': 'https://i.pravatar.cc/150?u=murat',
        'statu': 'SorBi Mentörü',
        'biyografi': 'Her türlü teknoloji ve oyun sorusunu bekliyorum! 🎮',
        'online': true,
        'isAdmin': false,
      },
      {
        'uid': 'user_ayse_sorbi',
        'kullaniciAdi': 'Ayşe Stil',
        'kullaniciFoto': 'https://i.pravatar.cc/150?u=ayse',
        'statu': 'Trend Takipçisi',
        'biyografi': 'Moda ve bakım üzerine konuşalım mı? ✨',
        'online': false,
        'isAdmin': false,
      },
      {
        'uid': 'user_deniz_sorbi',
        'kullaniciAdi': 'Deniz Kaşif',
        'kullaniciFoto': 'https://i.pravatar.cc/150?u=deniz',
        'statu': 'Gezgin Ruh',
        'biyografi': 'Dünya turu yapıyoruz, sorularınızı alalım! ✈️',
        'online': true,
        'isAdmin': false,
      }
    ];

    for (var user in kullanicilar) {
      String uid = user['uid'] as String;
      await _db.collection('kullanicilar').doc(uid).set(user, SetOptions(merge: true));
    }

    // 📢 2. ÖRNEK SORULAR
    final sorular = [
      {
        'kullaniciId': 'user_murat_sorbi',
        'kullaniciAdi': 'Murat Uzman',
        'kullaniciFoto': 'https://i.pravatar.cc/150?u=murat',
        'soruMetni': 'Sizce 2026 yılının en iyi yapay zekası hangisi olacak? 🤔',
        'kategori': 'Teknoloji',
        'beyeniSayisi': 15,
        'yorumSayisi': 8,
        'trendSkoru': 30,
        'zaman': FieldValue.serverTimestamp(),
      },
      {
        'kullaniciId': 'user_ayse_sorbi',
        'kullaniciAdi': 'Ayşe Stil',
        'kullaniciFoto': 'https://i.pravatar.cc/150?u=ayse',
        'soruMetni': 'Siyah elbisenin altına hangi renk ayakkabı gider? 👗👠',
        'kategori': 'Moda',
        'beyeniSayisi': 22,
        'yorumSayisi': 12,
        'trendSkoru': 50,
        'zaman': FieldValue.serverTimestamp(),
      }
    ];

    for (var soru in sorular) {
      await _db.collection('sorular').add(soru);
    }

    print("SorBi Örnek Veriler Başarıyla Yüklendi! 🚀");
  }
}
