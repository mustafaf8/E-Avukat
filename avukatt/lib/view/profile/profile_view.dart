// ignore_for_file: use_build_context_synchronously, unused_import
import 'dart:io';
import 'package:avukatt/common/color_extension.dart';
import 'package:avukatt/common_widget/contactus_view.dart';
import 'package:avukatt/common_widget/privacy_view.dart';
import 'package:avukatt/common_widget/setting_row.dart';
import 'package:avukatt/common_widget/title_subtitle_cell.dart';
import 'package:avukatt/view/login/login_view.dart';
import 'package:avukatt/view/profile/information_view.dart';
import 'package:avukatt/view/profile/lawyer_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:animated_toggle_switch/animated_toggle_switch.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late String _userName = ""; // Kullanıcının adını tutacak değişkenler
  File? _profileImage;
  bool positive = false;
  bool _isApproved = false; // Onay durumu

  @override
  void initState() {
    super.initState();
    getUserData();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? imagePath = prefs.getString('profile_image');
    if (imagePath != null) {
      setState(() {
        _profileImage = File(imagePath);
      });
    }
  }

  Future<void> _saveProfileImage(String imagePath) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image', imagePath);
  }

  Future<void> _changeProfilePicture() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    uploadUserProfileImage();
    if (pickedImage != null) {
      setState(() {
        _profileImage =
            File(pickedImage.path); // Seçilen resmi dosya olarak ayarla
      });
      _saveProfileImage(pickedImage.path);
       // Resim yolunu önbelleğe kaydet
    }
  }

  Future<void> getUserData() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        String uid = FirebaseAuth.instance.currentUser!.uid;

        DocumentSnapshot usersSnapshot = await FirebaseFirestore.instance
            .collection('users') // Kullanıcı verileri
            .doc(uid)
            .get();
        DocumentSnapshot lawyerSnapshot = await FirebaseFirestore.instance
            .collection('lawyer') // Avukat verileri
            .doc(uid)
            .get();

        // Verileri SharedPreferences ile kaydet
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String userName = usersSnapshot['name'] ?? "";

        bool isApproved =
            lawyerSnapshot.exists && lawyerSnapshot['accepted'] == 'true';

        await prefs.setString('userName', userName);
        await prefs.setBool('isApproved', isApproved);

        setState(() {
          _userName = userName;
          _isApproved = isApproved; // Onay durumu
        });
      }
    } catch (e) {
      print("Hata: $e");
    }
  }

  Future<void> uploadUserProfileImage() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Kullanıcı ID’sini alın
      final String userId = user.uid;

      // Resim seçin
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        // Firebase Storage referansını oluştur
        final storageRef =
            FirebaseStorage.instance.ref().child('pic/$userId.jpg');

        // Resmi yükle
        await storageRef.putFile(File(pickedFile.path));

        // İndirilebilir URL'yi alın
        final downloadUrl = await storageRef.getDownloadURL();

        print("Resim yükleme başarılı. İndirilebilir URL: $downloadUrl");

        // İndirilebilir URL'yi kullanıcı veritabanınıza kaydedin (opsiyonel)
        // Bunu Firestore veya Realtime Database'de user doc'a kaydedebilirsiniz.
      }
    }
  }

  List accountArr = [
    {
      "image": "lib/assets/img/Profileq.png",
      "name": "Kişisel Bilgiler",
      "tag": "1"
    },
    {"image": "lib/assets/img/Document.png", "name": "Belgeler", "tag": "2"},
    {
      "image": "lib/assets/img/Graph.png",
      "name": "Kabul Edilen Davalar",
      "tag": "3"
    },
    {
      "image": "lib/assets/img/Icon-Message.png",
      "name": "İletişime Geç",
      "tag": "4"
    },
  ];
  List othertArr = [
    {
      "image": "lib/assets/img/Icon-Privacy.png",
      "name": "Gizlilik",
      "tag": "5"
    },
    {"image": "lib/assets/img/Icon-Setting.png", "name": "Ayarlar", "tag": "6"},
    {"image": "lib/assets/img/Swap.png", "name": "Çıkıs Yap", "tag": "7"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        title: Text(
          "Profil",
          style: TextStyle(
              color: TColor.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      backgroundColor: TColor.white,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: _profileImage != null
                        ? Image.file(
                            _profileImage!, // Seçilen resmi doğrudan dosya yolundan yükle
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Image.asset(
                            "lib/assets/img/defaultuserr.png",
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                  ),
                  const SizedBox(
                    width: 15,
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Onaylı etiketi için
                        if (_isApproved)
                          Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Image.asset(
                              'lib/assets/img/verified.png', // PNG dosyasının yolu
                              width: 20, // İstenilen genişlik
                              height: 20, // İstenilen yükseklik
                            ),
                          ),
                        // Kullanıcı adı
                        Text(
                          _userName,
                          style: TextStyle(
                            color: TColor.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: _changeProfilePicture,
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.zero, // Buton içindeki boşlukları kaldır
                      ),
                      child: const Text("Düzenle"),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
              ElevatedButton(
                onPressed: () {
                  // lawyer_View sayfasına yönlendirme
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LawyerView()),
                  );
                },
                child: const Text("Avukat mısınız? formu doldurun"),
              ),

              const SizedBox(
                height: 25,
              ),
              //account kısmı
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(96, 6, 64, 255), blurRadius: 7)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hesap",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 25,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: accountArr.length,
                      itemBuilder: (context, index) {
                        var i0bj = accountArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: i0bj["image"].toString(),
                          title: i0bj["name"].toString(),
                          onPressed: () {
                            String tag = i0bj["tag"].toString();
                            switch (tag) {
                              case "1":
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const InformationView()),
                                );
                                break;
                              case "2":
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PrivacyView()),
                                );
                                break;
                              // case "3":
                              //   Navigator.push(
                              //     context,
                              //     MaterialPageRoute(
                              //         builder: (context) => const WelcomView()),
                              //   );
                              // break;
                              case "4":
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const ContactusView()),
                                );

                                break;
                              default:
                                break;
                            }
                          },
                        );
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),
              //account kısmı
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(96, 6, 64, 255), blurRadius: 7)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "tema",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SizedBox(
                      height: 40,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset("lib/assets/img/Notification.png",
                              height: 19, width: 19, fit: BoxFit.contain),
                          const SizedBox(
                            height: 25,
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              "temalar sıyah/beyaz",
                              style: TextStyle(
                                color: TColor.black,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          //bildirim switch
                          AnimatedToggleSwitch<bool>.dual(
                            current: positive,
                            first: false,
                            second: true,
                            spacing: 0.1,
                            style: const ToggleStyle(
                              borderColor: Colors.transparent,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 3,
                                  offset: Offset(2, 4),
                                ),
                              ],
                            ),
                            borderWidth: 2,
                            height: 25,
                            onChanged: (b) => setState(() => positive = b),
                            styleBuilder: (b) => ToggleStyle(
                                indicatorColor:
                                    b ? TColor.scondaryColor2 : TColor.gray),
                            textBuilder: (value) => value
                                ? const Center(
                                    child: Text(
                                    'Kapa',
                                    style: TextStyle(fontSize: 10),
                                  ))
                                : const Center(
                                    child: Text(
                                    'Aç',
                                    style: TextStyle(fontSize: 10),
                                  )),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 25,
              ),

              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromARGB(96, 6, 64, 255), blurRadius: 7)
                    ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Diğer",
                      style: TextStyle(
                        color: TColor.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: othertArr.length,
                      itemBuilder: (context, index) {
                        var i0bj = othertArr[index] as Map? ?? {};
                        return SettingRow(
                          icon: i0bj["image"].toString(),
                          title: i0bj["name"].toString(),
                          onPressed: () {
                            // onPressed işlevi ile farklı sayfalara yönlendirme yapılacak
                            String tag = i0bj["tag"].toString();
                            switch (tag) {
                              case "5":
                                // İletişime Geç sayfasına yönlendirme
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PrivacyView()),
                                );
                                break;
                              case "6":
                                // Gizlilik sayfasına yönlendirme
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PrivacyView()),
                                );
                                break;
                              case "7":
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text(
                                        'Çıkış Yapmak İstiyor Musunuz?'),
                                    content: const Text(
                                        'Hesabınızdan çıkış yapmak üzeresiniz.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () => Navigator.of(context)
                                            .pop(false), // Hayır
                                        child: const Text('Hayır'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          await FirebaseAuth.instance.signOut();
                                          SharedPreferences prefs =
                                              await SharedPreferences
                                                  .getInstance();
                                          await prefs.setBool(
                                              'isLoggedIn', false);
                                          //  await prefs.clear(); // Tüm SharedPreferences verilerini sil

                                          Navigator.pushAndRemoveUntil(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const LoginView()),
                                            (route) => false,
                                          );
                                        },
                                        child: const Text('Evet'),
                                      ),
                                    ],
                                  ),
                                );
                                break;
                              default:
                                break;
                            }
                          },
                        );
                      },
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
