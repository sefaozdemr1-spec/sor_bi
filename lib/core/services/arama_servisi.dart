import 'package:cloud_firestore/cloud_firestore.dart';

class AramaServisi {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 🔍 SORU ARAMA (Başlığa Göre)
  Stream<QuerySnapshot> soruAra(String kelime) {
    if (kelime.isEmpty) {
      // Kelime boşsa en yenileri getir
      return _db.collection('sorular').orderBy('zaman', descending: true).limit(30).snapshots();
    }

    // Basit Firestore String Araması (Büyük-küçük harf duyarlılığı için lowercase index gerekebilir)
    return _db
        .collection('sorular')
        .where('soruMetni', isGreaterThanOrEqualTo: kelime)
        .where('soruMetni', isLessThanOrEqualTo: '$kelime\uf8ff')
        .limit(20)
        .snapshots();
  }

  // 👤 KULLANICI ARAMA (İsme Göre)
  Stream<QuerySnapshot> kullaniciAra(String isim) {
    if (isim.isEmpty) return const Stream.empty();

    return _db
        .collection('kullanicilar')
        .where('kullaniciAdi', isGreaterThanOrEqualTo: isim)
        .where('kullaniciAdi', isLessThanOrEqualTo: '$isim\uf8ff')
        .limit(20)
        .snapshots();
  }
}
