import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MesajServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> mesajOkunduisaretle(String chatId) async {
    final suankiUid = _auth.currentUser?.uid;
    if (suankiUid == null) return;
    await _db.collection('chats').doc(chatId).update({'lastRead.$suankiUid': FieldValue.serverTimestamp()});
  }

  Future<void> yaziyorDurumuGuncelle(String chatId, bool isTyping) async {
    final suankiUid = _auth.currentUser?.uid;
    if (suankiUid == null) return;
    await _db.collection('chats').doc(chatId).update({'typing.$suankiUid': isTyping});
  }

  Future<void> onlineDurumuSet(bool isOnline) async {
    final suankiUid = _auth.currentUser?.uid;
    if (suankiUid == null) return;
    await _db.collection('kullanicilar').doc(suankiUid).update({
      'online': isOnline,
      'lastSeen': FieldValue.serverTimestamp(),
    });
  }

  Future<String> sohbetBaslatV3(String hedefUid) async {
    final suankiUid = _auth.currentUser?.uid;
    if (suankiUid == null) return "";
    final mevcutSohbet = await _db.collection('chats').where('participants', arrayContains: suankiUid).get();
    for (var doc in mevcutSohbet.docs) {
      if ((doc['participants'] as List).contains(hedefUid)) return doc.id;
    }
    final docRef = _db.collection('chats').doc();
    await docRef.set({
      'participants': [suankiUid, hedefUid],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastRead': {suankiUid: FieldValue.serverTimestamp(), hedefUid: FieldValue.serverTimestamp()},
      'typing': {suankiUid: false, hedefUid: false},
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  Future<void> mesajGonderV3(String chatId, String metin) async {
    final suankiUid = _auth.currentUser?.uid;
    if (suankiUid == null || metin.trim().isEmpty) return;
    final batch = _db.batch();
    final chatRef = _db.collection('chats').doc(chatId);
    final messageRef = chatRef.collection('messages').doc();

    batch.set(messageRef, {'senderId': suankiUid, 'text': metin, 'createdAt': FieldValue.serverTimestamp()});
    batch.update(chatRef, {
      'lastMessage': metin,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastRead.$suankiUid': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Stream<QuerySnapshot> sohbetleriGetir() {
    final suankiUid = _auth.currentUser?.uid;
    return _db.collection('chats').where('participants', arrayContains: suankiUid).orderBy('lastMessageTime', descending: true).snapshots();
  }

  Stream<QuerySnapshot> mesajlariGetir(String chatId) {
    return _db.collection('chats').doc(chatId).collection('messages').orderBy('createdAt', descending: true).limit(30).snapshots();
  }
}
