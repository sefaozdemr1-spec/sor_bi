import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/soru_model.dart';
import '../widgets/soru_karti.dart';
import '../main.dart'; // isVitrinModu flag

import '../widgets/paginated_soru_listesi.dart'; // 🏎️ Sayfalama motoru buraya!

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
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isVitrinModu) return _buildVitrinSayfasi(context);

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
        children: [
          // 🏎️ EN YENİLER (Paginated)
          PaginatedSoruListesi(
            baseQuery: FirebaseFirestore.instance.collection('sorular')
              .where('durum', isEqualTo: 'aktif')
              .orderBy('zaman', descending: true),
          ),
          // ⚡ TRENDLER (Paginated)
          PaginatedSoruListesi(
            baseQuery: FirebaseFirestore.instance.collection('sorular')
              .where('durum', isEqualTo: 'aktif')
              .orderBy('trendSkoru', descending: true),
          ),
        ],
      ),
    );
  }

  // 🛡️ VİTRİN MODU (Sadece ilk başta görmüştük, kalsın hatıra!)
  Widget _buildVitrinSayfasi(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("SorBi (Vitrin)")),
      body: const Center(child: Text("Vitrin Mode Active")),
    );
  }
}
