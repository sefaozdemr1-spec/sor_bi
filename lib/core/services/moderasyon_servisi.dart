class ModerasyonServisi {
  // 🛡️ KISITLI KELİMELER: Küfür, hakaret veya yasaklı içerik filtreleri
  final List<String> _yasakliKelimeler = [
    "küfür1", "küfür2", "hakaret", "reklam", // Buraya gerçek veriler eklenecek
  ];

  // 🛡️ İÇERİK TEMİZ Mİ? (Filtreleme)
  bool icerikTemizMi(String metin) {
    if (metin.trim().isEmpty) return false;

    String kontrolMetni = metin.toLowerCase();
    for (String yasakli in _yasakliKelimeler) {
      if (kontrolMetni.contains(yasakli)) {
        return false; // Zararlı içerik bulundu
      }
    }
    return true; // İçerik uygun
  }

  // 🛡️ SPAM KONTROLÜ (Aynı mesajın tekrarı engellenir)
  bool spamMi(String eskiMetin, String yeniMetin) {
    return eskiMetin.trim() == yeniMetin.trim();
  }
}
