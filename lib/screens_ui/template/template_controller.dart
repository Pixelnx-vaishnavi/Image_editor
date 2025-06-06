import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:image_editor/Const/routes_const.dart';
import 'package:image_editor/Const/color_const.dart';

class CreateTemplateController extends GetxController {
  final List<String> templates = [
    "assets/template/Template_1.jpg",
    "assets/template/Template_2.png",
    "assets/template/Template_3.png",
    "assets/template/Template_4.png",
    "assets/template/Template_5.png",
    "assets/template/Template_6.png",
  ];

  Widget openTemplatePickerBottomSheet() {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(Get.context!).size.height * 0.7,
        minHeight: 250,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow:  [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      padding:  EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      margin:  EdgeInsets.only(bottom: 20, top: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

           SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
                childAspectRatio: 0.9,
              ),
              itemCount: templates.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    selectTemplate(templates[index]);
                  },
                  child: Container(
                    height: 120,

                    child: ClipRRect(
                      // borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        templates[index],
                        height: 120,
                        width: 180,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> selectTemplate(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/template_${assetPath.split('/').last}';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      Get.back(); // Close the template picker bottom sheet
      Get.toNamed(Consts.ImageEditorScreen, arguments: file);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load template: $e');
    }
  }
}