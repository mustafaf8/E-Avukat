// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LawyerView extends StatefulWidget {
  const LawyerView({super.key});

  @override
  State<LawyerView> createState() => _LawyerViewState();
}

class _LawyerViewState extends State<LawyerView> {
  final TextEditingController tcController = TextEditingController();
  final TextEditingController baroController = TextEditingController();
  final TextEditingController birlikController = TextEditingController();
  String? selectedFilePath;
  String? selectedFileName;
  String status = ''; // Durum bilgisini tutacak

  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      _checkUserStatus(userId); // Kullanıcı durumunu kontrol et
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFilePath = result.files.first.path; // Tam dosya yolu
        selectedFileName = result.files.first.name; // Dosya adı
      });
    } else {
      setState(() {
        selectedFilePath = null;
        selectedFileName = null;
      });
    }
  }

  Future<void> _checkUserStatus(String userId) async {
    final userDoc = FirebaseFirestore.instance.collection('lawyer').doc(userId);
    final docSnapshot = await userDoc.get();

    if (docSnapshot.exists) {
      // Durumu kontrol et
      final accepted = docSnapshot.data()?['accepted'];
      print("Firestore'daki accepted durumu: $accepted"); // Durumu kontrol et

      if (accepted == 'true') {
        setState(() {
          status = 'Onaylandı';
        });
      } else if (accepted == 'false') {
        setState(() {
          status = 'Reddedildi';
        });
      } else {
        setState(() {
          status = 'Beklemede';
        });
      }
    } else {
      setState(() {
        status = 'Kayıt Yok'; // Kayıt yoksa beklemede
      });
    }

    print("Durum güncellendi: $status"); // Durum güncellemesini kontrol et
  }

  Future<void> _uploadFile(String filePath) async {
    try {
      // Dosya adını oluştur
      final fileName = filePath.split('/').last;
      final userId = FirebaseAuth.instance.currentUser?.uid; // Kullanıcı ID'si

      if (userId == null) {
        throw Exception("Kullanıcı kimliği alınamadı.");
      }

      // Firebase Storage referansı oluştur
      final storageRef =
          FirebaseStorage.instance.ref().child('lawyerFiles/$userId/$fileName');

      // Dosyayı Firebase Storage'a yükle
      final uploadTask = storageRef.putFile(File(filePath));

      // Yükleme tamamlandığında indirme URL'sini al
      final snapshot = await uploadTask.whenComplete(() => {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Firestore'da kullanıcı kaydı kontrolü
      final userDoc =
          FirebaseFirestore.instance.collection('lawyer').doc(userId);
      final docSnapshot = await userDoc.get();

      // Kullanıcı kaydı varsa güncelle
      if (docSnapshot.exists) {
        await FirebaseFirestore.instance.collection('lawyer').doc(userId).set({
          'tcNo': tcController.text,
          'baroNo': baroController.text,
          'birlikNo': birlikController.text,
          'belgeUrl': downloadUrl, // Belge URL'si burada güncelleniyor
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kayıt güncellendi')),
        );
      } else {
        // Kullanıcı kaydı yoksa oluştur
        await userDoc.set({
          'tcNo': tcController.text,
          'baroNo': baroController.text,
          'birlikNo': birlikController.text,
          'belgeUrl': downloadUrl, // Belge URL'si burada kaydediliyor
          'userId': userId, // Kullanıcı ID'sini burada kaydediyoruz
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yeni kayıt oluşturuldu')),
        );
      }
// prefs.setBool('isLoggedIn', true);
      // Kullanıcı durumunu kontrol et
      await _checkUserStatus(userId);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bir hata oluştu: ${e.toString()}')),
      );
    }
  }

  Future<void> _submitApplication() async {
    if (tcController.text.isEmpty ||
        baroController.text.isEmpty ||
        birlikController.text.isEmpty ||
        selectedFilePath == null) {
      // Eğer zorunlu alanlar boşsa uyarı göster
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Lütfen tüm alanları doldurun ve belge yükleyin')),
      );
      return;
    }

    // Seçilen dosyayı Firebase Storage'a yükle ve URL'sini Firestore'a kaydet
    await _uploadFile(selectedFilePath!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Avukat Başvuru Formu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Durum göstergesi
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _getStatusColor(status), // Duruma göre arka plan rengi
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  status,
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: tcController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'T.C. Kimlik No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: baroController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Baro Sicil No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: birlikController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Birlik Sicil No',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.upload_file),
                    const SizedBox(width: 10),
                    Text(selectedFileName ?? 'Belge yüklemek için dokunun'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _submitApplication,
                child: const Text('Avukatlık Onaylama Başvurusu'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Durum metnine göre arka plan rengi döndür
  Color _getStatusColor(String status) {
    print("Durum rengi kontrol ediliyor: $status"); // Renk kontrolünü yazdır
    switch (status) {
      case 'Onaylandı':
        return Colors.green; // Yeşil renk
      case 'Reddedildi':
        return Colors.red; // Kırmızı renk
      case 'Beklemede':
        return Colors.orange; // Turuncu renk
      case 'Kayıt Yok':
        return Colors.grey; // Gri renk
      default:
        return Colors.blueGrey; // Varsayılan renk
    }
  }
}
