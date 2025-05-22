import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class StickerModel {
  RxDouble top ;
  RxDouble left;
  RxDouble scale;
  RxDouble rotation;
  RxBool isFlipped;
  var path;
  GlobalKey widgetKey;


  StickerModel({
    required this.top,
    required this.left,
    required this.scale,
    required this.rotation,
    required this.isFlipped,
    required this.path,
    required this.widgetKey
  });
}
