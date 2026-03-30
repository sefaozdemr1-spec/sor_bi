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
      body: isVitrinModu 
        ? _buildVitrinProfil(context, isDark)
        : StreamBuilder<DocumentSnapshot>(
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
    return _buildProfilGovde(context, mockData, isDark);
  }

  Widget _buildProfilGovde(BuildContext context, Map<String, dynamic> d, bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(shape: BoxShape.circle, gradient: const LinearGradient(colors: [Colors.pinkAccent, Colors.deepPurpleAccent])),
              child: CircleAvatar(radius: 54, backgroundColor: Colors.black, backgroundImage: NetworkImage(d['kullaniciFoto'] ?? 'https://via.placeholder.com/150')),
            ),
          ),
          const SizedBox(height: 16),
          Text(d['kullaniciAdi'] ?? 'Kullanıcı', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, letterSpacing: -1)),
          const SizedBox(height: 4),
          Text(d['statu'] ?? 'SorBi Üyesi', style: const TextStyle(fontSize: 14, color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
          const SizedBox(height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard("Soru", (d['toplamSoru'] ?? 0).toString(), isDark),
              _buildStatCard("Beğeni", (d['toplamBegeni'] ?? 0).toString(), isDark),
              _buildStatCard("Puan", (d['itibar'] ?? 10).toString(), isDark),
            ],
          ),
          const SizedBox(height: 40),
          _buildProfileButton("Profilini Düzenle", Icons.edit_note_rounded, Colors.deepPurpleAccent, () {}),
          if (d['isAdmin'] == true) ... [
            const SizedBox(height: 16),
            _buildProfileButton("Denetim Merkezi", Icons.admin_panel_settings_rounded, Colors.redAccent.shade200, () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdminPanelSayfasi()))),
          ],
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
