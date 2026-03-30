import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_servisi.dart';
import '../models/soru_model.dart';
import '../widgets/soru_karti.dart';
import '../core/services/mesaj_servisi.dart';
import '../features/chat/presentation/mesajlasma_sayfasi.dart';
import 'profil_duzenle_sayfasi.dart';

class MisafirProfilSayfasi extends StatefulWidget {
  final String targetUid;
  final String isim;
  final String statu;
  final String avatarUrl;

  const MisafirProfilSayfasi({
    super.key,
    required this.targetUid,
    required this.isim,
    required this.statu,
    required this.avatarUrl,
  });

  @override
  State<MisafirProfilSayfasi> createState() => _MisafirProfilSayfasiState();
}

class _MisafirProfilSayfasiState extends State<MisafirProfilSayfasi> {
  bool _takipEdiliyor = false;
  bool _isLoading = false;
  bool _takipYukleniyor = true;

  @override
  void initState() {
    super.initState();
    _takipDurumunuKontrolEt();
  }

  Future<void> _takipDurumunuKontrolEt() async {
    final durum = await FirestoreServisi().isTakipEdiyorMu(widget.targetUid);
    if (mounted) setState(() { _takipEdiliyor = durum; _takipYukleniyor = false; });
  }

  Future<void> _takipToggle() async {
    setState(() => _takipYukleniyor = true);
    if (_takipEdiliyor) {
      await FirestoreServisi().takibiBirak(widget.targetUid);
    } else {
      await FirestoreServisi().takipEt(widget.targetUid);
    }
    _takipEdiliyor = !_takipEdiliyor;
    if (mounted) setState(() => _takipYukleniyor = false);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('kullanicilar').doc(widget.targetUid).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final veri = snapshot.data!.data() as Map<String, dynamic>;
        final bannerUrl = veri['bannerUrl'] ?? "";
        final fotoUrl = veri['kullaniciFoto'] ?? widget.avatarUrl;
        final lakap = veri['lakap'] ?? widget.statu;
        final biyografi = veri['biyografi'] ?? "";
        final takipci = veri['takipciSayisi'] ?? 0;
        final puan = veri['puan'] ?? 0;
        final gizliMi = veri['gizliHesapMi'] ?? false;

        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: const Color(0xFFF7F8FA),
            body: NestedScrollView(
              headerSliverBuilder: (context, innerBoxIsScrolled) {
                return [
                  SliverToBoxAdapter(
                    child: Column(
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomCenter,
                          children: [
                            // Banner
                            Container(
                              height: 250,
                              decoration: BoxDecoration(
                                color: Colors.blueAccent,
                                image: bannerUrl.isNotEmpty ? DecorationImage(image: NetworkImage(bannerUrl), fit: BoxFit.cover) : null,
                                gradient: bannerUrl.isEmpty
                                    ? LinearGradient(colors: [Colors.blueAccent.shade700, Colors.lightBlueAccent.shade400, Colors.tealAccent.shade400])
                                    : null,
                                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(60), bottomRight: Radius.circular(60)),
                              ),
                            ),
                            // Back Button
                            Positioned(
                              top: 45, left: 10,
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 24),
                                onPressed: () => Navigator.pop(context),
                              ),
                            ),
                            // Avatar
                            Positioned(
                              bottom: -55,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF7F8FA), shape: BoxShape.circle,
                                  boxShadow: [BoxShadow(color: Colors.blueAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 5))],
                                ),
                                child: CircleAvatar(
                                  radius: 54,
                                  backgroundImage: fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                                  child: fotoUrl.isEmpty ? const Icon(Icons.person, size: 60) : null,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 70),
                        Text(widget.isim, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.black87)),
                        const SizedBox(height: 4),
                        if (lakap.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(color: Colors.amber.shade400, borderRadius: BorderRadius.circular(15)),
                            child: Text(lakap, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        const SizedBox(height: 12),
                        // Follow Button (Task 4 Heart)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 50),
                          child: SizedBox(
                            width: double.infinity,
                            child: _takipYukleniyor 
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _takipToggle,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _takipEdiliyor ? Colors.grey.shade300 : Colors.blueAccent.shade700,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                  child: Text(_takipEdiliyor ? "Takibi Bırak" : "Takip Et", 
                                    style: TextStyle(color: _takipEdiliyor ? Colors.black87 : Colors.white, fontWeight: FontWeight.bold)),
                                ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(biyografi, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _mikroStat("Puan", puan.toString()),
                            _dikeyCizgi(),
                            _mikroStat("Takipçi", takipci.toString()),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _takipToggle,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _takipEdiliyor ? Colors.grey.shade200 : Colors.blueAccent,
                                    foregroundColor: _takipEdiliyor ? Colors.black87 : Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: Text(_takipEdiliyor ? "Takibi Bırak" : "Takip Et", style: const TextStyle(fontWeight: FontWeight.bold)),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                                child: IconButton(
                                  onPressed: () async {
                                    final chatId = await MesajServisi().sohbetBaslatV3(widget.targetUid);
                                    if (mounted && chatId.isNotEmpty) {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => MesajlasmaSayfasi(
                                        chatId: chatId,
                                        hedefIsim: widget.isim,
                                        hedefFoto: widget.avatarUrl,
                                        hedefUid: widget.targetUid,
                                      )));
                                    }
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline_rounded, color: Colors.blueAccent),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _SliverAppBarDelegate(
                      TabBar(
                        indicatorColor: Colors.blueAccent,
                        labelColor: Colors.blueAccent.shade700,
                        unselectedLabelColor: Colors.grey.shade500,
                        tabs: const [Tab(text: "ÖZET"), Tab(text: "GÖNDERİLER")],
                      ),
                    ),
                  ),
                ];
              },
              body: gizliMi && !_takipEdiliyor
                  ? _gizliHesapUyarisi()
                  : TabBarView(
                      children: [
                        _ozetSekmesi(puan),
                        _gonderilerSekmesi(),
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _gizliHesapUyarisi() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded, size: 60, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          const Text('Bu Hesap Gizlidir', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          Text('Gönderilerini görmek için takip et.', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _ozetSekmesi(int puan) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _anaStat(Icons.whatshot_rounded, "0", "Beğeni", Colors.pinkAccent),
            // Gönderi Sayısı (Gerçek)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('sorular').where('kullaniciId', isEqualTo: widget.targetUid).snapshots(),
              builder: (context, snapshot) {
                final sayi = snapshot.hasData ? snapshot.data!.docs.length.toString() : "0";
                return _anaStat(Icons.history_edu_rounded, sayi, "Gönderi", Colors.teal);
              },
            ),
            _anaStat(Icons.bolt_rounded, puan.toString(), "Puanı", Colors.deepPurpleAccent),
          ],
        ),
      ],
    );
  }

  Widget _gonderilerSekmesi() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sorular')
          .where('kullaniciId', isEqualTo: widget.targetUid)
          .orderBy('zaman', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) return const Center(child: Text("Henüz soru sormamış."));
        final sorular = snapshot.data!.docs.map((doc) => SoruModel.fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
        return ListView.builder(
          itemCount: sorular.length,
          itemBuilder: (context, index) => SoruKarti(soru: sorular[index]),
        );
      },
    );
  }

  Widget _mikroStat(String baslik, String deger) {
    return Column(
      children: [
        Text(baslik, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 4),
        Text(deger, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  Widget _dikeyCizgi() {
    return Container(height: 24, width: 1, color: Colors.grey.shade300, margin: const EdgeInsets.symmetric(horizontal: 16));
  }

  Widget _anaStat(IconData ikon, String sayi, String altYazi, Color ikonRengi) {
    return Column(
      children: [
        Icon(ikon, color: ikonRengi, size: 36),
        const SizedBox(height: 10),
        Text(sayi, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)),
        const SizedBox(height: 4),
        Text(altYazi, style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
      ],
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);
  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;
  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) { return Container(color: const Color(0xFFF7F8FA), child: _tabBar); }
  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) { return false; }
}
