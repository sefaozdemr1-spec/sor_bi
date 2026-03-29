// Aşama 6: Ödüllü Gamification (Oyunlaştırma) Motoru Lakapları
// Moderatörlerin aktif kullanıcılara 1 haftalık takacağı 50 Efsanevi Rütbe Listesi
class SorBiLakapKutuphanesi {
  static const List<String> asaletVeElitler = [
    "Mekanın Sahibi", "Yüce Divan", "Sefo'nun Sağ Kolu", "Taçsız Kral", 
    "Altın Aura", "Ağır Abi", "Saygıdeğer", "Sigma Kuralı", 
    "Konsolos", "Baş Yargıç", "Gecelerin Hakimi", "Sarsılmaz İrade"
  ];
  
  static const List<String> bilgelikVeKursu = [
    "Ayaklı Kütüphane", "Felsefe Taşı", "Kürsü Fatihi", "Satranç Ustası", 
    "Kral Cevapçı", "Olay Yeri İnceleme", "Çözüm Merkezi", "Derin Filozof", 
    "Strateji Dehası", "Kılavuz Kaptan", "Üstad-ı Azam", "Sessiz Dedektif", "Gölge Mantık"
  ];
  
  static const List<String> sosyalAtesVePopulerlik = [
    "Mahallenin Gülü", "Parlayan Yıldız", "Aura Makinesi", "Fişekleyici", 
    "Gece Kuşu", "Gıybet Bakanı", "Alfa Kurt", "Fenomen", 
    "Trend Belirleyici", "İlham Perisi", "Gözde Üye", "Nabız Tutan", "Cazibe Merkezi"
  ];
  
  static const List<String> mizahVeEglence = [
    "Trol Bükücü", "Boş Yapanların Kabusu", "Semtin Delikanlısı", 
    "Sır Küpü", "Pozitif Enerji Şelalesi", "Kara Mizahşör", "Laf Cambazı", 
    "Nükte Kralı", "Kahkaha Jeneratörü", "Gülümseten Prens", "Şen Şakrak", "Harbi İnsan"
  ];

  static List<String> get tum50EtkileyiciLakap => [
    ...asaletVeElitler,
    ...bilgelikVeKursu,
    ...sosyalAtesVePopulerlik,
    ...mizahVeEglence,
  ];
}
