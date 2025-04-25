import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_collage_widget/utils/collage_type.dart';
import 'package:image_collage_widget/model/images.dart';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class CollageController extends GetxController {
  var text = ''.obs;
  var selectedCollageType = CollageType.hSplit.obs; // Default to horizontal split
  var file1 = Rx<File?>(null);
  var file2 = Rx<File?>(null);
  var file3 = Rx<File?>(null);

  void updateText(String newText) => text.value = newText;
  void selectCollageType(CollageType type) => selectedCollageType.value = type;
  void clear() {
    text.value = '';
    selectedCollageType.value = CollageType.hSplit;
  }

  Future<void> generateData() async {
    file1.value = await getImageFileFromAssets('assets/templates_image.png');
    file2.value = await getImageFileFromAssets('assets/templates_image.png');
    file3.value = await getImageFileFromAssets('assets/templates_image.png');
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await DefaultAssetBundle.of(Get.context!).load(path);
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }
}