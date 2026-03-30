import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/soru_model.dart';
import '../widgets/soru_karti.dart';
import '../main.dart'; // isVitrinModu flag

class AnaAkisSayfasi extends StatefulWidget {
  const AnaAkisSayfasi({super.key});

  @override
  State<AnaAkisSayfasi> createState() => _AnaAkisSayfasiState();
}

class _AnaAkisSayfasiState extends State<AnaAkisSayfasi> with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
        title: const Text("SorBi", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, letterSpacing: -1, color: Colors.deepPurpleAccent)),
        elevation: 0,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.deepPurpleAccent,
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.deepPurpleAccent,
          indicatorWeight: 3,
          dividerColor: Colors.transparent,
          tabs: const [Tab(text: "En Yeniler"), Tab(text: "Trendler")],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildFeed(false), _buildFeed(true)],
      ),
    );
  }

  Widget _buildFeed(bool trendMi) {
    // 🛡️ VİTRİN MODU: Gerçek veri yerine örnek veriler gösterilir.
    if (isVitrinModu) {
      return _buildVitrinListe(trendMi);
    }

    Query query = FirebaseFirestore.instance.collection('sorular');
    if (trendMi) {
      query = query.orderBy('trendSkoru', descending: true);
    } else {
      query = query.orderBy('zaman', descending: true);
    }

    return StreamBuilder<QuerySnapshot>(
      stream: query.limit(30).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final sorular = snapshot.data!.docs.map((doc) => SoruModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
        return ListView.builder(itemCount: sorular.length, itemBuilder: (context, index) => SoruKarti(soru: sorular[index]));
      },
    );
  }

  Widget _buildVitrinListe(bool trendMi) {
    final ornekSorular = [
      SoruModel(
        id: "1",
        kullaniciId: "m",
        baslik: "Neden SorBi?",
        icerik: "Geleceğin sosyal medyasını Sefa Bey ile inşa ediyoruz. Sen de katıl! 🚀",
        kategori: "Vizyon",
        tarih: "2 dk önce",
        begeniSayisi: 45,
        yorumSayisi: 12,
        kullaniciAdi: "Murat Uzman",
        kullaniciFoto: "https://i.pravatar.cc/150?u=murat",
        isAnonim: false,
      ),
      SoruModel(
        id: "2",
        kullaniciId: "a",
        baslik: "Karanlık Mod Geldi!",
        icerik: "Mürdüm gece moduna bayıldım! Sizin favori ayarın hangisi? ✨",
        kategori: "Tasarım",
        tarih: "10 dk önce",
        begeniSayisi: 88,
        yorumSayisi: 24,
        kullaniciAdi: "Ayşe Stil",
        kullaniciFoto: "https://i.pravatar.cc/150?u=ayse",
        isAnonim: false,
      ),
      SoruModel(
        id: "3",
        kullaniciId: "d",
        baslik: "Gizli Bir Sorum Var...",
        icerik: "Anonim kalarak dertleşebilmek muazzam bir özgürlük değil mi?",
        kategori: "Hayat",
        tarih: "1 saat önce",
        begeniSayisi: 12,
        yorumSayisi: 5,
        kullaniciAdi: "Gizli Üye 🕵️‍♂️",
        kullaniciFoto: "",
        isAnonim: true,
      ),
    ];

    if (trendMi) ornekSorular.sort((a,b) => b.begeniSayisi.compareTo(a.begeniSayisi));

    return ListView.builder(
      itemCount: ornekSorular.length,
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemBuilder: (context, index) => SoruKarti(soru: ornekSorular[index]),
    );
  }
}
