//home profile vs gibi butonların context giris bolumleri
import 'package:avukatt/common/color_extension.dart';
import 'package:avukatt/common/tab_button.dart';
import 'package:avukatt/view/main_view/home_view.dart';
import 'package:avukatt/view/main_view/notifications.dart';
import 'package:avukatt/view/profile/profile_view.dart';
import 'package:avukatt/view/realchat_view/findeuser_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class MainTabView extends StatefulWidget {
  const MainTabView({super.key});

  @override
  State<MainTabView> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainTabView> {
  int selectTab = 0;

  String userId = "";
  final PageStorageBucket pageBucket = PageStorageBucket();
  Widget curentTab = const HomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: TColor.white,
      body: PageStorage(bucket: pageBucket, child: curentTab),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      floatingActionButton: SizedBox(
        width: 50,
        height: 50,
        child: InkWell(
          onTap: () {
            setState(() {
              curentTab = HomeView();
            });
          },
          child: Container(
            margin: const EdgeInsets.only(top: 5), // Butonu aşağıya taşır
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: TColor.primryG),
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.search,
              color: TColor.white,
              size: 30,
            ),
          ),
          //buraya search icon
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue[50],
        height: 61,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            TabButton(
                icon: "lib/assets/img/Message_open.png",
                selectIcon: "lib/assets/img/Message_open (1).png",
                isActive: selectTab == 0,
                onTab: () {
                  selectTab = 0;
                  curentTab = HomeView();
                  if (mounted) {
                    setState(() {});
                  }
                }),
            TabButton(
              icon: "lib/assets/img/Message@2x.png",
              selectIcon: "lib/assets/img/Message@2x (1).png",
              isActive: selectTab == 1,
              onTab: () {
                selectTab = 1;

                // Mevcut kullanıcıyı al
                User? user = FirebaseAuth.instance.currentUser;
                String? currentUserId = user?.uid; // Kullanıcının UID'sini al

                if (currentUserId != null) {
                  // Notifications sayfasını oluştur
                  curentTab = Notifications(currentUserId: currentUserId);
                } else {
                  // Kullanıcı giriş yapmamışsa bir uyarı göster
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Öncelikle giriş yapmalısınız.')),
                  );
                }

                if (mounted) {
                  setState(() {});
                }
              },
            ),
            const SizedBox(
              width: 45,
            ),
            TabButton(
                icon: "lib/assets/img/Chat@2x.png",
                selectIcon: "lib/assets/img/Chat@2x (1).png",
                isActive: selectTab == 2,
                onTab: () {
                  selectTab = 2;
                  curentTab = FindeuserView();
                  if (mounted) {
                    setState(() {});
                  }
                }),
            TabButton(
                icon: "lib/assets/img/User@2x.png",
                selectIcon: "lib/assets/img/User@2x (1).png",
                isActive: selectTab == 3,
                onTab: () {
                  selectTab = 3;
                  curentTab = ProfileView();
                  if (mounted) {
                    setState(() {});
                  }
                }),
          ],
        ),
      ),
    );
  }
}
