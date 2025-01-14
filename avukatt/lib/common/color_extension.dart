import 'package:flutter/material.dart';

class TColor {
  // Aydınlık tema renkleri
  static Color get primryColor1 => const Color(0xff92A3FD);
  static Color get primryColor2 => const Color(0xff9DCEFF);
  static Color get scondaryColor1 => const Color(0xffC58BF2);
  static Color get scondaryColor2 => const Color(0xffEEA4CE);

  // Koyu tema renkleri
  static Color get darkPrimaryColor1 => const Color(0xff1C1C1E);
  static Color get darkPrimaryColor2 => const Color(0xff2C2C2E);
  static Color get darkSecondaryColor1 => const Color(0xff3A3A3C);
  static Color get darkSecondaryColor2 => const Color(0xff48484A);

  static List<Color> get primryG => [primryColor2, primryColor1];
  static List<Color> get scondaryG => [scondaryColor2, scondaryColor1];

  static Color get black => const Color(0xff1D1617);
  static Color get gray => const Color(0xff786F72);
  static Color get white => Colors.white;
  static Color get lightgray => const Color(0xffF7F8F8);
}
