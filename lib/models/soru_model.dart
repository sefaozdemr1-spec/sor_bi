import 'package:cloud_firestore/cloud_firestore.dart';

class SoruModel {
  final String id;
  final String kullaniciId; // Soruyu soranın UID'si
  final String baslik;
  final String icerik;     // Sorunun detaylı metni (icerik)
  final String kategori;
  final String tarih;      // Okunabilir tarih (Örn: 2 dk önce)
  final int begeniSayisi;
  final int yorumSayisi;
  final String durum; // 🆕 UGC MODERASYON: 'aktif', 'silindi', 'incelemede'
  
  // Sosyal ve Görsel Tasarım Alanları (UX İçin Şart!)
  final String kullaniciAdi;
  final String kullaniciFoto;
  final String lakap;
  final bool isAnonim;

  SoruModel({
    required this.id,
    required this.kullaniciId,
    required this.baslik,
    required this.icerik,
    required this.kategori,
    required this.tarih,
    required this.begeniSayisi,
    required this.yorumSayisi,
    this.durum = 'aktif', // Yeni eklenen her şey aktiftir
    required this.kullaniciAdi,
    required this.kullaniciFoto,
    this.lakap = "",
    required this.isAnonim,
  });

  factory SoruModel.fromMap(String id, Map<String, dynamic> data) {
    String formatTarih(Timestamp? ts) {
      if (ts == null) return "Az önce";
      final fark = DateTime.now().difference(ts.toDate());
      if (fark.inMinutes < 1) return "Şimdi";
      if (fark.inHours < 1) return "${fark.inMinutes} dk önce";
      if (fark.inDays < 1) return "${fark.inHours} saat önce";
      return "${fark.inDays} gün önce";
    }

    return SoruModel(
      id: id,
      kullaniciId: data['kullaniciId'] ?? '',
      baslik: data['baslik'] ?? '',
      icerik: data['icerik'] ?? data['detay'] ?? '', // Geriye dönük uyum (icerik/detay)
      kategori: data['kategori'] ?? 'Genel',
      tarih: formatTarih(data['tarih'] as Timestamp? ?? data['zaman'] as Timestamp?),
      begeniSayisi: data['begeniSayisi'] ?? 0,
      yorumSayisi: data['yorumSayisi'] ?? 0,
      durum: data['durum'] ?? 'aktif',
      kullaniciAdi: data['kullaniciAdi'] ?? 'Gizli Üye',
      kullaniciFoto: data['kullaniciFoto'] ?? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
      lakap: data['lakap'] ?? '',
      isAnonim: data['isAnonim'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'kullaniciId': kullaniciId,
      'baslik': baslik,
      'icerik': icerik,
      'kategori': kategori,
      'tarih': FieldValue.serverTimestamp(), // Firestore'da 'tarih' olarak saklanır
      'begeniSayisi': begeniSayisi,
      'yorumSayisi': yorumSayisi,
      'durum': durum,
      'kullaniciAdi': kullaniciAdi,
      'kullaniciFoto': kullaniciFoto,
      'lakap': lakap,
      'isAnonim': isAnonim,
    };
  }
}

// Tasarım testleri için sahte veri (Sefa Abi Gözüyle Profesyonel Görünüm):
List<SoruModel> sahteSorular = [
  SoruModel(
    id: "1",
    kullaniciId: "mock1",
    baslik: "Nereden yazılıma başlamalıyım?",
    icerik: "Çok kararsızım ey ahali. Uygulama mı web sitesi mi daha çok iş yapar?",
    kategori: "Teknoloji",
    tarih: "5 dk önce",
    begeniSayisi: 85,
    yorumSayisi: 24,
    kullaniciAdi: "Sefo Başkan",
    kullaniciFoto: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
    lakap: "Yüce Divan",
    isAnonim: false,
  ),
  SoruModel(
    id: "2",
    kullaniciId: "mock2",
    baslik: "Hoşlandığım insana nasıl açılırım?",
    icerik: "Sürekli bakışıyoruz ama bir türlü dökülemiyorum. Ciddi taktik verin gençler.",
    kategori: "İlişkiler",
    tarih: "45 dk önce",
    begeniSayisi: 128,
    yorumSayisi: 45,
    kullaniciAdi: "Gizli Üye",
    kullaniciFoto: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png",
    isAnonim: true,
  ),
];
