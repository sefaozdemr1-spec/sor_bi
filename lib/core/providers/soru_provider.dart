import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/soru_model.dart';

// ───────────────────────────────────────────
// 📋 SORULAR PROVIDER — Ana Akış Feed'i
// ───────────────────────────────────────────

/// En yeni sorular - Firestore realtime stream
final yeniSorularProvider = StreamProvider<List<SoruModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('sorular')
      .where('durum', isEqualTo: 'aktif')
      .orderBy('tarih', descending: true)
      .limit(30)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => SoruModel.fromMap(doc.id, doc.data()))
          .toList());
});

/// Trend sorular - Beğeni sayısına göre sıralı
final trendSorularProvider = StreamProvider<List<SoruModel>>((ref) {
  return FirebaseFirestore.instance
      .collection('sorular')
      .where('durum', isEqualTo: 'aktif')
      .orderBy('begeniSayisi', descending: true)
      .limit(30)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => SoruModel.fromMap(doc.id, doc.data()))
          .toList());
});

/// Belirli bir kategoriye ait sorular
final kategoriSorularProvider =
    StreamProvider.family<List<SoruModel>, String>((ref, kategori) {
  return FirebaseFirestore.instance
      .collection('sorular')
      .where('kategori', isEqualTo: kategori)
      .where('durum', isEqualTo: 'aktif')
      .orderBy('tarih', descending: true)
      .limit(20)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => SoruModel.fromMap(doc.id, doc.data()))
          .toList());
});

// ───────────────────────────────────────────
// 📝 SORU SERVISI — Yaz / Beğen / Sil
// ───────────────────────────────────────────

class SoruServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Yeni soru paylaş
  Future<void> soruPaylAS({
    required String kullaniciId,
    required String kullaniciAdi,
    required String kullaniciFoto,
    required String baslik,
    required String icerik,
    required String kategori,
    bool isAnonim = false,
  }) async {
    await _db.collection('sorular').add({
      'kullaniciId': kullaniciId,
      'kullaniciAdi': isAnonim ? 'Anonim' : kullaniciAdi,
      'kullaniciFoto': isAnonim ? '' : kullaniciFoto,
      'baslik': baslik.trim(),
      'icerik': icerik.trim(),
      'kategori': kategori,
      'begeniSayisi': 0,
      'yorumSayisi': 0,
      'durum': 'aktif',
      'isAnonim': isAnonim,
      'tarih': FieldValue.serverTimestamp(),
    });
  }

  /// Soruyu beğen / beğeni kaldır
  Future<void> begeniToggle({
    required String soruId,
    required String kullaniciId,
    required bool simdiBegeniyor,
  }) async {
    final soruRef = _db.collection('sorular').doc(soruId);
    final begeniRef = soruRef.collection('begenenler').doc(kullaniciId);

    final batch = _db.batch();
    if (simdiBegeniyor) {
      batch.delete(begeniRef);
      batch.update(soruRef, {'begeniSayisi': FieldValue.increment(-1)});
    } else {
      batch.set(begeniRef, {'tarih': FieldValue.serverTimestamp()});
      batch.update(soruRef, {'begeniSayisi': FieldValue.increment(1)});
    }
    await batch.commit();
  }

  /// Soruyu sil (sadece sahip veya admin)
  Future<void> soruSil(String soruId) async {
    await _db
        .collection('sorular')
        .doc(soruId)
        .update({'durum': 'silindi'});
  }

  /// Kullanıcının bu soruyu beğenip beğenmediğini kontrol et
  Stream<bool> begeniDurumuGetir(String soruId, String kullaniciId) {
    return _db
        .collection('sorular')
        .doc(soruId)
        .collection('begenenler')
        .doc(kullaniciId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}

final soruServisiProvider = Provider<SoruServisi>((ref) => SoruServisi());
