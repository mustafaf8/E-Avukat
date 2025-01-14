// ignore_for_file: use_build_context_synchronously
import 'package:avukatt/common/color_extension.dart';
import 'package:avukatt/common_widget/round_button.dart';
import 'package:avukatt/common_widget/round_textfield.dart';
import 'package:avukatt/main.dart';
import 'package:avukatt/view/login/auth_phone_view.dart';
import 'package:avukatt/view/login/complete_view.dart';
import 'package:avukatt/view/login/login_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _auth = FirebaseAuth.instance;
  final _tName = TextEditingController();
  final _tEmail = TextEditingController();
  final _tPassword = TextEditingController();
  bool isCheck = false;
Future<void> _saveDeviceToken(String userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }
  Future<void> registerUser() async {
    if (_tEmail.text.isEmpty || _tPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    try {
      final newUser = await _auth.createUserWithEmailAndPassword(
        email: _tEmail.text.trim(),
        password: _tPassword.text.trim(),
      );
  
      await FirebaseFirestore.instance
          .collection('users')
          .doc(newUser.user!.uid)
          .set({
        'uid': newUser.user!.uid, 
        'name': _tName.text.trim(),
        'email': _tEmail.text.trim(),
        'status': "Unavalible",
        'createdAt': FieldValue.serverTimestamp(),
      });
      
      await _saveDeviceToken(newUser.user!.uid);
    
      // Kullanıcı kaydı başarılı olduğunda bildirim göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt işlemi başarıyla tamamlandı!'),
          duration: Duration(seconds: 2),
        ),
      );

   

    print("Current user: ${_auth.currentUser}");
                        print("Display name: ${_auth.currentUser?.displayName}");
      print('Navigating to HomeView...');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CompleteView(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      String message;
      switch (e.code) {
        case 'weak-password':
          message = 'Şifre çok zayıf. Lütfen daha güçlü bir şifre seçin.';
          break;
        case 'email-already-in-use':
          message = 'Bu e-posta adresi ile kayıtlı bir kullanıcı mevcut.';
          break;
        case 'invalid-email':
          message = 'Geçersiz e-posta adresi.';
          break;
        default:
          message = 'Kayıt işlemi sırasında bir hata oluştu: ${e.message}';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Diğer hataları yakala
      print('Hata: $e'); // Konsola hata yazdır
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bir hata oluştu. Lütfen tekrar deneyin.'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
  Future<void> updateDisplayName(String displayName) async {
  User? currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    await currentUser.updateProfile(displayName: displayName);
    await currentUser.reload(); // Değişiklikleri kaydetmek için yeniden yükle
    print("Güncellenen displayName: ${currentUser.displayName}");
  }
}

  Future<void> signInWithGoogle() async {
    try {
      // Google ile oturum açma işlemi
      GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      GoogleSignInAuthentication? googleAuth = await googleUser?.authentication;

      AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken, idToken: googleAuth?.idToken);

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Kullanıcı bilgilerini Firestore'a kaydet
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'uid': userCredential.user!.uid, // UID'yi burada doğru şekilde kaydediyoruz 
        'name': userCredential.user?.displayName,
        'email': userCredential.user?.email,
        'status': "Unavalible",
        'createdAt': FieldValue.serverTimestamp(),
      });
       
      // Google ile oturum açtıktan hemen sonra cihaz token'ını kaydet
await _saveDeviceToken(userCredential.user!.uid);

      print(userCredential.user?.displayName);
      prefs.setBool('isLoggedIn', true);
      print("buraya ugrad anlamaya calsiyorum");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const CompleteView(),
        ),
      );
    } catch (e) {
      // Hata durumunda kullanıcıya bilgi ver
      print('Google Sign In Hatası: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google ile oturum açarken bir hata oluştu.'),
          duration: Duration(seconds: 2),
        ),
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
                  "Hesap Oluşturun",
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
                  hitText: "Eposta Adresi",
                  icon: "lib/assets/img/essage.png",
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(
                  height: media.width * 0.03,
                ),
                RoundTextField(
                  controller: _tPassword,
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
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: media.height * 0.01,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () {
                        setState(() {
                          isCheck = !isCheck;
                        });
                      },
                      icon: Icon(
                        isCheck
                            ? Icons.check_box_outlined
                            : Icons.check_box_outline_blank_outlined,
                        color: TColor.gray,
                        size: 20,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0),
                      child: Text(
                        "Kullanım şartları ve gizlilik hakları aydınlatma metni",
                        style: TextStyle(color: TColor.gray, fontSize: 10),
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: media.width * 0.15,
                ),
                RoundButton(
                  title: "Kayıt Ol",
                  onPressed: () {
                    registerUser(); // Kayıt işlemi için fonksiyonu çağırın
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
                    Text(
                      "Veya",
                      style: TextStyle(color: TColor.gray, fontSize: 10),
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

                // Google ile Giriş Yap Butonu
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        signInWithGoogle(); // Google ile oturum açma fonksiyonu
                      },
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Google",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      width: media.width * 0.03,
                    ),

                    // Telefon ile Giriş Yap Butonu
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const AuthPhoneView()),
                        );
                      },
                      child: Container(
                        width: 120,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Telefon",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: media.width * 0.03,
                ),
                TextButton(
                  onPressed: () {
                    print("login sayfas");
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginView()),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Hesabınız var mı? ",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        "Giriş",
                        style: TextStyle(
                          color: TColor.black,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
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
}
