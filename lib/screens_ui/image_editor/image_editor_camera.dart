import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_filter.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/imagefilter_editor.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/rotate_mirror.dart';


class ImageEditorScreen extends StatelessWidget {
  final ImageEditorController _controller = Get.put(ImageEditorController());
  final ImageFilterController filtercontroller = Get.put(ImageFilterController());


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
      body:

      Obx(() {
        final Uint8List? memoryImage = _controller.editedImageBytes.value;
        final File? fileImage = _controller.editedImage.value;

        return Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Padding(
                    padding:  EdgeInsets.symmetric(horizontal: 25),
                    child: Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: memoryImage != null
                            ? Image.memory(memoryImage, fit: BoxFit.contain)
                            : (fileImage != null && fileImage.path.isNotEmpty
                            ? Image.file(fileImage, fit: BoxFit.contain)
                            :  Text("No image loaded")),
                      ),
                    ),
                  ),
                ),
                 SizedBox(height: 15),
                if (!_controller.showEditOptions.value) _buildToolBar(),
                if (_controller.showEditOptions.value) _controller.buildEditControls(),
              ],
            ),

            if (_controller.isFlipping.value)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                  child:  Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 6.0,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  ),
                ),
              ),



          ],
        );
      })







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
            _controller.buildToolButton('Filter', 'assets/filter.png', () {
              ImageFilterEditor(originalImageBytes: _controller.editedImageBytes.value!);
            }),
            SizedBox(width: 40),
            _controller.buildToolButton('Sticker', 'assets/elements.png', () {}),
          ],
        ),
      ),
    );
  }
}
