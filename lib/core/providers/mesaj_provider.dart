import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ───────────────────────────────────────────
// 💬 MESAJ PROVIDER — Realtime chat stream'leri
// ───────────────────────────────────────────

/// Sohbet listesi stream'i (gelen kutusu)
final sohbetListesiProvider = StreamProvider<QuerySnapshot>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return const Stream.empty();
  return FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: uid)
      .orderBy('lastMessageTime', descending: true)
      .snapshots();
});

/// Belirli bir sohbetin mesaj stream'i
final mesajlarProvider =
    StreamProvider.family<QuerySnapshot, String>((ref, chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots();
});

/// Yazıyor mu? indicator stream'i
final yaziyorProvider =
    StreamProvider.family<Map<String, dynamic>, String>((ref, chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .snapshots()
      .map((doc) {
    if (!doc.exists) return {};
    return (doc.data()?['typing'] as Map<String, dynamic>?) ?? {};
  });
});

// ───────────────────────────────────────────
// 👤 KULLANICI PROFİLİ PROVIDER
// ───────────────────────────────────────────

/// Belirli bir kullanıcının profil verisi
final kullaniciProfilProvider =
    StreamProvider.family<DocumentSnapshot, String>((ref, uid) {
  return FirebaseFirestore.instance
      .collection('kullanicilar')
      .doc(uid)
      .snapshots();
});

/// Şu anki kullanıcının profil verisi
final benimProfilimProvider = StreamProvider<DocumentSnapshot?>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(null);
  return FirebaseFirestore.instance
      .collection('kullanicilar')
      .doc(uid)
      .snapshots();
});

// ───────────────────────────────────────────
// 🔔 BİLDİRİM PROVIDER
// ───────────────────────────────────────────

/// Okunmamış bildirim sayısı
final okunmamisBildirimProvider = StreamProvider<int>((ref) {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return Stream.value(0);
  return FirebaseFirestore.instance
      .collection('bildirimler')
      .where('hedefKullanici', isEqualTo: uid)
      .where('okundu', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs.length);
});
