import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/soru_model.dart';
import '../screens/misafir_profil_sayfasi.dart';
import '../services/auth_servisi.dart';
import '../services/firestore_servisi.dart';
import '../services/sikayet_servisi.dart';
import '../main.dart'; // isVitrinModu flag

class SoruKarti extends StatefulWidget {
  final SoruModel soru;

  const SoruKarti({super.key, required this.soru});

  @override
  State<SoruKarti> createState() => _SoruKartiState();
}

class _SoruKartiState extends State<SoruKarti> {
  bool _begeniVerildi = false;
  bool _begeniYukleniyor = true;
  int _begeniSayisi = 0;

  @override
  void initState() {
    super.initState();
    _begeniSayisi = widget.soru.begeniSayisi;
    _begeniDurumunuKontrolEt();
  }

  Future<void> _begeniDurumunuKontrolEt() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || widget.soru.id.isEmpty) {
      if (mounted) setState(() => _begeniYukleniyor = false);
      return;
    }
    final doc = await FirebaseFirestore.instance.collection('sorular').doc(widget.soru.id).collection('begenenler').doc(uid).get();
    if (mounted) setState(() { _begeniVerildi = doc.exists; _begeniYukleniyor = false; });
  }

  Future<void> _begeniToggle() async {
    // 🛡️ VİTRİN MODU: Gerçek veri veritabanına gitmez, sadece animasyon çalışır!
    if (isVitrinModu) {
      setState(() { _begeniVerildi = !_begeniVerildi; _begeniSayisi += _begeniVerildi ? 1 : -1; });
      return; 
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || widget.soru.id.isEmpty) return;
    
    final batch = FirebaseFirestore.instance.batch();
    final soruRef = FirebaseFirestore.instance.collection('sorular').doc(widget.soru.id);
    final begeniRef = soruRef.collection('begenenler').doc(uid);
    final yazarRef = FirebaseFirestore.instance.collection('kullanicilar').doc(widget.soru.kullaniciId);

    setState(() { _begeniVerildi = !_begeniVerildi; _begeniSayisi += _begeniVerildi ? 1 : -1; });
    
    if (_begeniVerildi) {
      batch.set(begeniRef, {'zaman': FieldValue.serverTimestamp()});
      batch.update(soruRef, {'begeniSayisi': FieldValue.increment(1), 'trendSkoru': FieldValue.increment(2)});
      batch.update(yazarRef, {'toplamBegeni': FieldValue.increment(1)});
    } else {
      batch.delete(begeniRef);
      batch.update(soruRef, {'begeniSayisi': FieldValue.increment(-1), 'trendSkoru': FieldValue.increment(-2)});
      batch.update(yazarRef, {'toplamBegeni': FieldValue.increment(-1)});
    }
    await batch.commit();
  }

  @override
  Widget build(BuildContext context) {
    final soru = widget.soru;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 👤 ÜST BİLGİ (Yazar / Anonimlik)
          ListTile(
            onTap: () {
              if (!soru.isAnonim) {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MisafirProfilSayfasi(
                  targetUid: soru.kullaniciId,
                  isim: soru.kullaniciAdi,
                  statu: soru.lakap.isEmpty ? "SorBi Üyesi" : soru.lakap,
                  avatarUrl: soru.kullaniciFoto,
                )));
              }
            },
            leading: CircleAvatar(
              backgroundImage: !soru.isAnonim ? NetworkImage(soru.kullaniciFoto) : null,
              child: soru.isAnonim ? Icon(Icons.privacy_tip_rounded, color: Colors.teal.shade700) : null,
            ),
            title: Text(
              soru.isAnonim ? "Gizli Üye 🕵️‍♂️" : soru.kullaniciAdi,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: soru.isAnonim ? Colors.teal.shade700 : (isDark ? Colors.white : Colors.deepPurple.shade800),
              ),
            ),
            subtitle: Text(soru.tarih, style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
            trailing: IconButton(
              icon: const Icon(Icons.more_horiz, color: Colors.grey),
              onPressed: () => _uyariMekanizmasiniTetikle(context),
            ),
          ),

          // 📢 SORU BAŞLIĞI & İÇERİĞİ
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(soru.baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                const SizedBox(height: 8),
                Text(
                  soru.icerik,
                  style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade700, height: 1.4),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ❤️ ETKİLEŞİM ÇUBUĞU
          _buildEtkilesimCubugu(context),
        ],
      ),
    );
  }

  Widget _buildEtkilesimCubugu(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              // Beğeni
              GestureDetector(
                onTap: _begeniToggle,
                child: AnimatedScale(
                  scale: _begeniVerildi ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    _begeniVerildi ? Icons.favorite : Icons.favorite_border_rounded,
                    color: _begeniVerildi ? Colors.pinkAccent : Colors.grey,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Text("$_begeniSayisi", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(width: 20),
              // Yorum
              Icon(Icons.chat_bubble_outline_rounded, color: Colors.grey, size: 22),
              const SizedBox(width: 6),
              Text("${widget.soru.yorumSayisi}", style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.grey)),
            ],
          ),
          // Kategori Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(widget.soru.kategori, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          ),
        ],
      ),
    );
  }

  void _uyariMekanizmasiniTetikle(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report_problem_rounded, color: Colors.orange),
              title: const Text("Şikayet Et"),
              onTap: () {
                Navigator.pop(ctx);
                _sikayetEt(context, "Kural İhlali");
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_flipped, color: Colors.red),
              title: const Text("Kullanıcıyı Engelle"),
              onTap: () {
                Navigator.pop(ctx);
                _kullaniciEngelle(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _sikayetEt(BuildContext context, String neden) async {
    final basarili = await SikayetServisi().sikayetGonder(
      hedefId: widget.soru.id,
      hedefTip: 'soru',
      sikayetNedeni: neden,
      detay: 'UI Raporu',
    );
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(basarili ? "Şikayet iletildi." : "Hata oluştu.")));
    }
  }

  void _kullaniciEngelle(BuildContext context) async {
    await SikayetServisi().kullaniciEngelle(widget.soru.kullaniciId);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Kullanıcı engellendi.")));
    }
  }
}
