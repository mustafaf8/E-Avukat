// ignore_for_file: use_build_context_synchronously, unused_field
import 'package:avukatt/common/color_extension.dart';
import 'package:avukatt/common_widget/round_button.dart';
import 'package:avukatt/common_widget/round_textfield.dart';
import 'package:avukatt/view/main_view/main_tab_view.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore eklenmesi gerekiyor

class CompleteView extends StatefulWidget {
  const CompleteView({super.key});

  @override
  State<CompleteView> createState() => _CompleteViewState();
}

class _CompleteViewState extends State<CompleteView> {
  final _tName = TextEditingController();
  final _tEmail = TextEditingController();
  final _tPhone = TextEditingController(); // Telefon için yeni controller
  // Varsayılan olarak değiştirilebilir
  bool _isEditable = true;

  bool isCheck = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _getUserData(); // Kullanıcı verilerini al
  }

  // Kullanıcı verilerini Firestore'dan alma fonksiyonu
  Future<void> _getUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Firestore'daki `users` koleksiyonunda bu kullanıcıya ait belgeyi al
        DocumentSnapshot doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (doc.exists) {
          // Kullanıcı verilerini kontrol et ve text alanlarını doldur
          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;

          _tName.text = data?['name'] ?? ''; // Ad ve Soyad
          _tEmail.text = data?['email'] ?? ''; // E-posta adresi
          _tPhone.text = data?['phone'] ?? ''; // Telefon
          String status = data?['status'] ?? ''; // Status
           print("Status: $status");

          // Eğer `name` alanı doluysa, Firebase Authentication'daki displayName'i güncelle
          if (_tName.text.isNotEmpty) {
            await user.updateDisplayName(_tName.text);
            // Kullanıcıyı yeniden doğrula ve güncellenmiş bilgileri al
            await user.reload();
            print(
                "Display name Firebase'de güncellendi: ${_auth.currentUser?.displayName}");
          }

          // Telefon alanının dolu olup olmadığını kontrol et
          if (_tPhone.text.isEmpty) {
            print("Telefon numarası boş görünüyor.");
          } else {
            print("Telefon numarası: ${_tPhone.text}");
          }

          // Eğer tüm alanlar doluysa, kullanıcıya bilgi ver ve değişiklik yapmasına izin verme
          if (_tName.text.isNotEmpty &&
              _tEmail.text.isNotEmpty &&
              _tPhone.text.isNotEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tebrikler, artık hazırsınız.')),
            );

            setState(() {
              _isEditable = false;
            });

            // 3 saniye sonra MainTabView'a yönlendir
            await Future.delayed(const Duration(seconds: 2));
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MainTabView()),
            );
          } else {
            print("Eksik bilgiler var.");
            // Eğer eksik alan varsa, kullanıcıya değiştirme izni ver
            setState(() {
              _isEditable = true; // Kullanıcı bilgilerini güncelleyebilir
            });
          }
        }
      }
    } catch (e) {
      // Hata mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: ${e.toString()}')),
      );
    }
  }

  Future<void> _saveUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Firestore'daki `users` koleksiyonunda bu kullanıcıya ait belgeye erişip güncelleme yap
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'uid': user.uid, // Kullanıcının UID'sini ekleyin
          'name': _tName.text, // Ad ve Soyad
          'email': _tEmail.text, // E-posta adresi
          'phone': _tPhone.text, // Telefon
          'status': "Unavailable",
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true)); // Mevcut verilerle birleştir

        // Firebase Auth profilini güncelle
        await user.updateDisplayName(_tName
            .text); // Firestore'daki `name` alanını kullanarak displayName'i güncelle

        // Kullanıcıyı yeniden doğrula
        await user.reload();
        final updatedUser = FirebaseAuth.instance.currentUser;
       
        print("Current user: ${updatedUser}");
        print("Display name: ${updatedUser?.displayName}");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bilgiler başarıyla kaydedildi')),
        );
      } else {
        throw Exception("Kullanıcı kimliği alınamadı.");
      }
    } catch (e) {
      // Hata mesajı
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        reverse: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Bilgileri tamamla",
                  style: TextStyle(
                    color: TColor.black,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                RoundTextField(
                  controller: _tName,
                  hitText: "Adınız ve Soyadınız",
                  icon: "lib/assets/img/Profile.png",
                ),
                SizedBox(
                  height: media.width * 0.03,
                ),
                RoundTextField(
                  controller: _tEmail,
                  hitText: "E-posta Adresi",
                  icon: "lib/assets/img/essage.png",
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: media.width * 0.03,
                ),
                RoundTextField(
                  controller: _tPhone, // Telefon için controller düzeltildi
                  hitText: "Telefon",
                  icon: "lib/assets/img/Profile.png",
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                RoundButton(
                  title: "Kaydet",
                  onPressed: () async {
                    await _saveUserData(); // Verileri kaydet

                    // Kaydetme işlemi tamamlandıktan sonra navigasyon yığınını temizleyip ana sayfaya yönlendir
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (context) =>
                              const MainTabView()), // Yönlendirmek istediğin sayfa
                      (Route<dynamic> route) =>
                          false, // Tüm önceki sayfaları kaldır
                    );
                  },
                  elevation: 0,
                ),
                SizedBox(
                  height: media.width * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
