import 'package:flutter/material.dart';
import 'ana_akis_sayfasi.dart';
import 'profil_sayfasi.dart';
import 'kesfet_sayfasi.dart';
import 'bildirimler_sayfasi.dart';
import 'soru_sor_modal.dart';

class AnaSayfaRoot extends StatefulWidget {
  const AnaSayfaRoot({super.key});

  @override
  State<AnaSayfaRoot> createState() => _AnaSayfaRootState();
}

class _AnaSayfaRootState extends State<AnaSayfaRoot> {
  int _seciliSayfa = 0;

  final List<Widget> _sayfalar = [
    const AnaAkisSayfasi(),
    const KesfetSayfasi(),
    const SizedBox.shrink(),
    const BildirimlerSayfasi(),
    const ProfilSayfasi(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      body: _sayfalar[_seciliSayfa],
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => const SoruSorModal(),
          );
        },
        backgroundColor: Colors.pinkAccent, // Pembe ortadaki lüks cıvıl buton (KızlarSoruyor Merkezi)
        elevation: 6,
        shape: const CircleBorder(),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 36),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Theme(
        data: ThemeData(
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white, // Bembeyaz alt navigasyon paneli !!
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Colors.deepPurpleAccent.shade700, // Mor Tıklanmış Tuş Vurgusu
          unselectedItemColor: Colors.grey.shade400, // Gri elit pasif tuşlar
          showSelectedLabels: false,
          showUnselectedLabels: false,
          elevation: 20, // Pırıl pırıl elit gölge
          currentIndex: _seciliSayfa,
          onTap: (index) {
            if (index == 2) return;
            setState(() {
              _seciliSayfa = index;
            });
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled, size: 30), label: "Akış"),
            BottomNavigationBarItem(icon: Icon(Icons.search_rounded, size: 30), label: "Keşfet"),
            BottomNavigationBarItem(icon: Icon(Icons.add, color: Colors.transparent), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.notifications_rounded, size: 30), label: "Bildirimler"),
            BottomNavigationBarItem(icon: Icon(Icons.person_rounded, size: 30), label: "Profilim"),
          ],
        ),
      ),
    );
  }
}
