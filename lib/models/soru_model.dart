class SoruModel {
  final String id;
  final String baslik;
  final String detay;
  final String kullaniciAdi;
  final String kullaniciFoto; // Yeni eklenen avatar kancası
  final String lakap; // Haftanın Seçkin Lakabı (Altın Rozet için)
  final String zaman; // Yazı formatında yeni zaman etiketi
  final bool isAnonim;
  final int begeniSayisi;
  final int yorumSayisi;

  SoruModel({
    required this.id,
    required this.baslik,
    required this.detay,
    required this.kullaniciAdi,
    required this.kullaniciFoto,
    this.lakap = "", // Varsayılan olarak lakabı olmayabilir
    required this.zaman,
    required this.isAnonim,
    required this.begeniSayisi,
    required this.yorumSayisi,
  });
}

// Şimdilik Chrome ekranında arayüzü ve yepyeni Milyonluk Altın Rozeti görebilmen için sahte sorular:
List<SoruModel> sahteSorular = [
  SoruModel(
    id: "1",
    baslik: "Nereden yazılıma başlamalıyım?",
    detay: "Çok kararsızım ey ahali. Uygulama mı web sitesi mi daha çok iş yapar?",
    kullaniciAdi: "Sefo Başkan",
    kullaniciFoto: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", // Standart Lüks Avatar
    lakap: "Yüce Divan", // Modların verdiği özel lakap!
    zaman: "5 dk önce",
    isAnonim: false,
    begeniSayisi: 85,
    yorumSayisi: 24,
  ),
  SoruModel(
    id: "2",
    baslik: "Hoşlandığım insana nasıl açılırım?",
    detay: "Sürekli bakışıyoruz ama bir türlü dökülemiyorum. Ciddi taktik verin gençler daraldım.",
    kullaniciAdi: "KaraSovalye", 
    kullaniciFoto: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", 
    lakap: "", // Gizli üyede lüks rozet parlamaz
    zaman: "45 dk önce", 
    isAnonim: true,
    begeniSayisi: 128,
    yorumSayisi: 45,
  ),
  SoruModel(
    id: "3",
    baslik: "Geliştirici Modu (Developer Mode) tehlikeli falan mı?",
    detay: "Öğrenmek için açtım ama hacklenmeyiz dimi lan? 😂",
    kullaniciAdi: "KodcuÇırak",
    kullaniciFoto: "https://cdn-icons-png.flaticon.com/512/3135/3135715.png", 
    lakap: "Kürsü Fatihi", // Profilinde Sergilenen Parlak Ödül
    zaman: "2 saat önce",
    isAnonim: false,
    begeniSayisi: 18,
    yorumSayisi: 7,
  ),
];
