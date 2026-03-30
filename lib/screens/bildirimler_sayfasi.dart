import 'package:flutter/material.dart';

class BildirimlerSayfasi extends StatefulWidget {
  const BildirimlerSayfasi({super.key});

  @override
  State<BildirimlerSayfasi> createState() => _BildirimlerSayfasiState();
}

class _BildirimlerSayfasiState extends State<BildirimlerSayfasi> {
  String seciliFiltre = "Hepsi";
  final List<String> filtreler = ["Hepsi", "Beğeniler", "Yanıtlar", "Sistem"];

  final List<Map<String, dynamic>> bildirimler = [
    {
      "isim": "Zeynep Yılmaz",
      "mesaj": "size bir arkadaşlık isteği gönderdi.",
      "zaman": "12 dk önce",
      "okunmadi": true,
      "tip": "arkadaslik",
      "avatar": "https://cdn-icons-png.flaticon.com/512/4140/4140047.png"
    },
    {
      "isim": "Mekanın Sahibi (Sefo)",
      "mesaj": "size yeni bir mesaj gönderdi.",
      "zaman": "1 saat önce",
      "okunmadi": true,
      "tip": "mesaj",
      "avatar": "https://cdn-icons-png.flaticon.com/512/3135/3135715.png"
    },
    {
      "isim": "Cem K.",
      "mesaj": "\"Bu yaptığım yemek nasıl olmuş sizce?\" gönderinizi beğendi.",
      "zaman": "3 saat önce",
      "okunmadi": false,
      "tip": "begeni",
      "avatar": "https://cdn-icons-png.flaticon.com/512/4140/4140048.png"
    },
    {
      "isim": "Elif Aslan",
      "mesaj": "gönderinize yeni bir yanıt (yorum) bıraktı.",
      "zaman": "1 gün önce",
      "okunmadi": false,
      "tip": "yorum",
      "avatar": "https://cdn-icons-png.flaticon.com/512/4140/4140040.png"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Bildirimler', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text("Tümünü Oku", style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Filtre Çipleri (Horizontal Chips)
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: filtreler.length,
              itemBuilder: (context, index) {
                final f = filtreler[index];
                final secili = seciliFiltre == f;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    label: Text(f),
                    selected: secili,
                    onSelected: (val) => setState(() => seciliFiltre = f),
                    selectedColor: Colors.deepPurpleAccent,
                    labelStyle: TextStyle(color: secili ? Colors.white : Colors.grey.shade700, fontWeight: FontWeight.bold, fontSize: 13),
                    backgroundColor: Colors.grey.shade100,
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1),

          // 2. Bildirim Listesi
          Expanded(
            child: ListView.separated(
              itemCount: bildirimler.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: Colors.grey.shade100, indent: 80),
              itemBuilder: (context, index) {
                final b = bildirimler[index];
                return _buildBildirimTile(b);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBildirimTile(Map<String, dynamic> b) {
    final bool okunmadi = b["okunmadi"];
    return Container(
      color: okunmadi ? Colors.deepPurpleAccent.withOpacity(0.02) : Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundImage: NetworkImage(b["avatar"]),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _bildirimRengi(b["tip"]),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Icon(_bildirimIkonu(b["tip"]), size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 14, color: Colors.black87, height: 1.4),
                    children: [
                      TextSpan(text: "${b["isim"]} ", style: const TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: b["mesaj"]),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(b["zaman"], style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
                if (b["tip"] == "arkadaslik")
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.pinkAccent,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Kabul Et", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton(
                          onPressed: () {},
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.grey.shade300),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text("Sil", style: TextStyle(color: Colors.black87, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          if (okunmadi)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.pinkAccent, shape: BoxShape.circle)),
            ),
        ],
      ),
    );
  }

  IconData _bildirimIkonu(String tip) {
    switch (tip) {
      case "arkadaslik": return Icons.person_add_rounded;
      case "mesaj": return Icons.send_rounded;
      case "begeni": return Icons.favorite_rounded;
      case "yorum": return Icons.chat_bubble_rounded;
      default: return Icons.notifications_rounded;
    }
  }

  Color _bildirimRengi(String tip) {
    switch (tip) {
      case "arkadaslik": return Colors.blue;
      case "mesaj": return Colors.deepPurpleAccent;
      case "begeni": return Colors.pinkAccent;
      case "yorum": return Colors.teal;
      default: return Colors.grey;
    }
  }
}
