import 'package:avukatt/common/color_extension.dart';
import 'package:avukatt/view/realchat_view/realchat_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FindeuserView extends StatefulWidget {
  @override
  _FindeuserViewState createState() => _FindeuserViewState();
}

class _FindeuserViewState extends State<FindeuserView>
    with WidgetsBindingObserver {
  Map<String, dynamic>? userMap;
   Map<String, dynamic>? senderMap;
  bool isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    setStatus("Online");
  }

  Future<String?> getProfileImageUrl(String uid) async {
    try {
      final ref = FirebaseStorage.instance.ref().child('pic/$uid.jpg');
      return await ref.getDownloadURL();
    } catch (e) {
      print("Profile image not found for uid $uid: $e");
      return null; // Resim bulunmazsa null döner
    }
  }

  void setStatus(String status) async {
    await _firestore.collection('users').doc(_auth.currentUser!.uid).update({
      "status": status,
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // online
      setStatus("Online");
    } else {
      // offline
      setStatus("Offline");
    }
  }

  String chatRoomId(String user1, String user2) {
    // Kullanıcı adlarının boş olup olmadığını kontrol et
    if (user1.isEmpty || user2.isEmpty) {
      // Burada uygun bir hata mesajı veya boş bir değer döndürebilirsiniz
      return ""; // Veya bir hata fırlatabilirsiniz
    }

    // Kullanıcı adlarının ilk karakterlerine göre oda kimliği oluştur
    if (user1[0].toLowerCase().codeUnits[0] >
        user2[0].toLowerCase().codeUnits[0]) {
      return "$user1$user2";
    } else {
      return "$user2$user1";
    }
  }

  void addUserToChatList(Map<String, dynamic> userMap) async {
  var currentUser = _auth.currentUser;

  if (currentUser != null && userMap != null) {
    String user1 = currentUser.displayName ?? "No Name";
    String user2 = userMap['name'];

    String roomId = chatRoomId(user1, user2);

    // Oda zaten mevcut mu kontrol et
    var existingChatRoom = await _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('chats')
        .doc(userMap['uid']) // Kullanıcı UID ile kontrol et
        .get();

    if (!existingChatRoom.exists) {
      // Oda yoksa yeni oluştur
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('chats')
          .doc(userMap['uid'])
          .set(userMap);
    }
  }
}


  Stream<List<Map<String, dynamic>>> getChatList() {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    var currentUser = _auth.currentUser;

    if (currentUser != null) {
      return _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('chats')
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList());
    } else {
      return Stream.empty(); // Kullanıcı yoksa boş bir liste döner
    }
  }

  void navigateToChat(Map<String, dynamic> chatUser) {
    if (_auth.currentUser != null && chatUser != null) {
      Map<String, dynamic> currentUserMap = {
        'name': _auth.currentUser!.displayName ?? "No Name",
        'email': _auth.currentUser!.email ?? "No Email",
        'uid': _auth.currentUser!.uid,
        'photoURL': _auth.currentUser!.photoURL ?? "No Photo URL"
      };

      String user1 = currentUserMap['name'];
      String user2 = chatUser['name'];

      String roomId = chatRoomId(user1, user2);

      // Eğer roomId geçerliyse navigasyonu gerçekleştir
      if (roomId.isNotEmpty) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RealchatView(
              chatRoomId: roomId,
              userMap: chatUser, // Kullanıcı bilgilerini geç
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid user names')),
        );
      }
    }
  }

void addSenderToChatList(Map<String, dynamic> senderMap) async {
  var currentUser = _auth.currentUser;

  if (currentUser != null) {
    await _firestore
        .collection('users')
        .doc(senderMap['uid']) // Gönderen kişinin UID'si
        .collection('chats')
        .doc(currentUser.uid) // Alıcı olarak mevcut kullanıcının UID'si
        .set(senderMap); // Gönderen kişinin bilgilerini kaydet
  }
}


void sendMessage(String message, String recipientUid) async {
  var currentUser = _auth.currentUser;

  if (currentUser != null) {
    // Mesajı gönderme işlemi
    await _firestore.collection('messages').add({
      'senderId': currentUser.uid,
      'recipientId': recipientUid,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Gönderen kişinin bilgilerini al
    Map<String, dynamic> senderMap = {
      'uid': currentUser.uid,
      'name': currentUser.displayName ?? "No Name",
      'email': currentUser.email ?? "No Email",
      'photoURL': currentUser.photoURL ?? "No Photo URL"
    };

    // Alıcının listesine ekle
    addUserToChatList(senderMap); // Bu fonksiyonda senderMap kullanılıyor

    // Gönderenin alıcıda kaydını oluştur
    addSenderToChatList(senderMap); // Burada senderMap kullanın
  }
}



  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: TColor.white,
        centerTitle: true,
        elevation: 0,
        leadingWidth: 0,
        title: Text(
          "Sohbet Odasi",
          style: TextStyle(
              color: TColor.black, fontSize: 20, fontWeight: FontWeight.w700),
        ),
      ),
      body: isLoading
          ? Center(
              child: Container(
                height: size.height / 20,
                width: size.height / 20,
                child: CircularProgressIndicator(),
              ),
            )
          : Column(
              children: [
                SizedBox(
                  height: size.height / 30,
                ),
                userMap != null
                    ? ListTile(
                        onTap: () {
                          addUserToChatList(userMap!);
                          navigateToChat(userMap!);
                         addSenderToChatList(userMap!);
 
                          if (_auth.currentUser != null && userMap != null) {
                            Map<String, dynamic> currentUserMap = {
                              'name':
                                  _auth.currentUser!.displayName ?? "No Name",
                              'email': _auth.currentUser!.email ?? "No Email",
                              'uid': _auth.currentUser!.uid,
                              'photoURL':
                                  _auth.currentUser!.photoURL ?? "No Photo URL"
                            };
                            print(
                                "Oturum açan kullanıcı bilgileri (Map): $currentUserMap");
                            // Mevcut kullanıcının adı
                            String user1 = _auth.currentUser!.displayName ?? "";
                            // Diğer kullanıcının adı
                            String user2 = userMap!['name'] ?? "";

                            print("User1: $user1, User2: $user2");
                            print("userMap içeriği: $userMap");

                            String roomId = chatRoomId(user1, user2);

                            // Eğer roomId geçerliyse navigasyonu gerçekleştir
                            if (roomId.isNotEmpty) {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => RealchatView(
                                    chatRoomId: roomId,
                                    userMap:
                                        userMap!, // Kullanıcı bilgilerini geç
                                  ),
                                ),
                              );
                            } else {
                              // Kullanıcı adları geçerli değilse hata mesajı göster
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Invalid user names')),
                              );
                            }
                          }
                        },

                        leading: FutureBuilder<String?>(
                          future: getProfileImageUrl(userMap!['uid']),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting ||
                                !snapshot.hasData) {
                              return const CircleAvatar(
                                backgroundImage: AssetImage(
                                    "lib/assets/img/defaultuserr.png"),
                              );
                            } else {
                              return CircleAvatar(
                                backgroundImage: NetworkImage(snapshot.data!),
                              );
                            }
                          },
                        ),
                        title: Text(
                          userMap!['name'] ?? 'Unknown User', // Default değer
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                            userMap!['email'] ?? 'No Email'), // Default değer
                        trailing: Icon(Icons.chat, color: Colors.black),
                      )
                    : Container(),
                // Sohbet edilen kullanıcıları listelemek için StreamBuilder kullanıyoruz
                Expanded(
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: getChatList(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        var chatUsers = snapshot.data!;
                        return ListView.builder(
                          itemCount: chatUsers.length,
                          itemBuilder: (context, index) {
                            var chatUser = chatUsers[index];
                            return FutureBuilder<String?>(
                              future: getProfileImageUrl(chatUser['uid']),
                              builder: (context, snapshot) {
                                return ListTile(
                                  onTap: () {
                                    navigateToChat(chatUser);
                                  },
                                  leading:
                                      snapshot.hasData && snapshot.data != null
                                          ? CircleAvatar(
                                              backgroundImage:
                                                  NetworkImage(snapshot.data!),
                                            )
                                          : const Icon(Icons.account_box,
                                              color: Colors.black),
                                  title: Text(
                                    chatUser['name'] ?? 'Unknown User',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  trailing: const Icon(Icons.chat,
                                      color: Colors.black),
                                );
                              },
                            );
                          },
                        );
                      } else if (snapshot.hasError) {
                        return const Center(child: Text('Error loading chats'));
                      } else {
                        return const Center(child: CircularProgressIndicator());
                      }
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
