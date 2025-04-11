import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/image_editor/image_editor_controller.dart';

class ImageEditorScreen extends StatelessWidget {
  final ImageEditorController _controller = Get.put(ImageEditorController());

  @override
  Widget build(BuildContext context) {
    final File image = Get.arguments;
    _controller.setInitialImage(image);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                SizedBox(height: 20, child: Image.asset('assets/Save.png')),
                SizedBox(width: 15),
                SizedBox(height: 20, child: Image.asset('assets/Export.png')),
              ],
            ),
          )
        ],
      ),
      body: Obx(() {
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Obx(() {
                  final Uint8List? memoryImage = _controller.editedImageBytes.value;
                  return Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: memoryImage != null
                          ? Image.memory(memoryImage, fit: BoxFit.contain)
                          : Image.file(_controller.editedImage.value, fit: BoxFit.contain),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 15),
            if (!_controller.showEditOptions.value)
              _buildToolBar(),
            if (_controller.showEditOptions.value)
              _controller.buildEditControls(),
          ],
        );
      }),
    );
  }

  Widget _buildToolBar() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _controller.buildToolButton('Rotate', 'assets/rotate.png', () {
              _controller.showEditOptions.value = true;
            }),
            SizedBox(width: 40),
            _controller.buildToolButton('Tune', 'assets/tune.png', () {}),
            SizedBox(width: 40),
            _controller.buildToolButton('Crop', 'assets/crop.png', () {}),
            SizedBox(width: 40),
            _controller.buildToolButton('Text', 'assets/text.png', () {}),
            SizedBox(width: 40),
            _controller.buildToolButton('Camera', 'assets/camera.png', () {}),
            SizedBox(width: 40),
            _controller.buildToolButton('Filter', 'assets/filter.png', () {}),
            SizedBox(width: 40),
            _controller.buildToolButton('Sticker', 'assets/elements.png', () {}),
          ],
        ),
      ),
    );
  }
}
