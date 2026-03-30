import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/soru_model.dart';

class FirestoreServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🏰 ADMİN & MODERASYON: Yayındaki soruları süzerek indirir
  Stream<List<SoruModel>> sorulariGetir() {
    return _db
        .collection('sorular')
        .where('durum', isEqualTo: 'aktif') // Sadece 'aktif' olanlar akışa girer
        .orderBy('tarih', descending: true) 
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => SoruModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  // 🚀 MİLYARLIK SPAM ZIRHI & BAN KONTROLÜ
  Future<Map<String, dynamic>> soruEkle(SoruModel soru) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return {'success': false, 'message': 'Oturum açılmamış.'};

    try {
      // 0. KURAL: Ban Kontrolü (Apple Guideline 1.2)
      final userDoc = await _db.collection('kullanicilar').doc(uid).get();
      if (userDoc.data()?['isBanned'] == true) {
        return {'success': false, 'message': 'Hesabınız moderasyon kuralları gereği askıya alınmıştır.'};
      }

      // 1. KURAL: Spam Kontrolü (Dakikada 1 post)
      final sonSoru = await _db
          .collection('sorular')
          .where('kullaniciId', isEqualTo: uid)
          .orderBy('tarih', descending: true)
          .limit(1)
          .get();

      if (sonSoru.docs.isNotEmpty) {
        final data = sonSoru.docs.first.data();
        final Timestamp? ts = data['tarih'] as Timestamp?;
        if (ts != null) {
          final fark = DateTime.now().difference(ts.toDate());
          if (fark.inMinutes < 1) {
            return {'success': false, 'message': 'Çok hızlısınız! Lütfen 1 dakika bekleyin.'};
          }
        }
      }

      // 2. KURAL: Normal Ekleme
      await _db.collection('sorular').add(soru.toMap());
      return {'success': true, 'message': 'Soru başarıyla paylaşıldı.'};
    } catch (e) {
      return {'success': false, 'message': 'Hata: $e'};
    }
  }

  // 🏰 ADMİN KALKANI: İçeriği kalıcı olarak değil, 'silindi' durumuna çekmek tercih edilir.
  Future<void> soruSilTamamen(String soruId) async {
    await _db.collection('sorular').doc(soruId).delete();
  }

  // İçeriği sadece "Gizle" (Moderasyon)
  Future<void> soruGuncelleDurum(String soruId, String yeniDurum) async {
    await _db.collection('sorular').doc(soruId).update({'durum': yeniDurum});
  }

  // 🔴 HESAP SİLME (FULL BACKEND CASCADE + STORAGE CLEANUP)
  Future<void> kullanicinTumVerileriniSil(String uid) async {
    final batch = _db.batch();
    
    // 1. Sorularını Sil
    final sorular = await _db.collection('sorular').where('kullaniciId', isEqualTo: uid).get();
    for (var doc in sorular.docs) {
      batch.delete(doc.reference);
    }

    // 2. Profil Dokümanını Sil
    batch.delete(_db.collection('kullanicilar').doc(uid));

    // 3. STORAGE TEMİZLİĞİ (Apple Rejection Engelleyici!)
    try {
      await FirebaseStorage.instance.ref("profiles/$uid.jpg").delete();
      await FirebaseStorage.instance.ref("banners/$uid.jpg").delete();
    } catch (e) {
      // Dosya yoksa veya silinemezse sessizce devam et
      print("Storage temizleme hatası (Normal olabilir): $e");
    }
    
    await batch.commit();
  }

  // Task 4: Takip Et Sistemi
  Future<void> takipEt(String hedefUid) async {
    final suankiUid = FirebaseAuth.instance.currentUser?.uid;
    if (suankiUid == null || suankiUid == hedefUid) return;
    final batch = _db.batch();
    final takipciRef = _db.collection('kullanicilar').doc(hedefUid).collection('takipciler').doc(suankiUid);
    batch.set(takipciRef, {'zaman': FieldValue.serverTimestamp()});
    final takipEdilenRef = _db.collection('kullanicilar').doc(suankiUid).collection('takipEdilenler').doc(hedefUid);
    batch.set(takipEdilenRef, {'zaman': FieldValue.serverTimestamp()});
    batch.update(_db.collection('kullanicilar').doc(hedefUid), {'takipciSayisi': FieldValue.increment(1)});
    batch.update(_db.collection('kullanicilar').doc(suankiUid), {'takipEdilenSayisi': FieldValue.increment(1)});
    await batch.commit();
  }

  Future<void> takibiBirak(String hedefUid) async {
    final suankiUid = FirebaseAuth.instance.currentUser?.uid;
    if (suankiUid == null) return;
    final batch = _db.batch();
    batch.delete(_db.collection('kullanicilar').doc(hedefUid).collection('takipciler').doc(suankiUid));
    batch.delete(_db.collection('kullanicilar').doc(suankiUid).collection('takipEdilenler').doc(hedefUid));
    batch.update(_db.collection('kullanicilar').doc(hedefUid), {'takipciSayisi': FieldValue.increment(-1)});
    batch.update(_db.collection('kullanicilar').doc(suankiUid), {'takipEdilenSayisi': FieldValue.increment(-1)});
    await batch.commit();
  }

  Future<void> likeToggle(String soruId, bool isLiked) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    final batch = _db.batch();
    final userRef = _db.collection('kullanicilar').doc(uid);
    final soruRef = _db.collection('sorular').doc(soruId);

    if (isLiked) {
      batch.update(userRef, {'likedPosts': FieldValue.arrayRemove([soruId])});
      batch.update(soruRef, {
        'beyeniSayisi': FieldValue.increment(-1),
        'trendSkoru': FieldValue.increment(-2), // 📉 Beğeni çekilince trend düşer
      });
    } else {
      batch.update(userRef, {'likedPosts': FieldValue.arrayUnion([soruId])});
      batch.update(soruRef, {
        'beyeniSayisi': FieldValue.increment(1),
        'trendSkoru': FieldValue.increment(2), // 🔥 Beğeni trendi artırır
      });
    }
    await batch.commit();
  }

  Future<bool> isTakipEdiyorMu(String hedefUid) async {
    final suankiUid = FirebaseAuth.instance.currentUser?.uid;
    if (suankiUid == null) return false;
    final doc = await _db.collection('kullanicilar').doc(suankiUid).collection('takipEdilenler').doc(hedefUid).get();
    return doc.exists;
  }
}
