import 'package:avukatt/common/color_extension.dart';
import 'package:flutter/material.dart';

class TabButton extends StatelessWidget {
  final String icon;
  final String selectIcon;
  final VoidCallback onTab;
  final bool isActive;

  const TabButton({
    super.key,
    required this.icon,
    required this.selectIcon,
    required this.onTab,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent, // Arka planı şeffaf yap
      child: InkWell(
        onTap: onTab,
        highlightColor: Colors.transparent, // Tıklandığında gölge efekti için
        splashColor: Colors.transparent, // Splash efekti için
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              isActive ? selectIcon : icon,
              height: 25,
              fit: BoxFit.fitWidth,
            ),
            SizedBox(
              height: isActive ? 8 : 12,
            ),
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: TColor.scondaryG),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
