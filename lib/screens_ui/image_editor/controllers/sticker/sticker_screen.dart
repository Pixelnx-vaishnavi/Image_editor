import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
import 'package:image_picker/image_picker.dart';

class EditCameraWidget extends StatelessWidget {
  final ValueNotifier<File?> LogoStcikerImage;
  final ValueNotifier<bool> CameraEditSticker;
  final StickerController controller;
  final ValueNotifier<double> imageOpacity;
  final ImageEditorController _controller = Get.put(ImageEditorController());


  EditCameraWidget({
    required this.LogoStcikerImage,
    required this.CameraEditSticker,
    required this.controller,
  }) : imageOpacity = ValueNotifier(1.0);

  Widget _buildCameraButton(
      String label,
      Color color,
      IconData icon,
      VoidCallback onPressed,
      )
  {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      icon: Icon(icon, color: Colors.white),
      label: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // padding: EdgeInsets.all(20),
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
          _buildCameraButton(
            "Select Image",
            Colors.cyan,
            Icons.flip,
                () async {
              final ImagePicker picker = ImagePicker();
              final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
              if (photo != null) {
                LogoStcikerImage.value = File(photo.path);
                print('${LogoStcikerImage.value}');
                Widget widget = ValueListenableBuilder<double>(
                  valueListenable: imageOpacity,
                  builder: (context, opacity, _) {
                    return Container(
                      height: 100,
                      width: 100,
                      padding: EdgeInsets.all(12),
                      child: Opacity(
                        opacity: opacity,
                        child: Image.file(LogoStcikerImage.value!),
                      ),
                    );
                  },
                );
                _controller.controller.add(widget);
              }
            },
          ),
          SizedBox(height: 10),
          _buildCameraButton(
            "Change Image",
            Colors.deepPurpleAccent,
            Icons.rotate_right,
                () async {
              final ImagePicker picker = ImagePicker();
              final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
              if (photo != null && _controller.controller.selectedWidget != null) {
                LogoStcikerImage.value = File(photo.path);
                print('${LogoStcikerImage.value}');
                Widget widget = ValueListenableBuilder<double>(
                  valueListenable: imageOpacity,
                  builder: (context, opacity, _) {
                    return Container(
                      height: 100,
                      width: 100,
                      padding: EdgeInsets.all(12),
                      child: Opacity(
                        opacity: opacity,
                        child: Image.file(LogoStcikerImage.value!),
                      ),
                    );
                  },
                );
                _controller.controller.selectedWidget!.edit(widget);
              }
            },
          ),
          SizedBox(height: 10),
          // Opacity Slider (shown only when a widget is selected)
          ValueListenableBuilder(
            valueListenable: LogoStcikerImage,
            builder: (context, file, _) {
              if (file == null || _controller.controller.selectedWidget == null) {
                return SizedBox.shrink();
              }
              return Column(
                children: [
                  Text(
                    'Opacity',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: imageOpacity,
                    builder: (context, opacity, _) {
                      return Slider(
                        value: opacity,
                        min: 0.0,
                        max: 1.0,
                        divisions: 100,
                        activeColor: Colors.cyan,
                        inactiveColor: Colors.grey,
                        onChanged: (value) {
                          imageOpacity.value = value;
                        },
                      );
                    },
                  ),
                ],
              );
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  _controller.controller.selectedWidget?.delete();
                  CameraEditSticker.value = false;
                  imageOpacity.value = 1.0; // Reset opacity
                },
                child: SizedBox(
                  height: 30,
                  child: Image.asset('assets/cross.png'),
                ),
              ),
              Text(
                'Camera',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              GestureDetector(
                onTap: () {
                  CameraEditSticker.value = false;
                  _controller.controller.clearAllBorders();
                },
                child: SizedBox(
                  height: 30,
                  child: Image.asset('assets/right.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}