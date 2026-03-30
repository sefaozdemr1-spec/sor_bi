import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SikayetServisi {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // APPLE & GOOGLE ZORUNLULUĞU: Şikayet Kaydetme (UGC Moderation)
  Future<bool> sikayetGonder({
    required String hedefId,      // Şikayet edilen soru veya yorumun ID'si
    required String hedefTip,     // 'soru' veya 'yorum'
    required String sikayetNedeni, // 'spam', 'taciz', 'uygunsuz' vb.
    required String detay,        // Kullanıcının ek notu
  }) async {
    try {
      final raporlayanUid = _auth.currentUser?.uid ?? "anonim";
      
      await _firestore.collection('sikayetler').add({
        'raporlayanUid': raporlayanUid,
        'hedefId': hedefId,
        'hedefTip': hedefTip,
        'sikayetNedeni': sikayetNedeni,
        'detay': detay,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'acik', // acik, incelemede, cozuldu
      });
      return true;
    } catch (e) {
      print("Şikayet gönderme arızası: $e");
      return false;
    }
  }

  // 🛡️ USER STRIKE SYSTEM: Kullanıcıya ceza puanı ekle (Admin kullanır)
  Future<void> kullaniciyaCezaPuaniEkle(String hedefUid) async {
    await _firestore.collection('kullanicilar').doc(hedefUid).update({
      'cezaPuani': FieldValue.increment(1),
      'sonCezaTarihi': FieldValue.serverTimestamp(),
    });
    
    // Eğer 3 strike olduysa kullanıcının post atma yetkisini kısıtla (Yasakla)
    final doc = await _firestore.collection('kullanicilar').doc(hedefUid).get();
    if ((doc.data()?['cezaPuani'] ?? 0) >= 3) {
      await _firestore.collection('kullanicilar').doc(hedefUid).update({'isBanned': true});
    }
  }

  // ⚖️ ADİL SÜREÇ: İçeriği silinen kullanıcı itiraz edebilir
  Future<bool> itirazGonder({
    required String hedefId,
    required String neden,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      await _firestore.collection('itirazlar').add({
        'itirazEdenUid': uid,
        'hedefId': hedefId,
        'neden': neden,
        'tarih': FieldValue.serverTimestamp(),
        'durum': 'beklemede', 
      });
      return true;
    } catch (e) {
      print("İtiraz gönderme hatası: $e");
      return false;
    }
  }

  // APPLE ZORUNLULUĞU: Kullanıcıyı Engelle (Block User)
  Future<void> kullaniciEngelle(String hedefUid) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('kullanicilar').doc(uid).update({
      'engellenenler': FieldValue.arrayUnion([hedefUid])
    });
  }
}
