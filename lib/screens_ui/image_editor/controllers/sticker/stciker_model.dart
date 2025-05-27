import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StickerModel {
  final String path;
  final RxDouble top;
  final RxDouble left;
  final RxDouble scale;
  final RxDouble rotation;
  final RxBool isFlipped;
   GlobalKey widgetKey;

  StickerModel({
    required this.path,
    required this.isFlipped,
    required double top,
    required double left,
    double scale = 1.0,
    double rotation = 0.0,
    required this.widgetKey,
  })  : top = top.obs,
        left = left.obs,
        scale = scale.obs,
        rotation = rotation.obs;
}
