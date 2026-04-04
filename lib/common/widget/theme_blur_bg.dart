// import 'package:flutter/material.dart';
// import 'package:shortzz/utilities/asset_res.dart';

// class ThemeBlurBg extends StatelessWidget {
//   const ThemeBlurBg({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Image.asset(
//       AssetRes.icBackground,
//       height: double.infinity,
//       width: double.infinity,
//       fit: BoxFit.cover,
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:shortzz/utilities/asset_res.dart';
import 'package:shortzz/utilities/color_res.dart';

class ThemeBlurBg extends StatelessWidget {
  final bool useGradient; // 👈 condition flag

  const ThemeBlurBg({super.key, this.useGradient = true});

  @override
  Widget build(BuildContext context) {
    if (useGradient) {
      // 🔵 Show Gradient Background
      return Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              ColorRes.themeGradient1, // Sky Blue
              ColorRes.themeGradient2, // Deep Sky Blue
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }

    // 🖼 Show Image Background
    return Image.asset(
      AssetRes.icBackground,
      height: double.infinity,
      width: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
