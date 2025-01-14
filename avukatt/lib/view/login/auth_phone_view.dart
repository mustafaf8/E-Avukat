// ignore_for_file: use_build_context_synchronously
import 'package:avukatt/view/login/complete_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:avukatt/main.dart';
import 'package:avukatt/view/main_view/main_tab_view.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthPhoneView extends StatefulWidget {
  const AuthPhoneView({super.key});

  @override
  State<AuthPhoneView> createState() => _AuthPhoneViewState();
}

class _AuthPhoneViewState extends State<AuthPhoneView> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String? _verificationId;

Future<void> _saveDeviceToken(String userId) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();

    if (token != null) {
      FirebaseFirestore.instance.collection('users').doc(userId).update({
        'fcmToken': token,
      });
    }
  }
  Future<void> _verifyPhoneNumber() async {
    await _auth.verifyPhoneNumber(
      phoneNumber: _phoneController.text.trim(),
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        await _checkUserInFirestore();
      },
      verificationFailed: (FirebaseAuthException e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: ${e.message}')),
        );
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }

  Future<void> _signInWithOTP() async {
    if (_verificationId != null) {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _otpController.text.trim(),
      );

      try {
        await _auth.signInWithCredential(credential);
         prefs.setBool('isLoggedIn', true);
         
        // Kullanıcı giriş yaptıktan sonra cihaz token'ını kaydet
      await _saveDeviceToken(_auth.currentUser!.uid);

    print("Current user: ${_auth.currentUser}");
                        print("Display name: ${_auth.currentUser?.displayName}");
        await _checkUserInFirestore();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Doğrulama kodu hatalı.')),
        );
      }
    }
  }

 Future<void> _checkUserInFirestore() async {
  final User? currentUser = _auth.currentUser;
  if (currentUser != null) {
    final DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(currentUser.uid).get();

    if (userDoc.exists) {
      // Kullanıcı Firestore'da kayıtlıysa
      final Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
      
      // Firestore'daki 'name' alanını kullanarak Firebase Auth'daki displayName'i güncelle
      final String? firestoreName = userData['name'];
      if (firestoreName != null && firestoreName.isNotEmpty && 
          (currentUser.displayName == null || currentUser.displayName!.isEmpty)) {
        await currentUser.updateProfile(displayName: firestoreName);
        await currentUser.reload();  // Kullanıcı profilini yeniden yükleyin
      }

      print("Current user: ${_auth.currentUser}");
                        print("Display name: ${_auth.currentUser?.displayName}");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainTabView()),
      );
    } else {
      // Kullanıcı Firestore'da kayıtlı değilse, yeni kullanıcı oluştur
      await _firestore.collection('users').doc(currentUser.uid).set({
        'uid': currentUser.uid,  // UID'yi ekliyoruz
        'phone': currentUser.phoneNumber,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // InformationView'e yönlendir, name ayarlanmayacak
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const CompleteView()),
      );
    }
  }
}


  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        reverse: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: media.height * 0.1),
                const Text(
                  "Telefonla Giriş Yap",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: media.height * 0.05),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: "Telefon Numaranız",
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: media.height * 0.03),
                ElevatedButton(
                  onPressed: _verifyPhoneNumber,
                  child: const Text("Kısa Mesaj ile Kod Al"),
                ),
                SizedBox(height: media.height * 0.05),
                if (_verificationId != null) ...[
                  TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: "Doğrulama Kodu",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: media.height * 0.03),
                  ElevatedButton(
                    onPressed: _signInWithOTP,
                    child: const Text("Kodu Onayla"),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
