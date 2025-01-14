import 'package:avukatt/common/color_extension.dart';
import 'package:avukatt/view/on_bording/on_bording_view.dart';
import 'package:flutter/material.dart';
import '../../common_widget/round_button.dart';

class StartedView extends StatefulWidget {
  const StartedView({super.key});

  @override
  State<StartedView> createState() => _StartedViewState();
}

class _StartedViewState extends State<StartedView> {
  bool isChangeColor = false;
  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: TColor.white,
      body: Container(
          width: media.width,
          decoration: BoxDecoration(
            gradient: isChangeColor
                ? LinearGradient(
                    colors: TColor.primryG,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
               
            Stack(
              alignment: Alignment.center, 
              children: [
                Image.asset(
                  'lib/assets/img/logoe.png', 
                  width: media.width * 0.8,
                  height: media.height * 0.4,
                  fit: BoxFit.contain,
                ),
                
                Positioned(
                  bottom: media.height * 0.09, 
                  child: Text(
                    "Biz sana inanıyoruz",
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),

              const Spacer(),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 25, vertical: 25), //butonun konumu

                  child: RoundButton(
                    title: "Başlayalım",
                    type: isChangeColor
                        ? RoundButtonType.textGradient
                        : RoundButtonType.bgGradient,
                    onPressed: () {
                      
                        print("baslangic sayfasi");
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const OnBordingView()));
                     
                    },
                    elevation: 0,
                  ),
                ),
              ),
              SizedBox(
                height: media.height*0.05,
              ),
            ],
            
          )
          ),
          
    );
  }
}
