import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart'; // 🚀 debugPrint için gerekli

// ───────────────────────────────────────────
// 🔥 AUTH STATE — Tüm app için tek gerçek kaynak
// ───────────────────────────────────────────

/// Firebase kullanıcı stream'i — anlık oturum değişimlerini yayınlar
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Şu anki kullanıcının UID'si (null = giriş yapılmamış)
final currentUserUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).valueOrNull?.uid;
});

// ───────────────────────────────────────────
// 👤 AUTH SERVİSİ — Login / Register / Logout
// ───────────────────────────────────────────

class AuthServisi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Email & Şifre ile Giriş
  Future<UserCredential> girisYap({
    required String email,
    required String sifre,
  }) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: sifre.trim(),
    );
  }

  /// Email & Şifre ile Kayıt + Firestore'a kullanıcı yaz
  Future<UserCredential> kayitOl({
    required String email,
    required String sifre,
    required String kullaniciAdi,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: sifre.trim(),
    );

    // Firestore'a kullanıcı profili oluştur
    await _db.collection('kullanicilar').doc(cred.user!.uid).set({
      'kullaniciAdi': kullaniciAdi.trim(),
      'email': email.trim(),
      'kullaniciFoto': '',
      'bio': '',
      'takipciSayisi': 0,
      'takipEdilenSayisi': 0,
      'soruSayisi': 0,
      'online': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'olusturmaTarihi': FieldValue.serverTimestamp(),
      'rolü': 'kullanici', // admin / moderator / kullanici
    });

    return cred;
  }

  /// 🚀 Google ile Giriş (Web / Popup)
  Future<void> googleIleGiris() async {
    try {
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      // Chrome/Web Browser üzerinde en asil ve hızlı Gmail onayı!
      final userCredential = await _auth.signInWithPopup(googleProvider);
      final user = userCredential.user;

      if (user != null) {
        // Eğer bu Gmail kullanıcısı sisteme İLK KEZ geliyorsa, profilini kuruyoruz!
        final doc = await _db.collection('kullanicilar').doc(user.uid).get();
        if (!doc.exists) {
          await _db.collection('kullanicilar').doc(user.uid).set({
            'kullaniciAdi': user.displayName ?? "Yeni SorBi Üyesi",
            'email': user.email,
            'kullaniciFoto': user.photoURL ?? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
            'bio': 'Merhaba, SorBi\'ye Google ile katıldım! 🚀',
            'takipciSayisi': 0,
            'takipEdilenSayisi': 0,
            'soruSayisi': 0,
            'online': true,
            'lastSeen': FieldValue.serverTimestamp(),
            'olusturmaTarihi': FieldValue.serverTimestamp(),
            'rolü': 'kullanici',
          });
        }
      }
    } catch (e) {
      debugPrint("🔴 Google Giriş Arızası: $e");
      rethrow;
    }
  }

  /// Çıkış
  Future<void> cikisYap() async {
    await _auth.signOut();
  }

  /// Şifre Sıfırlama
  Future<void> sifreSifirla(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}

/// Riverpod Provider — AuthServisi singleton
final authServisiProvider = Provider<AuthServisi>((ref) => AuthServisi());
