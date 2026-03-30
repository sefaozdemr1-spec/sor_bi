import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_servisi.dart';
import 'eula_sayfasi.dart'; // Milyarlık Hukuk Sözleşmesi

class KayitSayfasi extends StatefulWidget {
  const KayitSayfasi({super.key});

  @override
  State<KayitSayfasi> createState() => _KayitSayfasiState();
}

class _KayitSayfasiState extends State<KayitSayfasi> {
  final _isimSecici = TextEditingController();
  final _emailSecici = TextEditingController();
  final _sifreSecici = TextEditingController();
  final _sifreTekrarSecici = TextEditingController(); // 🆕 Şifre Tekrar
  final AuthServisi _authServisi = AuthServisi();
  bool _isLoading = false;
  bool _sifreGoster = false; // 🆕 Görünürlük
  bool _sifreTekrarGoster = false; // 🆕 Görünürlük
  bool _eulaKabulEdildi = false;
  bool _acikRizaKabulEdildi = false;
  bool _pazarlamaKabulEdildi = false;

  void _sekreterKayit(BuildContext context) async {
    // 1. KURAL: EULA Kabul Edilmediyse Kapıdan Sokma!
    if (!_eulaKabulEdildi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Lütfen Kullanıcı Sözleşmesi'ni (EULA) kabul ediniz."), backgroundColor: Colors.orange),
      );
      return;
    }
    // 2. KURAL: KVKK Açık Rıza Onayı Zorunlu!
    if (!_acikRizaKabulEdildi) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Lütfen KVKK Açık Rıza Metnini kabul ediniz."), backgroundColor: Colors.orange),
      );
      return;
    }
    
    if (_isimSecici.text.isEmpty || _emailSecici.text.isEmpty || _sifreSecici.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lütfen tüm alanları doldurun.")));
      return;
    }
    
    // 3. KURAL: Şifreler Aynı Olmadan Kapı Açılmaz!
    if (_sifreSecici.text != _sifreTekrarSecici.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Girdiğiniz şifreler birbirleriyle uyuşmuyor!"), backgroundColor: Colors.red),
      );
      return;
    }

    if (_sifreSecici.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Şifreniz en az 8 karakter uzunluğunda olmalıdır."), backgroundColor: Colors.orange),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = await _authServisi.epostaIleKayit(_isimSecici.text.trim(), _emailSecici.text.trim(), _sifreSecici.text.trim());
      
      if (mounted) {
        setState(() => _isLoading = false);
        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Kayıt işlemi başarısız oldu. Bilgilerinizi kontrol ediniz."), backgroundColor: Colors.redAccent),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Kayıt Başarılı! ✅ Lütfen e-postanıza giderek hesabınızı doğrulayın."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 4),
            ),
          );
          Navigator.pop(context); 
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        String mesaj = "Kayıt sırasında bir hata oluştu.";
        if (e.code == 'email-already-in-use') mesaj = "Bu e-posta adresi zaten kullanımda.";
        else if (e.code == 'weak-password') mesaj = "Şifre çok zayıf.";
        else if (e.code == 'invalid-email') mesaj = "Geçersiz e-posta adresi.";
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hata: $mesaj"), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  @override
  void dispose() {
    _isimSecici.dispose();
    _emailSecici.dispose();
    _sifreSecici.dispose();
    _sifreTekrarSecici.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.deepPurpleAccent),
      ),
      extendBodyBehindAppBar: true, // Appbar şeffaf olsun, arkadan asil tasarım aksın diye
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Cıvıl Cıvıl Lüks Çatı!
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.pinkAccent.shade400, Colors.deepPurpleAccent.shade400],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(80)), // Tek taraflı janjanlı kavis
              ),
              child: const SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.person_add_alt_1_rounded, size: 70, color: Colors.white),
                    SizedBox(height: 10),
                    Text("Hesap Oluştur", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  ],
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  // K.S Kürsü İsmi
                  TextField(
                    controller: _isimSecici,
                    decoration: InputDecoration(
                      labelText: "Kullanıcı Adı",
                      prefixIcon: const Icon(Icons.badge_outlined, color: Colors.pinkAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Çaylak Maili
                  TextField(
                    controller: _emailSecici,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "E-Posta Adresi",
                      prefixIcon: const Icon(Icons.email_outlined, color: Colors.pinkAccent),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Şifre Üretim Tesisi 1
                  TextField(
                    controller: _sifreSecici,
                    obscureText: !_sifreGoster,
                    decoration: InputDecoration(
                      labelText: "Şifre (En az 8 karakter)",
                      prefixIcon: const Icon(Icons.shield_outlined, color: Colors.pinkAccent),
                      suffixIcon: IconButton(
                        icon: Icon(_sifreGoster ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey),
                        onPressed: () => setState(() => _sifreGoster = !_sifreGoster),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 🆕 KİLİT NOKTASI: Şifre Tekrar
                  TextField(
                    controller: _sifreTekrarSecici,
                    obscureText: !_sifreTekrarGoster,
                    decoration: InputDecoration(
                      labelText: "Şifre Tekrar",
                      prefixIcon: const Icon(Icons.verified_user_outlined, color: Colors.pinkAccent),
                      suffixIcon: IconButton(
                        icon: Icon(_sifreTekrarGoster ? Icons.visibility_off_rounded : Icons.visibility_rounded, color: Colors.grey),
                        onPressed: () => setState(() => _sifreTekrarGoster = !_sifreTekrarGoster),
                      ),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // CHECKBOX 1: KULLANICI SÖZLEŞMESİ (ZORUNLU)
                  _checkboxSatiri(
                    deger: _eulaKabulEdildi,
                    renk: Colors.deepPurpleAccent,
                    onDegisti: (val) => setState(() => _eulaKabulEdildi = val ?? false),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EulaSayfasi())),
                    metin: "Üyelik Sözleşmesi ve Gizlilik Politikası'nı okudum, kabul ediyorum.",
                    link: "Sözleşmeyi Oku",
                    linkRenk: Colors.deepPurpleAccent,
                    zorunlu: true,
                  ),
                  const SizedBox(height: 8),

                  // CHECKBOX 2: KVKK AÇIK RIZA (ZORUNLU)
                  _checkboxSatiri(
                    deger: _acikRizaKabulEdildi,
                    renk: Colors.teal,
                    onDegisti: (val) => setState(() => _acikRizaKabulEdildi = val ?? false),
                    onTap: () => _acikRizaMetniGoster(context),
                    metin: "Kişisel verilerimin işlenmesine yönelik Açık Rıza Metni'ni okudum ve kabul ediyorum.",
                    link: "Metni Oku",
                    linkRenk: Colors.teal,
                    zorunlu: true,
                  ),
                  const SizedBox(height: 8),

                  // CHECKBOX 3: PAZARLAMA (OPSİYONEL)
                  _checkboxSatiri(
                    deger: _pazarlamaKabulEdildi,
                    renk: Colors.orangeAccent,
                    onDegisti: (val) => setState(() => _pazarlamaKabulEdildi = val ?? false),
                    onTap: null,
                    metin: "Kampanya ve bilgilendirme amaçlı ileti almayı kabul ediyorum.",
                    link: "",
                    linkRenk: Colors.orangeAccent,
                    zorunlu: false,
                  ),
                  const SizedBox(height: 20),

                  // Efsane Roket Butonu
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : () => _sekreterKayit(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pinkAccent.shade400,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        elevation: 5,
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white) 
                        : const Text("Kayıt Ol", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    ),
                  ),
                  
                  const SizedBox(height: 30),
                  Row(children: [ Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)), const Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("VEYA ŞUNUNLA KAYIT OL", style: TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.bold))), Expanded(child: Divider(color: Colors.grey.shade300, thickness: 1)) ]),
                  const SizedBox(height: 30),

                  // 4'LÜ VİP SOSYAL KAYIT KAPILARI (Google, Apple, SMS)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildPoshLogoButton(Icons.g_mobiledata_rounded, Colors.redAccent, "Google"),
                      const SizedBox(width: 15),
                      _buildPoshLogoButton(Icons.apple_rounded, Colors.black87, "Apple"),
                      const SizedBox(width: 15),
                      _buildPoshLogoButton(Icons.phone_iphone_rounded, Colors.teal, "SMS"),
                    ],
                  ),
                  const SizedBox(height: 40),
                  
                  // Task 3: Giriş Sayfasına Köprü 🌉
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Zaten bir hesabın var mı?", style: TextStyle(color: Colors.grey)),
                      TextButton(
                        onPressed: () {
                          // GirisSayfasi zaten navigation stack'inde olabilir, 
                          // ama yoksa direkt oraya yönlendiriyoruz.
                          Navigator.pop(context); 
                        },
                        child: const Text("Giriş Yap", style: TextStyle(color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Milyarlık Yeniden Kullanılabilir Checkbox Satırı Fabrikası
  Widget _checkboxSatiri({
    required bool deger,
    required Color renk,
    required Function(bool?) onDegisti,
    required VoidCallback? onTap,
    required String metin,
    required String link,
    required Color linkRenk,
    required bool zorunlu,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: renk.withOpacity(0.04),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: renk.withOpacity(0.15)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Checkbox(
            value: deger,
            activeColor: renk,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            onChanged: onDegisti,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (zorunlu)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: renk, borderRadius: BorderRadius.circular(4)),
                        child: const Text("ZORUNLU", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                      )
                    else
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                        decoration: BoxDecoration(color: Colors.grey.shade400, borderRadius: BorderRadius.circular(4)),
                        child: const Text("OPSİYONEL", style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(metin, style: const TextStyle(fontSize: 12, color: Colors.black54, height: 1.4)),
                if (link.isNotEmpty && onTap != null) ...[
                  const SizedBox(height: 3),
                  GestureDetector(
                    onTap: onTap,
                    child: Text(link, style: TextStyle(fontSize: 12, color: linkRenk, fontWeight: FontWeight.bold, decoration: TextDecoration.underline)),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // KVKK Açık Rıza Metnini Alttan Kayan Lüks Panelde Göster
  void _acikRizaMetniGoster(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 16),
              // Başlık
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF009688), Color(0xFF00796B)], begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.privacy_tip_rounded, color: Colors.white, size: 28),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "KVKK Açık Rıza Metni",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // İçerik
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.teal.shade200)),
                        child: const Text(
                          "6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında, Sorbisende platformu tarafından kişisel verilerimin;",
                          style: TextStyle(fontSize: 14, height: 1.6, fontWeight: FontWeight.w600, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _rizaMaddesi("Hizmetlerin sunulması"),
                      _rizaMaddesi("Üyelik işlemlerinin gerçekleştirilmesi"),
                      _rizaMaddesi("Kullanıcı deneyiminin geliştirilmesi"),
                      _rizaMaddesi("Güvenlik ve analiz faaliyetlerinin yürütülmesi"),
                      _rizaMaddesi("Gerekli durumlarda benimle iletişime geçilmesi"),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
                        child: const Text(
                          "amaçlarıyla işlenmesine,\n\nBu verilerin, gerekli durumlarda hizmet alınan üçüncü taraflarla ve yasal yükümlülükler kapsamında yetkili kamu kurumlarıyla paylaşılmasına,\n\nAçık rıza verdiğimi kabul, beyan ve taahhüt ederim.",
                          style: TextStyle(fontSize: 14, height: 1.7, color: Colors.black87),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() => _acikRizaKabulEdildi = true);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text("Okudum, Açık Rıza Veriyorum ✓", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rizaMaddesi(String metin) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.teal, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(metin, style: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87))),
        ],
      ),
    );
  }

  // Lüks Giriş Logolarını inşa eden gizli fonksiyon (Google Apple)
  Widget _buildPoshLogoButton(IconData asilIkon, Color renk, String tul) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [ BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)) ],
      ),
      child: IconButton(
        icon: Icon(asilIkon, color: renk, size: 35),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        tooltip: tul,
        onPressed: () {
          // Firebase Panelinden Ayar Açılınca Devreye Girecek (Şimdilik Uyarı atıyor)
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$tul ile Kayıt Olma Yakında Etkinleştirilecek!")));
        },
      ),
    );
  }
}
