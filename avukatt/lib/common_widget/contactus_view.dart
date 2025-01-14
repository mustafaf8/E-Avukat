import 'package:flutter/material.dart';

class ContactusView extends StatelessWidget {
  const ContactusView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("İletişime Geç"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "İletişim Bilgileri",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Telefon Numaraları",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Colors.blue[50],
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "+905347168754",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Colors.blue[50],
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "+905789135692",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "E-mail Adresleri",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Colors.blue[50],
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "mustafanahsan754@gmail.com",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Colors.blue[50],
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "mustafanahsan54@gmail.com",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blueAccent),
                borderRadius: const BorderRadius.all(Radius.circular(5)),
                color: Colors.blue[50],
              ),
              child: const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "kartalkus754@gmail.com",
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
