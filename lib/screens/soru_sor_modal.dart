import 'package:flutter/material.dart';

class SoruSorModal extends StatefulWidget {
  const SoruSorModal({super.key});

  @override
  State<SoruSorModal> createState() => _SoruSorModalState();
}

class _SoruSorModalState extends State<SoruSorModal> {
  final _baslikController = TextEditingController();
  final _detayController = TextEditingController();
  bool _gizliUyeOlsun = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20, // Telefon klavyesi açılınca pencere yukarı iter
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A), // Temaya uyan lüks, hafif siyah arka plan
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ekranın tümünü kaplamasın, içerik kadar yer kaplasın
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // En üstteki küçük çentik/çizgi
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade700,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Aklındaki Soruyu Ateşle 🔥",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          // Soru Başlığı Yazılacak Kutu
          TextField(
            controller: _baslikController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Örn: En kârlı yazılım dili hangisidir?",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Detayların Yazılacağı Uzun Kutu
          TextField(
            controller: _detayController,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Sorunu, dertlerini veya olayları buraya dök kanka...",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Sefa'nın Özel İstediği "Gizli Üye" Şalteri
          SwitchListTile(
            title: const Text(
              "Gizli Üye Olarak Sor 🕵️‍♂️",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              "Profilin ve gerçek adın asla gözükmez.",
              style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            ),
            value: _gizliUyeOlsun,
            activeColor: Colors.deepPurpleAccent,
            onChanged: (value) {
              setState(() {
                _gizliUyeOlsun = value;
              });
            },
          ),
          const SizedBox(height: 20),
          // Büyülü Gönder Butonu
          ElevatedButton(
            onPressed: () {
              // Firebase'e "Veri Kaydetme" mantığı Aşama 3'te buraya bağlanacak! Şimdilik ekranda bildirim fırlatacak.
              Navigator.pop(context); // Tıklandığında pencereyi usulca kapatır
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Soru roketlendi! 🚀"),
                  backgroundColor: Colors.deepPurpleAccent,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Roketle (Gönder)",
              style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
