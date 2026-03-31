import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profil_duzenle_sayfasi.dart';
import 'admin_panel_sayfasi.dart';
import '../main.dart'; // isVitrinModu flag

class ProfilSayfasi extends StatelessWidget {
  const ProfilSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    // 🛡️ BEYAZ/KIRMIZI EKRAN ÖNLEYİCİ: En tepede Vitrin kontrolü!
    if (isVitrinModu) {
      return _buildVitrinProfil(context, Theme.of(context).brightness == Brightness.dark);
    }

    final user = FirebaseAuth.instance.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profilim", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // 🌙/☀️ TEMA DEĞİŞTİRİCİ
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.dark ? Icons.wb_sunny_rounded : Icons.nightlight_round, color: Colors.orangeAccent),
            onPressed: () {
              themeNotifier.value = (themeNotifier.value == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.grey), onPressed: () {}),
          IconButton(icon: const Icon(Icons.logout_rounded, color: Colors.redAccent), onPressed: () => FirebaseAuth.instance.signOut()),
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('kullanicilar').doc(user?.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text("Hata: ${snapshot.error}"));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final d = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          return _buildProfilGovde(context, d, isDark);
        }
      ),
    );
  }

  Widget _buildVitrinProfil(BuildContext context, bool isDark) {
    final mockData = {
      'kullaniciAdi': 'Sefa Bey (Kurucu)',
      'statu': 'SorBi Platformu Sahibi',
      'kullaniciFoto': 'https://i.pravatar.cc/150?u=sefa',
      'toplamSoru': 125,
      'toplamBegeni': 1450,
      'itibar': 99,
      'isAdmin': true,
    };
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profilim", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(themeNotifier.value == ThemeMode.dark ? Icons.wb_sunny_rounded : Icons.nightlight_round, color: Colors.orangeAccent),
            onPressed: () {
              themeNotifier.value = (themeNotifier.value == ThemeMode.dark) ? ThemeMode.light : ThemeMode.dark;
            },
          ),
          IconButton(icon: const Icon(Icons.settings_outlined, color: Colors.grey), onPressed: () {}),
        ],
      ),
      body: _buildProfilGovde(context, mockData, isDark)
    );
  }

  Widget _buildProfilGovde(BuildContext context, Map<String, dynamic> d, bool isDark) {
    final user = FirebaseAuth.instance.currentUser;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 💎 PREMIUM AVATAR HEADER
          Center(
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(colors: [Colors.pinkAccent, Colors.deepPurpleAccent, Colors.blueAccent]),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: isDark ? Colors.black : Colors.white,
                    backgroundImage: (d['kullaniciFoto'] != null && d['kullaniciFoto'] != "") 
                      ? NetworkImage(d['kullaniciFoto']) 
                      : null,
                    child: (d['kullaniciFoto'] == null || d['kullaniciFoto'] == "")
                      ? Icon(Icons.person_rounded, size: 50, color: Colors.grey.shade400)
                      : null,
                  ),
                ),
                if (d['isAdmin'] == true)
                  Positioned(
                    bottom: 5, right: 5,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle),
                      child: const Icon(Icons.verified_rounded, color: Colors.white, size: 20),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            d['kullaniciAdi'] ?? 'İsimsiz Üye', 
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, letterSpacing: -1)
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.pinkAccent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              d['lakap'] ?? 'Yeni SorBiliyo Üyesi', 
              style: const TextStyle(fontSize: 12, color: Colors.pinkAccent, fontWeight: FontWeight.w800)
            ),
          ),
          
          const SizedBox(height: 30),
          
          // 📊 STATS ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("Soru", (d['toplamSoru'] ?? 0).toString(), isDark),
              _buildStatCard("Beğeni", (d['toplamBegeni'] ?? 0).toString(), isDark),
              _buildStatCard("Puan", (d['puan'] ?? 0).toString(), isDark),
            ],
          ),

          const SizedBox(height: 30),
          
          // 🛠️ ACTIONS
          _buildProfileButton("Profilini Düzenle", Icons.settings_suggest_rounded, Colors.blueAccent, () {}),
          if (d['isAdmin'] == true) ... [
            const SizedBox(height: 12),
            _buildProfileButton("Denetim Merkezi", Icons.admin_panel_settings_rounded, Colors.redAccent, () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPanelSayfasi()))),
          ],

          const SizedBox(height: 40),

          // 📜 KENDİ SORULARIM (Dynamic Feed)
          Row(
            children: [
              Icon(Icons.auto_awesome_motion_rounded, color: isDark ? Colors.white60 : Colors.black45, size: 20),
              const SizedBox(width: 10),
              Text(
                "Sorularım", 
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: isDark ? Colors.white : Colors.black87)
              ),
            ],
          ),
          const SizedBox(height: 10),
          
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
              .collection('sorular')
              .where('kullaniciId', isEqualTo: user?.uid)
              .orderBy('zaman', descending: true)
              .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) return const Center(child: Text("Yüklenemedi."));
              if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
              
              final sorular = snapshot.data!.docs;
              if (sorular.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(40.0),
                  child: Text("Henüz hiç soru sormadın kanka! 🎤", style: TextStyle(color: Colors.grey.shade500)),
                );
              }

              return Column(
                children: sorular.map((doc) {
                   final data = doc.data() as Map<String, dynamic>;
                   // SoruKarti widget'ı import edilmeli veya buraya uygun bir yapı kurulmalı
                   // Şimdilik daha hafif bir liste elemanı gösterelim
                   return ListTile(
                     contentPadding: EdgeInsets.zero,
                     leading: const Icon(Icons.question_answer_outlined, color: Colors.pinkAccent),
                     title: Text(data['baslik'] ?? "", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                     subtitle: Text(data['kategori'] ?? "Genel", style: const TextStyle(fontSize: 11)),
                     trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                   );
                }).toList(),
              );
            },
          ),
          
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String val, bool isDark) {
    return Container(
      width: 100,
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C24) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20)],
      ),
      child: Column(
        children: [
          Text(val, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.pinkAccent)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildProfileButton(String text, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15), border: Border.all(color: color.withOpacity(0.2))),
        child: Row(children: [Icon(icon, color: color), const SizedBox(width: 16), Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)), const Spacer(), Icon(Icons.chevron_right_rounded, color: color.withOpacity(0.5))]),
      ),
    );
  }
}
