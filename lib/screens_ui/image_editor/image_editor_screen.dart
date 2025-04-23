import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_filter.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';

class ImageEditorScreen extends StatelessWidget {
  final ImageEditorController _controller = Get.put(ImageEditorController());
  final ImageFilterController filtercontroller = Get.put(ImageFilterController());
  final StickerController stickerController = Get.put(StickerController());
  final TextEditorControllerWidget textEditorControllerWidget = Get.put(TextEditorControllerWidget());
  final GlobalKey _imageKey = GlobalKey(); // Key to measure image position/size

  @override
  Widget build(BuildContext context) {
    final File image = Get.arguments;
    _controller.setInitialImage(image);
    _controller.decodeEditedImage();
    filtercontroller.setInitialImage(image);

    return SafeArea(
      bottom: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
        body: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final position = renderBox.localToGlobal(Offset.zero);
                final size = renderBox.size;
                print('Image bounds: position=($position), size=($size)');
              }
            });

            return Obx(() {
              final Uint8List? memoryImage = _controller.editedImageBytes.value;
              final File? fileImage = _controller.editedImage.value;
              print('Rebuilding ImageEditorScreen UI, text count: ${textEditorControllerWidget.text.length}');
              return Stack(
                children: [
                  Column(
                    children: [
                      Expanded(
                        child: Obx(() {
                          bool isAnyEditOpen = _controller.showEditOptions.value ||
                              _controller.showFilterEditOptions.value ||
                              _controller.showStickerEditOptions.value ||
                              _controller.showtuneOptions.value;

                          return AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            transform: Matrix4.translationValues(0, isAnyEditOpen ? 20 : 0, 0)
                              ..scale(isAnyEditOpen ? 0.94 : 1.0),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Container(
                                    key: _imageKey,
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.matrix(
                                        _controller.calculateColorMatrix(),
                                      ),
                                      child: memoryImage != null
                                          ? Image.memory(memoryImage, fit: BoxFit.contain)
                                          : (fileImage != null && fileImage.path.isNotEmpty
                                          ? Image.file(fileImage, fit: BoxFit.contain)
                                          : Text("No image loaded", style: TextStyle(color: Colors.white))),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 15),
                      if (!_controller.showEditOptions.value &&
                          !_controller.showFilterEditOptions.value &&
                          !_controller.showStickerEditOptions.value &&
                          !_controller.showtuneOptions.value &&
                          !_controller.TextEditOptions.value)
                        _buildToolBar(context),

                      if (_controller.showEditOptions.value) _controller.buildEditControls(),
                      if (_controller.showStickerEditOptions.value) _controller.buildShapeSelectorSheet(),
                      if (_controller.showtuneOptions.value) _controller.TuneEditControls(),
                      if (_controller.TextEditOptions.value) _controller.TextEditControls(),
                      if (_controller.showFilterEditOptions.value)
                        _controller.buildFilterControlsSheet(onClose: () {
                          _controller.showFilterEditOptions.value = false;
                        }),
                    ],
                  ),
                  Obx(() {
                    print('Rendering sticker list: ${stickerController.stickers.length}');
                    return Stack(
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
                                    width: 60.0 * sticker.scale.value,
                                    height: 60.0 * sticker.scale.value,
                                    decoration: BoxDecoration(
                                      border: isSelected
                                          ? Border.all(color: Color(ColorConst.purplecolor), width: 2)
                                          : null,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: SvgPicture.asset(
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
                                          onPanUpdate: (details) => stickerController.rotateSticker(0.03),
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
                                          color: Color(ColorConst.purplecolor),
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
                    );
                  }),
                  Obx(() {
                    print('Rendering text list: ${textEditorControllerWidget.text.length}');
                    return Stack(
                      clipBehavior: Clip.none,
                      children: textEditorControllerWidget.text.asMap().entries.map((entry) {
                        final index = entry.key;
                        final textModel = entry.value;
                        final isSelected = textModel == textEditorControllerWidget.selectedText.value;
                        // Ensure text is positioned within image bounds
                        final double maxWidth = constraints.maxWidth - 20; // Account for padding
                        final double maxHeight = constraints.maxHeight - 100; // Account for app bar and toolbar
                        if (textModel.top.value == 50 && textModel.left.value == 50) {
                          textModel.top.value = maxHeight * 0.1; // 10% from top
                          textModel.left.value = maxWidth * 0.1; // 10% from left
                          print('Adjusted text position for index $index: top=${textModel.top.value}, left=${textModel.left.value}');
                        }
                        // Clamp positions to prevent off-screen rendering
                        textModel.top.value = textModel.top.value.clamp(0, maxHeight);
                        textModel.left.value = textModel.left.value.clamp(0, maxWidth);
                        print('Rendering text item $index: text="${textModel.text.value}", '
                            'top=${textModel.top.value}, left=${textModel.left.value}, '
                            'fontSize=${textModel.fontSize.value}, color=${textModel.textColor.value}');
                        return Positioned(
                          top: textModel.top.value,
                          left: textModel.left.value,
                          child: GestureDetector(
                            onTap: () {
                              textEditorControllerWidget.selectText(textModel);
                              print('Selected text: ${textModel.text.value} at index $index');
                            },
                            onPanUpdate: (details) {
                              if (isSelected) {
                                textModel.top.value += details.delta.dy;
                                textModel.left.value += details.delta.dx;
                                textModel.top.value = textModel.top.value.clamp(0, maxHeight);
                                textModel.left.value = textModel.left.value.clamp(0, maxWidth);
                                print('Moved text at index $index to: top=${textModel.top.value}, left=${textModel.left.value}');
                              }
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Debug rectangle to visualize text position
                                Container(
                                  width: 100,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.red, width: 2), // Red border for debugging
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: isSelected
                                        ? Border.all(color: Color(ColorConst.purplecolor), width: 2)
                                        : null,
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.black.withOpacity(0.5), // High-contrast background
                                  ),
                                  padding: EdgeInsets.all(8),
                                  child: Text(
                                    textModel.text.value.isEmpty ? 'Empty' : textModel.text.value,
                                    style: TextStyle(
                                      fontSize: textModel.fontSize.value > 0 ? textModel.fontSize.value : 24.0,
                                      color: textModel.textColor.value.withOpacity(1.0),
                                      fontWeight: FontWeight.bold, // Bold for visibility
                                      shadows: [
                                        Shadow(
                                          blurRadius: 3.0,
                                          color: Colors.black,
                                          offset: Offset(2, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }),
                  if (_controller.isFlipping.value)
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
            });
          },
        ),
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
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 12, color: Colors.white),
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
            _controller.buildToolButton('Tune', 'assets/tune.png', () {
              _controller.showtuneOptions.value = true;
            }),
            SizedBox(width: 40),
            _controller.buildToolButton('Crop', 'assets/crop.png', () {
              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
              _controller.pickAndCropImage();
            }),
            SizedBox(width: 40),
            _controller.buildToolButton('Text', 'assets/text.png', () {
              _controller.TextEditOptions.value = true;
            }),
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
            SizedBox(width: 40),
            _controller.buildToolButton('Debug Text', 'assets/text.png', () {
              textEditorControllerWidget.updateText('Debug Text ${DateTime.now().millisecondsSinceEpoch}');
              print('Manually added debug text');
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