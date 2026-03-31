import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/services/arama_servisi.dart';
import '../models/soru_model.dart';
import '../widgets/soru_karti.dart';
import 'misafir_profil_sayfasi.dart';
import '../main.dart'; // isVitrinModu flag

class KesfetSayfasi extends StatefulWidget {
  const KesfetSayfasi({super.key});

  @override
  State<KesfetSayfasi> createState() => _KesfetSayfasiState();
}

class _KesfetSayfasiState extends State<KesfetSayfasi> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _aramaController = TextEditingController();
  String _aramaKelimesi = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        title: Container(
          height: 45,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(25), border: Border.all(color: Colors.white.withOpacity(0.05))),
          child: TextField(
            controller: _aramaController,
            style: const TextStyle(color: Colors.white),
            onChanged: (val) => setState(() => _aramaKelimesi = val),
            decoration: const InputDecoration(
              hintText: 'Soru veya kişi ara...',
              hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
              prefixIcon: Icon(Icons.search_rounded, color: Colors.pinkAccent),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.pinkAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.pinkAccent,
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          tabs: const [Tab(text: "Sorular"), Tab(text: "Kullanıcılar")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildFeed(false), // Sorular
          _buildFeed(true),  // Kullanıcılar
        ],
      ),
    );
  }

  Widget _buildFeed(bool isKullanici) {
    if (isVitrinModu) {
       return _buildVitrinListe(isKullanici);
    }
    
    // Orijinal StreamBuilder yapısı (Firebase hatası vermemesi için vitrin açıkken buraya asla girmez)
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildVitrinListe(bool isKullanici) {
    if (isKullanici) {
      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
           _buildKullaniciTile("Murat Uzman", "@murat_sorbi", "Teknoloji Tutkunu"),
           _buildKullaniciTile("Ayşe Stil", "@ayse_stil", "Moda Yazarı"),
           _buildKullaniciTile("Deniz Kaşif", "@gezgin_deniz", "Dünya Turu"),
        ],
      );
    }
    
    // Örnek Sorular (Vitrin)
    return ListView.builder(
      itemCount: 2,
      itemBuilder: (context, index) => SoruKarti(soru: SoruModel(
        id: "v$index",
        kullaniciId: "m",
        baslik: index == 0 ? "Bursa'da En İyi Kebapçı?" : "SorBi 2.0 Hakkında",
        icerik: "Gezilecek yerler ve lezzet durakları...",
        kategori: "Seyahat",
        tarih: "Dün",
        begeniSayisi: 10,
        yorumSayisi: 4,
        kullaniciAdi: "Deniz Kaşif",
        kullaniciFoto: "https://i.pravatar.cc/150?u=deniz",
        isAnonim: false,
      )),
    );
  }

  Widget _buildKullaniciTile(String isim, String nick, String bio) {
    return ListTile(
      leading: CircleAvatar(radius: 25, backgroundColor: Colors.pinkAccent.withOpacity(0.2), child: Icon(Icons.person, color: Colors.pinkAccent)),
      title: Text(isim, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      subtitle: Text(nick, style: const TextStyle(color: Colors.pinkAccent, fontSize: 12)),
    );
  }
}
