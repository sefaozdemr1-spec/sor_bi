import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/soru_model.dart';
import '../screens/misafir_profil_sayfasi.dart';
import '../screens/soru_detay_sayfasi.dart'; // 🚀 Detay sayfası bağlandı!
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

  bool _isLikeProcessing = false; // 🛡️ RACE CONDITION ÖNLEYİCİ BAYRAK

  Future<void> _begeniToggle() async {
    // ⚔️ AYNI ANDA 2 TIKLAMAYI ENGELLE (Debounce)
    if (_isLikeProcessing) return;
    
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("🧡 Beğenmek için önce giriş yapmalısın!")));
      return;
    }

    setState(() { 
      _isLikeProcessing = true; 
      // 🚀 OPTIMISTIC UI: Kullanıcıyı bekletme, hemen sonucu göster!
      _begeniVerildi = !_begeniVerildi; 
      _begeniSayisi += _begeniVerildi ? 1 : -1; 
    });

    try {
      final soruRef = FirebaseFirestore.instance.collection('sorular').doc(widget.soru.id);
      final begenenRef = soruRef.collection('begenenler').doc(uid);
      final yazarRef = FirebaseFirestore.instance.collection('kullanicilar').doc(widget.soru.kullaniciId);

      // 🔥 ATOMIC WRITE (BATCH): Ya hepsi ya hiçbiri!
      WriteBatch batch = FirebaseFirestore.instance.batch();

      if (_begeniVerildi) {
        batch.set(begenenRef, {'zaman': FieldValue.serverTimestamp()});
        batch.update(soruRef, {
          'begeniSayisi': FieldValue.increment(1),
          'trendSkoru': FieldValue.increment(2),
        });
        if (widget.soru.kullaniciId.isNotEmpty) {
          batch.set(yazarRef, {'toplamBegeni': FieldValue.increment(1)}, SetOptions(merge: true));
        }
      } else {
        batch.delete(begenenRef);
        batch.update(soruRef, {
          'begeniSayisi': FieldValue.increment(-1),
          'trendSkoru': FieldValue.increment(-2),
        });
        if (widget.soru.kullaniciId.isNotEmpty) {
          batch.set(yazarRef, {'toplamBegeni': FieldValue.increment(-1)}, SetOptions(merge: true));
        }
      }

      await batch.commit().timeout(const Duration(seconds: 5));
      
    } catch (e) {
      // 🔄 HATA DURUMUNDA ROLLBACK: Eski haline anında dön!
      if (mounted) {
        setState(() {
          _begeniVerildi = !_begeniVerildi;
          _begeniSayisi += _begeniVerildi ? 1 : -1;
        });
        debugPrint("❌ Like Hatası: $e");
      }
    } finally {
      if (mounted) {
        setState(() => _isLikeProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final soru = widget.soru;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SoruDetaySayfasi(soru: soru))),
      child: AnimatedScale(
        duration: const Duration(milliseconds: 100),
        scale: 1.0, 
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E24) : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 👤 CUSTOM HEADER (Premium Row)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      GestureDetector(
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
                        child: Container(
                          width: 45, height: 45,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.pinkAccent.withOpacity(0.3), width: 2),
                            image: !soru.isAnonim && soru.kullaniciFoto.isNotEmpty
                              ? DecorationImage(image: NetworkImage(soru.kullaniciFoto), fit: BoxFit.cover)
                              : null,
                            color: isDark ? Colors.white10 : Colors.grey.shade100,
                          ),
                          child: (soru.isAnonim || soru.kullaniciFoto.isEmpty)
                            ? Icon(Icons.person_rounded, color: isDark ? Colors.white60 : Colors.grey)
                            : null,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                soru.isAnonim ? "Gizli Üye 🕵️‍♂️" : soru.kullaniciAdi,
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : Colors.black87,
                                  letterSpacing: -0.2,
                                ),
                              ),
                              if (soru.lakap.isNotEmpty && !soru.isAnonim) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(color: Colors.pinkAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
                                  child: Text(soru.lakap, style: const TextStyle(fontSize: 9, color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ],
                          ),
                          Text(soru.tarih, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.more_horiz_rounded, color: isDark ? Colors.white38 : Colors.grey.shade400),
                      onPressed: () => _uyariMekanizmasiniTetikle(context),
                    ),
                  ],
                ),
              ),

              // 📢 CONTENT AREA
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      soru.baslik,
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: isDark ? Colors.white : Colors.black.withOpacity(0.85),
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (soru.icerik.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        soru.icerik,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : Colors.black54,
                          height: 1.5,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ❤️ INTERACTION BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        _interactionItem(
                          icon: _begeniVerildi ? Icons.favorite_rounded : Icons.favorite_outline_rounded,
                          label: "$_begeniSayisi",
                          color: _begeniVerildi ? Colors.pinkAccent : Colors.grey.shade500,
                          onTap: _begeniToggle,
                          isActive: _begeniVerildi,
                        ),
                        const SizedBox(width: 8),
                        _interactionItem(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: "${soru.yorumSayisi}",
                          color: Colors.grey.shade500,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => SoruDetaySayfasi(soru: soru))),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        "#" + soru.kategori,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: isDark ? Colors.white38 : Colors.black38),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    );
  }

  Widget _interactionItem({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w800, fontSize: 13)),
          ],
        ),
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
