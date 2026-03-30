import 'package:flutter/material.dart';

class SohbetSayfasi extends StatelessWidget {
  final String isim;
  final String avatarUrl;
  final bool aktifMi;

  const SohbetSayfasi({
    super.key,
    required this.isim,
    required this.avatarUrl,
    required this.aktifMi,
  });

  @override
  Widget build(BuildContext context) {
    // Sefa Abi İçin Hazırlanan Örnek Chat (Sohbet) Balonları Şelalesi
    final List<Map<String, dynamic>> sohbetGecmisi = [
      {
        "metin": "Selam Sefa abi, senin verdiğin vizyonla projenin son tasarımlarına ufak bir Apple HIG makyajı çektik.",
        "benimMi": false,
        "zaman": "14:22",
        "durum": "" 
      },
      {
        "metin": "Selamlar. Evet inceledim, özellikle o devasa yeşil ışıklı 'Çevrimiçi' zırhı harika oldu.",
        "benimMi": true,
        "zaman": "14:25",
        "durum": "mavi_cift_tik" // Okundu
      },
      {
        "metin": "Harika haber! Şimdi senden aldığım onayla 'Sohbet Odasını' ve baloncuklarını kodluyorum.",
        "benimMi": false,
        "zaman": "14:26",
        "durum": ""
      },
      {
        "metin": "Mükemmel. Gönderildiğinde tek gri, iletildiğinde çift gri, okunduğunda ise çift mavi tık olması çok kurumsal duracaktır.",
        "benimMi": true,
        "zaman": "14:27",
        "durum": "gri_cift_tik" // İletildi (Karşı taraf çevrimiçi ama bakmadı varsayalım)
      },
      {
        "metin": "App Store PEGI reytingini 12+ alacağımız gerçeğini de planlar arasına kesin koyalım, Apple oradan kesin çakar yoksa.",
        "benimMi": true,
        "zaman": "14:28",
        "durum": "gri_tek_tik" // Sadece Gitti (Network de kaldı varsayalım)
      },
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        automaticallyImplyLeading: false, // Orijinal Geri tuşunu biz kuruyoruz
        title: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.blueAccent),
              onPressed: () => Navigator.pop(context),
            ),
            Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 20, 
                  backgroundColor: Colors.grey.shade200, 
                  backgroundImage: NetworkImage(avatarUrl)
                ),
                if (aktifMi)
                  Positioned(
                    bottom: 0, right: -2,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(color: Colors.greenAccent.shade400, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2)),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(isim, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)),
                Text(aktifMi ? 'Çevrimiçi' : 'Son görülme 2 saat önce', style: TextStyle(fontSize: 12, color: aktifMi ? Colors.green.shade600 : Colors.grey.shade500)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.videocam_rounded, color: Colors.blueAccent, size: 28), onPressed: () {}),
          IconButton(icon: const Icon(Icons.call_rounded, color: Colors.blueAccent, size: 24), onPressed: () {}),
          const SizedBox(width: 8)
        ],
      ),
      body: Column(
        children: [
          // Sohbet Alanı
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: sohbetGecmisi.length,
              itemBuilder: (context, index) {
                final mesaj = sohbetGecmisi[index];
                bool benimMi = mesaj["benimMi"];

                return Row(
                  mainAxisAlignment: benimMi ? MainAxisAlignment.end : MainAxisAlignment.start,
                  children: [
                    if (!benimMi) ...[
                      CircleAvatar(radius: 14, backgroundImage: NetworkImage(avatarUrl)),
                      const SizedBox(width: 8),
                    ],
                    // Baloncuk Container
                    Flexible(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: benimMi ? Colors.blueAccent.shade700 : Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(20),
                            topRight: const Radius.circular(20),
                            bottomLeft: Radius.circular(benimMi ? 20 : 0),
                            bottomRight: Radius.circular(benimMi ? 0 : 20),
                          ),
                          boxShadow: [
                            BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2))
                          ]
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              mesaj["metin"],
                              style: TextStyle(
                                fontSize: 15,
                                color: benimMi ? Colors.white : Colors.black87,
                                height: 1.3
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Saat ve Durum Simgeleri (Tıklar) Tablosu
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  mesaj["zaman"],
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: benimMi ? Colors.white70 : Colors.grey.shade500
                                  ),
                                ),
                                if (benimMi) ...[
                                  const SizedBox(width: 4),
                                  _durumIkonuOlustur(mesaj["durum"])
                                ]
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          
          // Alt Kısım - Alt Menü (Text Field ve Araçlar)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey.shade200, width: 1))
            ),
            child: Row(
              children: [
                IconButton(icon: const Icon(Icons.add_circle_outline_rounded, color: Colors.blueAccent, size: 28), onPressed: () {}),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 0.5)
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: "Mesaj yaz...",
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(bottom: 8)
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(icon: const Icon(Icons.mic_none_rounded, color: Colors.blueAccent, size: 28), onPressed: () {}),
              ],
            ),
          )
        ],
      ),
    );
  }

  // Sefa Abi'nin Özel İsteği: Gittiğinde 1 tık, Okunduğunda 2 tık
  Widget _durumIkonuOlustur(String durumAd) {
    switch (durumAd) {
      case "mavi_cift_tik":
        return const Icon(Icons.done_all_rounded, color: Colors.cyanAccent, size: 16); // Mavi tonlarında okundu tiki
      case "gri_cift_tik":
        return const Icon(Icons.done_all_rounded, color: Colors.white70, size: 16); // Beyaz/Gri silik çift tık
      case "gri_tek_tik":
        return const Icon(Icons.done_rounded, color: Colors.white70, size: 16); // Beyaz/Gri tek tık
      default:
        return const SizedBox.shrink();
    }
  }
}
