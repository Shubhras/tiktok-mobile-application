import 'dart:ui';

import 'package:figma_squircle_updated/figma_squircle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shortzz/utilities/asset_res.dart';

class LiveStreamBlurBackgroundImage extends StatelessWidget {
  const LiveStreamBlurBackgroundImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width,
      height: Get.height,
      decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage(AssetRes.icBattleView), fit: BoxFit.cover)),
      child: ClipSmoothRect(
        child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 160, sigmaY: 160),
            child: const SizedBox()),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:shortzz/utilities/color_res.dart';

// class LiveStreamBlurBackgroundImage extends StatelessWidget {
//   final bool useGradient; // 👈 condition flag

//   const LiveStreamBlurBackgroundImage({super.key, this.useGradient = true});

//   @override
//   Widget build(BuildContext context) {

//       // 🔵 Show Gradient Background
//       return Container(
//         height: double.infinity,
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               ColorRes.themeGradient1, // Sky Blue
//               ColorRes.themeGradient2, // Deep Sky Blue
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//       );
//     }

// }
