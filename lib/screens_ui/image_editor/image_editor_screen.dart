import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_filter.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/hbstyles_container.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';

class ImageEditorScreen extends StatelessWidget {
  final ImageEditorController _controller = Get.put(ImageEditorController());
  final ImageFilterController filtercontroller =
      Get.put(ImageFilterController());
  final StickerController stickerController = Get.put(StickerController());

  @override
  Widget build(BuildContext context) {
    final File image = Get.arguments;
    _controller.setInitialImage(image);
    _controller.decodeEditedImage();
    filtercontroller.setInitialImage(image);

    return SafeArea(
      child: Scaffold(
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
          final Uint8List? memoryImage = _controller.editedImageBytes.value;
          final File? fileImage = _controller.editedImage.value;
      
          return Stack(
            children: [
              Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                            key: stickerController.imagekey.value,
                            child: memoryImage != null
                                ? Image.memory(memoryImage, fit: BoxFit.contain)
                                : (fileImage != null && fileImage.path.isNotEmpty
                                    ? Image.file(fileImage, fit: BoxFit.contain)
                                    : Text("No image loaded")),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15),
                  if (!_controller.showEditOptions.value &&
                      !_controller.showFilterEditOptions.value &&
                      !_controller.showStickerEditOptions.value)
                    _buildToolBar(context),
      
                  if (_controller.showEditOptions.value)
                    _controller.buildEditControls(),
                  if (_controller.showStickerEditOptions.value)
                    _controller.buildShapeSelectorSheet(),
                  if (_controller.showFilterEditOptions.value)
                    _controller.buildFilterControlsSheet(onClose: () {
                      _controller.showFilterEditOptions.value = false;
                    }),
                  // if()
                ],
              ),
              Obx(() => Stack(
                children: stickerController.stickers.map((sticker) {
                  final isSelected = sticker == stickerController.selectedSticker.value;
      
                  return Positioned(
                    top: sticker.top.value,
                    left: sticker.left.value,
                    child: GestureDetector(
                      onTap: () => stickerController.selectSticker(sticker),
                      onPanUpdate: (details) {
                        if (isSelected) {
                          stickerController.moveSticker(details);
                        }
                      },
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.identity()
                          ..rotateZ(sticker.rotation.value)
                          ..scale(
                            sticker.isFlipped.value ? -1.0 : 1.0,
                            1.0,
                          ),
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 60 * sticker.scale.value,
                              height: 60 * sticker.scale.value,
                              decoration: BoxDecoration(
                                border: isSelected
                                    ? Border.all(color: Color(ColorConst.purplecolor), width: 2)
                                    : null,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: SvgPicture.asset(
                                  width: 10,
                                  height: 10,
                                  sticker.path,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
      
                            if (isSelected) ...[
                              Positioned(
                                top: -3,
                                left: -3,
                                child: Transform.rotate(
                                  angle: sticker.rotation.value,
                                  child: _cornerControl(
                                    icon: Icons.rotate_right,
                                    color: Color(ColorConst.purplecolor),
                                    scale: sticker.scale.value,
                                    onPanUpdate: (details) =>
                                        stickerController.rotateSticker(0.03),
      
                                  ),
                                ),
                              ),
                              Positioned(
                                top: -3,
                                right: -3,
                                child: Transform.rotate(
                                  angle: sticker.rotation.value,
                                  child: _cornerControl(
                                    icon: Icons.close,
                                    color: Color(ColorConst.purplecolor),
                                    scale: sticker.scale.value,
                                    onTap: () => stickerController.removeSticker(sticker),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -3,
                                left: -3,
                                child: Transform.rotate(
                                  angle: sticker.rotation.value,
                                  child: _cornerControl(
                                    icon: Icons.flip,
                                    color: Color(ColorConst.purplecolor),
                                    scale: sticker.scale.value,
                                    onTap: stickerController.flipSticker,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: -3,
                                right: -3,
                                child: Transform.rotate(
                                  angle: sticker.rotation.value,
                                  child: _cornerControl(
                                    icon: Icons.zoom_out_map,
                                    color:Color(ColorConst.purplecolor),
                                    scale: sticker.scale.value,
                                    onPanUpdate: (details) =>
                                        stickerController.resizeSticker(details.delta.dy * 0.01),
                                  ),
                                ),
                              ),
                            ]
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              )),
      
      
      
              // GestureDetector(
              //     onPanUpdate: (details) {
              //       print('resizing');
              //       stickerController.rotateSticker(details.delta.dy * 0.01);
              //     },
              //   // onTap: () {
              //   //   stickerController.resizeSticker();
              //   // },
              //     child: SizedBox(
              //       height: 30,
              //         width: 39,
              //         child: SvgPicture.asset( stickerController.selectedSticker.value!.path))),
      
              if (_controller.isFlipping.value == true)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 6.0,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _cornerControl({
    required IconData icon,
    required Color color,
    required double scale,
    void Function()? onTap,
    void Function(DragUpdateDetails)? onPanUpdate,
  }) {
    return GestureDetector(
      onTap: onTap,
      onPanUpdate: onPanUpdate,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 18 ,
        height: 18 ,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 12 , color: Colors.white),
      ),
    );
  }



  Widget _circleIcon(IconData icon, Color color) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
      child: Icon(icon, color: Colors.white, size: 18),
    );
  }

  Widget _buildToolBar(BuildContext context) {
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
            _controller.buildToolButton('Crop', 'assets/crop.png', () {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              _controller.pickAndCropImage();
            }),
            SizedBox(width: 40),
            _controller.buildToolButton('Text', 'assets/text.png', () {}),
            SizedBox(width: 40),
            _controller.buildToolButton('Camera', 'assets/camera.png', () {}),
            SizedBox(width: 40),
            _controller.buildToolButton('Filter', 'assets/filter.png', () {
              _controller.showFilterEditOptions.value = true;
            }),
            SizedBox(width: 40),
            _controller.buildToolButton('Sticker', 'assets/elements.png', () {
              _controller.showStickerEditOptions.value = true;
            }),
          ],
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color color,
    void Function(DragUpdateDetails)? onpanupdate,
    void Function()? ontap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onPanUpdate: onpanupdate,
      onTap: ontap,
      child: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}
