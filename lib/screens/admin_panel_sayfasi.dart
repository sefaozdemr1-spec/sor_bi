import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/firestore_servisi.dart';
import '../core/utils/seeder.dart';

class AdminPanelSayfasi extends StatelessWidget {
  const AdminPanelSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("SorBi Denetim Merkezi", style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: Colors.black87,
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Colors.pinkAccent,
            tabs: [
              Tab(text: "ŞİKAYETLER"),
              Tab(text: "İTİRAZLAR"),
              Tab(text: "SİSTEM"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _SikayetListesi(),
            _ItirazListesi(),
            _SistemSekmesi(),
          ],
        ),
      ),
    );
  }
}

class _SistemSekmesi extends StatelessWidget {
  const _SistemSekmesi();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.settings_suggest_rounded, size: 80, color: Colors.blueGrey),
          const SizedBox(height: 20),
          const Text("Sistem Araçları", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text("Uygulamayı test etmek için sahte veri yükle.", style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () async {
              showDialog(context: context, builder: (c) => const Center(child: CircularProgressIndicator()));
              await SorBiSeeder.ornekVerileriYukle();
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Örnek veriler başarıyla yüklendi! 🚀")));
              }
            },
            icon: const Icon(Icons.auto_awesome),
            label: const Text("Örnek Verileri Yükle"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
          ),
        ],
      ),
    );
  }
}

class _SikayetListesi extends StatelessWidget {
  const _SikayetListesi();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('sikayetler')
          .where('durum', isEqualTo: 'acik')
          .orderBy('tarih', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final raporlar = snapshot.data!.docs;

        if (raporlar.isEmpty) return const Center(child: Text("Bekleyen şikayet yok. 🛡️"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: raporlar.length,
          itemBuilder: (context, index) {
            final r = raporlar[index];
            final data = r.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text("Neden: ${data['sikayetNedeni']}"),
                subtitle: Text("Detay: ${data['detay']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red), onPressed: () async {
                      await FirebaseFirestore.instance.collection('sorular').doc(data['hedefId']).update({'statu': 'silindi'});
                      await r.reference.update({'durum': 'cozuldu'});
                    }),
                    IconButton(icon: const Icon(Icons.check, color: Colors.green), onPressed: () async {
                      await r.reference.update({'durum': 'reddedildi'});
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ItirazListesi extends StatelessWidget {
  const _ItirazListesi();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('itirazlar')
          .where('durum', isEqualTo: 'beklemede')
          .orderBy('tarih', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final itirazlar = snapshot.data!.docs;

        if (itirazlar.isEmpty) return const Center(child: Text("Bekleyen itiraz yok. ⚖️"));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: itirazlar.length,
          itemBuilder: (context, index) {
            final i = itirazlar[index];
            final data = i.data() as Map<String, dynamic>;
            return Card(
              child: ListTile(
                title: Text("İtiraz Nedeni: ${data['itirazNedeni']}"),
                subtitle: Text("İçerik ID: ${data['hedefId']}"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(icon: const Icon(Icons.restore, color: Colors.blue), onPressed: () async {
                      await FirebaseFirestore.instance.collection('sorular').doc(data['hedefId']).update({'statu': 'aktif'});
                      await i.reference.update({'durum': 'kabul_edildi'});
                    }),
                    IconButton(icon: const Icon(Icons.close, color: Colors.red), onPressed: () async {
                      await i.reference.update({'durum': 'reddedildi'});
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
