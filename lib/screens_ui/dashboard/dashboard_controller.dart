import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/Const/routes_const.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:image_editor/screens_ui/Collage/collage_controller.dart';

class BottomSheetController extends GetxController {
  final ImagePicker pickerGallery = ImagePicker();
  final ImagePicker pickerCamera = ImagePicker();
  final CollageController collageController = Get.put(CollageController());
  final TemplateController collageTemplateController = Get.put(TemplateController());


  // List of available whiteboard types
  final List<Map<String, String>> whiteboardTypes = [
    {'size': '1920*1080', 'path': 'assets/whiteboards/Rectangle 1 (23).png', 'name': 'Video Thumbnail'},
    {'size': '1920*250', 'path': 'assets/whiteboards/Rectangle 1 (22).png', 'name': 'Video Thumbnail(SQUARE)'},
    {'size': '300*600', 'path': 'assets/whiteboards/Rectangle 1 (21).png', 'name': 'Facebook Post'},
    {'size': '250*250', 'path': 'assets/whiteboards/Rectangle 1 (20).png', 'name': 'Facebook SQUARE'},
    {'size': '728*90', 'path': 'assets/whiteboards/Rectangle 1 (19).png', 'name': 'Instagram Post'},
    {'size': '336*280', 'path': 'assets/whiteboards/Rectangle 1 (18).png', 'name': 'Pinterest Pins'},
    {'size': '300*250', 'path': 'assets/whiteboards/Rectangle 1 (17).png', 'name': 'Twitter Post'},
    {'size': '590*295', 'path': 'assets/whiteboards/Rectangle 1 (16).png', 'name': 'Google+Post'},
    {'size': '800*200', 'path': 'assets/whiteboards/Rectangle 1 (15).png', 'name': 'Facebook Covers'},
    {'size': '1200*444', 'path': 'assets/whiteboards/Rectangle 1 (14).png', 'name': 'Twitter Header'},
    {'size': '1200*900', 'path': 'assets/whiteboards/Rectangle 1 (13).png', 'name': 'Facebook Website Conversions'},
    {'size': '1200*628', 'path': 'assets/whiteboards/Rectangle 1 (12).png', 'name': 'Facebook Page Post Engagements'},
    {'size': '1500*500', 'path': 'assets/whiteboards/Rectangle 1 (10).png', 'name': 'Facebook Page Likes'},
    {'size': '851*315', 'path': 'assets/whiteboards/Rectangle 1 (9).png', 'name': 'Twitter Lead Gen. Card'},
    {'size': '497*373', 'path': 'assets/whiteboards/Rectangle 1 (8).png', 'name': 'Twitter Promoted Tweet'},
    {'size': '1024*512', 'path': 'assets/whiteboards/Rectangle 1 (7).png', 'name': 'AdWords-Medium Rectangle'},
    {'size': '735*1102', 'path': 'assets/whiteboards/Rectangle 1 (6).png', 'name': 'AdWords-Large Rectangle'},
    {'size': '1080*1080', 'path': 'assets/whiteboards/Rectangle 1 (5).png', 'name': 'AdWords Leaderboard'},
    {'size': '628*628', 'path': 'assets/whiteboards/Rectangle 1 (4).png', 'name': 'Adwords -250*250'},
    {'size': '1080*1920', 'path': 'assets/whiteboards/Rectangle 1 (3).png', 'name': 'Adwords -300*600'},
    {'size': '940*940', 'path': 'assets/whiteboards/Rectangle 1 (2).png', 'name': 'Website Headers'},
    {'size': '1200*1200', 'path': 'assets/whiteboards/Rectangle 1 (1).png', 'name': 'Website Banners'},
    {'size': '1200*885', 'path': 'assets/whiteboards/Rectangle 1.png', 'name': 'Video Thumbnail'},
  ];

  void showCreateTemplateSheet() {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.only(bottom: 24),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Wrap(
            children: [
              const Padding(
                padding: EdgeInsets.only(left: 5, right: 5, top: 15, bottom: 8),
                child: Center(
                  child: Text(
                    'New Template',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 2, top: 25, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.find<BottomSheetController>().pickImageFromCamera();
                      },
                      child: Container(
                        height: 120,
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(ColorConst.lightishbordercolorgrey)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/addsquare.png'),
                              const SizedBox(height: 7),
                              Text(
                                'From Camera',
                                style: TextStyle(
                                  color: Color(ColorConst.textblackcolor),
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Get.find<BottomSheetController>().pickImageFromGallery();
                      },
                      child: Container(
                        height: 120,
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(ColorConst.lightishbordercolorgrey)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/magicpen.png'),
                              const SizedBox(height: 7),
                              Text(
                                'From Gallery',
                                style: TextStyle(
                                  color: Color(ColorConst.textblackcolor),
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 2, right: 2, top: 25, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.find<TemplateController>().showTemplatePicker();
                        Get.back();
                      },
                      child: Container(
                        height: 120,
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(ColorConst.lightishbordercolorgrey)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset('assets/category.png'),
                              const SizedBox(height: 7),
                              Text(
                                'From Template',
                                style: TextStyle(
                                  color: Color(ColorConst.textblackcolor),
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        Get.find<BottomSheetController>().showWhiteboardSelectionSheet();
                      },
                      child: Container(
                        height: 120,
                        width: 130,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Color(ColorConst.lightishbordercolorgrey)),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                height: 60,
                                width: 60,
                                child: Image.asset('assets/whiteboards/whiteboard.png'),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                'From Whiteboard',
                                style: TextStyle(
                                  color: Color(ColorConst.textblackcolor),
                                  fontFamily: 'Outfit',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12,
                                  height: 1.0,
                                  letterSpacing: 0.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      // collageController.showCollageOption.value = true;
                      Get.back(); // Close the create template sheet
                      Get.bottomSheet(
                        collageTemplateController.openTemplatePickerBottomSheet(),

                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                      );
                    },
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(ColorConst.lightishbordercolorgrey)),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Image.asset('assets/from_collage.png'),
                            ),
                            const SizedBox(height: 7),
                            Text(
                              'From Collage',
                              style: TextStyle(
                                color: Color(ColorConst.textblackcolor),
                                fontFamily: 'Outfit',
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                                height: 1.0,
                                letterSpacing: 0.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void showWhiteboardSelectionSheet() {
    Get.bottomSheet(
      Padding(
        padding: const EdgeInsets.only(bottom: 0),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: whiteboardTypes.length,
                    itemBuilder: (context, index) {
                      final whiteboard = whiteboardTypes[index];
                      return GestureDetector(
                        onTap: () {
                          Get.find<BottomSheetController>().createWhiteboard(whiteboard['path']!);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Container(
                            height: 80,
                            width: 130,
                            padding: EdgeInsets.only(left: 10, right: 10),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(ColorConst.skyBlue),
                                  Color(ColorConst.lightpurple),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Color(ColorConst.lightishbordercolorgrey)),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 90,
                                    child: Text(
                                      whiteboard['name']!,
                                      style: TextStyle(
                                        color: Color(ColorConst.textblackcolor),
                                        fontFamily: 'Outfit',
                                        fontWeight: FontWeight.w400,
                                        fontSize: 12,
                                        height: 1.0,
                                        letterSpacing: 0.0,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Text(
                                    whiteboard['size']!,
                                    style: TextStyle(
                                      color: Color(ColorConst.textblackcolor),
                                      fontFamily: 'Outfit',
                                      fontWeight: FontWeight.w400,
                                      fontSize: 12,
                                      height: 1.0,
                                      letterSpacing: 0.0,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> pickImageFromGallery() async {
    final XFile? pickedFile = await pickerGallery.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      Get.back();
      Get.toNamed(Consts.ImageEditorScreen, arguments: imageFile);
    } else {
      Get.snackbar('Cancelled', 'No image selected');
    }
  }

  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await pickerCamera.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      Get.back();
      Get.toNamed(Consts.ImageEditorScreen, arguments: imageFile);
    } else {
      Get.snackbar('Cancelled', 'No image selected');
    }
  }

  Future<void> createWhiteboard(String assetPath) async {
    try {
      final byteData = await rootBundle.load(assetPath);
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/whiteboard_${assetPath.split('/').last}';
      final file = File(filePath);
      await file.writeAsBytes(byteData.buffer.asUint8List());

      Get.back(); // Close the whiteboard selection bottom sheet
      Get.back(); // Close the main bottom sheet
      Get.toNamed(Consts.ImageEditorScreen, arguments: file);
    } catch (e) {
      Get.snackbar('Error', 'Failed to load whiteboard: $e');
    }
  }
}