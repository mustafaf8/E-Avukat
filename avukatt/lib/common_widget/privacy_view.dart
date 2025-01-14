import 'package:flutter/material.dart';

class PrivacyView extends StatelessWidget {
  const PrivacyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Gizlilik"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gizlilik Politikası",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Text(
                  "Gizlilik politikamız, sizin ve kişisel bilgilerinizin korunmasına yönelik olarak geliştirilmiştir. Bu politika, internet sitemizi ve mobil uygulamamızı kullanırken hangi bilgilerin toplandığını, bu bilgilerin nasıl kullanıldığını ve hangi koşullarda üçüncü taraflarla paylaşılacağını açıklamaktadır. Bu gizlilik politikasını okuyarak, kişisel bilgilerinizin nasıl işlendiğini ve korunduğunu anlayabilirsiniz.Kişisel bilgileriniz, adınız, e-posta adresiniz, telefon numaranız gibi bilgileri içerebilir. Bu bilgiler, sizinle iletişim kurmak, hizmetlerimizi iyileştirmek ve size daha iyi bir kullanıcı deneyimi sunmak amacıyla kullanılır. Kişisel bilgileriniz asla üçüncü taraflarla paylaşılmayacak veya satılmayacaktır.Sitemizi veya uygulamamızı kullanarak, bu gizlilik politikasını kabul etmiş olursunuz. Politikada yapılan değişikliklerden haberdar olmak için zaman zaman politikayı gözden geçirmenizi öneririz. Gizlilik politikamızla ilgili herhangi bir sorunuz varsa, lütfen bizimle iletişime geçmekten çekinmeyin.",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: PrivacyView(),
  ));
}
