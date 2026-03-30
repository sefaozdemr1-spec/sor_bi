import 'package:flutter/material.dart';
import 'sohbet_sayfasi.dart'; // Milyarlık Gizli Sohbet Sığınağımız

class MesajlarKutusuSayfasi extends StatelessWidget {
  const MesajlarKutusuSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    // Kurumsal Fake DM (Mesaj) Veritabanı
    final List<Map<String, dynamic>> mesajlar = [
      {
        "isim": "Zeynep Ateş",
        "sonMesaj": "Son gönderdiğim tasarıma baktın mı patron?",
        "zaman": "Şimdi",
        "okunmadiMi": true, 
        "aktifMi": true,
        "avatar": "https://cdn-icons-png.flaticon.com/512/4140/4140047.png"
      },
      {
        "isim": "Cem K.",
        "sonMesaj": "Helal olsun vizyon harika cidden 🚀",
        "zaman": "12 dk",
        "okunmadiMi": true, 
        "aktifMi": false,
        "avatar": "https://cdn-icons-png.flaticon.com/512/4140/4140048.png"
      },
      {
        "isim": "Elif Aslan",
        "sonMesaj": "Haha evet oranın manzarası bir efsane!",
        "zaman": "2 saat",
        "okunmadiMi": false, 
        "aktifMi": true,
        "avatar": "https://cdn-icons-png.flaticon.com/512/4140/4140040.png"
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Mesajlar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black87)),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.mode_edit_rounded, color: Colors.blueAccent, size: 28), onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          // DM Arama Çubuğu
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Container(
              height: 45,
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(20)),
              child: const TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search_rounded, color: Colors.grey),
                  hintText: "Mesajlarda ara...",
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12)
                ),
              ),
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              itemCount: mesajlar.length,
              itemBuilder: (context, index) {
                final ds = mesajlar[index];
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CircleAvatar(radius: 28, backgroundColor: Colors.grey.shade200, backgroundImage: NetworkImage(ds["avatar"])),
                      // YİNE PROFİL AKTİF (ONLINE) IŞIĞI BURADA DA VAR!
                      if (ds["aktifMi"])
                        Positioned(
                          bottom: 0, right: -4,
                          child: Container(
                            width: 18, height: 18,
                            decoration: BoxDecoration(color: Colors.greenAccent.shade400, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
                          ),
                        ),
                    ],
                  ),
                  title: Text(ds["isim"], style: TextStyle(fontWeight: ds["okunmadiMi"] ? FontWeight.bold : FontWeight.w600, fontSize: 16)),
                  subtitle: Text(
                    ds["sonMesaj"], 
                    maxLines: 1, 
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: ds["okunmadiMi"] ? Colors.black87 : Colors.grey.shade600, fontWeight: ds["okunmadiMi"] ? FontWeight.bold : FontWeight.normal),
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(ds["zaman"], style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
                      const SizedBox(height: 6),
                      if (ds["okunmadiMi"])
                        Container(width: 10, height: 10, decoration: const BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle)),
                    ],
                  ),
                  onTap: () {
                    // SEFA ABİ ARTIK DİREKT ODANIN İÇİNE ZIMBALIYORUZ
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => SohbetSayfasi(
                        isim: ds["isim"], 
                        avatarUrl: ds["avatar"],
                        aktifMi: ds["aktifMi"],
                      )
                    ));
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
