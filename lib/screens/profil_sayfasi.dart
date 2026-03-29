import 'package:flutter/material.dart';

class ProfilSayfasi extends StatelessWidget {
  const ProfilSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA), // Pırlanta beyazı ferah arkaplan
        appBar: AppBar(
          title: const Text('Sefo Başkan 👑', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white)),
          backgroundColor: Colors.deepPurpleAccent.shade700,
          elevation: 0,
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
        // WEB İÇİN %100 ÇÖKMEYEN GARANTİ YAPI: Sadece Column ve Expanded Motoru
        body: Column(
          children: [
            // Üst Kısım: Profil Resmi, Banner ve Mikro Statlar (Sabit kalır, asla web'de çökmez)
            Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.bottomCenter,
                  children: [
                    Container(
                      height: 140,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.deepPurpleAccent.shade400, Colors.purple.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: -45,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF7F8FA),
                          shape: BoxShape.circle,
                        ),
                        child: CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.white,
                          child: Icon(Icons.person, size: 50, color: Colors.teal.shade300), 
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 55),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      "Sefo Başkan",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    const SizedBox(width: 10),
                    // KULLANICININ İSTEDİĞİ: "İSMİN YANINDA ALTIN ÇEMBER İÇİNDE" LÜKS TAHT.
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.amber.shade400, Colors.orange.shade700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20), // Çember ve lüks oval hat
                        boxShadow: [
                          BoxShadow(color: Colors.amber.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 3)),
                        ],
                        border: Border.all(color: Colors.amber.shade200, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.verified_rounded, color: Colors.white, size: 16),
                          const SizedBox(width: 4),
                          const Text(
                            "Mekanın Sahibi",
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _mikroStat("Rütbe", "Kurucu"),
                    _dikeyCizgi(),
                    _mikroStat("Kral", "%24"),
                    _dikeyCizgi(),
                    _mikroStat("Takipçi", "141"),
                    _dikeyCizgi(),
                    _mikroStat("Yaş", "33"),
                  ],
                ),
                const SizedBox(height: 15),
              ],
            ),
            // Sabit Sekmeler Barımız (PinkAccent detaylı)
            Container(
              color: const Color(0xFFF7F8FA),
              child: TabBar(
                isScrollable: true,
                indicatorColor: Colors.pinkAccent, 
                labelColor: Colors.deepPurpleAccent.shade700,
                unselectedLabelColor: Colors.grey.shade500,
                tabs: const [
                  Tab(text: "PROFİL ÖZETİ"),
                  Tab(text: "SORULAR"),
                  Tab(text: "KÜRSÜ"),
                  Tab(text: "CEVAPLAR"),
                ],
              ),
            ),
            // Alt Kısım: Sadece bu içerikler kaydırılabilir (Siyah Bembeyaz Ekranı Bitiren Ana Parça)
            Expanded(
              child: TabBarView(
                children: [
                  ListView(
                    padding: const EdgeInsets.only(top: 20, bottom: 80),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _anaStat(Icons.whatshot_rounded, "1.683", "Fişekledi", Colors.pinkAccent),
                          _anaStat(Icons.history_edu_rounded, "0", "Kürsü Yazısı", Colors.teal),
                          _anaStat(Icons.bolt_rounded, "8.539", "Ateş Edildi", Colors.deepPurpleAccent),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _puanFormat("30.022", "SorBi Puanı"),
                          _puanFormat("+1.000", "Genel Sıralama", isGreen: true),
                          _puanFormat("+1.000", "Erkekler Sırası", isGreen: true),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.deepPurple.withOpacity(0.1),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            )
                          ],
                          border: Border.all(color: Colors.teal.shade100, width: 1),
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Kral Cevap 👑",
                              style: TextStyle(color: Colors.deepPurpleAccent.shade700, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '"Bu paylaşımın insanlara ne gibi bir faydası oldu ki durumu anlatsın..."',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text("3", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.deepPurple.shade50),
                                  child: Icon(Icons.thumb_up_alt_rounded, color: Colors.deepPurpleAccent.shade700, size: 14),
                                ),
                                const SizedBox(width: 8),
                                Text("0", style: TextStyle(color: Colors.grey.shade400)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                  Center(child: Text("Sorduğun sorular burada listelenecek 🚧", style: TextStyle(color: Colors.grey.shade600))),
                  Center(child: Text("Kendi özgür ifadelerin (Kürsü) burada tütüyor olacak 🚧", style: TextStyle(color: Colors.grey.shade600))),
                  Center(child: Text("Verdiğin tüm cevaplar buraya düşecek 🚧", style: TextStyle(color: Colors.grey.shade600))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mikroStat(String baslik, String deger) {
    return Column(
      children: [
        Text(baslik, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
        const SizedBox(height: 3),
        Text(deger, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _dikeyCizgi() {
    return Container(
      height: 20, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 14),
    );
  }

  Widget _anaStat(IconData ikon, String sayi, String altYazi, Color ikonRengi) {
    return Column(
      children: [
        Icon(ikon, color: ikonRengi, size: 30),
        const SizedBox(height: 8),
        Text(sayi, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 2),
        Text(altYazi, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }

  Widget _puanFormat(String sayi, String altYazi, {bool isGreen = false}) {
    return Column(
      children: [
        Text(sayi, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isGreen ? Colors.teal.shade600 : Colors.deepPurpleAccent.shade700)),
        const SizedBox(height: 2),
        Text(altYazi, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}
