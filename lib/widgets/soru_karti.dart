import 'package:flutter/material.dart';
import '../models/soru_model.dart';

class SoruKarti extends StatelessWidget {
  final SoruModel soru;

  const SoruKarti({super.key, required this.soru});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white, // Bembeyaz pırıl pırıl kart zeminimiz!
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200, // Hafif lüks ve elit gölge efekti
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Ekstra Lüks: Turkuaz-Mor Yuvarlak Köşeler
              CircleAvatar(
                backgroundColor: soru.isAnonim ? Colors.teal.shade100 : Colors.deepPurple.shade100, 
                backgroundImage: !soru.isAnonim ? NetworkImage(soru.kullaniciFoto) : null,
                child: soru.isAnonim ? Icon(Icons.privacy_tip_rounded, color: Colors.teal.shade700) : null,
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        soru.isAnonim ? "Gizli Üye 🕵️‍♂️" : soru.kullaniciAdi,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: soru.isAnonim ? Colors.teal.shade700 : Colors.deepPurple.shade800,
                        ),
                      ),
                      // Sefa Başkan Onaylı "Altın Çerçeveli İnce İsim Rozeti"
                      if (!soru.isAnonim && soru.lakap.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            border: Border.all(color: Colors.amber.shade600, width: 1),
                            borderRadius: BorderRadius.circular(6), // Kavisli modern K.S köşeleri
                          ),
                          child: Text(
                            soru.lakap,
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    soru.zaman,
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                  ),
                ],
              ),
              const Spacer(),
              Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            soru.baslik,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black87),
          ),
          const SizedBox(height: 6),
          Text(
            soru.detay,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.4),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _etkilesimButonu(Icons.thumb_up_alt_rounded, soru.begeniSayisi.toString(), Colors.pinkAccent), // Tatlı Pembe Beğeniler
              const SizedBox(width: 20),
              _etkilesimButonu(Icons.chat_bubble_outline_rounded, soru.yorumSayisi.toString(), Colors.deepPurpleAccent), // Lüks Mor Yorum
              const Spacer(),
              Icon(Icons.share_rounded, color: Colors.grey.shade400, size: 20),
            ],
          )
        ],
      ),
    );
  }

  Widget _etkilesimButonu(IconData ikon, String sayi, Color renk) {
    return Row(
      children: [
        Icon(ikon, size: 20, color: renk),
        const SizedBox(width: 6),
        Text(sayi, style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600)),
      ],
    );
  }
}
