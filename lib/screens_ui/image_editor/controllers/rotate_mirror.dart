import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageEditorController extends GetxController {
  Rx<File> editedImage = File('').obs;
  Rx<Uint8List?> editedImageBytes = Rx<Uint8List?>(null);
  Rx<Uint8List?> flippedImageBytes = Rx<Uint8List?>(null);
  RxBool showEditOptions = false.obs;
  final Rx<Uint8List?> flippedBytes = Rx<Uint8List?>(null);
  final RxBool isFlipping = false.obs;



  void setInitialImage(File image) {
    editedImage.value = image;
    editedImageBytes.value = null;
  }

  Future<void> rotateImage() async {
    final Uint8List input = editedImageBytes.value ?? await editedImage.value.readAsBytes();

    final Uint8List? result = await FlutterImageCompress.compressWithList(
      input,
      rotate: 90,
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      editedImageBytes.value = result;
    }
  }



  Uint8List flipImageBytes(Uint8List input) {
    final img.Image? original = img.decodeImage(input);
    if (original == null) return input;

    final img.Image resized = img.copyResize(original, width: 1080);
    final img.Image flipped = img.flipHorizontal(resized);

    return Uint8List.fromList(img.encodeJpg(flipped, quality: 80));
  }




  Future<void> mirrorImage() async {
    try {
      isFlipping.value = true;

      final Uint8List inputBytes = editedImageBytes.value ?? await editedImage.value.readAsBytes();
      final img.Image? original = img.decodeImage(inputBytes);
      if (original == null) {
        print("Failed to decode image");
        isFlipping.value = false;
        return;
      }

      final img.Image resized = img.copyResize(original, width: 1080);
      final img.Image flipped = img.flipHorizontal(resized);

      final Uint8List result = Uint8List.fromList(img.encodeJpg(flipped, quality: 80));
      flippedBytes.value = result;

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/mirrored_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(path);
      await file.writeAsBytes(result);

      editedImageBytes.value = result;

      print("Mirror applied and saved");
    } catch (e, stackTrace) {
      print("Mirror error: $e");
      print("StackTrace: $stackTrace");
    } finally {
      isFlipping.value = false; // Stop loader
    }
  }






  Widget buildEditControls() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          _buildActionButton(
            "Mirror Photo",
            Colors.cyan,
            Icons.flip,
                () async {
              await mirrorImage();
            },
          ),
          SizedBox(height: 10),
          _buildActionButton(
            "Rotate",
            Colors.deepPurpleAccent,
            Icons.rotate_right,
                () => rotateImage(),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  flippedBytes.value = null;
                  showEditOptions.value = false;
                  editedImageBytes.value = null;
                },
                child: SizedBox(
                  height: 40,
                  child: Image.asset('assets/cross.png'),
                ),
              ),
              Text(
                'Rotate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  showEditOptions.value = false;

                  if (flippedBytes.value != null) {
                    final tempDir = await getTemporaryDirectory();
                    final path = '${tempDir.path}/confirmed_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final file = File(path);
                    await file.writeAsBytes(flippedBytes.value!);

                    editedImage.value = file;
                    editedImageBytes.value = null;
                    // editedImageBytes.value = flippedBytes.value;
                    flippedBytes.value = null;
                  }


                  Get.toNamed('/ImageEditorScreen', arguments: editedImage.value);
                },
                child: SizedBox(
                  height: 40,
                  child: Image.asset('assets/right.png'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }


  Widget buildToolButton(String label, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(height: 22, child: Image.asset(imagePath)),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Outfit')),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(text, style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
