import 'package:avukatt/view/main_view/main_tab_view.dart';
import 'package:avukatt/view/on_bording/started_veiw.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'common/color_extension.dart';

late SharedPreferences prefs;

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Bir bildirim arka planda alındı: ${message.messageId}");
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  prefs = await SharedPreferences.getInstance();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E AVUKAT',
      theme:
          ThemeData(primaryColor: TColor.primryColor1, fontFamily: "Poppins"),
      home: Builder(
        builder: (context) {
          if (_checkUserLoggedIn()) {
            return const MainTabView(); // Giriş yapmış kullanıcı için HomeView
          } else {
            return const StartedView(); // Giriş yapmamış kullanıcı için StartedView
          }
        },
      ),
    );
  }

  // Kullanıcının giriş durumunu kontrol eden fonksiyon
  bool _checkUserLoggedIn() {
    return prefs.getBool('isLoggedIn') ?? false;
  }
}
//flutter build apk --split-per-abi