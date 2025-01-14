// ignore_for_file: use_build_context_synchronously

import 'package:avukatt/common/color_extension.dart';
import 'package:avukatt/common_widget/round_button.dart';
import 'package:avukatt/common_widget/round_textfield.dart';
import 'package:avukatt/main.dart';
import 'package:avukatt/view/login/signup_view.dart';
import 'package:avukatt/view/main_view/main_tab_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _saveDeviceToken(String userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            height: media.height,
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Tekrar Hoş Geldin",
                  style: TextStyle(
                      color: TColor.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: media.width * 0.05,
                ),
                SizedBox(
                  height: media.width * 0.03,
                ),
                RoundTextField(
                  controller: _emailController,
                  hitText: "Eposta Adresi",
                  icon: "lib/assets/img/essage.png",
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: media.width * 0.03,
                ),
                RoundTextField(
                  controller: _passwordController,
                  hitText: "Şifre",
                  icon: "lib/assets/img/ock.png",
                  obscureText: true,
                  rightIcon: TextButton(
                      onPressed: () {},
                      child: Container(
                          alignment: Alignment.center,
                          width: 20,
                          height: 20,
                          child: Image.asset(
                            "lib/assets/img/ide-Password.png",
                            width: 23,
                            height: 23,
                            fit: BoxFit.contain,
                            color: TColor.gray,
                          ))),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: TextButton(
                        onPressed:
                            _resetPassword, // Şifremi unuttum butonuna tıklanma olayını bağladık
                        child: Text(
                          "Şifremi unuttum",
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: media.height *
                      0.21, // Boşluk ekleyerek butonu aşağıya indiriyoruz
                ),
                RoundButton(
                  title: "Giriş Yap",
                  onPressed: () async {
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .signInWithEmailAndPassword(
                        email: _emailController.text.trim(),
                        password: _passwordController.text.trim(),
                      );

                      if (userCredential.user != null) {
                        await userCredential.user
                            ?.reload(); // Kullanıcıyı yeniden yükle
                        User? currentUser = FirebaseAuth.instance.currentUser;

                       // Cihaz token'ını kaydet
                        await _saveDeviceToken(
                            currentUser!.uid); // Burada token'ı kaydediyoruz
                        prefs.setBool('isLoggedIn', true);

                        print("Current user: ${_auth.currentUser}");
                        print(
                            "Display name: ${_auth.currentUser?.displayName}");

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainTabView(),
                          ),
                        );
                      }
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text("Hata"),
                            content: const Text(
                                "Giriş yapılamadı. Lütfen bilgilerinizi kontrol edin."),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text("Tamam"),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  elevation: 0,
                ),
                SizedBox(
                  height: media.width * 0.03,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: TColor.gray,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        "Coryp",
                        style: TextStyle(color: TColor.gray, fontSize: 10),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: TColor.gray,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: media.width * 0.03,
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const SignUpView()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Hesabın yok mu?",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "Kayıt Ol",
                        style: TextStyle(
                            color: TColor.black,
                            fontSize: 15,
                            fontWeight: FontWeight.w700),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Şifre sıfırlama işlemi
  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    if (email.isEmpty) {
      // E-posta boşsa hata mesajı göster
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Uyarı"),
            content: const Text("Lütfen e-posta adresinizi girin."),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Tamam"),
              ),
            ],
          );
        },
      );
      return;
    }

    try {
      // Firestore'da e-posta kontrolü
      var userSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .get();

      if (userSnapshot.docs.isNotEmpty) {
        // E-posta varsa, şifre sıfırlama maili gönder
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Şifre Sıfırlama"),
              content: const Text(
                  "Şifre sıfırlama bağlantısı e-posta adresinize gönderildi."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Tamam"),
                ),
              ],
            );
          },
        );
      } else {
        // E-posta Firestore'da yoksa hata mesajı
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text("Hata"),
              content: const Text(
                  "Bu e-posta adresiyle kayıtlı bir kullanıcı bulunamadı."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Tamam"),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Genel hata durumu
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Hata"),
            content: Text("Bir hata oluştu: $e"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text("Tamam"),
              ),
            ],
          );
        },
      );
    }
  }
}
