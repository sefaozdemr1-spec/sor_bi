class ModerasyonServisi {
  // Sefa Abi, burası kurumsal Milyar Dolarlık uygulamanın "Kara Listesidir".
  // Bu listeye eklenen kelimeler gönderi atılırken sistem tarafından kesilir ve yayınlanmaz!
  static final List<String> _kufurVeSansurSistemi = [
    "aptal",
    "salak",
    "gerizekalı",
    "gerizekali",
    "o.ç",
    "amk",
    "aq",
    "sürtük",
    "köpek", // Örnek argo
    // Apple İnceleme Kurulu için (UGC Kuralları gereği pornografik ve nefret kelimeleri buraya dahil edilmelidir).
  ];

  /// Eğer gönderi bu kara listedeki kelimelerden birini barındırıyorsa TRUE döner (İhbar Alarmi)
  static bool kufurVarMi(String metin) {
    if (metin.isEmpty) return false;

    // Kelimenin aralarına nokta koyup geçemesinler diye küçük harfe çevirip boşlukları siliyoruz (Temel Düzey Yapay Zeka)
    String kucukHarfliMetin = metin.toLowerCase().replaceAll(" ", "").replaceAll(".", "");

    for (String yasakliKelime in _kufurVeSansurSistemi) {
      if (kucukHarfliMetin.contains(yasakliKelime)) {
        return true; 
      }
    }
    return false;
  }
}
