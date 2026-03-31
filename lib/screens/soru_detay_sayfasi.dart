import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/soru_model.dart';
import '../widgets/soru_karti.dart';

class SoruDetaySayfasi extends StatefulWidget {
  final SoruModel soru;
  const SoruDetaySayfasi({super.key, required this.soru});

  @override
  State<SoruDetaySayfasi> createState() => _SoruDetaySayfasiState();
}

class _SoruDetaySayfasiState extends State<SoruDetaySayfasi> {
  final _yorumController = TextEditingController();
  bool _isPosting = false;

  void _yorumYap() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || _yorumController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);
    try {
      final userDoc = await FirebaseFirestore.instance.collection('kullanicilar').doc(uid).get();
      final userData = userDoc.data() ?? {};
      
      final String ad = userData['kullaniciAdi'] ?? FirebaseAuth.instance.currentUser?.displayName ?? "SorBi Üyesi";
      final String foto = userData['kullaniciFoto'] ?? FirebaseAuth.instance.currentUser?.photoURL ?? "";

      await FirebaseFirestore.instance.collection('sorular').doc(widget.soru.id).collection('yorumlar').add({
        'kullaniciId': uid,
        'kullaniciAdi': ad,
        'kullaniciFoto': foto,
        'icerik': _yorumController.text.trim(),
        'zaman': FieldValue.serverTimestamp(),
      });

      // Soru dökümanındaki yorum sayısını artıralım
      await FirebaseFirestore.instance.collection('sorular').doc(widget.soru.id).update({
        'yorumSayisi': FieldValue.increment(1),
      });

      _yorumController.clear();
      if (mounted) FocusScope.of(context).unfocus();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Hata: $e")));
    }
    setState(() => _isPosting = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Soru Detayı", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              slivers: [
                // 💎 SORU KARTININ KENDİSİ (En Tepede)
                SliverToBoxAdapter(
                  child: SoruKarti(soru: widget.soru),
                ),

                // 💬 YORUMLAR BAŞLIĞI
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Text(
                      "Yorumlar", 
                      style: TextStyle(
                        fontSize: 18, 
                        fontWeight: FontWeight.w900, 
                        color: isDark ? Colors.white70 : Colors.black87
                      )
                    ),
                  ),
                ),

                // 📜 YORUM LİSTESİ (Gerçek Zamanlı!)
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('sorular')
                      .doc(widget.soru.id)
                      .collection('yorumlar')
                      .orderBy('zaman', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SliverFillRemaining(child: Center(child: CircularProgressIndicator()));
                    
                    final yorumlar = snapshot.data!.docs;
                    if (yorumlar.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: Text("İlk yorumu sen yaz! 🎤", style: TextStyle(color: Colors.grey))),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final data = yorumlar[index].data() as Map<String, dynamic>;
                          return _buildYorumSatiri(data, isDark);
                        },
                        childCount: yorumlar.length,
                      ),
                    );
                  },
                ),
                // Altta input için boşluk
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),

          // 🎹 YORUM INPUT (Sabit Alt Bar)
          _buildYorumInput(isDark),
        ],
      ),
    );
  }

  Widget _buildYorumSatiri(Map<String, dynamic> data, bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.04) : Colors.black.withOpacity(0.02),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundImage: (data['kullaniciFoto'] != null && data['kullaniciFoto'] != "") 
                ? NetworkImage(data['kullaniciFoto']) 
                : null,
            child: (data['kullaniciFoto'] == null || data['kullaniciFoto'] == "") 
                ? const Icon(Icons.person, size: 20) 
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data['kullaniciAdi'] ?? "Misafir", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.pinkAccent)),
                const SizedBox(height: 4),
                Text(data['icerik'] ?? "", style: TextStyle(fontSize: 14, color: isDark ? Colors.white70 : Colors.black87)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildYorumInput(bool isDark) {
    return Container(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 10, 
        bottom: MediaQuery.of(context).padding.bottom + 10
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16161D) : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                borderRadius: BorderRadius.circular(25),
              ),
              child: TextField(
                controller: _yorumController,
                style: TextStyle(color: isDark ? Colors.white : Colors.black87),
                decoration: const InputDecoration(
                  hintText: "Fikrini belirt kanka...",
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: _isPosting ? null : _yorumYap,
            child: CircleAvatar(
              backgroundColor: Colors.pinkAccent,
              child: _isPosting 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.send_rounded, color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}
