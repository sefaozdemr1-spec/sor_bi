import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_servisi.dart';
import '../services/firestore_servisi.dart';

class ProfilDuzenleSayfasi extends StatefulWidget {
  const ProfilDuzenleSayfasi({super.key});

  @override
  State<ProfilDuzenleSayfasi> createState() => _ProfilDuzenleSayfasiState();
}

class _ProfilDuzenleSayfasiState extends State<ProfilDuzenleSayfasi> {
  final TextEditingController _isimController = TextEditingController();
  final TextEditingController _statuController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  bool _gizliHesapMi = false;
  bool _yukleniyor = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _verileriGetir();
  }

  Future<void> _verileriGetir() async {
    final veri = await AuthServisi().getCurrentUserProfil();
    if (veri != null && mounted) {
      setState(() {
        _isimController.text = veri['kullaniciAdi'] ?? "";
        _statuController.text = veri['lakap'] ?? "";
        _bioController.text = veri['biyografi'] ?? "";
        _gizliHesapMi = veri['gizliHesapMi'] ?? false;
        _yukleniyor = false;
      });
    }
  }

  @override
  void dispose() {
    _isimController.dispose();
    _statuController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _profiliKaydet() async {
    setState(() => _yukleniyor = true);
    
    final basarili = await AuthServisi().updateUserProfile(
      ad: _isimController.text.trim(),
      lakap: _statuController.text.trim(),
      bio: _bioController.text.trim(),
      gizli: _gizliHesapMi,
    );

    if (mounted) {
      setState(() => _yukleniyor = false);
      if (basarili) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Profil başarıyla güncellendi! ✅"), backgroundColor: Colors.green));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Güncelleme sırasında bir hata oluştu. ❌"), backgroundColor: Colors.red));
      }
    }
  }

  Future<void> _hesapSilmeOnayi(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Hesabı Sil? 🚨", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Hesabınızı ve tüm verilerinizi kalıcı olarak silmek istediğinize emin misiniz? Bu işlem geri alınamaz."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Vazgeç", style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null) {
                final uid = user.uid;
                // 1. TÜM VERİLERİ SİL (Cascade)
                await FirestoreServisi().kullanicinTumVerileriniSil(uid);
                
                // 2. AUTH HESABINI SİL
                await user.delete();

                if (context.mounted) {
                  Navigator.of(context).pop(); // Dialogu kapat
                  Navigator.of(context).pop(); // Düzenleme sayfasını kapat
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Hesabınız ve tüm verileriniz başarıyla silindi. Elveda!")),
                  );
                }
              }
            },
            child: const Text("Evet, Kalıcı Olarak Sil", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _fotografSec() {
    _fotografYukle(isBanner: false);
  }

  Future<void> _fotografYukle({required bool isBanner}) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    
    if (image != null) {
      setState(() => _yukleniyor = true);
      try {
        final uid = FirebaseAuth.instance.currentUser?.uid;
        if (uid == null) return;

        final storageRef = FirebaseStorage.instance.ref();
        final folder = isBanner ? "banners" : "profiles";
        final imageRef = storageRef.child("$folder/$uid.jpg");

        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          await imageRef.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
        } else {
          await imageRef.putFile(File(image.path));
        }

        final downloadUrl = await imageRef.getDownloadURL();
        
        if (isBanner) {
          await AuthServisi().updateUserProfile(bannerUrl: downloadUrl);
        } else {
          await AuthServisi().updateUserProfile(fotoUrl: downloadUrl);
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isBanner ? "Banner güncellendi! ✨" : "Profil fotoğrafı güncellendi! ✨")));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Yükleme Arızası: $e"), backgroundColor: Colors.red));
        }
      } finally {
        if (mounted) setState(() => _yukleniyor = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_yukleniyor) {
      return const Scaffold(body: Center(child: CircularProgressIndicator(color: Colors.pinkAccent)));
    }

    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Profili Düzenle', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87)),
            backgroundColor: Colors.white,
            centerTitle: false,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.check_rounded, color: Colors.pinkAccent, size: 28),
                onPressed: _profiliKaydet,
              ),
              const SizedBox(width: 8)
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _fotografSec,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: Colors.grey.shade200, width: 2)),
                          child: FutureBuilder<Map<String, dynamic>?>(
                            future: AuthServisi().getCurrentUserProfil(),
                            builder: (context, snapshot) {
                              final url = snapshot.hasData ? snapshot.data!['kullaniciFoto'] : "";
                              return CircleAvatar(
                                radius: 54,
                                backgroundColor: Colors.grey.shade100,
                                backgroundImage: (url != null && url.isNotEmpty) ? NetworkImage(url) : null,
                                child: (url == null || url.isEmpty) ? Icon(Icons.person, size: 60, color: Colors.teal.shade400) : null,
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 4, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(color: Colors.blueAccent.shade700, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 3)),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 20),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _fotografSec,
                  child: const Text("Yeni Profil Fotoğrafı Seç", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 15)),
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Kullanıcı Adı", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _isimController,
                        decoration: _inputDekorasyon("Adınızı Soyadınızı girin"),
                      ),
                      const SizedBox(height: 20),
                      Text("Hakkımda (Bio)", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _bioController,
                        maxLines: 3,
                        decoration: _inputDekorasyon("Kendinizden kısaca bahsedin..."),
                      ),
                      const SizedBox(height: 20),
                      Text("Kurumsal Statü / Rozet", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade500)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _statuController,
                        decoration: _inputDekorasyon("Örn: Yazılımcı, Uzman, Lider"),
                      ),
                      const SizedBox(height: 40),
                      const Divider(),
                      SwitchListTile(
                        activeColor: Colors.deepPurpleAccent,
                        contentPadding: EdgeInsets.zero,
                        title: const Text("Gizli Profil (Kilitli Hesap)", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        subtitle: Text("Açıldığında gönderilerinizi sadece takipçileriniz görebilir.", style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        value: _gizliHesapMi,
                        onChanged: (bool deger) {
                          setState(() {
                            _gizliHesapMi = deger;
                          });
                        },
                      ),
                      const SizedBox(height: 20),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.panorama_rounded, color: Colors.deepPurpleAccent),
                        title: const Text("Banner Fotoğrafını Değiştir", style: TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: const Text("Profilinin arkasındaki o büyük alanı süsle!"),
                        onTap: () => _fotografYukle(isBanner: true),
                      ),
                      const SizedBox(height: 40),
                      const Divider(),
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.delete_forever_rounded, color: Colors.red.shade400, size: 28),
                        title: Text("Hesabımı Kalıcı Olarak Sil", style: TextStyle(color: Colors.red.shade400, fontWeight: FontWeight.bold)),
                        onTap: () => _hesapSilmeOnayi(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_yukleniyor)
          Container(
            color: Colors.black26,
            child: const Center(child: CircularProgressIndicator(color: Colors.pinkAccent)),
          )
      ],
    );
  }

  InputDecoration _inputDekorasyon(String hint) {
    return InputDecoration(
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)
    );
  }
}
