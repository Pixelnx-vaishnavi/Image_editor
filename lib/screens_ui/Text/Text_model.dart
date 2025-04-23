import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';

// class EditableTextModel {
//   final RxString text;
//   // final RxDouble top;
//   // final RxDouble left;
//   // final RxDouble scale;
//   // final RxDouble rotation;
//   // final RxDouble opacity;
//   // final RxBool isFlipped;
//   // final Rx<TextAlign> textAlign;
//   // final Rx<FontWeight> fontWeight;
//   // final Rx<Color> color;
//   // final Rx<Color?> shadowColor;
//   // final RxDouble shadowBlurRadius;
//   // final RxDouble shadowOffsetX;
//   // final RxDouble shadowOffsetY;
//   // final RxString fontFamily;
//
//   EditableTextModel({
//     required String text,
//     // required double top,
//     // required double left,
//     // required double scale,
//     // required double rotation,
//     // required double opacity,
//     // required bool isFlipped,
//     // required TextAlign textAlign,
//     // required FontWeight fontWeight,
//     // required Color color,
//     // required Color? shadowColor,
//     // required double shadowBlurRadius,
//     // required double shadowOffsetX,
//     // required double shadowOffsetY,
//     // required String fontFamily,
//   })  : text = text.obs;
//         // top = top.obs,
//         // left = left.obs,
//         // scale = scale.obs,
//         // rotation = rotation.obs,
//         // opacity = opacity.obs,
//         // isFlipped = isFlipped.obs,
//         // textAlign = textAlign.obs,
//         // fontWeight = fontWeight.obs,
//         // color = color.obs,
//         // shadowColor = shadowColor.obs,
//         // shadowBlurRadius = shadowBlurRadius.obs,
//         // shadowOffsetX = shadowOffsetX.obs,
//         // shadowOffsetY = shadowOffsetY.obs,
//         // fontFamily = fontFamily.obs;
// }

class EditableTextModel {
  RxString text;
  RxDouble top;
  RxDouble left;

  EditableTextModel({
    required String text,
    required double top,
    required double left,
  })  : text = text.obs,
        top = top.obs,
        left = left.obs;
}
