import 'package:avukatt/common/color_extension.dart';
import 'package:avukatt/common_widget/favorite_color.dart';
import 'package:avukatt/common_widget/ilgileniyorum_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:avukatt/view/lewsuit/lewsuit_case_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  String? generatedCode; // Üretilen kodu saklamak için

  Future<void> _sendNotification(String receiverId, String senderId,
      String ilanTopic, String ilanCode) async {
    await FirebaseFirestore.instance.collection('notifications').add({
      'receiverId': receiverId,
      'senderId': senderId,
      'ilanTopic': ilanTopic,
      'ilanCode': ilanCode,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> _getIlanlarStream() {
    return FirebaseFirestore.instance
        .collection('ilanlar')
        .orderBy('PostedOn', descending: true) // Tarihe göre azalan sırayla
        .snapshots();
  }

  Future<String> _getUserName(String uid) async {
    DocumentSnapshot userDoc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return userDoc['name'] ??
        'Belirtilmemiş'; // Kullanıcı adı yoksa 'Belirtilmemiş' göster
  }

  String _obscureName(String name) {
    List<String> parts = name.split(' ');
    String firstName = parts.isNotEmpty ? parts[0] : '';
    String lastName = parts.length > 1 ? parts[1] : '';

    String obscuredLastName = lastName.length > 2
        ? lastName.substring(0, 2) +
            '*' * (lastName.length - 2) // İlk iki harf açık, geri kalan yıldız
        : lastName; // 2 harf yoksa olduğu gibi bırak

    return '$firstName $obscuredLastName';
  }

  Map<String, bool> _favoriteStatus = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        title: Text(
          "İlanlar",
          style: TextStyle(
              color: TColor.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
        centerTitle: true, // Başlığı ortalamak için
        actions: [
          // Sağ tarafa ikon eklemek için
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Henüz bir bildiriminiz yok.')),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: StreamBuilder<QuerySnapshot>(
          stream: _getIlanlarStream(), // İlanlar için Stream
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // Yükleniyor göstergesi
            }
            if (snapshot.hasError) {
              return Text('Bir hata oluştu: ${snapshot.error}');
            }
            final ilanlar = snapshot.data?.docs;

            if (ilanlar == null || ilanlar.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('Henüz bir ilan oluşturulmadı.'),
              );
            }
            return ListView.builder(
              itemCount: ilanlar.length,
              itemBuilder: (context, index) {
                final ilanDoc = ilanlar[index]; // Firestore belgesi
                final ilan = ilanDoc.data()
                    as Map<String, dynamic>; // İlan verilerini al
                final String ilanId = ilanDoc.id; // Belgenin ID'sini al
                final String uid = ilan['uid'];
                final String topic = ilan['topic'];
                final String code = ilan['code']; // İlan kodunu al

                return FutureBuilder<String>(
                  future: _getUserName(
                      ilan['uid']), // Kullanıcı adını almak için çağır
                  builder: (context, snapshot) {
                    String userName =
                        snapshot.connectionState == ConnectionState.waiting
                            ? 'Yükleniyor...'
                            : snapshot.data ?? 'Belirtilmemiş';

                    String obscuredUserName = _obscureName(userName);
                    bool isFavorited = _favoriteStatus[ilanId] ??
                        false; // İlanın id'sini kullanarak durum kontrolü

                    return Container(
                      width: MediaQuery.of(context).size.width *
                          0.95, // Ekranın %95'i
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          color: TColor.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: const [
                            BoxShadow(
                                color: Color.fromARGB(96, 6, 64, 255),
                                blurRadius: 7)
                          ],
                        ),
                        child: Card(
                          color: TColor.white,
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      obscuredUserName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    FavoriteButton(
                                      isFavorited: isFavorited,
                                      onFavoriteChanged: () {
                                        setState(() {
                                          _favoriteStatus[ilanId] =
                                              !_favoriteStatus[
                                                  ilanId]!; // Favori durumu değiştir
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    text: 'Davanın Konusu: ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: ilan['topic'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    text: 'Davanın İçeriği: ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: ilan['content'],
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                RichText(
                                  text: TextSpan(
                                    text: 'Fiyat Aralığı: ',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black),
                                    children: [
                                      TextSpan(
                                        text: '${ilan['price']} ₺',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    CustomButton(
                                      ilanTopic: topic,
                                      onPressed: () async {
                                        // Mevcut kullanıcı ID'sini al
                                        User? user = FirebaseAuth.instance
                                            .currentUser; // Giriş yapan kullanıcıyı al
                                        String? currentUserId = user
                                            ?.uid; // Kullanıcının UID'sini al
                                           print('İlan sahibi UID: $uid');
                                           print('İlan Konusu: $topic');
                                           print('İlan Kodu: $code');
                                        if (currentUserId != null) {
                                          // Bildirim gönder
                                          await _sendNotification(
                                              uid, currentUserId, topic, code);
                                          // Kullanıcıya bir onay mesajı gösterebilirsin
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Bildirim gönderildi!')),
                                          );
                                        } else {
                                          // Kullanıcı giriş yapmamışsa bir uyarı göster
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Öncelikle giriş yapmalısınız.')),
                                          );
                                        }
                                      },
                                    ),
                                    if (ilan['code'] != null &&
                                        ilan['code']
                                            .isNotEmpty) // Eğer kod mevcutsa göster
                                      Text('Kod: ${ilan['code']}'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: () async {
          // LewsuitCaseView sayfasına git ve üretilen kodu al
          final code = await Navigator.push<String>(
            context,
            MaterialPageRoute(builder: (context) => const LewsuitCaseView()),
          );
          // Geri dönen kodu sakla
          if (code != null) {
            setState(() {
              generatedCode = code; // Kod burada saklanıyor
              //bura
            });
          }
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(60),
          ),
          backgroundColor: const Color.fromARGB(255, 98, 147, 233),
          padding: const EdgeInsets.all(16.0),
        ),
        child: const Icon(
          Icons.add,
          size: 14,
          color: Colors.white,
        ),
      ),
    );
  }
}
//  print('İlan sahibi UID: $uid');
//                                         print('İlan Konusu: $topic');
//                                         print('İlan Kodu: $code');