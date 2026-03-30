import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:google_sign_in/google_sign_in.dart'; // Web ayarları yapılana kadar kapalı.

class AuthServisi {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // GoogleSignIn _googleSignIn = GoogleSignIn(); (Web Client ID olmadan patlar, maskeledik)

  // Çaylakları SorBi evrenine sokan Kayıt Motoru
  Future<User?> epostaIleKayit(String ad, String email, String sifre) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: sifre,
      );
      
      User? user = userCredential.user;
      if (user != null) {
        // Milyarlık Zırh 3: Kayıt Olanın Posta Kutusuna Doğrulama Mektubu Fırlat! ✉️
        await user.sendEmailVerification();

        // Kullanıcının Lüks Profilini (Lakap vs.) Veritabanına (Kullanıcılar kasasına) Kazıyoruz
        await _firestore.collection('kullanicilar').doc(user.uid).set({
          'kullaniciAdi': ad,
          'lakap': '', // Yeni üye çaylaktır ve lakapsız başlar, Modlar verir!
          'kullaniciFoto': 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
          'bannerUrl': '', // Varsayılan: Boş (Gradient gösterilecek)
          'biyografi': 'Merhaba, ben bir SorBi üyesiyim! 👋',
          'email': email,
          'kayitTarihi': FieldValue.serverTimestamp(),
          'gizliHesapMi': false, // APPLE: Yeni eklenen Gizlilik Zırhı!
          'isAdmin': false, // SorBi Yöneticisi mi? (Default: Hayır)
          'puan': 0,
          'takipciSayisi': 0,
          'takipEdilenSayisi': 0,
          'toplamBegeni': 0, // 🆕 Beğeni metriği sıfırdan başlasın
        });
      }
      return user;
    } catch (e) {
      print("SorBi Kayıt Arızası: $e");
      return null; // (Hata yakalama ekranını UI tarafında göstereceğiz)
    }
  }

  // Orijinal üyeleri İçeri Alan Giriş Motoru
  Future<User?> epostaIleGiris(String email, String sifre) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: sifre,
      );
      return userCredential.user;
    } catch (e) {
      print("SorBi Giriş Arızası: $e");
      return null;
    }
  }

  // MİLYARLIK ZIRH 1: Gerçek Google (Gmail) Girişi
  Future<User?> googleIleGiris() async {
    try {
      // Chrome/Web Browser üzerinde en asil ve hızlı Gmail onayı!
      GoogleAuthProvider googleProvider = GoogleAuthProvider();
      
      UserCredential userCredential = await _auth.signInWithPopup(googleProvider);
      User? user = userCredential.user;

      if (user != null) {
        // Eğer bu Gmail kullanıcısı sisteme İLK KEZ geliyorsa, profilini kuruyoruz!
        final doc = await _firestore.collection('kullanicilar').doc(user.uid).get();
        if (!doc.exists) {
          await _firestore.collection('kullanicilar').doc(user.uid).set({
            'kullaniciAdi': user.displayName ?? "Yeni SorBi Üyesi",
            'lakap': 'Gmail Üyesi', 
            'kullaniciFoto': user.photoURL ?? 'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
            'bannerUrl': '',
            'biyografi': 'Merhaba, ben Gmail ile katıldım! 🚀',
            'email': user.email,
            'kayitTarihi': FieldValue.serverTimestamp(),
            'gizliHesapMi': false,
            'isAdmin': false,
            'puan': 5, // Gmail ile gelene +5 hoşgeldin puanı!
            'takipciSayisi': 0,
            'takipEdilenSayisi': 0,
            'toplamBegeni': 0,
          });
        }
      }
      return user;
    } catch (e) {
      print("Google (Gmail) Giriş Arızası: $e");
      return null;
    }
  }

  // MİLYARLIK ZIRH 2: Gerçek Apple Girişi (Sadece iOS Cihazlarda Aktif Olur)
  Future<User?> appleIleGiris() async {
     // sign_in_with_apple paketi iOS cihazda çalışacağı için kodun web'de hata vermemesi adına şimdilik maskeledik.
     print("Apple Sign-In motoru tetiklendi Sefa Abi. Sadece iPhone'da asaletle açılacak.");
     return null;
  }

  // SorBi'den Asaletle Çıkış Kapısı
  Future<void> cikisYap() async {
    await _auth.signOut();
  }

  // MİLYARLIK ZIRH 3: Şifremi Unuttum (Reset Maili Fırlatır)
  Future<bool> sifremiUnuttum(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      print("Şifre Sıfırlama Hatası: $e");
      return false;
    }
  }

  // Aktif (Giriş Yapmış) Kürsü Sahibinin Tüm Detaylarını Çeken Radar
  Future<Map<String, dynamic>?> getCurrentUserProfil() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final doc = await _firestore.collection('kullanicilar').doc(uid).get();
    return doc.data();
  }

  // MİLYARLIK PROFİL GÜNCELLEME: İsim, Bio, Foto her şeyi tekte halleder
  Future<bool> updateUserProfile({
    String? ad,
    String? bio,
    String? fotoUrl,
    String? bannerUrl,
    bool? gizli,
    String? lakap,
  }) async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return false;

      Map<String, dynamic> guncelleme = {};
      if (ad != null) guncelleme['kullaniciAdi'] = ad;
      if (bio != null) guncelleme['biyografi'] = bio;
      if (fotoUrl != null) guncelleme['kullaniciFoto'] = fotoUrl;
      if (bannerUrl != null) guncelleme['bannerUrl'] = bannerUrl;
      if (gizli != null) guncelleme['gizliHesapMi'] = gizli;
      if (lakap != null) guncelleme['lakap'] = lakap;

      if (guncelleme.isNotEmpty) {
        await _firestore.collection('kullanicilar').doc(uid).update(guncelleme);
        // Firebase Auth Name Update (İsim değişirse)
        if (ad != null) {
          await _auth.currentUser?.updateDisplayName(ad);
        }
        // Foto değişirse Firebase Auth Photo Update
        if (fotoUrl != null) {
          await _auth.currentUser?.updatePhotoURL(fotoUrl);
        }
      }
      return true;
    } catch (e) {
      print("Profil Güncelleme Hatası: $e");
      return false;
    }
  }
}
