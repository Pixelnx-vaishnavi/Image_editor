import 'package:get/get.dart';

class StickerModel {
  RxDouble top;
  RxDouble left;
  RxDouble scale;
  RxDouble rotation;
  RxBool isFlipped;
  var path;

  StickerModel({
    required this.top,
    required this.left,
    required this.scale,
    required this.rotation,
    required this.isFlipped,
    required this.path,
  });
}
