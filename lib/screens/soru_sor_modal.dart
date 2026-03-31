import '../services/dino_servisi.dart'; // 🦖 Dino AI buraya, en tepeye!
import '../services/telegram_servisi.dart'; // 🛰️ TELEGRAM KOMUTA MERKEZİ!
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/soru_model.dart';
import '../core/providers/auth_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SoruSorModal extends ConsumerStatefulWidget {
  const SoruSorModal({super.key});

  @override
  ConsumerState<SoruSorModal> createState() => _SoruSorModalState();
}

class _SoruSorModalState extends ConsumerState<SoruSorModal> {
  final _baslikController = TextEditingController();
  final _detayController = TextEditingController();
  bool _gizliUyeOlsun = false;
  String _seciliKategori = "Genel";
  bool _isPosting = false;

  final List<Map<String, dynamic>> _kategoriler = [
    {"baslik": "Genel", "ikon": Icons.widgets_rounded, "renk": Colors.grey},
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.only(
        top: 24,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1D) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 50, height: 5,
              decoration: BoxDecoration(color: Colors.grey.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Aklındaki Soruyu Ateşle 🔥",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: isDark ? Colors.white60 : Colors.black45),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // KATEGORİ SEÇİCİ
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

          TextField(
            controller: _baslikController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            decoration: InputDecoration(
              hintText: "Soru başlığı ne olsun?",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _detayController,
            style: TextStyle(color: isDark ? Colors.white : Colors.black),
            maxLines: 4,
            decoration: InputDecoration(
              hintText: "Biraz detay ver kanka...",
              hintStyle: TextStyle(color: Colors.grey.shade500),
              filled: true,
              fillColor: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),

          SwitchListTile(
            title: Text("Gizli Üye olarak sor 🕵️‍♂️", style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 14)),
            value: _gizliUyeOlsun,
            activeColor: Colors.pinkAccent,
            onChanged: (val) => setState(() => _gizliUyeOlsun = val),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isPosting ? null : _soruGonder,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.pinkAccent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 5,
            ),
            child: _isPosting 
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text("Soruyu Ateşle 🔥", style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _soruGonder() async {
    if (_baslikController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Kullanıcı profilini çekelim (İsim Garantili!)
      final userDoc = await FirebaseFirestore.instance.collection('kullanicilar').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      
      // 🛡️ İsim ve Fotoğraf için 3 katmanlı güvenlik (Firestore -> Auth -> Varsayılan)
      final String ad = _gizliUyeOlsun 
          ? "Gizli Kullanıcı" 
          : (userData['kullaniciAdi'] ?? user.displayName ?? "SorBiliyo Üyesi");
      
      final String foto = _gizliUyeOlsun 
          ? "" 
          : (userData['kullaniciFoto'] ?? user.photoURL ?? "");

      final yeniSoru = {
        'kullaniciId': user.uid,
        'kullaniciAdi': ad,
        'kullaniciFoto': foto,
        'baslik': _baslikController.text.trim(),
        'icerik': _detayController.text.trim(),
        'kategori': _seciliKategori,
        'zaman': FieldValue.serverTimestamp(),
        'begeniSayisi': 0,
        'yorumSayisi': 0,
        'isAnonim': _gizliUyeOlsun,
        'trendSkoru': 0,
        'durum': 'aktif',
      };

      // 🦖 SORUYU EKLE VE ID'YI AL
      final docRef = await FirebaseFirestore.instance.collection('sorular').add(yeniSoru).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw 'Firestore Zaman Aşımı! Lütfen veritabanı kapalı mı kontrol edin.',
      );

      // Dino AI Cevap Versin (Arka planda çalışsın!)
      DinoServisi().ilkCevabiPatlat(docRef.id, _baslikController.text.trim());

      // 🛡️ TELEGRAM KOMUTA MERKEZİNE BİLDİR! (Sefa Abi Elite Rapor)
      try {
        await TelegramServisi.yeniSoruBildir(
          baslik: _baslikController.text.trim(),
          yazar: ad,
          kategori: _seciliKategori,
        );
      } catch (e) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(content: Text("🚀 Telegram Raporu Fırlatılamadı: $e"), backgroundColor: Colors.orangeAccent),
           );
        }
      }

      // ✅ PUAN KAZANDIR (Sessiz ve Güvenli Mod)
      try {
        await FirebaseFirestore.instance.collection('kullanicilar').doc(user.uid).set({
          'puan': FieldValue.increment(_gizliUyeOlsun ? 5 : 15),
          'toplamSoru': FieldValue.increment(1),
        }, SetOptions(merge: true)).timeout(const Duration(seconds: 4)); 
      } catch (_) {
        // Puan başarısız olsa da kullanıcıya hata gösterme
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("🚀 Sorun ateşlendi! Dino AI uyandı! 🦖"), backgroundColor: Colors.pinkAccent),
        );
      }
    } catch (e) {
      if (mounted) {
        String msg = e.toString();
        if (msg.contains("permission-denied")) msg = "🔒 Üzgünüz, Firestore yazma iznin yok. (Rules'ı kontrol et!)";
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $msg"), backgroundColor: Colors.redAccent));
      }
    }
    setState(() => _isPosting = false);
  }
}
