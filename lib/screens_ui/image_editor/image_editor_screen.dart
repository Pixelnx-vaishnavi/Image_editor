import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/Collage/collage_controller.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_filter.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_icon.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ImageEditorScreen extends StatelessWidget {
  final ImageEditorController _controller = Get.put(ImageEditorController());
  final ImageFilterController filtercontroller = Get.put(ImageFilterController());
  final StickerController stickerController = Get.put(StickerController());
  final CollageController collageController = Get.put(CollageController());
  final TextEditorControllerWidget textEditorControllerWidget = Get.put(TextEditorControllerWidget());
  final TemplateController CollageTemplatecontroller = Get.put(TemplateController());

  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _repaintKey = GlobalKey(); // Key for capturing the image view

  // Function to capture the image view (image + stickers + text) as an image
  Future<Uint8List?> captureView() async {
    try {
      // Log sticker and text counts for debugging
      print('Stickers: ${stickerController.stickers.length}, Text: ${textEditorControllerWidget.text.length}');
      print('LindiController widgets: ${_controller.controller.widgets.length}');

      // Deselect stickers and text to exclude control borders/icons
      stickerController.selectedSticker.value = null;
      textEditorControllerWidget.clearSelection();

      // Force a rebuild and wait for rendering
      await Future.delayed(Duration(milliseconds: 200));

      final RenderRepaintBoundary? boundary =
      _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Get.snackbar("Error", "Failed to find render boundary");
        return null;
      }
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      Get.snackbar("Error", "Failed to capture view: $e");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final File image = Get.arguments;
    _controller.setInitialImage(image);
    _controller.decodeEditedImage();
    filtercontroller.setInitialImage(image);

    _controller.controller = LindiController(
      borderColor: Colors.white,
      shouldRotate: true,
      icons: [
        LindiStickerIcon(
          icon: Icons.rotate_90_degrees_ccw,
          iconColor: Colors.purple,
          alignment: Alignment.topRight,
          type: IconType.resize,
        ),
        LindiStickerIcon(
          icon: Icons.lock_open,
          alignment: Alignment.topCenter,
          onTap: () {
            _controller.controller.clearAllBorders();
          },
        ),
        LindiStickerIcon(
          icon: Icons.close,
          alignment: Alignment.topLeft,
          onTap: () {
            _controller.controller.selectedWidget!.delete();
          },
        ),
        LindiStickerIcon(
          icon: Icons.flip,
          alignment: Alignment.bottomLeft,
          onTap: () {
            _controller.controller.selectedWidget!.flip();
          },
        ),
        LindiStickerIcon(
          icon: Icons.crop_free,
          alignment: Alignment.bottomRight,
          type: IconType.resize,
        ),
      ],
    );

    // Sync LindiController stickers with StickerController
    // _controller.controller.onWidgetAdded((widget) {
    //   // Assuming widget has a path or similar property; adjust based on your Sticker model
    //   stickerController.stickers.add(Sticker(
    //     path: widget.path ?? 'assets/default_sticker.svg', // Replace with actual path
    //     top: RxDouble(widget.top ?? 0),
    //     left: RxDouble(widget.left ?? 0),
    //     scale: RxDouble(widget.scale ?? 1.0),
    //     rotation: RxDouble(widget.rotation ?? 0.0),
    //     isFlipped: RxBool(false),
    //   ));
    //   print('Added LindiController sticker to StickerController: ${stickerController.stickers.length}');
    // });

    _controller.controller.onPositionChange((index) {
      debugPrint("widgets size: ${_controller.controller.widgets.length}, current index: $index");
    });

    return SafeArea(
      bottom: true,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap:(){
                      _controller.showImageLayer.value = true;
                    },
                      child: SizedBox(height: 20, child: Image.asset('assets/image_layer.png'))),
                  const SizedBox(width: 25),
                  SizedBox(height: 20, child: Image.asset('assets/Save.png')),
                  const SizedBox(width: 15),
                  SizedBox(
                    height: 20,
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final Uint8List? capturedImage = await captureView();
                          if (capturedImage != null) {
                            final tempDir = await getTemporaryDirectory();
                            final file = await File('${tempDir.path}/shared_image.png').create();
                            await file.writeAsBytes(capturedImage);

                            await Share.shareXFiles(
                              [XFile(file.path)],
                              text: 'Check out my edited image!',
                            );
                          } else {
                            Get.snackbar("Error", "Failed to capture image");
                          }
                        } catch (e) {
                          Get.snackbar("Error", "Failed to share image: $e");
                        }
                      },
                      child: Image.asset('assets/Export.png'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              final RenderBox? renderBox =
              _imageKey.currentContext?.findRenderObject() as RenderBox?;
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
                  Container(
                    height: 700,
                    child: (_controller.isSelectingText.value == true)
                  ?  SingleChildScrollView(
                      child: Container(
                        height: 700,
                        child: Column(
                          children: [
                            Expanded(
                              child: Obx(() {
                                bool isAnyEditOpen =
                                    _controller.showEditOptions.value ||
                                        _controller.showFilterEditOptions.value ||
                                        _controller.showStickerEditOptions.value ||
                                        _controller.showtuneOptions.value;

                                return RepaintBoundary(
                                  key: _repaintKey,
                                  child: LindiStickerWidget(
                                    controller: _controller.controller,
                                    child: AnimatedContainer(
                                      duration:  Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      transform: Matrix4.translationValues(0, isAnyEditOpen ? 20 : 0, 0)
                                        ..scale(isAnyEditOpen ? 0.94 : 1.0),
                                      child: Padding(
                                        padding:  EdgeInsets.symmetric(horizontal: 10),
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
                                                    :  Text(
                                                  "No image loaded",
                                                  style: TextStyle(color: Colors.white),
                                                )),
                                              ),
                                            ),
                                            // Stickers layer
                                            Obx(() {
                                              print('Rendering sticker list: ${stickerController.stickers.length}');
                                              return Stack(
                                                children: stickerController.stickers.map((sticker) {
                                                  final isSelected =
                                                      sticker == stickerController.selectedSticker.value;
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
                                                      // child: Transform(
                                                      //   alignment: Alignment.center,
                                                      //   transform: Matrix4.identity()
                                                      //     ..rotateZ(sticker.rotation.value)
                                                      //     ..scale(
                                                      //       sticker.isFlipped.value ? -1.0 : 1.0,
                                                      //       1.0,
                                                      //     ),
                                                      //   child: Stack(
                                                      //     clipBehavior: Clip.none,
                                                      //     alignment: Alignment.center,
                                                      //     children: [
                                                      //       Container(
                                                      //         width: 60.0 * sticker.scale.value,
                                                      //         height: 60.0 * sticker.scale.value,
                                                      //         decoration: BoxDecoration(
                                                      //           border: isSelected
                                                      //               ? Border.all(
                                                      //               color:  Color(ColorConst.purplecolor),
                                                      //               width: 2)
                                                      //               : null,
                                                      //           borderRadius: BorderRadius.circular(8),
                                                      //         ),
                                                      //         child: Padding(
                                                      //           padding:  EdgeInsets.all(8.0),
                                                      //           child: SvgPicture.asset(
                                                      //             sticker.path,
                                                      //             fit: BoxFit.contain,
                                                      //           ),
                                                      //         ),
                                                      //       ),
                                                      //       if (isSelected) ...[
                                                      //         Positioned(
                                                      //           top: -3,
                                                      //           left: -3,
                                                      //           child: Transform.rotate(
                                                      //             angle: sticker.rotation.value,
                                                      //             child: _cornerControl(
                                                      //               icon: Icons.rotate_right,
                                                      //               color: const Color(ColorConst.purplecolor),
                                                      //               scale: sticker.scale.value,
                                                      //               onPanUpdate: (details) =>
                                                      //                   stickerController.rotateSticker(0.03),
                                                      //             ),
                                                      //           ),
                                                      //         ),
                                                      //         Positioned(
                                                      //           top: -3,
                                                      //           right: -3,
                                                      //           child: Transform.rotate(
                                                      //             angle: sticker.rotation.value,
                                                      //             child: _cornerControl(
                                                      //               icon: Icons.close,
                                                      //               color: const Color(ColorConst.purplecolor),
                                                      //               scale: sticker.scale.value,
                                                      //               onTap: () =>
                                                      //                   stickerController.removeSticker(sticker),
                                                      //             ),
                                                      //           ),
                                                      //         ),
                                                      //         Positioned(
                                                      //           bottom: -3,
                                                      //           left: -3,
                                                      //           child: Transform.rotate(
                                                      //             angle: sticker.rotation.value,
                                                      //             child: _cornerControl(
                                                      //               icon: Icons.flip,
                                                      //               color: const Color(ColorConst.purplecolor),
                                                      //               scale: sticker.scale.value,
                                                      //               onTap: stickerController.flipSticker,
                                                      //             ),
                                                      //           ),
                                                      //         ),
                                                      //         Positioned(
                                                      //           bottom: -3,
                                                      //           right: -3,
                                                      //           child: Transform.rotate(
                                                      //             angle: sticker.rotation.value,
                                                      //             child: _cornerControl(
                                                      //               icon: Icons.zoom_out_map,
                                                      //               color: const Color(ColorConst.purplecolor),
                                                      //               scale: sticker.scale.value,
                                                      //               onPanUpdate: (details) =>
                                                      //                   stickerController.resizeSticker(
                                                      //                       details.delta.dy * 0.01),
                                                      //             ),
                                                      //           ),
                                                      //         ),
                                                      //       ],
                                                      //     ],
                                                      //   ),
                                                      // ),
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            }),
                                            // Text layer
                                            Obx(() {
                                              final double maxWidth = constraints.maxWidth - 20;
                                              final double maxHeight = constraints.maxHeight - 100;
                                              print('Text count: ${textEditorControllerWidget.text}');
                                              return Stack(
                                                clipBehavior: Clip.none,
                                                children: textEditorControllerWidget.text
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  final index = entry.key;
                                                  final textModel = entry.value;
                                                  final isSelected =
                                                      textModel == textEditorControllerWidget.selectedText.value;

                                                  if (textModel.top.value == 50 && textModel.left.value == 50) {
                                                    textModel.top.value = maxHeight * 0.1;
                                                    textModel.left.value = maxWidth * 0.1;
                                                    print(
                                                        'Adjusted text position for index $index: top=${textModel.top.value}, left=${textModel.left.value}');
                                                  }

                                                  textModel.top.value = textModel.top.value.clamp(0, maxHeight);
                                                  textModel.left.value = textModel.left.value.clamp(0, maxWidth);

                                                  final textPainter = TextPainter(
                                                    text: TextSpan(
                                                      text: textModel.text.value.isEmpty
                                                          ? 'Empty'
                                                          : textModel.text.value,
                                                      style: GoogleFonts.getFont(
                                                        'Roboto',
                                                        fontSize: textModel.fontSize.value.toDouble(),
                                                        fontWeight: textModel.isBold.value
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        fontStyle: textModel.isItalic.value
                                                            ? FontStyle.italic
                                                            : FontStyle.normal,
                                                      ),
                                                    ),
                                                    textDirection: TextDirection.ltr,
                                                    textAlign: textModel.textAlign.value,
                                                  )..layout(maxWidth: maxWidth);

                                                  final textWidth = textPainter.width + 16;
                                                  final textHeight = textPainter.height;

                                                  return Positioned(
                                                    top: textModel.top.value,
                                                    left: textModel.left.value,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        textEditorControllerWidget.selectText(textModel);
                                                        print(
                                                            'Selected text: ${textModel.text.value} at index $index');
                                                      },
                                                      onPanUpdate: (details) {
                                                        if (isSelected) {
                                                          textModel.top.value += details.delta.dy;
                                                          textModel.left.value += details.delta.dx;
                                                          textModel.top.value =
                                                              textModel.top.value.clamp(0, maxHeight);
                                                          textModel.left.value =
                                                              textModel.left.value.clamp(0, maxWidth);
                                                          print(
                                                              'Moved text at index $index to: top=${textModel.top.value}, left=${textModel.left.value}');
                                                        }
                                                      },
                                                      child: Transform(
                                                        alignment: Alignment.center,
                                                        transform: Matrix4.identity()
                                                          ..rotateZ(textModel.rotation.value)
                                                          ..scale(
                                                            textModel.isFlippedHorizontally.value ? -1.0 : 1.0,
                                                            1.0,
                                                          ),
                                                        // child: Container(
                                                        //   decoration: BoxDecoration(
                                                        //     border: isSelected
                                                        //         ? Border.all(color: Colors.purple, width: 2)
                                                        //         : null,
                                                        //     borderRadius: BorderRadius.circular(8),
                                                        //   ),
                                                        //   child: Stack(
                                                        //     clipBehavior: Clip.none,
                                                        //     alignment: Alignment.center,
                                                        //     children: [
                                                        //       Container(
                                                        //         width: textWidth,
                                                        //         decoration: BoxDecoration(
                                                        //           color: textModel.backgroundColor.value,
                                                        //           borderRadius: BorderRadius.circular(8),
                                                        //         ),
                                                        //         padding: const EdgeInsets.all(8),
                                                        //         child: SizedBox(
                                                        //           width: textWidth - 16,
                                                        //           child: Text(
                                                        //             textModel.text.value.isEmpty
                                                        //                 ? 'Empty'
                                                        //                 : textModel.text.value,
                                                        //             textAlign: textModel.textAlign.value,
                                                        //             style: GoogleFonts.getFont(
                                                        //               textModel.fontFamily.value.isEmpty
                                                        //                   ? 'Roboto'
                                                        //                   : textModel.fontFamily.value,
                                                        //               fontSize:
                                                        //               textModel.fontSize.value.toDouble(),
                                                        //               color: textModel.textColor.value
                                                        //                   .withOpacity(textModel.opacity.value),
                                                        //               fontWeight: textModel.isBold.value
                                                        //                   ? FontWeight.bold
                                                        //                   : FontWeight.normal,
                                                        //               fontStyle: textModel.isItalic.value
                                                        //                   ? FontStyle.italic
                                                        //                   : FontStyle.normal,
                                                        //               decoration: textModel.isUnderline.value
                                                        //                   ? TextDecoration.underline
                                                        //                   : (textModel.isStrikethrough.value
                                                        //                   ? TextDecoration.lineThrough
                                                        //                   : null),
                                                        //               shadows: [
                                                        //                 Shadow(
                                                        //                   blurRadius:
                                                        //                   textModel.shadowBlur.value,
                                                        //                   color: textModel.shadowColor.value,
                                                        //                   offset: Offset(
                                                        //                     textModel.shadowOffsetX.value,
                                                        //                     textModel.shadowOffsetY.value,
                                                        //                   ),
                                                        //                 ),
                                                        //               ],
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       ),
                                                        //       if (isSelected) ...[
                                                        //         Positioned(
                                                        //           top: -3,
                                                        //           left: -3,
                                                        //           child: Transform.rotate(
                                                        //             angle: textModel.rotation.value,
                                                        //             child: _cornerControl(
                                                        //               icon: Icons.rotate_right,
                                                        //               color: const Color(0xFF9C27B0),
                                                        //               onPanUpdate: (details) {
                                                        //                 textEditorControllerWidget.updateRotation(
                                                        //                     details.localPosition.dy * 0.02);
                                                        //               },
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //         Positioned(
                                                        //           top: -3,
                                                        //           right: -3,
                                                        //           child: Transform.rotate(
                                                        //             angle: textModel.rotation.value,
                                                        //             child: _cornerControl(
                                                        //               icon: Icons.close,
                                                        //               color: const Color(0xFF9C27B0),
                                                        //               onTap: () {
                                                        //                 textEditorControllerWidget.text
                                                        //                     .remove(textModel);
                                                        //                 textEditorControllerWidget.clearSelection();
                                                        //                 print('Removed text at index $index');
                                                        //               },
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //         Positioned(
                                                        //           bottom: -3,
                                                        //           left: -3,
                                                        //           child: Transform.rotate(
                                                        //             angle: textModel.rotation.value,
                                                        //             child: _cornerControl(
                                                        //               icon: Icons.flip,
                                                        //               color: const Color(0xFF9C27B0),
                                                        //               onTap: () {
                                                        //                 textEditorControllerWidget
                                                        //                     .toggleFlipHorizontally();
                                                        //                 print(
                                                        //                     'Flipped text at index $index, flipH=${textModel.isFlippedHorizontally.value}');
                                                        //               },
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //         Positioned(
                                                        //           bottom: -3,
                                                        //           right: -3,
                                                        //           child: Transform.rotate(
                                                        //             angle: textModel.rotation.value,
                                                        //             child: _cornerControl(
                                                        //               icon: Icons.zoom_out_map,
                                                        //               color: const Color(0xFF9C27B0),
                                                        //               onPanUpdate: (details) {
                                                        //                 textEditorControllerWidget.resizeText(
                                                        //                     details.localPosition.dy * 0.2);
                                                        //               },
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       ],
                                                        //     ],
                                                        //   ),
                                                        // ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 15),
                            if (!_controller.showEditOptions.value &&
                                !_controller.showFilterEditOptions.value &&
                                !_controller.showStickerEditOptions.value &&
                                !_controller.showtuneOptions.value &&
                                !_controller.TextEditOptions.value &&
                                !_controller.CameraEditSticker.value &&
                                !collageController.showCollageOption.value && !_controller.showPresetsEditOptions.value)
                              _buildToolBar(context),
                            if (_controller.showEditOptions.value) _controller.buildEditControls(),
                            if (_controller.showStickerEditOptions.value)
                              _controller.buildShapeSelectorSheet(),
                            if (_controller.showtuneOptions.value) _controller.TuneEditControls(),
                            if (_controller.TextEditOptions.value)
                              _controller.TextEditControls(constraints, _imageKey),
                            if (_controller.CameraEditSticker.value) _controller.buildEditCamera(),
                            if (collageController.showCollageOption.value)
                              CollageTemplatecontroller.openTemplatePickerBottomSheet(),
                            if (_controller.showFilterEditOptions.value)
                              _controller.buildFilterControlsSheet(onClose: () {
                                _controller.showFilterEditOptions.value = false;
                              }),
                            if(_controller.showPresetsEditOptions.value)
                              _controller.showFilterControlsBottomSheet(context, () {
                                   _controller.showFilterEditOptions.value = false;
                                   }),
                          ],
                        ),
                      ),
                    )
                        :Column(
                          children: [
                            Expanded(
                              child: Obx(() {
                                bool isAnyEditOpen =
                                    _controller.showEditOptions.value ||
                                        _controller.showFilterEditOptions.value ||
                                        _controller.showStickerEditOptions.value ||
                                        _controller.showtuneOptions.value;

                                return RepaintBoundary(
                                  key: _repaintKey,
                                  child: LindiStickerWidget(
                                    controller: _controller.controller,
                                    child: AnimatedContainer(
                                      duration:  Duration(milliseconds: 200),
                                      curve: Curves.easeInOut,
                                      transform: Matrix4.translationValues(0, isAnyEditOpen ? 20 : 0, 0)
                                        ..scale(isAnyEditOpen ? 0.94 : 1.0),
                                      child: Padding(
                                        padding:  EdgeInsets.symmetric(horizontal: 10),
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
                                                    :  Text(
                                                  "No image loaded",
                                                  style: TextStyle(color: Colors.white),
                                                )),
                                              ),
                                            ),
                                            // Stickers layer
                                            Obx(() {
                                              print('Rendering sticker list: ${stickerController.stickers.length}');
                                              return Stack(
                                                children: stickerController.stickers.map((sticker) {
                                                  final isSelected =
                                                      sticker == stickerController.selectedSticker.value;
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
                                                      // child: Transform(
                                                      //   alignment: Alignment.center,
                                                      //   transform: Matrix4.identity()
                                                      //     ..rotateZ(sticker.rotation.value)
                                                      //     ..scale(
                                                      //       sticker.isFlipped.value ? -1.0 : 1.0,
                                                      //       1.0,
                                                      //     ),
                                                      //   child: Stack(
                                                      //     clipBehavior: Clip.none,
                                                      //     alignment: Alignment.center,
                                                      //     children: [
                                                      //       Container(
                                                      //         width: 60.0 * sticker.scale.value,
                                                      //         height: 60.0 * sticker.scale.value,
                                                      //         decoration: BoxDecoration(
                                                      //           border: isSelected
                                                      //               ? Border.all(
                                                      //               color:  Color(ColorConst.purplecolor),
                                                      //               width: 2)
                                                      //               : null,
                                                      //           borderRadius: BorderRadius.circular(8),
                                                      //         ),
                                                      //         child: Padding(
                                                      //           padding:  EdgeInsets.all(8.0),
                                                      //           child: SvgPicture.asset(
                                                      //             sticker.path,
                                                      //             fit: BoxFit.contain,
                                                      //           ),
                                                      //         ),
                                                      //       ),
                                                      //       if (isSelected) ...[
                                                      //         Positioned(
                                                      //           top: -3,
                                                      //           left: -3,
                                                      //           child: Transform.rotate(
                                                      //             angle: sticker.rotation.value,
                                                      //             child: _cornerControl(
                                                      //               icon: Icons.rotate_right,
                                                      //               color: const Color(ColorConst.purplecolor),
                                                      //               scale: sticker.scale.value,
                                                      //               onPanUpdate: (details) =>
                                                      //                   stickerController.rotateSticker(0.03),
                                                      //             ),
                                                      //           ),
                                                      //         ),
                                                      //         Positioned(
                                                      //           top: -3,
                                                      //           right: -3,
                                                      //           child: Transform.rotate(
                                                      //             angle: sticker.rotation.value,
                                                      //             child: _cornerControl(
                                                      //               icon: Icons.close,
                                                      //               color: const Color(ColorConst.purplecolor),
                                                      //               scale: sticker.scale.value,
                                                      //               onTap: () =>
                                                      //                   stickerController.removeSticker(sticker),
                                                      //             ),
                                                      //           ),
                                                      //         ),
                                                      //         Positioned(
                                                      //           bottom: -3,
                                                      //           left: -3,
                                                      //           child: Transform.rotate(
                                                      //             angle: sticker.rotation.value,
                                                      //             child: _cornerControl(
                                                      //               icon: Icons.flip,
                                                      //               color: const Color(ColorConst.purplecolor),
                                                      //               scale: sticker.scale.value,
                                                      //               onTap: stickerController.flipSticker,
                                                      //             ),
                                                      //           ),
                                                      //         ),
                                                      //         Positioned(
                                                      //           bottom: -3,
                                                      //           right: -3,
                                                      //           child: Transform.rotate(
                                                      //             angle: sticker.rotation.value,
                                                      //             child: _cornerControl(
                                                      //               icon: Icons.zoom_out_map,
                                                      //               color: const Color(ColorConst.purplecolor),
                                                      //               scale: sticker.scale.value,
                                                      //               onPanUpdate: (details) =>
                                                      //                   stickerController.resizeSticker(
                                                      //                       details.delta.dy * 0.01),
                                                      //             ),
                                                      //           ),
                                                      //         ),
                                                      //       ],
                                                      //     ],
                                                      //   ),
                                                      // ),
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            }),
                                            // Text layer
                                            Obx(() {
                                              final double maxWidth = constraints.maxWidth - 20;
                                              final double maxHeight = constraints.maxHeight - 100;
                                              print('Text count: ${textEditorControllerWidget.text.length}');
                                              return Stack(
                                                clipBehavior: Clip.none,
                                                children: textEditorControllerWidget.text
                                                    .asMap()
                                                    .entries
                                                    .map((entry) {
                                                  final index = entry.key;
                                                  final textModel = entry.value;
                                                  final isSelected =
                                                      textModel == textEditorControllerWidget.selectedText.value;

                                                  if (textModel.top.value == 50 && textModel.left.value == 50) {
                                                    textModel.top.value = maxHeight * 0.1;
                                                    textModel.left.value = maxWidth * 0.1;
                                                    print(
                                                        'Adjusted text position for index $index: top=${textModel.top.value}, left=${textModel.left.value}');
                                                  }

                                                  textModel.top.value = textModel.top.value.clamp(0, maxHeight);
                                                  textModel.left.value = textModel.left.value.clamp(0, maxWidth);

                                                  final textPainter = TextPainter(
                                                    text: TextSpan(
                                                      text: textModel.text.value.isEmpty
                                                          ? 'Empty'
                                                          : textModel.text.value,
                                                      style: GoogleFonts.getFont(
                                                        'Roboto',
                                                        fontSize: textModel.fontSize.value.toDouble(),
                                                        fontWeight: textModel.isBold.value
                                                            ? FontWeight.bold
                                                            : FontWeight.normal,
                                                        fontStyle: textModel.isItalic.value
                                                            ? FontStyle.italic
                                                            : FontStyle.normal,
                                                      ),
                                                    ),
                                                    textDirection: TextDirection.ltr,
                                                    textAlign: textModel.textAlign.value,
                                                  )..layout(maxWidth: maxWidth);

                                                  final textWidth = textPainter.width + 16;
                                                  final textHeight = textPainter.height;

                                                  return Positioned(
                                                    top: textModel.top.value,
                                                    left: textModel.left.value,
                                                    child: GestureDetector(
                                                      onTap: () {
                                                        textEditorControllerWidget.selectText(textModel);
                                                        print(
                                                            'Selected text: ${textModel.text.value} at index $index');
                                                      },
                                                      onPanUpdate: (details) {
                                                        if (isSelected) {
                                                          textModel.top.value += details.delta.dy;
                                                          textModel.left.value += details.delta.dx;
                                                          textModel.top.value =
                                                              textModel.top.value.clamp(0, maxHeight);
                                                          textModel.left.value =
                                                              textModel.left.value.clamp(0, maxWidth);
                                                          print(
                                                              'Moved text at index $index to: top=${textModel.top.value}, left=${textModel.left.value}');
                                                        }
                                                      },
                                                      child: Transform(
                                                        alignment: Alignment.center,
                                                        transform: Matrix4.identity()
                                                          ..rotateZ(textModel.rotation.value)
                                                          ..scale(
                                                            textModel.isFlippedHorizontally.value ? -1.0 : 1.0,
                                                            1.0,
                                                          ),
                                                        // child: Container(
                                                        //   decoration: BoxDecoration(
                                                        //     border: isSelected
                                                        //         ? Border.all(color: Colors.purple, width: 2)
                                                        //         : null,
                                                        //     borderRadius: BorderRadius.circular(8),
                                                        //   ),
                                                        //   child: Stack(
                                                        //     clipBehavior: Clip.none,
                                                        //     alignment: Alignment.center,
                                                        //     children: [
                                                        //       Container(
                                                        //         width: textWidth,
                                                        //         decoration: BoxDecoration(
                                                        //           color: textModel.backgroundColor.value,
                                                        //           borderRadius: BorderRadius.circular(8),
                                                        //         ),
                                                        //         padding: const EdgeInsets.all(8),
                                                        //         child: SizedBox(
                                                        //           width: textWidth - 16,
                                                        //           child: Text(
                                                        //             textModel.text.value.isEmpty
                                                        //                 ? 'Empty'
                                                        //                 : textModel.text.value,
                                                        //             textAlign: textModel.textAlign.value,
                                                        //             style: GoogleFonts.getFont(
                                                        //               textModel.fontFamily.value.isEmpty
                                                        //                   ? 'Roboto'
                                                        //                   : textModel.fontFamily.value,
                                                        //               fontSize:
                                                        //               textModel.fontSize.value.toDouble(),
                                                        //               color: textModel.textColor.value
                                                        //                   .withOpacity(textModel.opacity.value),
                                                        //               fontWeight: textModel.isBold.value
                                                        //                   ? FontWeight.bold
                                                        //                   : FontWeight.normal,
                                                        //               fontStyle: textModel.isItalic.value
                                                        //                   ? FontStyle.italic
                                                        //                   : FontStyle.normal,
                                                        //               decoration: textModel.isUnderline.value
                                                        //                   ? TextDecoration.underline
                                                        //                   : (textModel.isStrikethrough.value
                                                        //                   ? TextDecoration.lineThrough
                                                        //                   : null),
                                                        //               shadows: [
                                                        //                 Shadow(
                                                        //                   blurRadius:
                                                        //                   textModel.shadowBlur.value,
                                                        //                   color: textModel.shadowColor.value,
                                                        //                   offset: Offset(
                                                        //                     textModel.shadowOffsetX.value,
                                                        //                     textModel.shadowOffsetY.value,
                                                        //                   ),
                                                        //                 ),
                                                        //               ],
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       ),
                                                        //       if (isSelected) ...[
                                                        //         Positioned(
                                                        //           top: -3,
                                                        //           left: -3,
                                                        //           child: Transform.rotate(
                                                        //             angle: textModel.rotation.value,
                                                        //             child: _cornerControl(
                                                        //               icon: Icons.rotate_right,
                                                        //               color: const Color(0xFF9C27B0),
                                                        //               onPanUpdate: (details) {
                                                        //                 textEditorControllerWidget.updateRotation(
                                                        //                     details.localPosition.dy * 0.02);
                                                        //               },
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //         Positioned(
                                                        //           top: -3,
                                                        //           right: -3,
                                                        //           child: Transform.rotate(
                                                        //             angle: textModel.rotation.value,
                                                        //             child: _cornerControl(
                                                        //               icon: Icons.close,
                                                        //               color: const Color(0xFF9C27B0),
                                                        //               onTap: () {
                                                        //                 textEditorControllerWidget.text
                                                        //                     .remove(textModel);
                                                        //                 textEditorControllerWidget.clearSelection();
                                                        //                 print('Removed text at index $index');
                                                        //               },
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //         Positioned(
                                                        //           bottom: -3,
                                                        //           left: -3,
                                                        //           child: Transform.rotate(
                                                        //             angle: textModel.rotation.value,
                                                        //             child: _cornerControl(
                                                        //               icon: Icons.flip,
                                                        //               color: const Color(0xFF9C27B0),
                                                        //               onTap: () {
                                                        //                 textEditorControllerWidget
                                                        //                     .toggleFlipHorizontally();
                                                        //                 print(
                                                        //                     'Flipped text at index $index, flipH=${textModel.isFlippedHorizontally.value}');
                                                        //               },
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //         Positioned(
                                                        //           bottom: -3,
                                                        //           right: -3,
                                                        //           child: Transform.rotate(
                                                        //             angle: textModel.rotation.value,
                                                        //             child: _cornerControl(
                                                        //               icon: Icons.zoom_out_map,
                                                        //               color: const Color(0xFF9C27B0),
                                                        //               onPanUpdate: (details) {
                                                        //                 textEditorControllerWidget.resizeText(
                                                        //                     details.localPosition.dy * 0.2);
                                                        //               },
                                                        //             ),
                                                        //           ),
                                                        //         ),
                                                        //       ],
                                                        //     ],
                                                        //   ),
                                                        // ),
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              );
                                            }),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 15),
                            if (!_controller.showEditOptions.value &&
                                !_controller.showFilterEditOptions.value &&
                                !_controller.showStickerEditOptions.value &&
                                !_controller.showtuneOptions.value &&
                                !_controller.TextEditOptions.value &&
                                !_controller.CameraEditSticker.value &&
                                !collageController.showCollageOption.value && !_controller.showPresetsEditOptions.value &&!_controller.showImageLayer.value)
                              _buildToolBar(context),
                            if (_controller.showEditOptions.value) _controller.buildEditControls(),
                            if (_controller.showStickerEditOptions.value)
                              _controller.buildShapeSelectorSheet(),
                            if (_controller.showImageLayer.value)
                              _controller.buildImageLayerSheet(),
                            if (_controller.showtuneOptions.value) _controller.TuneEditControls(),
                            if (_controller.TextEditOptions.value)
                              _controller.TextEditControls(constraints, _imageKey),
                            if (_controller.CameraEditSticker.value) _controller.buildEditCamera(),
                            if (collageController.showCollageOption.value)
                              CollageTemplatecontroller.openTemplatePickerBottomSheet(),
                            if (_controller.showFilterEditOptions.value)
                              _controller.buildFilterControlsSheet(onClose: () {
                                _controller.showFilterEditOptions.value = false;
                              }),
                            if(_controller.showPresetsEditOptions.value)
                              _controller.showFilterControlsBottomSheet(context, () {
                                _controller.showFilterEditOptions.value = false;
                              }),
                          ],
                        ),),
                  if (_controller.isFlipping.value)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.8),
                        child: const Center(
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
    void Function()? onTap,
    void Function(DragUpdateDetails)? onPanUpdate,
    double scale = 1.0,
  }) {
    return GestureDetector(
      onTap: onTap,
      onPanUpdate: onPanUpdate,
      behavior: HitTestBehavior.translucent,
      child: Container(
        width: 24 * scale,
        height: 24 * scale,
        decoration: BoxDecoration(
          color: color.withOpacity(0.9),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16 * scale, color: Colors.white),
      ),
    );
  }

  Widget _buildToolBar(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration:  BoxDecoration(
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
            _controller.buildToolButton('Camera', 'assets/camera.png', () {
              _controller.CameraEditSticker.value = true;
            }),
             SizedBox(width: 40),
            _controller.buildToolButton('Filter', 'assets/filter.png', () {
              _controller.showFilterEditOptions.value = true;
            }),
             SizedBox(width: 40),
            _controller.buildToolButton('Sticker', 'assets/elements.png', () {
              _controller.showStickerEditOptions.value = true;
            }),
             SizedBox(width: 40),
            _controller.buildToolButton('Collage', 'assets/collage.png', () {
              collageController.showCollageOption.value = true;
            }),
            SizedBox(width: 40),
            _controller.buildToolButton('Presets', 'assets/presets.png', () {
              _controller.showPresetsEditOptions.value = true;
            }),
          ],
        ),
      ),
    );
  }
}

class Sticker {
  final String path;
  final RxDouble top;
  final RxDouble left;
  final RxDouble scale;
  final RxDouble rotation;
  final RxBool isFlipped;

  Sticker({
    required this.path,
    required this.top,
    required this.left,
    required this.scale,
    required this.rotation,
    required this.isFlipped,
  });
}