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
  final ImageFilterController filtercontroller =
      Get.put(ImageFilterController());
  final StickerController stickerController = Get.put(StickerController());
  final CollageController collageController = Get.put(CollageController());
  final TextEditorControllerWidget textEditorControllerWidget =
      Get.put(TextEditorControllerWidget());
  final TemplateController CollageTemplatecontroller =
      Get.put(TemplateController());

  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _repaintKey = GlobalKey();
  final GlobalKey<_ShapeSelectorSheetState> _shapeSelectorKey =
      GlobalKey<_ShapeSelectorSheetState>();

  Future<Uint8List?> captureView() async {
    try {
      print(
          'Stickers: ${stickerController.stickers.length}, Text: ${textEditorControllerWidget.text.length}');
      print(
          'LindiController widgets: ${_controller.controller.widgets.length}');

      stickerController.selectedSticker.value = null;
      textEditorControllerWidget.clearSelection();

      await Future.delayed(Duration(milliseconds: 200));

      final RenderRepaintBoundary? boundary = _repaintKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Get.snackbar("Error", "Failed to find render boundary");
        return null;
      }
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);
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
      borderColor: Colors.blue,
      shouldRotate: true,
      showBorders: true,
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

    _controller.controller.onPositionChange((index) {
   // print('=====onPostionChanged=====${_controller.controller.selectedWidget!.key}');
      debugPrint(
          "widgets size: ${_controller.controller.widgets.length}, current index: $index");
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
            icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _shapeSelectorKey.currentState?._undo();
                    },
                    icon: Icon(Icons.undo, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      _shapeSelectorKey.currentState?._redo();
                    },
                    icon: Icon(Icons.redo, color: Colors.white),
                  ),
                  SizedBox(width: 25),
                  GestureDetector(
                    onTap: () {
                      _controller.showImageLayer.value = true;
                    },
                    child: SizedBox(
                        height: 20,
                        child: Image.asset('assets/image_layer.png')),
                  ),
                  SizedBox(width: 25),
                  SizedBox(
                    height: 20,
                    child: GestureDetector(
                      onTap: () async {
                        try {
                          final Uint8List? capturedImage = await captureView();
                          if (capturedImage != null) {
                            final tempDir = await getTemporaryDirectory();
                            final file =
                                await File('${tempDir.path}/shared_image.png')
                                    .create();
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
                          print("Error sharing image: $e");
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
              print(
                  'Rebuilding ImageEditorScreen UI, text count: ${textEditorControllerWidget.text.length}');
              return Stack(
                children: [
                  Container(
                    height: 700,
                    child: (_controller.isSelectingText.value == true)
                        ? SingleChildScrollView(
                            child: Container(
                              height: 700,
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Obx(() {
                                      bool isAnyEditOpen =
                                          _controller.showEditOptions.value ||
                                              _controller.showFilterEditOptions
                                                  .value ||
                                              _controller.showStickerEditOptions
                                                  .value ||
                                              _controller.showtuneOptions.value;
                                      return RepaintBoundary(
                                        key: _repaintKey,
                                        child: LindiStickerWidget(
                                          controller: _controller.controller,
                                          child: AnimatedContainer(
                                            duration:
                                                Duration(milliseconds: 200),
                                            curve: Curves.easeInOut,
                                            transform:
                                                Matrix4.translationValues(0,
                                                    isAnyEditOpen ? 20 : 0, 0)
                                                  ..scale(isAnyEditOpen
                                                      ? 0.94
                                                      : 1.0),
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: Stack(
                                                alignment: Alignment.center,
                                                children: [
                                                  Container(
                                                    key: _imageKey,
                                                    child: ColorFiltered(
                                                      colorFilter:
                                                          ColorFilter.matrix(
                                                        _controller
                                                            .calculateColorMatrix(),
                                                      ),
                                                      child: memoryImage != null
                                                          ? Image.memory(
                                                              memoryImage,
                                                              fit: BoxFit
                                                                  .contain)
                                                          : (fileImage !=
                                                                      null &&
                                                                  fileImage.path
                                                                      .isNotEmpty
                                                              ? Image.file(
                                                                  fileImage,
                                                                  fit: BoxFit
                                                                      .contain)
                                                              : Text(
                                                                  "No image loaded",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white),
                                                                )),
                                                    ),
                                                  ),
                                                  Obx(() {
                                                    final double maxWidth =
                                                        constraints.maxWidth -
                                                            20;
                                                    final double maxHeight =
                                                        constraints.maxHeight -
                                                            100;
                                                    print(
                                                        'Text count: ${textEditorControllerWidget.text.length}');
                                                    return Stack(
                                                      clipBehavior: Clip.none,
                                                      children:
                                                          textEditorControllerWidget
                                                              .text
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                        final index = entry.key;
                                                        final textModel =
                                                            entry.value;
                                                        final isSelected =
                                                            textModel ==
                                                                textEditorControllerWidget
                                                                    .selectedText
                                                                    .value;

                                                        if (textModel.top
                                                                    .value ==
                                                                50 &&
                                                            textModel.left
                                                                    .value ==
                                                                50) {
                                                          textModel.top.value =
                                                              maxHeight * 0.1;
                                                          textModel.left.value =
                                                              maxWidth * 0.1;
                                                          print(
                                                              'Adjusted text position for index $index: top=${textModel.top.value}, left=${textModel.left.value}');
                                                        }

                                                        textModel.top.value =
                                                            textModel.top.value
                                                                .clamp(0,
                                                                    maxHeight);
                                                        textModel.left.value =
                                                            textModel.left.value
                                                                .clamp(0,
                                                                    maxWidth);

                                                        final textPainter =
                                                            TextPainter(
                                                          text: TextSpan(
                                                            text: textModel
                                                                    .text
                                                                    .value
                                                                    .isEmpty
                                                                ? 'Empty'
                                                                : textModel
                                                                    .text.value,
                                                            style: GoogleFonts
                                                                .getFont(
                                                              'Roboto',
                                                              fontSize: textModel
                                                                  .fontSize
                                                                  .value
                                                                  .toDouble(),
                                                              fontWeight: textModel
                                                                      .isBold
                                                                      .value
                                                                  ? FontWeight
                                                                      .bold
                                                                  : FontWeight
                                                                      .normal,
                                                              fontStyle: textModel
                                                                      .isItalic
                                                                      .value
                                                                  ? FontStyle
                                                                      .italic
                                                                  : FontStyle
                                                                      .normal,
                                                            ),
                                                          ),
                                                          textDirection:
                                                              TextDirection.ltr,
                                                          textAlign: textModel
                                                              .textAlign.value,
                                                        )..layout(
                                                                maxWidth:
                                                                    maxWidth);

                                                        final textWidth =
                                                            textPainter.width +
                                                                16;
                                                        final textHeight =
                                                            textPainter.height;

                                                        return Positioned(
                                                          top: textModel
                                                              .top.value,
                                                          left: textModel
                                                              .left.value,
                                                          child:
                                                              GestureDetector(
                                                            onTap: () {
                                                              textEditorControllerWidget
                                                                  .selectText(
                                                                      textModel);
                                                              print(
                                                                  'Selected text: ${textModel.text.value} at index $index');
                                                            },
                                                            onPanUpdate:
                                                                (details) {
                                                              if (isSelected) {
                                                                textModel.top
                                                                        .value +=
                                                                    details
                                                                        .delta
                                                                        .dy;
                                                                textModel.left
                                                                        .value +=
                                                                    details
                                                                        .delta
                                                                        .dx;
                                                                textModel.top
                                                                        .value =
                                                                    textModel
                                                                        .top
                                                                        .value
                                                                        .clamp(
                                                                            0,
                                                                            maxHeight);
                                                                textModel.left
                                                                        .value =
                                                                    textModel
                                                                        .left
                                                                        .value
                                                                        .clamp(
                                                                            0,
                                                                            maxWidth);
                                                                print(
                                                                    'Moved text at index $index to: top=${textModel.top.value}, left=${textModel.left.value}');
                                                              }
                                                            },
                                                            child: Transform(
                                                              alignment:
                                                                  Alignment
                                                                      .center,
                                                              transform: Matrix4
                                                                  .identity()
                                                                ..rotateZ(
                                                                    textModel
                                                                        .rotation
                                                                        .value)
                                                                ..scale(
                                                                  textModel
                                                                          .isFlippedHorizontally
                                                                          .value
                                                                      ? -1.0
                                                                      : 1.0,
                                                                  1.0,
                                                                ),
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  border: isSelected
                                                                      ? Border.all(
                                                                          color: Colors
                                                                              .purple,
                                                                          width:
                                                                              2)
                                                                      : null,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              8),
                                                                ),
                                                                child: Stack(
                                                                  clipBehavior:
                                                                      Clip.none,
                                                                  alignment:
                                                                      Alignment
                                                                          .center,
                                                                  children: [
                                                                    Container(
                                                                      width:
                                                                          textWidth,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        color: textModel
                                                                            .backgroundColor
                                                                            .value,
                                                                        borderRadius:
                                                                            BorderRadius.circular(8),
                                                                      ),
                                                                      padding:
                                                                          const EdgeInsets
                                                                              .all(
                                                                              8),
                                                                      child:
                                                                          SizedBox(
                                                                        width: textWidth -
                                                                            16,
                                                                        child:
                                                                            Text(
                                                                          textModel.text.value.isEmpty
                                                                              ? 'Empty'
                                                                              : textModel.text.value,
                                                                          textAlign: textModel
                                                                              .textAlign
                                                                              .value,
                                                                          style:
                                                                              GoogleFonts.getFont(
                                                                            textModel.fontFamily.value.isEmpty
                                                                                ? 'Roboto'
                                                                                : textModel.fontFamily.value,
                                                                            fontSize:
                                                                                textModel.fontSize.value.toDouble(),
                                                                            color:
                                                                                textModel.textColor.value.withOpacity(textModel.opacity.value),
                                                                            fontWeight: textModel.isBold.value
                                                                                ? FontWeight.bold
                                                                                : FontWeight.normal,
                                                                            fontStyle: textModel.isItalic.value
                                                                                ? FontStyle.italic
                                                                                : FontStyle.normal,
                                                                            decoration: textModel.isUnderline.value
                                                                                ? TextDecoration.underline
                                                                                : (textModel.isStrikethrough.value ? TextDecoration.lineThrough : null),
                                                                            shadows: [
                                                                              Shadow(
                                                                                blurRadius: textModel.shadowBlur.value,
                                                                                color: textModel.shadowColor.value,
                                                                                offset: Offset(
                                                                                  textModel.shadowOffsetX.value,
                                                                                  textModel.shadowOffsetY.value,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    if (isSelected) ...[
                                                                      Positioned(
                                                                        top: -3,
                                                                        left:
                                                                            -3,
                                                                        child: Transform
                                                                            .rotate(
                                                                          angle: textModel
                                                                              .rotation
                                                                              .value,
                                                                          child:
                                                                              _cornerControl(
                                                                            icon:
                                                                                Icons.rotate_right,
                                                                            color:
                                                                                const Color(0xFF9C27B0),
                                                                            onPanUpdate:
                                                                                (details) {
                                                                              textEditorControllerWidget.updateRotation(details.localPosition.dy * 0.02);
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        top: -3,
                                                                        right:
                                                                            -3,
                                                                        child: Transform
                                                                            .rotate(
                                                                          angle: textModel
                                                                              .rotation
                                                                              .value,
                                                                          child:
                                                                              _cornerControl(
                                                                            icon:
                                                                                Icons.close,
                                                                            color:
                                                                                const Color(0xFF9C27B0),
                                                                            onTap:
                                                                                () {
                                                                              textEditorControllerWidget.text.remove(textModel);
                                                                              textEditorControllerWidget.clearSelection();
                                                                              print('Removed text at index $index');
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        bottom:
                                                                            -3,
                                                                        left:
                                                                            -3,
                                                                        child: Transform
                                                                            .rotate(
                                                                          angle: textModel
                                                                              .rotation
                                                                              .value,
                                                                          child:
                                                                              _cornerControl(
                                                                            icon:
                                                                                Icons.flip,
                                                                            color:
                                                                                const Color(0xFF9C27B0),
                                                                            onTap:
                                                                                () {
                                                                              textEditorControllerWidget.toggleFlipHorizontally();
                                                                              print('Flipped text at index $index, flipH=${textModel.isFlippedHorizontally.value}');
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Positioned(
                                                                        bottom:
                                                                            -3,
                                                                        right:
                                                                            -3,
                                                                        child: Transform
                                                                            .rotate(
                                                                          angle: textModel
                                                                              .rotation
                                                                              .value,
                                                                          child:
                                                                              _cornerControl(
                                                                            icon:
                                                                                Icons.zoom_out_map,
                                                                            color:
                                                                                const Color(0xFF9C27B0),
                                                                            onPanUpdate:
                                                                                (details) {
                                                                              textEditorControllerWidget.resizeText(details.localPosition.dy * 0.2);
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ],
                                                                ),
                                                              ),
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
                                      !_controller
                                          .showFilterEditOptions.value &&
                                      !_controller
                                          .showStickerEditOptions.value &&
                                      !_controller.showtuneOptions.value &&
                                      !_controller.TextEditOptions.value &&
                                      !_controller.CameraEditSticker.value &&
                                      !collageController
                                          .showCollageOption.value &&
                                      !_controller
                                          .showPresetsEditOptions.value &&
                                      !_controller.showImageLayer.value)
                                    _buildToolBar(context),
                                  if (_controller.showEditOptions.value)
                                    _controller.buildEditControls(),
                                  if (_controller.showStickerEditOptions.value)
                                    ShapeSelectorSheet(
                                      key: _shapeSelectorKey,
                                      controller: _controller.controller,
                                      shapeCategories:
                                          _controller.shapeCategories,
                                    ),
                                  if (_controller.showImageLayer.value)
                                    _controller.buildImageLayerSheet(),
                                  if (_controller.showtuneOptions.value)
                                    _controller.TuneEditControls(),
                                  if (_controller.TextEditOptions.value)
                                    _controller.TextEditControls(
                                        constraints, _imageKey),
                                  if (_controller.CameraEditSticker.value)
                                    _controller.buildEditCamera(),
                                  if (collageController.showCollageOption.value)
                                    CollageTemplatecontroller
                                        .openTemplatePickerBottomSheet(),
                                  if (_controller.showFilterEditOptions.value)
                                    _controller.buildFilterControlsSheet(
                                        onClose: () {
                                      _controller.showFilterEditOptions.value =
                                          false;
                                    }),
                                  if (_controller.showPresetsEditOptions.value)
                                    _controller.showFilterControlsBottomSheet(
                                        context, () {
                                      _controller.showFilterEditOptions.value =
                                          false;
                                    }),
                                ],
                              ),
                            ),
                          )
                        : Column(
                            children: [
                              Expanded(
                                child: Obx(() {
                                  bool isAnyEditOpen = _controller
                                          .showEditOptions.value ||
                                      _controller.showFilterEditOptions.value ||
                                      _controller
                                          .showStickerEditOptions.value ||
                                      _controller.showtuneOptions.value;
                                  return RepaintBoundary(
                                    key: _repaintKey,
                                    child: LindiStickerWidget(
                                      controller: _controller.controller,
                                      child: AnimatedContainer(
                                        duration: Duration(milliseconds: 200),
                                        curve: Curves.easeInOut,
                                        transform: Matrix4.translationValues(
                                            0, isAnyEditOpen ? 20 : 0, 0)
                                          ..scale(isAnyEditOpen ? 0.94 : 1.0),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Container(
                                                key: _imageKey,
                                                child: ColorFiltered(
                                                  colorFilter:
                                                      ColorFilter.matrix(
                                                    _controller
                                                        .calculateColorMatrix(),
                                                  ),
                                                  child: memoryImage != null
                                                      ? Image.memory(
                                                          memoryImage,
                                                          fit: BoxFit.contain)
                                                      : (fileImage != null &&
                                                              fileImage.path
                                                                  .isNotEmpty
                                                          ? Image.file(
                                                              fileImage,
                                                              fit: BoxFit
                                                                  .contain)
                                                          : Text(
                                                              "No image loaded",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white),
                                                            )),
                                                ),
                                              ),
                                              Obx(() {
                                                final double maxWidth =
                                                    constraints.maxWidth - 20;
                                                final double maxHeight =
                                                    constraints.maxHeight - 100;
                                                print(
                                                    'Text count: ${textEditorControllerWidget.text.length}');
                                                return Stack(
                                                  clipBehavior: Clip.none,
                                                  children:
                                                      textEditorControllerWidget
                                                          .text
                                                          .asMap()
                                                          .entries
                                                          .map((entry) {
                                                    final index = entry.key;
                                                    final textModel =
                                                        entry.value;
                                                    final isSelected = textModel ==
                                                        textEditorControllerWidget
                                                            .selectedText.value;

                                                    if (textModel.top.value ==
                                                            50 &&
                                                        textModel.left.value ==
                                                            50) {
                                                      textModel.top.value =
                                                          maxHeight * 0.1;
                                                      textModel.left.value =
                                                          maxWidth * 0.1;
                                                      print(
                                                          'Adjusted text position for index $index: top=${textModel.top.value}, left=${textModel.left.value}');
                                                    }

                                                    textModel.top.value =
                                                        textModel.top.value
                                                            .clamp(
                                                                0, maxHeight);
                                                    textModel.left.value =
                                                        textModel.left.value
                                                            .clamp(0, maxWidth);

                                                    final textPainter =
                                                        TextPainter(
                                                      text: TextSpan(
                                                        text: textModel.text
                                                                .value.isEmpty
                                                            ? 'Empty'
                                                            : textModel
                                                                .text.value,
                                                        style:
                                                            GoogleFonts.getFont(
                                                          'Roboto',
                                                          fontSize: textModel
                                                              .fontSize.value
                                                              .toDouble(),
                                                          fontWeight: textModel
                                                                  .isBold.value
                                                              ? FontWeight.bold
                                                              : FontWeight
                                                                  .normal,
                                                          fontStyle: textModel
                                                                  .isItalic
                                                                  .value
                                                              ? FontStyle.italic
                                                              : FontStyle
                                                                  .normal,
                                                        ),
                                                      ),
                                                      textDirection:
                                                          TextDirection.ltr,
                                                      textAlign: textModel
                                                          .textAlign.value,
                                                    )..layout(
                                                            maxWidth: maxWidth);

                                                    final textWidth =
                                                        textPainter.width + 16;
                                                    final textHeight =
                                                        textPainter.height;

                                                    return Positioned(
                                                      top: textModel.top.value,
                                                      left:
                                                          textModel.left.value,
                                                      child: GestureDetector(
                                                        onTap: () {
                                                          textEditorControllerWidget
                                                              .selectText(
                                                                  textModel);
                                                          print(
                                                              'Selected text: ${textModel.text.value} at index $index');
                                                        },
                                                        onPanUpdate: (details) {
                                                          if (isSelected) {
                                                            textModel.top
                                                                    .value +=
                                                                details
                                                                    .delta.dy;
                                                            textModel.left
                                                                    .value +=
                                                                details
                                                                    .delta.dx;
                                                            textModel
                                                                    .top.value =
                                                                textModel
                                                                    .top.value
                                                                    .clamp(0,
                                                                        maxHeight);
                                                            textModel.left
                                                                    .value =
                                                                textModel
                                                                    .left.value
                                                                    .clamp(0,
                                                                        maxWidth);
                                                            print(
                                                                'Moved text at index $index to: top=${textModel.top.value}, left=${textModel.left.value}');
                                                          }
                                                        },
                                                        child: Transform(
                                                          alignment:
                                                              Alignment.center,
                                                          transform:
                                                              Matrix4.identity()
                                                                ..rotateZ(
                                                                    textModel
                                                                        .rotation
                                                                        .value)
                                                                ..scale(
                                                                  textModel
                                                                          .isFlippedHorizontally
                                                                          .value
                                                                      ? -1.0
                                                                      : 1.0,
                                                                  1.0,
                                                                ),
                                                          child: Container(
                                                            decoration:
                                                                BoxDecoration(
                                                              border: isSelected
                                                                  ? Border.all(
                                                                      color: Colors
                                                                          .purple,
                                                                      width: 2)
                                                                  : null,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                            child: Stack(
                                                                clipBehavior:
                                                                    Clip.none,
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                children: [
                                                                  Container(
                                                                    width:
                                                                        textWidth,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      color: textModel
                                                                          .backgroundColor
                                                                          .value,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              8),
                                                                    ),
                                                                    padding:
                                                                        const EdgeInsets
                                                                            .all(
                                                                            8),
                                                                    child:
                                                                        SizedBox(
                                                                      width:
                                                                          textWidth -
                                                                              16,
                                                                      child:
                                                                          Text(
                                                                        textModel.text.value.isEmpty
                                                                            ? 'Empty'
                                                                            : textModel.text.value,
                                                                        textAlign: textModel
                                                                            .textAlign
                                                                            .value,
                                                                        style: GoogleFonts
                                                                            .getFont(
                                                                          textModel.fontFamily.value.isEmpty
                                                                              ? 'Roboto'
                                                                              : textModel.fontFamily.value,
                                                                          fontSize: textModel
                                                                              .fontSize
                                                                              .value
                                                                              .toDouble(),
                                                                          color: textModel
                                                                              .textColor
                                                                              .value
                                                                              .withOpacity(textModel.opacity.value),
                                                                          fontWeight: textModel.isBold.value
                                                                              ? FontWeight.bold
                                                                              : FontWeight.normal,
                                                                          fontStyle: textModel.isItalic.value
                                                                              ? FontStyle.italic
                                                                              : FontStyle.normal,
                                                                          decoration: textModel.isUnderline.value
                                                                              ? TextDecoration.underline
                                                                              : (textModel.isStrikethrough.value ? TextDecoration.lineThrough : null),
                                                                          shadows: [
                                                                            Shadow(
                                                                              blurRadius: textModel.shadowBlur.value,
                                                                              color: textModel.shadowColor.value,
                                                                              offset: Offset(
                                                                                textModel.shadowOffsetX.value,
                                                                                textModel.shadowOffsetY.value,
                                                                              ),
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  if (isSelected) ...[
                                                                    Positioned(
                                                                      top: -3,
                                                                      left: -3,
                                                                      child: Transform
                                                                          .rotate(
                                                                        angle: textModel
                                                                            .rotation
                                                                            .value,
                                                                        child:
                                                                            _cornerControl(
                                                                          icon:
                                                                              Icons.rotate_right,
                                                                          color:
                                                                              const Color(0xFF9C27B0),
                                                                          onPanUpdate:
                                                                              (details) {
                                                                            textEditorControllerWidget.updateRotation(details.localPosition.dy *
                                                                                0.02);
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      top: -3,
                                                                      right: -3,
                                                                      child: Transform
                                                                          .rotate(
                                                                        angle: textModel
                                                                            .rotation
                                                                            .value,
                                                                        child:
                                                                            _cornerControl(
                                                                          icon:
                                                                              Icons.close,
                                                                          color:
                                                                              const Color(0xFF9C27B0),
                                                                          onTap:
                                                                              () {
                                                                            textEditorControllerWidget.text.remove(textModel);
                                                                            textEditorControllerWidget.clearSelection();
                                                                            print('Removed text at index $index');
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      bottom:
                                                                          -3,
                                                                      left: -3,
                                                                      child: Transform
                                                                          .rotate(
                                                                        angle: textModel
                                                                            .rotation
                                                                            .value,
                                                                        child:
                                                                            _cornerControl(
                                                                          icon:
                                                                              Icons.flip,
                                                                          color:
                                                                              const Color(0xFF9C27B0),
                                                                          onTap:
                                                                              () {
                                                                            textEditorControllerWidget.toggleFlipHorizontally();
                                                                            print('Flipped text at index $index, flipH=${textModel.isFlippedHorizontally.value}');
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                    Positioned(
                                                                      bottom:
                                                                          -3,
                                                                      right: -3,
                                                                      child: Transform
                                                                          .rotate(
                                                                        angle: textModel
                                                                            .rotation
                                                                            .value,
                                                                        child:
                                                                            _cornerControl(
                                                                          icon:
                                                                              Icons.zoom_out_map,
                                                                          color:
                                                                              const Color(0xFF9C27B0),
                                                                          onPanUpdate:
                                                                              (details) {
                                                                            textEditorControllerWidget.resizeText(details.localPosition.dy *
                                                                                0.2);
                                                                          },
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ]),
                                                          ),
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
                              SizedBox(height: 15),
                              if (!_controller.showEditOptions.value &&
                                  !_controller.showFilterEditOptions.value &&
                                  !_controller.showStickerEditOptions.value &&
                                  !_controller.showtuneOptions.value &&
                                  !_controller.TextEditOptions.value &&
                                  !_controller.CameraEditSticker.value &&
                                  !collageController.showCollageOption.value &&
                                  !_controller.showPresetsEditOptions.value &&
                                  !_controller.showImageLayer.value)
                                _buildToolBar(context),
                              if (_controller.showEditOptions.value)
                                _controller.buildEditControls(),
                              if (_controller.showStickerEditOptions.value)
                                ShapeSelectorSheet(
                                  key: _shapeSelectorKey,
                                  controller: _controller.controller,
                                  shapeCategories: _controller.shapeCategories,
                                ),
                              if (_controller.showImageLayer.value)
                                _controller.buildImageLayerSheet(),
                              if (_controller.showtuneOptions.value)
                                _controller.TuneEditControls(),
                              if (_controller.TextEditOptions.value)
                                _controller.TextEditControls(
                                    constraints, _imageKey),
                              if (_controller.CameraEditSticker.value)
                                _controller.buildEditCamera(),
                              if (collageController.showCollageOption.value)
                                CollageTemplatecontroller
                                    .openTemplatePickerBottomSheet(),
                              if (_controller.showFilterEditOptions.value)
                                _controller.buildFilterControlsSheet(
                                    onClose: () {
                                  _controller.showFilterEditOptions.value =
                                      false;
                                }),
                              if (_controller.showPresetsEditOptions.value)
                                _controller
                                    .showFilterControlsBottomSheet(context, () {
                                  _controller.showFilterEditOptions.value =
                                      false;
                                }),
                            ],
                          ),
                  ),
                  if (_controller.isFlipping.value)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.8),
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 6.0,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
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







class WidgetWithPosition {
  final Widget widget;
  final Alignment position;
  final GlobalKey globalKey;

  WidgetWithPosition({
    required this.widget,
    required this.position,
    required this.globalKey,
  });
}

class ShapeSelectorSheet extends StatefulWidget {
  final LindiController controller;
  final Map<String, List<String>> shapeCategories;

  const ShapeSelectorSheet({
    super.key,
    required this.controller,
    required this.shapeCategories,
  });

  @override
  State<ShapeSelectorSheet> createState() => _ShapeSelectorSheetState();
}

class _ShapeSelectorSheetState extends State<ShapeSelectorSheet> {
  final selectedTabIndex = ValueNotifier<int>(0);
  final selectedImageLayer = ValueNotifier<List<String>>([]);
  final stickerController = Get.find<StickerController>();
  final showStickerEditOptions = ValueNotifier<bool>(false);
  final showEditOptions = ValueNotifier<bool>(false);
  final editedImage = ValueNotifier<File?>(null);
  final editedImageBytes = ValueNotifier<List<int>?>(null);
  final flippedBytes = ValueNotifier<List<int>?>(null);
  final ImageEditorController editorController = Get.put(ImageEditorController());

  final List<WidgetWithPosition> _undoStack = [];
  final List<WidgetWithPosition> _redoStack = [];

  @override
  void initState() {
    super.initState();
    // Listen for position changes to update widget positions after dragging
    widget.controller.onPositionChange((index) {
      if (index >= 0 && index < widget.controller.widgets.length) {
        final widgetWithPosition = _undoStack.firstWhere(
              (w) => w.globalKey == widget.controller.widgets[index].key,

        );
        if (widgetWithPosition != null) {
          Future.delayed(Duration(milliseconds: 100), () {
            _updateWidgetPosition(widgetWithPosition);
          });
        } else {
          print('No matching widget found in _undoStack for key: ${widget.controller.widgets[index].key}');
        }
      }
    });
  }

  /// Updates the position of a widget in the undo stack after dragging or before undo
  Alignment _getWidgetPosition(WidgetWithPosition widgetWithPosition) {
    try {
      final renderBox = widgetWithPosition.globalKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        final position = renderBox.localToGlobal(Offset.zero);
        final size = renderBox.size;
        final stickerWidgetBox = LindiStickerWidget.globalKey.currentContext?.findRenderObject() as RenderBox?;
        if (stickerWidgetBox != null) {
          final stickerSize = stickerWidgetBox.size;
          final stickerOffset = stickerWidgetBox.localToGlobal(Offset.zero);
          final widgetCenter = Offset(
            position.dx + size.width/2,
            position.dy + size.height/2 ,
          );
          final alignmentX = ((widgetCenter.dx - stickerOffset.dx) / stickerSize.width) * 2- 1;
          final alignmentY = ((widgetCenter.dy - stickerOffset.dy) / stickerSize.height) * 2- 1;
          final newPosition = Alignment(alignmentX.clamp(-1, 1.0), alignmentY.clamp(-1, 1.0));
          print('Calculated position for widget ${widgetWithPosition.globalKey}: $newPosition'
              '(dx: ${widgetCenter.dx}, dy: ${widgetCenter.dy})');
          return newPosition;
        } else {
          print('Warning: LindiStickerWidget.globalKey is null, using stored position');
        }
      } else {
        print('Warning: RenderBox is null for widget ${widgetWithPosition.globalKey}');
      }
    } catch (e, stackTrace) {
      print('Error calculating widget position: $e');
      print(stackTrace);
    }
    return widgetWithPosition.position; // Fallback to stored position
  }

  /// Updates the position in _undoStack after dragging
  void _updateWidgetPosition(WidgetWithPosition widgetWithPosition) {
    final newPosition = _getWidgetPosition(widgetWithPosition);
    print('====newPosition=====${newPosition}');
    final index = _undoStack.indexWhere((w) => w.globalKey == widgetWithPosition.globalKey);
    if (index != -1) {
      _undoStack[index] = WidgetWithPosition(
        widget: widgetWithPosition.widget,
        position: newPosition,
        globalKey: widgetWithPosition.globalKey,
      );
    }
  }

  /// Adds a new widget to the controller and undo stack, preventing duplicates.
  void _addWidget(Widget newWidget, {Alignment? initialPosition}) {
    if (newWidget == null) return;
    try {
      final globalKey = GlobalKey();
      final keyedWidget = KeyedSubtree(
        key: globalKey,
        child: newWidget,
      );
      final position = initialPosition ?? Alignment.center;
      print('Adding widget: $keyedWidget (key: ${keyedWidget.key}) at position: $position');
      if (!widget.controller.widgets.any((w) => w.key == globalKey)) {
        widget.controller.add(keyedWidget, position: position);
        _undoStack.add(WidgetWithPosition(
          widget: keyedWidget,
          position: position,
          globalKey: globalKey,
        ));
        _redoStack.clear();
        print('Widget added, undoStack: ${_undoStack.length}, controller.widgets: ${widget.controller.widgets.length}');
        setState(() {});
        widget.controller.notifyListeners();
      } else {
        print('Widget with key ${keyedWidget.key} already exists, skipping add');
      }
    } catch (e, stackTrace) {
      print('Error adding widget: $e');
      print(stackTrace);
    }
  }

  /// Removes the last widget from the undo stack and adds it to the redo stack.
  void _undo() {
    if (_undoStack.isEmpty) {
      print('Undo stack is empty');
      return;
    }
    try {
      print('Undo called, undoStack length: ${_undoStack.length}');
      final undoneWidgetWithPosition = _undoStack.last;
      final undoneWidget = undoneWidgetWithPosition.widget;
      final widgetKey = (undoneWidget as KeyedSubtree).key;

      final currentPosition = _getWidgetPosition(undoneWidgetWithPosition);

      // _undoStack.removeLast();

      // final index = widget.controller.widgets.indexWhere((w) => w.key == widgetKey);
      // if (index != -1) {
      //   widget.controller.widgets[index].showBorder(true);
      //   widget.controller.widgets[index].delete();
      //   print('Deleted widget with key $widgetKey at index $index');
      // } else {
      //   print('Warning: Widget with key $widgetKey not found in controller.widgets');
      // }
      // widget.controller.widgets.last.showBorder(true);
      print('=====currentPsiton======${currentPosition.x}');
      print('=====currentPsiton======${currentPosition.y}');
      // final index = widget.controller.widgets.indexWhere((w) => w.key == widgetKey);

        // widget.controller.delete(index); // Use LindiController's delete method
        // print('Widget with key $widgetKey removed from controller at index $index');

      widget.controller.widgets.last.delete();
      widget.controller.add(undoneWidget, position: currentPosition);
      _redoStack.add(WidgetWithPosition(
        widget: undoneWidget,
        position: currentPosition,
        globalKey: undoneWidgetWithPosition.globalKey,
      ));

      setState(() {});
      widget.controller.notifyListeners();
    } catch (e, stackTrace) {
      print('Error during undo: $e');
      print(stackTrace);
    }
  }

  /// Re-adds the last widget from the redo stack to the controller and undo stack.
  void _redo() {
    if (_redoStack.isEmpty) {
      print('Redo stack is empty');
      return;
    }
    try {
      print('Redo called, redoStack length: ${_redoStack.length}');
      final redoneWidgetWithPosition = _redoStack.removeLast();
      final redoneWidget = redoneWidgetWithPosition.widget;
      final widgetKey = (redoneWidget as KeyedSubtree).key;
      print('Processing redo widget: $redoneWidget (key: $widgetKey)');
      print('===position===x====${redoneWidgetWithPosition.position.x}');
      print('===position===y====${redoneWidgetWithPosition.position.y}');

      if (!widget.controller.widgets.any((w) => w.key == widgetKey)) {
        widget.controller.add(redoneWidget, position: redoneWidgetWithPosition.position);
        _undoStack.add(redoneWidgetWithPosition);
        widget.controller.showBorders = true;
        print('Redo completed, undoStack: ${_undoStack.length}, '
            'redoStack: ${_redoStack.length}, '
            'controller.widgets: ${widget.controller.widgets.length}');
      } else {
        print('Widget with key $widgetKey already exists in controller.widgets, skipping redo');
      }

      setState(() {});
      widget.controller.notifyListeners();
    } catch (e, stackTrace) {
      print('Error in redo: $e');
      print(stackTrace);
    }
  }

  /// Programmatically triggers undo and redo for testing or automatic actions.
  void _triggerUndoRedoProgrammatically() {
    _undo();
    print('Undo triggered programmatically');
    Future.delayed(const Duration(seconds: 1), () {
      _redo();
      print('Redo triggered programmatically');
    });
  }

  @override
  void dispose() {
    selectedTabIndex.dispose();
    selectedImageLayer.dispose();
    showStickerEditOptions.dispose();
    showEditOptions.dispose();
    editedImage.dispose();
    editedImageBytes.dispose();
    flippedBytes.dispose();
    widget.controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.shapeCategories.keys.length,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1E1E1E),
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(20),
            topLeft: Radius.circular(20),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: TabBarView(
                children: widget.shapeCategories.values.map((imagePaths) {
                  return GridView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: imagePaths.length,
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final path = imagePaths[index];
                      return GestureDetector(
                        onTapDown: (details) {
                          selectedImageLayer.value.add(path);
                          print('Selected: ${selectedImageLayer.value}');
                          final newWidget = Container(
                            height: 100,
                            width: 100,
                            padding: const EdgeInsets.all(12),
                            child: SvgPicture.asset(path),
                          );
                          final tapPosition = details.globalPosition;
                          final stickerWidgetBox = LindiStickerWidget.globalKey.currentContext?.findRenderObject() as RenderBox?;
                          Alignment initialPosition = Alignment.center;
                          if (stickerWidgetBox != null) {
                            final stickerSize = stickerWidgetBox.size;
                            final stickerOffset = stickerWidgetBox.localToGlobal(Offset.zero);
                            final alignmentX = ((tapPosition.dx - stickerOffset.dx) / stickerSize.width) * 2 - 1;
                            final alignmentY = ((tapPosition.dy - stickerOffset.dy) / stickerSize.height) * 2 - 1;
                            initialPosition = Alignment(alignmentX.clamp(-1.0, 1.0), alignmentY.clamp(-1.0, 1.0));
                          } else {
                            print('Warning: LindiStickerWidget.globalKey is null, using default position');
                          }
                          print('Tapped at position: $initialPosition (dx: ${tapPosition.dx}, dy: ${tapPosition.dy})');
                          _addWidget(newWidget, initialPosition: initialPosition);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade800,
                              ),
                              child: SvgPicture.asset(path),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }).toList(),
              ),
            ),
            ValueListenableBuilder<int>(
              valueListenable: selectedTabIndex,
              builder: (context, currentIndex, _) {
                return TabBar(
                  onTap: (index) => selectedTabIndex.value = index,
                  isScrollable: true,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  tabs: widget.shapeCategories.keys.map((category) {
                    final index = widget.shapeCategories.keys.toList().indexOf(category);
                    return Tab(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: index == currentIndex
                              ? const Color(0xFF6200EE)
                              : const Color(0xFF424242),
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: index == currentIndex ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _undoStack.isNotEmpty ? _undo : null,
                        child: Opacity(
                          opacity: _undoStack.isNotEmpty ? 1.0 : 0.5,
                          child: Image.asset('assets/undo.png', height: 40),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _redoStack.isNotEmpty ? _redo : null,
                        child: Opacity(
                          opacity: _redoStack.isNotEmpty ? 1.0 : 0.5,
                          child: Image.asset('assets/redo.png', height: 40),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          stickerController.clearStickers();
                          flippedBytes.value = null;
                          showStickerEditOptions.value = false;
                          editedImageBytes.value = null;
                          _undoStack.clear();
                          _redoStack.clear();
                          widget.controller.widgets.clear();
                          widget.controller.clearAllBorders();
                          setState(() {});
                          widget.controller.notifyListeners();
                        },
                        child: SizedBox(
                          height: 40,
                          child: Image.asset('assets/cross.png'),
                        ),
                      ),
                    ],
                  ),
                  const Text(
                    'Sticker',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      editorController.showEditOptions.value = false;
                      editorController.showStickerEditOptions.value = false;
                      if (flippedBytes.value != null) {
                        final tempDir = await getTemporaryDirectory();
                        final path =
                            '${tempDir.path}/confirmed_${DateTime.now().millisecondsSinceEpoch}.jpg';
                        final file = File(path);
                        await file.writeAsBytes(flippedBytes.value!);
                        editedImage.value = file;
                        editedImageBytes.value = null;
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}







/// Mock class for color constants (replace with actual implementation).









