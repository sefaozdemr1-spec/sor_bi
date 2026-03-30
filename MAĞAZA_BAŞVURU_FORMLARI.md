# 🍎 APP STORE + 🤖 GOOGLE PLAY — MAĞAZA BAŞVURU FORMLARIM
> **SorBi / Sorbisende Platformu — Hazırlık Dosyası**
> Bu dosyayı Developer hesabı açıldığında kopyala-yapıştır olarak kullan.

---

## 🍎 APPLE APP STORE — APP PRIVACY FORM

### DATA COLLECTION (Toplanan Veriler)

| Veri Türü | Durum |
|-----------|-------|
| Email Address | ✅ Collected |
| User ID | ✅ Collected |
| Device ID | ✅ Collected |
| App Usage / Product Interaction | ✅ Collected |
| Diagnostics / Crash Data | ✅ Collected |

### DATA USAGE PURPOSES (Kullanım Amaçları)
- ✅ App Functionality
- ✅ Analytics
- ✅ Security

### DATA LINKED TO USER
- ✅ **Yes**

### TRACKING
- ❌ **No** *(Reklam SDK kullanılmıyor)*

### PRIVACY POLICY URL
```
https://sorbisende.com/gizlilik
```

---

## 🤖 GOOGLE PLAY — DATA SAFETY FORM

### DATA COLLECTION (Toplanan Veriler)

| Veri Türü | Durum |
|-----------|-------|
| Personal Info — Email Address | ✅ Collected |
| App Activity — App Interactions | ✅ Collected |
| Device or Other IDs | ✅ Collected |

### DATA SHARING
- ✅ **Yes** *(hosting ve servis sağlayıcılar nedeniyle)*

### DATA SECURITY
- ✅ Data is encrypted in transit: **Yes** (Firebase / HTTPS)
- ✅ Users can request data deletion: **Yes**

### DATA USAGE PURPOSES
- ✅ App functionality
- ✅ Analytics
- ✅ Security

### ACCOUNT DELETION URL
```
https://sorbisende.com/hesap-sil
```

---

## ☑️ UYGULAMA İÇİ CHECKBOX METİNLERİ (Uygulamada Kullanılan)

### 1. KULLANICI SÖZLEŞMESİ (ZORUNLU)
> *"Üyelik Sözleşmesi ve Gizlilik Politikası'nı okudum, kabul ediyorum."*

### 2. AÇIK RIZA — KVKK (ZORUNLU)
> *"Kişisel verilerimin işlenmesine yönelik Açık Rıza Metni'ni okudum ve kabul ediyorum."*

### 3. PAZARLAMA (OPSİYONEL)
> *"Kampanya ve bilgilendirme amaçlı ileti almayı kabul ediyorum."*

---

## 🔗 ZORUNLU YASAL LİNKLER

| Sayfa | URL |
|-------|-----|
| Gizlilik Politikası | https://sorbisende.com/gizlilik |
| Kullanıcı Sözleşmesi | https://sorbisende.com/sozlesme |
| Hesap Silme Talebi | https://sorbisende.com/hesap-sil |

---

## 📋 AÇIK RIZA METNİ (KVKK — Tam Metin)

6698 sayılı Kişisel Verilerin Korunması Kanunu kapsamında, Sorbisende platformu tarafından kişisel verilerimin;

- Hizmetlerin sunulması
- Üyelik işlemlerinin gerçekleştirilmesi
- Kullanıcı deneyiminin geliştirilmesi
- Güvenlik ve analiz faaliyetlerinin yürütülmesi
- Gerekli durumlarda benimle iletişime geçilmesi

amaçlarıyla işlenmesine,

Bu verilerin, gerekli durumlarda hizmet alınan üçüncü taraflarla ve yasal yükümlülükler kapsamında yetkili kamu kurumlarıyla paylaşılmasına,

**Açık rıza verdiğimi kabul, beyan ve taahhüt ederim.**

---

## 📝 NOTLAR

- Firebase Authentication ve Cloud Firestore, Google'ın altyapısını kullandığı için "Data Sharing: Yes" işaretlenmeli.
- Apple için "Tracking: No" seçilmeli çünkü uygulama reklam SDK'sı içermiyor.
- Developer hesabı açıldığında önce **App Store Connect → My Apps → App Privacy** bölümüne git.
- Google Play için: **Play Console → Policy → App content → Data safety** bölümüne git.
