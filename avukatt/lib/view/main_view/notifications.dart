import 'package:avukatt/common/color_extension.dart';
import 'package:avukatt/view/realchat_view/findeuser_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Notifications extends StatefulWidget {
  final String currentUserId; // Mevcut kullanıcının ID'si

  const Notifications({super.key, required this.currentUserId});

  @override
  State<Notifications> createState() => _NotificationsState();
}

void addUserToChatList(Map<String, dynamic> userMap) async {
  final currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUser.uid)
        .collection('chats')
        .doc(userMap['uid'])
        .set(userMap);
  }
}

class _NotificationsState extends State<Notifications> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        title: Text(
          "Bildirimler",
          style: TextStyle(
              color: TColor.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('notifications')
            .where('receiverId',
                isEqualTo: widget.currentUserId) // Sadece mevcut kullanıcıya ait bildirimler
            .orderBy('timestamp', descending: true)
            .limit(50) // İlk 50 bildirimi getir
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('Henüz bir bildiriminiz yok.'),
            );
          }
          final notifications = snapshot.data!.docs;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notification = notifications[index];
              final ilanTopic = notification.get('ilanTopic');
              final senderId = notification.get('senderId');

              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(senderId)
                    .get(), // Sender ID ile users koleksiyonundan kullanıcıyı al
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return const ListTile(
                      title: Text('Yükleniyor...'),
                    );
                  }

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                    return const ListTile(
                      title: Text('Kullanıcı bulunamadı.'),
                    );
                  }

                  final userName =
                      userSnapshot.data!.get('name'); // Kullanıcı adını al
                  final userMap = userSnapshot.data!.data() as Map<String, dynamic>;

                  return Card(
                    margin:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.notifications,
                          size: 40, color: Colors.blue),
                      title: Text(
                          '$ilanTopic başlıklı ilanınızla ilgileniliyor',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('İlgilenen Avukat : $userName'),
                      trailing: TextButton(
                        onPressed: () async {
                          // Kullanıcıyı sohbet listesine ekle
                          addUserToChatList(userMap);

                         
                          navigateToChat(userMap);
                        },
                        child: const Text('Sohbete Geç',
                            style: TextStyle(color: Colors.blue)),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  void navigateToChat(Map<String, dynamic> userMap) {
    // Sohbet ekranına yönlendir
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(userMap: userMap),
      ),
    );
  }
}

// Bu ChatScreen, kullanıcıların sohbete geçtiği ekranı temsil ediyor
class ChatScreen extends StatelessWidget {
  final Map<String, dynamic> userMap;

  const ChatScreen({super.key, required this.userMap});

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${userMap['name']}'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: Text(
              '${userMap['name']} ile sohbet odası oluşturuldu, sohbet odasına gidebilirsiniz.',
              textAlign: TextAlign.center, // Metni ortalar
              style: TextStyle(fontSize: 18), // Yazı boyutu
            ),
          ),
          const SizedBox(height: 20), // Buton ile metin arasındaki boşluk
          ElevatedButton(
            onPressed: () {
              // FindeuserView sayfasına yönlendirme işlemi
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FindeuserView(), // FindeuserView'e yönlendirme
                ),
              );
            },
            child: Text('Sohbete Git'),
          ),
        ],
      ),
    );
  }
}
