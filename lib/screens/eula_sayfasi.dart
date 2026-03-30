import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EulaSayfasi extends StatelessWidget {
  const EulaSayfasi({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: const Text(
          'Kullanıcı Sözleşmesi & Gizlilik',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        centerTitle: false,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık Bölümü
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6A0DAD), Color(0xFFE91E8C)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.deepPurpleAccent.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "SORBİSENDE PLATFORMU",
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white70, letterSpacing: 2),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Kullanıcı Sözleşmesi, Gizlilik Politikası ve Yasal Metinler",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white, height: 1.3),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
                    child: const Text("Son Güncelleme: Mart 2026", style: TextStyle(fontSize: 13, color: Colors.white70)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Hızlı uyarı bant
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                border: Border.all(color: Colors.amber.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Colors.amber.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Platformu kullanan herkes bu sözleşmeyi kabul etmiş sayılır.",
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.amber.shade900),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _kuralMaddesi("1. TARAFLAR VE KONU",
                "İşbu sözleşme, Sorbisende.com internet sitesi ve SorBi mobil uygulamasını işleten Yönetim ile platformu kullanan kullanıcı/üyeler arasında akdedilmiştir. Platformu kullanan herkes bu sözleşmeyi kabul etmiş sayılır."),

            _kuralMaddesi("2. TANIMLAR",
                "• Platform: Sorbisende.com ve SorBi mobil uygulaması\n• Kullanıcı: Üye olmadan erişim sağlayan kişiler\n• Üye: Platforma kayıt olan kişiler\n• İçerik: Yazı, görsel, video ve her türlü veri"),

            _kuralMaddesi("3. ÜYELİK ŞARTLARI",
                "• 18 yaşını doldurmuş olmak zorunludur\n• Doğru ve güncel bilgi verilmelidir\n• Her kullanıcı yalnızca bir hesap oluşturabilir\n• Hesap güvenliği kullanıcı sorumluluğundadır"),

            _kuralMaddesi("4. KULLANIM KURALLARI",
                "Kullanıcılar:\n• Hukuka aykırı içerik paylaşamaz\n• Hakaret, tehdit, taciz içeren içerik üretemez\n• Nefret söylemi ve şiddet içerikleri paylaşamaz\n• Spam ve reklam amaçlı kullanım yapamaz"),

            _kuralMaddesi("5. İÇERİK SORUMLULUĞU",
                "Paylaşılan içeriklerden tamamen kullanıcı sorumludur. Platform içerikleri önceden denetlemek zorunda değildir ancak gerekli gördüğünde kaldırabilir veya erişimi engelleyebilir."),

            _kuralMaddesi("6. HESAP VE ERİŞİM",
                "Yönetim, kurallara aykırı davranışlarda bulunan kullanıcıların hesaplarını askıya alabilir veya kalıcı olarak silebilir."),

            _kuralMaddesi("7. FİKRİ MÜLKİYET",
                "Platforma ait tüm yazılım, tasarım ve içerikler korunmaktadır. İzinsiz kullanılamaz."),

            _kuralMaddesi("8. SORUMLULUK SINIRI",
                "Platform, kullanıcılar arası etkileşimlerden doğabilecek zararlardan sorumlu değildir. Hizmet kesintilerinden dolayı sorumluluk kabul edilmez."),

            _kuralMaddesi("9. GİZLİLİK VE VERİLER",
                "Kullanıcı verileri, yürürlükteki mevzuata uygun olarak işlenir. Toplanan veriler şunlardır:\n• Ad, kullanıcı adı\n• E-posta\n• IP adresi\n• Cihaz bilgileri\n• Kullanım verileri\n\nBu veriler; hizmet sunmak, güvenlik sağlamak, kullanıcı deneyimini geliştirmek ve yasal yükümlülükleri yerine getirmek amaçlarıyla kullanılabilir."),

            _kuralMaddesi("10. VERİ PAYLAŞIMI",
                "Veriler yalnızca:\n• Yasal zorunluluklar kapsamında resmi makamlarla\n• Hizmet sağlayıcılarla\npaylaşılabilir."),

            _kuralMaddesi("11. KULLANICI HAKLARI (KVKK)",
                "Kullanıcılar aşağıdaki haklara sahiptir:\n• Verilerine erişme\n• Düzeltme talep etme\n• Silinmesini isteme\n• İşlenmesine itiraz etme"),

            _kuralMaddesi("12. ÇEREZ POLİTİKASI",
                "Platform, çerezler kullanır. Çerezler;\n• Oturum yönetimi\n• Analiz\n• Performans\namaçlarıyla kullanılır."),

            _kuralMaddesi("13. TOPLULUK KURALLARI",
                "Kullanıcılar:\n• Cinsel içerik paylaşamaz\n• Şiddet içerikleri yayınlayamaz\n• Taciz ve zorbalık yapamaz\n• Yasa dışı faaliyet teşvik edemez\n\nİhlal durumunda içerikler silinir ve hesap kapatılabilir."),

            _kuralMaddesi("14. İÇERİK MODERASYONU",
                "Platform içerikleri otomatik ve manuel olarak denetlenebilir. Şikayet edilen içerikler incelenir ve gerekli aksiyon alınır."),

            _kuralMaddesi("15. HESAP SİLME",
                "Kullanıcılar hesaplarını uygulama içinden silebilir. Yasal zorunluluklar hariç veriler silinir."),

            _kuralMaddesi("16. YAŞ SINIRI",
                "Platform yalnızca 18 yaş ve üzeri kullanıcılar içindir."),

            _kuralMaddesi("17. DEĞİŞİKLİK",
                "Yönetim sözleşmeyi değiştirme hakkını saklı tutar. Değişiklikler platform üzerinden duyurulur."),

            _kuralMaddesi("18. YETKİLİ MAHKEME",
                "İşbu sözleşmeden doğabilecek uyuşmazlıklarda Ankara Mahkemeleri ve İcra Daireleri yetkilidir."),

            _kuralMaddesi("19. YÜRÜRLÜK",
                "Platformu kullanan herkes bu sözleşmeyi okumuş, anlamış ve tüm maddelerini kabul etmiş sayılır."),

            const SizedBox(height: 32),

            // ZORUNLU YASAL LİNKLER (App Store / Google Play)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Yasal Bağlantılar", style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5)),
                  const SizedBox(height: 12),
                  _linkButonu(Icons.privacy_tip_outlined, "Gizlilik Politikası", "https://sorbisende.com/gizlilik", Colors.deepPurpleAccent),
                  const Divider(height: 16),
                  _linkButonu(Icons.description_outlined, "Kullanıcı Sözleşmesi", "https://sorbisende.com/sozlesme", Colors.blueAccent),
                  const Divider(height: 16),
                  _linkButonu(Icons.delete_outline_rounded, "Hesap Silme Talebi", "https://sorbisende.com/hesap-sil", Colors.redAccent),
                ],
              ),
            ),

            const SizedBox(height: 24),
            // Alt Kapat Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurpleAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 4,
                  shadowColor: Colors.deepPurpleAccent.withOpacity(0.4),
                ),
                child: const Text(
                  "Okudum, Kabul Ediyorum ✓",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _kuralMaddesi(String baslik, String icerik) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.grey.shade200, blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            baslik,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.deepPurpleAccent, letterSpacing: 0.3),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          const SizedBox(height: 10),
          Text(
            icerik,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _linkButonu(IconData ikon, String baslik, String url, Color renk) {
    return GestureDetector(
      onTap: () => _urlAc(url),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(color: renk.withOpacity(0.1), shape: BoxShape.circle),
            child: Icon(ikon, color: renk, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(baslik, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: renk)),
          ),
          Icon(Icons.open_in_new_rounded, color: renk.withOpacity(0.6), size: 16),
        ],
      ),
    );
  }

  Future<void> _urlAc(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}
