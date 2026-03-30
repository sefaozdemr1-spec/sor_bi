import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class BildirimServisi {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔔 BİLDİRİM KURULUMU (İzinler ve Token Kaydı)
  Future<void> bildirimKurulumu() async {
    // 1. İZİN İSTE: Apple & Android 13+ zorunlu!
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Bildirim izni verildi! ✅');
      
      // 2. TOKEN AL: Cihaza özel anahtarı al
      String? token = await _fcm.getToken();
      if (token != null) {
        await _tokenKaydet(token);
      }
    } else {
      print('Bildirim izni reddedildi! ❌');
    }

    // 3. ARKAPLAN DİNLEME: App açık değilken gelenleri yönet
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print("Uygulama açıkken bildirim geldi: ${message.notification?.body}");
    });
  }

  // ⛓️ TOKEN'I DB'YE BAĞLA (PROFESYONEL V3): Cloud Functions için 'fcmTokens' dizisine ekler
  Future<void> _tokenKaydet(String token) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    await _db.collection('kullanicilar').doc(uid).update({
      'fcmTokens': FieldValue.arrayUnion([token]), // Tüm cihazlarını kaydet
      'sonAktifTarih': FieldValue.serverTimestamp(),
    });
  }
}
