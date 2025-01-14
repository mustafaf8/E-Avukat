//baslangıc ekranı dortlu
import 'package:avukatt/common_widget/on_borading_page.dart';
import 'package:avukatt/view/login/signup_view.dart';
import 'package:flutter/material.dart';

import '../../common/color_extension.dart';

class OnBordingView extends StatefulWidget {
  const OnBordingView({super.key});

  @override
  State<OnBordingView> createState() => OnBordingViewState();
}

class OnBordingViewState extends State<OnBordingView> {
  int selectPage = 0;
  PageController controller = PageController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    controller.addListener(() {
      selectPage = controller.page?.round() ?? 0;

      setState(() {});
    });
  }

  List pageArr = [
    {
      "title": "Biz sana inanıyoruz",
      "subtitle":
          "ATM'den para çektikten sonra kartın bir başkasına ait olduğunu mu fark ettin? İnsanlık hali, hepimiz dalgınız. Hakim, sana inanmayabilir; ben sana inanıyorum.",
      "image": "lib/assets/img/resim1.png",
    },
    {
      "title": "Biz bu işi çözeriz",
      "subtitle":
          "Sokakta yürürken yerde bir makine buldunuz ve bu makinenin silah olduğunu mu öğrendiniz. Bu silahla iki kişinin öldürüldüğünü mü öğrendiniz? Karakoldakiler size inanmayabilir ama ben sana inanıyorum.",
      "image": "lib/assets/img/resim2.png",
    },
    {
      "title": "Belirsizliği ortadan kaldırıyoruz",
      "subtitle":
          "Doğada yürürken bulduğun bibloyu kuyumcu arkadaşına gösterirken 2000 yıllık olduğunu mu fark ettiniz? Nereden bilecektiniz?",
      "image": "lib/assets/img/resim3.png",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: TColor.white,
        body: Stack(
          alignment: Alignment.bottomRight,
          children: [
            PageView.builder(
                controller: controller,
                itemCount: pageArr.length,
                itemBuilder: (context, index) {
                  var p0bj = pageArr[index] as Map? ?? {};
                  return OnBoardingPage(p0bj: p0bj);
                }),
            SizedBox(
              width: 120,
              height: 120,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      color: TColor.primryColor1,
                      value: (selectPage + 1) / 3,
                      strokeWidth: 2,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 15, vertical: 15),
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                        color: TColor.primryColor1,
                        borderRadius: BorderRadius.circular(40)),
                    child: IconButton(
                      icon: Icon(
                        Icons
                            .navigate_next, //burası onbording page sol alt icon içi buyuktur işareti
                        color: TColor.white,
                      ),
                      onPressed: () {
                        if (pageArr.length < 3) {
                          selectPage = selectPage + 1;

                          controller.animateToPage(selectPage,
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.bounceInOut);

                          //controller.jumpToPage(selectPage);

                          setState(() {});
                        } else {
                          // ignore: avoid_print
                          print("signup sayfas");
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const SignUpView()));
                        }
                      },
                    ),
                  ),
                ],
              ),
            )
          ],
        ));
  }
}
