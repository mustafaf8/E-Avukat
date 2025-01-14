import 'package:avukatt/common/color_extension.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math'; // Rastgele sayı ve karakter üretimi için

class LewsuitCaseView extends StatefulWidget {
  const LewsuitCaseView({super.key});

  @override
  State<LewsuitCaseView> createState() => _LewsuitCaseViewState();
}

class _LewsuitCaseViewState extends State<LewsuitCaseView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _konuController = TextEditingController();
  final TextEditingController _icerikController = TextEditingController();
  final TextEditingController _fiyatController = TextEditingController();

  // Rastgele 5 haneli kod üretme fonksiyonu
  String generateUniqueCode() {
    const characters = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final Random random = Random();
    String code = '';

    for (int i = 0; i < 5; i++) {
      code += characters[random.nextInt(characters.length)];
    }

    return code;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        title: Text(
          "Dava Olustur",
          style: TextStyle(
              color: TColor.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                controller: _konuController,
                decoration: const InputDecoration(
                  labelText: 'Davanın Konusu',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen davanın konusunu giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _icerikController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Davanın Basit İçeriği',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen davanın içeriğini giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fiyatController,
                decoration: const InputDecoration(
                  labelText: 'Fiyat Aralığı (₺)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir fiyat aralığı giriniz.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    // Kullanıcı bilgilerini al
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user != null) {
                      // Kullanıcının bilgilerini users koleksiyonundan al
                      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

                      if (userDoc.exists) {
                        // Kullanıcıdan alınan diğer bilgiler
                        String name = userDoc['name'] ?? 'Belirtilmemiş'; // Kullanıcının adı
                        String email = userDoc['email'] ?? 'Belirtilmemiş'; // Kullanıcının e-postası

                        // Rastgele kod oluştur
                        String uniqueCode = generateUniqueCode();

                        // İlan verisini hazırlama
                        final ilan = {
                          'uid': user.uid,
                          'name': name,
                          'email': email,
                          'topic': _konuController.text,
                          'content': _icerikController.text,
                          'price': _fiyatController.text,
                          'code': uniqueCode, // Üretilen kod
                          'PostedOn': FieldValue.serverTimestamp(), // Oluşturulma tarihi
                        };

                        // Firestore'a ilanı kaydet
                        await FirebaseFirestore.instance.collection('ilanlar').add(ilan);

                        // İlanı geri döndürüyoruz
                        Navigator.pop(context, uniqueCode);
                      } else {
                        // Kullanıcı kaydı bulunamazsa
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Kullanıcı bilgileri bulunamadı.')),
                        );
                      }
                    } else {
                      // Kullanıcı girişi yapılmamışsa uyarı
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Kullanıcı girişi yapılmamış.')),
                      );
                    }
                  }
                },
                child: const Text('İlanı Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _konuController.dispose();
    _icerikController.dispose();
    _fiyatController.dispose();
    super.dispose();
  }
}
