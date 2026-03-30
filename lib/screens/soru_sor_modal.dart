import 'package:flutter/material.dart';
import '../models/soru_model.dart';
import '../services/firestore_servisi.dart';
import '../services/auth_servisi.dart';
import '../services/moderasyon_servisi.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SoruSorModal extends StatefulWidget {
  const SoruSorModal({super.key});

  @override
  State<SoruSorModal> createState() => _SoruSorModalState();
}

class _SoruSorModalState extends State<SoruSorModal> {
  final _baslikController = TextEditingController();
  final _detayController = TextEditingController();
  bool _gizliUyeOlsun = false;
  String _seciliKategori = "Genel";

  // Mevcut Kategoriler (Ana Akışla Birebir Uyumlu!)
  final List<Map<String, dynamic>> _kategoriler = [
    {"baslik": "Genel", "ikon": Icons.widgets_rounded, "renk": Colors.black87},
    {"baslik": "Gündem", "ikon": Icons.local_fire_department_rounded, "renk": Colors.redAccent},
    {"baslik": "Mutfak", "ikon": Icons.restaurant_rounded, "renk": Colors.orangeAccent},
    {"baslik": "Kombin", "ikon": Icons.checkroom_rounded, "renk": Colors.pinkAccent},
    {"baslik": "Teknoloji", "ikon": Icons.computer_rounded, "renk": Colors.blueAccent},
    {"baslik": "İlişkiler", "ikon": Icons.favorite_rounded, "renk": Colors.purpleAccent},
    {"baslik": "Seyahat", "ikon": Icons.flight_takeoff_rounded, "renk": Colors.teal},
    {"baslik": "Spor", "ikon": Icons.sports_soccer_rounded, "renk": Colors.green},
    {"baslik": "Eğitim", "ikon": Icons.school_rounded, "renk": Colors.indigoAccent},
    {"baslik": "Sanat", "ikon": Icons.movie_rounded, "renk": Colors.deepPurpleAccent},
    {"baslik": "Kariyer", "ikon": Icons.work_rounded, "renk": Colors.blueGrey},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey.shade700, borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Aklındaki Soruyu Ateşle 🔥",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),

          // KATEGORİ SEÇİCİ (Yatay Kaydıran Chip Menüsü)
          const Text("Kategori Seç", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          SizedBox(
            height: 42,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _kategoriler.length,
              itemBuilder: (context, index) {
                final kat = _kategoriler[index];
                final seciliMi = _seciliKategori == kat["baslik"];
                final Color renk = kat["renk"] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _seciliKategori = kat["baslik"]),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: seciliMi ? renk : renk.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: renk.withOpacity(seciliMi ? 1 : 0.3), width: 1.5),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(kat["ikon"] as IconData, size: 14, color: seciliMi ? Colors.white : renk),
                        const SizedBox(width: 5),
                        Text(kat["baslik"], style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: seciliMi ? Colors.white : renk)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),

          // Soru Başlığı
          TextField(
            controller: _baslikController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: "Örn: En kârlı yazılım dili hangisidir?",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          // Detay
          TextField(
            controller: _detayController,
            style: const TextStyle(color: Colors.white),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Sorunu, dertlerini veya olayları buraya dök kanka...",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: const Color(0xFF2C2C2C),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),

          // Gizli Üye Şalteri
          SwitchListTile(
            title: const Text("Gizli Üye Olarak Sor 🕵️‍♂️", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text("Profilin ve gerçek adın asla gözükmez.", style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
            value: _gizliUyeOlsun,
            activeColor: Colors.deepPurpleAccent,
            onChanged: (value) => setState(() => _gizliUyeOlsun = value),
          ),
          const SizedBox(height: 20),

          // Paylaş Butonu
          ElevatedButton(
            onPressed: () async {
              if (_baslikController.text.isEmpty || _detayController.text.isEmpty) return;

              // MİLYARLIK MODERASYON FİLTRESİ (UGC)
              if (ModerasyonServisi.kufurVarMi(_baslikController.text) ||
                  ModerasyonServisi.kufurVarMi(_detayController.text)) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("⚠️ Uyarı: Sorunuz uygunsuz kelimeler içeriyor. Lütfen asil bir dil kullanın."),
                      backgroundColor: Colors.redAccent,
                    ),
                  );
                }
                return;
              }

              final orijinalUyemiz = await AuthServisi().getCurrentUserProfil();
              if (orijinalUyemiz == null) return;

              final firebaseUid = FirebaseAuth.instance.currentUser?.uid ?? "";
              final anaIsim = orijinalUyemiz['kullaniciAdi'] ?? "Anonim Kullanıcı";
              final asilAvatar = orijinalUyemiz['kullaniciFoto'] ?? "https://cdn-icons-png.flaticon.com/512/3135/3135715.png";
              final sahipLakap = orijinalUyemiz['lakap'] ?? "";

              final sistemKullanicisi = _gizliUyeOlsun ? "Gizli Kullanıcı" : anaIsim;
              final sistemLakabi = _gizliUyeOlsun ? "" : sahipLakap;

              final yeniBulutSoru = SoruModel(
                id: "",
                kullaniciId: _gizliUyeOlsun ? "" : firebaseUid,
                baslik: _baslikController.text,
                icerik: _detayController.text,
                kategori: _seciliKategori, 
                tarih: "Şimdi",
                begeniSayisi: 0,
                yorumSayisi: 0,
                kullaniciAdi: sistemKullanicisi,
                kullaniciFoto: asilAvatar,
                lakap: sistemLakabi,
                isAnonim: _gizliUyeOlsun,
              );

              await FirestoreServisi().soruEkle(yeniBulutSoru);
              
              // Task 5: Puan Kazandır (+10 Puan)
              if (!_gizliUyeOlsun && firebaseUid.isNotEmpty) {
                await FirebaseFirestore.instance.collection('kullanicilar').doc(firebaseUid).update({
                  'puan': FieldValue.increment(10)
                });
              }

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(_gizliUyeOlsun
                        ? "Gönderiniz anonim olarak başarıyla paylaşıldı."
                        : "$anaIsim, gönderiniz başarıyla paylaşıldı."),
                    backgroundColor: Colors.deepPurpleAccent,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Paylaş", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
