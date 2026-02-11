import 'package:flutter/material.dart';

/// Home (Main) ekranı için layout sabitleri.
/// AppBar, orta içerik ve bottom bar aynı yatay boşluğu kullanır.
class HomeLayout {
  HomeLayout._();

  /// Ekran sol/sağ kenarından boşluk (AppBar, içerik, bottom bar).
  static const double screenHorizontalPadding = 16;

  /// AppBar ve bottom bar dikey padding.
  static const double screenBarVerticalPadding = 8;

  /// Orta alan (ScrollView) üst/alt padding.
  static const double contentVerticalPadding = 16;

  /// AppBar ve bottom bar için padding.
  static EdgeInsets get barPadding => EdgeInsets.fromLTRB(
        screenHorizontalPadding,
        screenBarVerticalPadding,
        screenHorizontalPadding,
        screenBarVerticalPadding,
      );

  /// Orta içerik (SingleChildScrollView) için padding.
  static EdgeInsets get contentPadding => EdgeInsets.symmetric(
        horizontal: screenHorizontalPadding,
        vertical: contentVerticalPadding,
      );
}
