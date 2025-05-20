import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/Collage/collage_controller.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_filter.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stciker_model.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
import 'package:image_editor/screens_ui/save_file/save_image_screen.dart';
import 'package:image_editor/screens_ui/save_file/saved_image_model.dart';
import 'package:image_editor/undo_redo_add/sticker_screen.dart';
import 'package:image_editor/undo_redo_add/undo_redo_controller.dart';
import 'package:lindi_sticker_widget/draggable_widget.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_icon.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';

class ImageEditorScreen extends StatefulWidget {
  @override
  _ImageEditorScreenState createState() => _ImageEditorScreenState();
}

class _ImageEditorScreenState extends State<ImageEditorScreen> {
  final ImageEditorController _controller = Get.put(ImageEditorController());
  final ImageFilterController filterController = Get.put(ImageFilterController());
  final StickerController stickerController = Get.put(StickerController());
  final CollageController collageController = Get.put(CollageController());
  final TextEditorControllerWidget textEditorControllerWidget = Get.put(TextEditorControllerWidget());
  final TemplateController collageTemplateController = Get.put(TemplateController());
  final GlobalKey _imageKey = GlobalKey();
  late GlobalKey _repaintKey;
  // Map to store widget keys and their associated models
  final Map<Key, dynamic> _widgetModels = {};

  @override
  void initState() {
    super.initState();
    _repaintKey = GlobalKey();
    // Initialize LindiController
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
            final selectedWidget = _controller.controller.selectedWidget;
            if (selectedWidget != null) {
              final model = _widgetModels[selectedWidget.key];
              if (model is StickerModel) {
                stickerController.stickers.remove(model);
              } else if (model is EditableTextModel) {
                textEditorControllerWidget.text.remove(model);
              }
              _widgetModels.remove(selectedWidget.key);
              selectedWidget.delete();
            }
          },
        ),
        LindiStickerIcon(
          icon: Icons.flip,
          alignment: Alignment.bottomLeft,
          onTap: () {
            _controller.controller.selectedWidget?.flip();
          },
        ),
        LindiStickerIcon(
          icon: Icons.crop_free,
          alignment: Alignment.bottomRight,
          type: IconType.resize,
        ),
      ],
    );

    // Track position changes during dragging
    _controller.controller.onPositionChange((index) {
      if (index >= 0 && index < _controller.controller.widgets.length) {
        _controller.indexvalueOnChange.value = index;
        print('index value=====${_controller.indexvalueOnChange.value}');
        final DraggableWidget widget = _controller.controller.widgets[index];
        final Key widgetKey = widget.key!;
        debugPrint('Widget $index (key: $widgetKey) moved.');

        // Debug DraggableWidget properties
        debugPrint('Widget properties: ${widget.toString()}');

        // Get canvas size and position
        final RenderBox? canvasBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
        if (canvasBox != null) {
          final Size canvasSize = canvasBox.size;
          final Offset canvasPosition = canvasBox.localToGlobal(Offset.zero);
          debugPrint('Canvas size: width=${canvasSize.width}, height=${canvasSize.height}');
          debugPrint('Canvas position: x=${canvasPosition.dx}, y=${canvasPosition.dy}');

          // Get widget position using GlobalKey
          final GlobalKey widgetKey = widget.centerKey ;
          final RenderBox? widgetBox = widgetKey.currentContext?.findRenderObject() as RenderBox?;
          if (widgetBox != null) {
            final Offset widgetPosition = widgetBox.localToGlobal(Offset.zero);
            // Calculate position relative to canvas
            final double x = widgetPosition.dx - canvasPosition.dx;
            final double y = widgetPosition.dy - canvasPosition.dy;
            debugPrint('Widget $index position: x=$x, y=$y');

            // Update corresponding model
            final model = _widgetModels[widgetKey];
            if (model is StickerModel) {
              model.left.value = x;
              model.top.value = y;
              debugPrint('Updated Sticker $index: top=${model.top.value}, left=${model.left.value}');
            } else if (model is EditableTextModel) {
              model.left = x.obs;
              model.top = y.obs;
              debugPrint('Updated Text ${index - stickerController.stickers.length}: top=${model.top}, left=${model.left}');
            }
          } else {
            debugPrint('Failed to get widget RenderBox for key: $widgetKey');
          }
        } else {
          debugPrint('Failed to get canvas RenderBox');
        }

        // Attempt to find position via DraggableWidget properties
        try {
          debugPrint('Check DraggableWidget source for transform/offset properties.');
        } catch (e) {
          debugPrint('Error accessing widget $index properties: $e');
        }
      } else {
        debugPrint('Invalid index: $index');
      }
    });

    // Reset controllers
    stickerController.stickers.clear();
    textEditorControllerWidget.text.clear();
    _widgetModels.clear();
  }

  @override
  void dispose() {
    _controller.controller.widgets.clear();
    stickerController.stickers.clear();
    textEditorControllerWidget.text.clear();
    _widgetModels.clear();
    super.dispose();
  }

  Future<Uint8List?> captureView() async {
    try {
      print('Stickers: ${stickerController.stickers.length}, Text: ${textEditorControllerWidget.text.length}');
      print('LindiController widgets: ${_controller.controller.widgets.length}');

      stickerController.selectedSticker.value = null;
      textEditorControllerWidget.clearSelection();

      await Future.delayed(Duration(milliseconds: 200));

      final RenderRepaintBoundary? boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
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

  Future<void> saveImage() async {
    try {
      final Uint8List? capturedImage = await captureView();
      if (capturedImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        final filePath = path.join(directory.path, 'image_${DateTime.now().millisecondsSinceEpoch}.png');
        final file = File(filePath);
        await file.writeAsBytes(capturedImage);

        final dbHelper = DatabaseHelper.instance;
        await dbHelper.saveImage(filePath);
        Get.snackbar("Success", "Image saved successfully");
        Get.off(() => SavedImagesScreen());
      } else {
        Get.snackbar("Error", "Failed to capture image");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to save image: $e");
    }
  }

  Future<void> saveTemplate() async {
    try {
      final Uint8List? capturedImage = await captureView();
      if (capturedImage != null) {
        final directory = await getApplicationDocumentsDirectory();
        _controller.filePath.value = path.join(directory.path, 'image_${DateTime.now().millisecondsSinceEpoch}.png');
        final file = File(_controller.filePath.value!);
        await file.writeAsBytes(capturedImage);
        Get.snackbar("Success", "Image saved successfully");
      } else {
        Get.snackbar("Error", "Failed to capture image");
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to save image: $e");
    }

    try {
      final File? imageFile = _controller.editedImage.value;
      if (imageFile == null || imageFile.path.isEmpty) {
        Get.snackbar("Error", "No image to save as template");
        return;
      }
      if ( _controller.indexvalueOnChange.value >= 0 &&  _controller.indexvalueOnChange.value < _controller.controller.widgets.length) {
        // _controller.indexvalueOnChange.value = index;
        // print('index value=====${_controller.indexvalueOnChange.value}');
        final DraggableWidget widget = _controller.controller.widgets[ _controller.indexvalueOnChange.value];
        final Key widgetKey = widget.key!;
        debugPrint('Widget ${_controller.indexvalueOnChange.value} (key: $widgetKey) moved.');

        // Debug DraggableWidget properties
        debugPrint('Widget properties: ${widget.toString()}');

        // Get canvas size and position
        final RenderBox? canvasBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
        if (canvasBox != null) {
          final Size canvasSize = canvasBox.size;
          final Offset canvasPosition = canvasBox.localToGlobal(Offset.zero);
          debugPrint('Canvas size: width=${canvasSize.width}, height=${canvasSize.height}');
          debugPrint('Canvas position: x=${canvasPosition.dx}, y=${canvasPosition.dy}');

          // Get widget position using GlobalKey
          final GlobalKey widgetKey = widget.centerKey ;
          final RenderBox? widgetBox = widgetKey.currentContext?.findRenderObject() as RenderBox?;
          if (widgetBox != null) {
            final Offset widgetPosition = widgetBox.localToGlobal(Offset.zero);
            // Calculate position relative to canvas
            final double x = widgetPosition.dx - canvasPosition.dx;
            final double y = widgetPosition.dy - canvasPosition.dy;
            debugPrint('Widget ${ _controller.indexvalueOnChange.value} position: x=$x, y=$y');

            // Update corresponding model
            final model = _widgetModels[widgetKey];
            if (model is StickerModel) {
              model.left.value = x;
              model.top.value = y;
              debugPrint('Updated Sticker ${ _controller.indexvalueOnChange.value}: top=${model.top.value}, left=${model.left.value}');
            } else if (model is EditableTextModel) {
              model.left = x.obs;
              model.top = y.obs;
              debugPrint('Updated Text ${ _controller.indexvalueOnChange.value} - stickerController.stickers.length}: top=${model.top}, left=${model.left}');
            }
          } else {
            debugPrint('Failed to get widget RenderBox for key: $widgetKey');
          }
        } else {
          debugPrint('Failed to get canvas RenderBox');
        }

        // Attempt to find position via DraggableWidget properties
        try {
          debugPrint('Check DraggableWidget source for transform/offset properties.');
        } catch (e) {
          debugPrint('Error accessing widget ${ _controller.indexvalueOnChange.value} properties: $e');
        }
      } else {
        debugPrint('Invalid index: ${ _controller.indexvalueOnChange.value}');}
      final editingState = {
        'imagePath': imageFile.path,
        'stickers': stickerController.stickers.map((sticker) => {
          'path': sticker.path,
          'top': sticker.top.value,
          'left': sticker.left.value,
          'scale': sticker.scale.value,
          'rotation': sticker.rotation.value,
          'isFlipped': sticker.isFlipped.value,
        }).toList(),
        'text': textEditorControllerWidget.text.map((textModel) => {
          'text': textModel.text,
          'top': textModel.top,
          'left': textModel.left,
          'fontSize': textModel.fontSize,
          'fontFamily': textModel.fontFamily,
          'textColor': textModel.textColor.value,
          'backgroundColor': textModel.backgroundColor.value,
          'opacity': textModel.opacity,
          'isBold': textModel.isBold,
          'isItalic': textModel.isItalic,
          'isUnderline': textModel.isUnderline,
          'isStrikethrough': textModel.isStrikethrough,
          'shadowBlur': textModel.shadowBlur,
          'shadowColor': textModel.shadowColor.value,
          'shadowOffsetX': textModel.shadowOffsetX,
          'shadowOffsetY': textModel.shadowOffsetY,
          'rotation': textModel.rotation,
          'isFlippedHorizontally': textModel.isFlippedHorizontally,
          'textAlign': textModel.textAlign.toString(),
        }).toList(),
        'filters': {
          'brightness': _controller.brightness.value,
          'contrast': _controller.contrast.value,
        },
        'transformations': {
          'scale': _controller.scale.value,
          'offset': {
            'dx': _controller.offset.value.dx,
            'dy': _controller.offset.value.dy,
          },
        },
      };
      print('=============editingState=========${editingState}');
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.saveTemplate('Template_${DateTime.now().millisecondsSinceEpoch}', editingState, _controller.filePath.value!);
      Get.snackbar("Success", "Template saved successfully");
      Get.off(() => SavedImagesScreen());
    } catch (e) {
      Get.snackbar("Error", "Failed to save template: $e");
      print("Error saving template: $e");
    }
  }

  void _loadSavedState(Map<String, dynamic> state) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      // Restore image
      final String? imagePath = state['imagePath'];
      if (imagePath != null && imagePath.isNotEmpty && File(imagePath).existsSync()) {
        final File imageFile = File(imagePath);
        _controller.setInitialImage(imageFile);
        _controller.decodeEditedImage();
        filterController.setInitialImage(imageFile);
      } else {
        Get.snackbar("Error", "Image file not found");
      }

      // Clear existing widgets
      stickerController.stickers.clear();
      _controller.controller.widgets.clear();
      textEditorControllerWidget.text.clear();
      _widgetModels.clear();

      // Restore stickers
      for (var stickerData in state['stickers'] ?? []) {
        final sticker = StickerModel(
          path: stickerData['path'] ?? '',
          top: RxDouble(stickerData['top']?.toDouble() ?? 0.0),
          left: RxDouble(stickerData['left']?.toDouble() ?? 0.0),
          scale: RxDouble(stickerData['scale']?.toDouble() ?? 1.0),
          rotation: RxDouble(stickerData['rotation']?.toDouble() ?? 0.0),
          isFlipped: RxBool(stickerData['isFlipped'] ?? false),
        );
        final GlobalKey widgetKey = GlobalKey();
        print('===========before adding to lindi sticker widget=====${stickerData['path']}');
        print('===========before adding to lindi sticker widget=====${stickerData['top']}');
        print('===========before adding to lindi sticker widget=====${stickerData['left']}');
        Widget widget = Container(
          key: widgetKey,
          height: 60,
          width: 60,
          child: (stickerData['path'].toString().contains('svg'))
              ? SvgPicture.asset(stickerData['path'])
              : Image.file(File(stickerData['path'])),
        );
        final alignment = Alignment(
          (stickerData['left'] / _controller.canvasWidth.value) * 2 - 1,
          (stickerData['top'] / _controller.canvasHeight.value) * 2 - 1,
        );

        _controller.controller.add(widget, position: alignment);
        stickerController.stickers.add(sticker);
        _widgetModels[widgetKey] = sticker;
      }

      // Restore text
      for (var textData in state['text'] ?? []) {
        final textModel = EditableTextModel(
          text: textData['text'] ?? '',
          top: textData['top']?.toDouble() ?? 0.0,
          left: textData['left']?.toDouble() ?? 0.0,
          fontSize: textData['fontSize']?.toDouble() ?? 16.0,
          fontFamily: textData['fontFamily'] ?? 'Roboto',
          textColor: Color(textData['textColor'] ?? Colors.black.value),
          backgroundColor: Color(textData['backgroundColor'] ?? Colors.transparent.value),
          opacity: textData['opacity']?.toDouble() ?? 1.0,
          isBold: textData['isBold'] ?? false,
          isItalic: textData['isItalic'] ?? false,
          isUnderline: textData['isUnderline'] ?? false,
          isStrikethrough: textData['isStrikethrough'] ?? false,
          shadowBlur: textData['shadowBlur']?.toDouble() ?? 0.0,
          shadowColor: Color(textData['shadowColor'] ?? Colors.black.value),
          shadowOffsetX: textData['shadowOffsetX']?.toDouble() ?? 0.0,
          shadowOffsetY: textData['shadowOffsetY']?.toDouble() ?? 0.0,
          rotation: textData['rotation']?.toDouble() ?? 0.0,
          isFlippedHorizontally: textData['isFlippedHorizontally'] ?? false,
          textAlign: TextAlign.values.firstWhere(
                (e) => e.toString() == textData['textAlign'],
            orElse: () => TextAlign.left,
          ),
        );
        final GlobalKey widgetKey = GlobalKey();
        textEditorControllerWidget.text.add(textModel);
        _controller.controller.add(
          Container(
            key: widgetKey,
            child: Transform(
              transform: Matrix4.identity()
                ..translate(textModel.left, textModel.top.value)
                ..rotateZ(textModel.rotation.value)
                ..scale(textModel.isFlippedHorizontally.value ? -1.0 : 1.0, 1.0),
              child: Text(
                textModel.text.value,
                style: GoogleFonts.getFont(
                  textModel.fontFamily.value,
                  fontSize: textModel.fontSize.toDouble(),
                  color: textModel.textColor.value.withOpacity(textModel.opacity.value),
                  fontWeight: textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
                  fontStyle: textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
                  decoration: textModel.isUnderline.value ? TextDecoration.underline : TextDecoration.none,
                  shadows: [
                    Shadow(
                      blurRadius: textModel.shadowBlur.value,
                      color: textModel.shadowColor.value,
                      offset: Offset(textModel.shadowOffsetX.value, textModel.shadowOffsetY.value),
                    ),
                  ],
                ),
                textAlign: textModel.textAlign.value,
              ),
            ),
          ),
          position: Alignment(
            (textModel.left / _controller.canvasWidth.value) * 2 - 1,
            (textModel.top / _controller.canvasHeight.value) * 2 - 1,
          ),
        );
        _widgetModels[widgetKey] = textModel;
      }

      // Restore filters
      _controller.brightness.value = state['filters']?['brightness']?.toDouble() ?? 0.0;
      _controller.contrast.value = state['filters']?['contrast']?.toDouble() ?? 1.0;

      // Restore transformations
      _controller.scale.value = state['transformations']?['scale']?.toDouble() ?? 1.0;
      _controller.offset.value = Offset(
        state['transformations']?['offset']?['dx']?.toDouble() ?? 0.0,
        state['transformations']?['offset']?['dy']?.toDouble() ?? 0.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamic imageArg = Get.arguments;
    File? fileImage;
    Uint8List? memoryImage;
    Map<String, dynamic>? savedState;

    if (imageArg is File) {
      fileImage = imageArg;
    } else if (imageArg is Uint8List) {
      memoryImage = imageArg;
    } else if (imageArg is Map<String, dynamic>) {
      savedState = imageArg;
      fileImage = File(savedState['imagePath'] ?? '');
    }

    if (savedState != null) {
      _loadSavedState(savedState);
    } else {
      _controller.setInitialImage(fileImage ?? File(''));
      _controller.decodeEditedImage();
      filterController.setInitialImage(fileImage ?? File(''));
    }

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
                      _controller.undo();
                    },
                    icon: Icon(Icons.undo, color: Colors.white),
                  ),
                  SizedBox(width: 10),
                  IconButton(
                    onPressed: () {
                      _controller.redo();
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
                      child: Image.asset(
                        'assets/image_layer.png',
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.image, color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 25),
                  SizedBox(
                    height: 20,
                    child: GestureDetector(
                      onTap: saveTemplate,
                      child: Image.asset(
                        'assets/template.png',
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.save, color: Colors.white),
                      ),
                    ),
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
                          print("Error sharing image: $e");
                        }
                      },
                      child: Image.asset(
                        'assets/Export.png',
                        errorBuilder: (context, error, stackTrace) => Icon(Icons.share, color: Colors.white),
                      ),
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
              final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final position = renderBox.localToGlobal(Offset.zero);
                final size = renderBox.size;
                _controller.canvasWidth.value = size.width;
                _controller.canvasHeight.value = size.height;
                print('Image bounds: position=($position), size=($size)');
              }
            });
            return Obx(() {
              final Uint8List? editedMemoryImage = _controller.editedImageBytes.value;
              final File? editedFileImage = _controller.editedImage.value;
              print('Rebuilding ImageEditorScreen UI, text count: ${textEditorControllerWidget.text.length}');
              return Stack(
                children: [
                  Container(
                    height: constraints.maxHeight,
                    child: (_controller.isSelectingText.value == true)
                        ? SingleChildScrollView(
                      child: Container(
                        height: constraints.maxHeight,
                        child: Column(
                          children: [
                            Expanded(
                              child: Obx(() {
                                bool isAnyEditOpen = _controller.showEditOptions.value ||
                                    _controller.showFilterEditOptions.value ||
                                    _controller.showStickerEditOptions.value ||
                                    _controller.showtuneOptions.value;
                                return ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: constraints.maxWidth,
                                    maxHeight: constraints.maxHeight,
                                  ),
                                  child: RepaintBoundary(
                                    key: _repaintKey,
                                    child: LindiStickerWidget(
                                      controller: _controller.controller,
                                      child: AnimatedContainer(
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
                                              child: editedMemoryImage != null
                                                  ? Image.memory(
                                                editedMemoryImage,
                                                fit: BoxFit.contain,
                                              )
                                                  : (editedFileImage != null && editedFileImage.path.isNotEmpty
                                                  ? Image.file(
                                                editedFileImage,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) => Text(
                                                  "Error loading image",
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              )
                                                  : (memoryImage != null
                                                  ? Image.memory(
                                                memoryImage,
                                                fit: BoxFit.contain,
                                              )
                                                  : (fileImage != null && fileImage.path.isNotEmpty
                                                  ? Image.file(
                                                fileImage,
                                                fit: BoxFit.contain,
                                                errorBuilder: (context, error, stackTrace) => Text(
                                                  "Error loading image",
                                                  style: TextStyle(color: Colors.white),
                                                ),
                                              )
                                                  : Text(
                                                "No image loaded",
                                                style: TextStyle(color: Colors.white),
                                              )))),
                                            ),
                                            )],
                                          ),
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
                                !collageController.showCollageOption.value &&
                                !_controller.showPresetsEditOptions.value &&
                                !_controller.showImageLayer.value)
                              _buildToolBar(context),
                            if (_controller.showEditOptions.value) _controller.buildEditControls(),
                            if (_controller.showStickerEditOptions.value)
                              ShapeSelectorSheet(
                                controller: _controller.controller,
                                shapeCategories: _controller.shapeCategories,
                              ),
                            if (_controller.showImageLayer.value) _controller.buildImageLayerSheet(),
                            if (_controller.showtuneOptions.value) _controller.TuneEditControls(),
                            if (_controller.TextEditOptions.value)
                              _controller.TextEditControls(constraints, _imageKey),
                            if (_controller.CameraEditSticker.value) _controller.buildEditCamera(),
                            if (collageController.showCollageOption.value)
                              collageTemplateController.openTemplatePickerBottomSheet(),
                            if (_controller.showFilterEditOptions.value)
                              _controller.buildFilterControlsSheet(onClose: () {
                                _controller.showFilterEditOptions.value = false;
                              }),
                            if (_controller.showPresetsEditOptions.value)
                              _controller.showFilterControlsBottomSheet(context, () {
                                _controller.showFilterEditOptions.value = false;
                              }),
                          ],
                        ),
                      ),
                    )
                        : Column(
                      children: [
                        Expanded(
                          child: Obx(() {
                            bool isAnyEditOpen = _controller.showEditOptions.value ||
                                _controller.showFilterEditOptions.value ||
                                _controller.showStickerEditOptions.value ||
                                _controller.showtuneOptions.value;
                            return ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth,
                                maxHeight: constraints.maxHeight,
                              ),
                              child: RepaintBoundary(
                                key: _repaintKey,
                                child: LindiStickerWidget(
                                  controller: _controller.controller,
                                  child: AnimatedContainer(
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.easeInOut,
                                    transform: Matrix4.translationValues(0, isAnyEditOpen ? 20 : 0, 0)
                                      ..scale(isAnyEditOpen ? 0.94 : 1.0),
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 10),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          GestureDetector(
                                            onScaleStart: (details) {
                                              _controller.baseScale.value = _controller.scale.value;
                                            },
                                            onScaleUpdate: (details) {
                                              final newScale = (_controller.baseScale.value * details.scale).clamp(1.0, 5.0);
                                              _controller.scale.value = newScale;
                                            },
                                            child: Obx(() {
                                              return Transform.translate(
                                                  offset: _controller.offset.value,
                                                  child: Transform.scale(
                                                  scale: _controller.scale.value,
                                                  child: Container(
                                                  key: _imageKey,
                                                  child: ColorFiltered(
                                                  colorFilter: ColorFilter.matrix(
                                                  _controller.calculateColorMatrix(),
                                              ),
                                              child: editedMemoryImage != null
                                              ? Image.memory(
                                              editedMemoryImage,
                                              fit: BoxFit.contain,
                                              )
                                                  : (editedFileImage != null && editedFileImage.path.isNotEmpty
                                              ? Image.file(
                                              editedFileImage,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) => Text(
                                              "Error loading image",
                                              style: TextStyle(color: Colors.white),
                                              ),
                                              )
                                                  : (memoryImage != null
                                              ? Image.memory(
                                              memoryImage,
                                              fit: BoxFit.contain,
                                              )
                                                  : (fileImage != null && fileImage.path.isNotEmpty
                                              ? Image.file(
                                              fileImage,
                                              fit: BoxFit.contain,
                                              errorBuilder: (context, error, stackTrace) => Text(
                                              "Error loading image",
                                              style: TextStyle(color: Colors.white),
                                              ),
                                              )
                                                  : Text(
                                              "No image loaded",
                                              style: TextStyle(color: Colors.white),
                                              )))),
                                              ),
                                              ),
                                              ));
                                            }),
                                          ),
                                        ],
                                      ),
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
                        if (_controller.showEditOptions.value) _controller.buildEditControls(),
                        if (_controller.showStickerEditOptions.value)
                          ShapeSelectorSheet(
                            controller: _controller.controller,
                            shapeCategories: _controller.shapeCategories,
                          ),
                        if (_controller.showImageLayer.value) _controller.buildImageLayerSheet(),
                        if (_controller.showtuneOptions.value) _controller.TuneEditControls(),
                        if (_controller.TextEditOptions.value)
                          _controller.TextEditControls(constraints, _imageKey),
                        if (_controller.CameraEditSticker.value) _controller.buildEditCamera(),
                        if (collageController.showCollageOption.value)
                          collageTemplateController.openTemplatePickerBottomSheet(),
                        if (_controller.showFilterEditOptions.value)
                          _controller.buildFilterControlsSheet(onClose: () {
                            _controller.showFilterEditOptions.value = false;
                          }),
                        if (_controller.showPresetsEditOptions.value)
                          _controller.showFilterControlsBottomSheet(context, () {
                            _controller.showFilterEditOptions.value = false;
                          }),
                      ],
                    ),
                  ),
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
            _controller.buildToolButton('Pres  ets', 'assets/presets.png', () {
              _controller.showPresetsEditOptions.value = true;
            }),
          ],
        ),
      ),
    );
  }
}