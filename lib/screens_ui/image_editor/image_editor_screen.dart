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

  late GlobalKey _repaintKey;
  DateTime? _interactionStartTime;
  Offset? _lastPosition;
  static const _tapDurationThreshold = Duration(milliseconds: 300);
  static const _tapDistanceThreshold = 5.0; // Pixels

  @override
  void initState() {
    super.initState();
    _repaintKey = GlobalKey();

    // Initialize LindiController
    _controller.controller = LindiController(
      borderColor: Colors.blue,
      shouldRotate: true,
      // showBorders: false, // Borders off by default
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
            debugPrint('Cleared all borders');
          },
        ),
        LindiStickerIcon(
          icon: Icons.close,
          alignment: Alignment.topLeft,
          onTap: () {
            final selectedWidget = _controller.controller.selectedWidget;
            if (selectedWidget != null) {
              final model = _controller.widgetModels[selectedWidget.key];
              if (model is StickerModel) {
                stickerController.stickers.remove(model);
              } else if (model is EditableTextModel) {
                textEditorControllerWidget.text.remove(model);
              }
              _controller.widgetModels.remove(selectedWidget.key);
              selectedWidget.delete();
              debugPrint('Deleted widget: key=${selectedWidget.key}');
            }
          },
        ),
        LindiStickerIcon(
          icon: Icons.flip,
          alignment: Alignment.bottomLeft,
          onTap: () {
            _controller.controller.selectedWidget?.flip();
            debugPrint('Flipped selected widget');
          },
        ),
        LindiStickerIcon(
          icon: Icons.crop_free,
          alignment: Alignment.bottomRight,
          type: IconType.resize,
        ),
      ],
    );

    // Initialize canvas size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('=============enter========');
      final RenderBox? canvasBox = _controller.imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (canvasBox != null) {
        final size = canvasBox.size;
        _controller.canvasWidth.value = size.width;
        _controller.canvasHeight.value = size.height;
        _controller.lastValidCanvasSize = size;
        debugPrint('Initialized canvas size: $size');
      } else {
        debugPrint('Canvas RenderBox not available, using fallback size');
        _controller.lastValidCanvasSize = Size(360, 705); // Moto g34 5G
      }
    });

    // Set up position change listener
    _controller.controller.onPositionChange((index) {
      if (index >= 0 && index < _controller.controller.widgets.length) {
        _controller.indexvalueOnChange.value = index;
        debugPrint('index value=====$index');

        final DraggableWidget widget = _controller.controller.widgets[index];
        GlobalKey? widgetKey;

        // Log all widget keys to detect duplicates
        final keyCounts = <Key, int>{};
        for (var w in _controller.controller.widgets) {
          keyCounts[w.key!] = (keyCounts[w.key] ?? 0) + 1;
        }
        keyCounts.forEach((key, count) {
          if (count > 1) {
            debugPrint('Warning: Duplicate key detected: $key, count: $count');
          }
        });

        if (widget.key is GlobalKey) {
          widgetKey = widget.key as GlobalKey;
          debugPrint('Widget $index (key: $widgetKey) interaction detected.');
        }
        else {
          debugPrint('Warning: Widget $index has unsupported key type: ${widget.key.runtimeType}');
          // Attempt to recover GlobalKey from widgetModels
          final model = _controller.widgetModels.values.firstWhere(
                (m) =>
            (m is StickerModel && stickerController.stickers.contains(m)) ||
                (m is EditableTextModel && textEditorControllerWidget.text.contains(m)),
            orElse: () => null,
          );
          if (model != null && model.widgetKey is GlobalKey) {
            widgetKey = model.widgetKey as GlobalKey;
            debugPrint('Recovered key for widget $index: $widgetKey');
          } else {
            debugPrint('Failed to recover key for widget $index, skipping');
            return;
          }
        }

        final model = _controller.widgetModels[widgetKey];
        if (model == null) {
          debugPrint('No model found for widget $index (key: $widgetKey)');
          return;
        }

        // Show border for the tapped widget
        _controller.controller.clearAllBorders(); // Clear existing borders
        _controller.controller.showBorders = true; // Select the tapped widget to show border
        debugPrint('Showing border for widget $index (key: $widgetKey)');

        final RenderBox? canvasBox = _controller.imageKey.currentContext?.findRenderObject() as RenderBox?;
        if (canvasBox == null) {
          debugPrint('Failed to get canvas RenderBox');
          return;
        }
        final Size canvasSize = canvasBox.size;
        if (canvasSize.width == 0 || canvasSize.height == 0) {
          debugPrint('Invalid canvas size: $canvasSize, using last valid size: ${_controller.lastValidCanvasSize}');
          if (_controller.lastValidCanvasSize == null) return;
        } else {
          _controller.lastValidCanvasSize = canvasSize;
        }
        final Offset canvasPosition = canvasBox.localToGlobal(Offset.zero);

        final RenderBox? widgetBox = widgetKey.currentContext?.findRenderObject() as RenderBox?;
        if (widgetBox == null) {
          debugPrint('Failed to get widget RenderBox for key: $widgetKey');
          return;
        }
        final Offset widgetPosition = widgetBox.localToGlobal(Offset.zero);
        final double x = widgetPosition.dx - canvasPosition.dx;
        final double y = widgetPosition.dy - canvasPosition.dy;
        debugPrint('Widget $index position: x=$x, y=$y');

        if (_interactionStartTime == null) {
          _interactionStartTime = DateTime.now();
          _lastPosition = Offset(x, y);
          debugPrint('Interaction started at: $_interactionStartTime, position: $_lastPosition');
        }

        if (model is StickerModel) {
          model.left.value = x;
          model.top.value = y;
          stickerController.selectSticker(model);
          debugPrint('Updated Sticker $index: top=${model.top.value}, left=${model.left.value}');
        } else if (model is EditableTextModel) {
          model.left.value = x; // Non-reactive double
          model.top.value = y; // Non-reactive double
          // Do NOT select text or fill text controller
          debugPrint('Updated Text ${index - stickerController.stickers.length}: top=${model.top}, left=${model.left}, text=${model.text.value}');

          final duration = DateTime.now().difference(_interactionStartTime!);
          final distance = (_lastPosition! - Offset(x, y)).distance;
          debugPrint('Interaction duration: $duration, distance: $distance');

          // Do NOT open TextUIWithTabsScreen or fill text field on tap
          if (duration < _tapDurationThreshold && distance < _tapDistanceThreshold) {
            debugPrint('Detected tap on text widget: text=${model.text.value}, border shown, no text selection');
          } else {
            debugPrint('Detected drag on text widget: position updated, no text selection');
          }
        }

        _lastPosition = Offset(x, y);

        Future.delayed(_tapDurationThreshold, () {
          if (_interactionStartTime != null &&
              DateTime.now().difference(_interactionStartTime!) >= _tapDurationThreshold) {
            debugPrint('Interaction ended, resetting tap detection');
            _interactionStartTime = null;
            _lastPosition = null;
          }
        });
      } else {
        debugPrint('Invalid index: $index');
      }
    });

    // Clear state
    stickerController.stickers.clear();
    textEditorControllerWidget.text.clear();
    _controller.widgetModels.clear();
  }

  @override
  void dispose() {
    _controller.controller.widgets.clear();
    _controller.widgetModels.clear();
    stickerController.stickers.clear();
    textEditorControllerWidget.text.clear();
    _controller.controller.clearAllBorders();
    debugPrint('Disposed ImageEditorScreen, cleared all widgets and models');
    super.dispose();
  }

  Future<Uint8List?> captureView() async {
    try {
      debugPrint('Stickers: ${stickerController.stickers.length}, Text: ${textEditorControllerWidget.text.length}');
      debugPrint('LindiController widgets: ${_controller.controller.widgets.length}');

      if (!_controller.TextEditOptions.value) {
        stickerController.selectedSticker.value = null;
        textEditorControllerWidget.clearSelection();
      }

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
        final filePath = path.join(directory.path, 'image_${DateTime.now().millisecondsSinceEpoch}.png');
        final file = File(filePath);
        await file.writeAsBytes(capturedImage);
        _controller.filePath.value = filePath;
        Get.snackbar("Success", "Image saved successfully");
      } else {
        Get.snackbar("Error", "Failed to capture image");
        return;
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to save image: $e");
      debugPrint("Error saving image: $e");
      return;
    }

    try {
      final File? imageFile = _controller.editedImage.value;
      if (imageFile == null || imageFile.path.isEmpty) {
        Get.snackbar("Error", "No image to save as template");
        return;
      }

      final RenderBox? canvasBox = _controller.imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (canvasBox == null) {
        debugPrint('Failed to get canvas RenderBox');
        Get.snackbar("Error", "Failed to get canvas information");
        return;
      }
      final Size canvasSize = canvasBox.size;
      final Offset canvasPosition = canvasBox.localToGlobal(Offset.zero);
      debugPrint('Canvas size: width=${canvasSize.width}, height=${canvasSize.height}');
      debugPrint('Canvas position: x=${canvasPosition.dx}, y=${canvasPosition.dy}');

      final List<Map<String, dynamic>> stickerDataList = [];
      debugPrint('Total widgets: ${_controller.controller.widgets.length}');
      debugPrint('Total stickers in controller: ${stickerController.stickers.length}');
      debugPrint('Widget models: ${_controller.widgetModels.length}');

      _controller.widgetModels.forEach((widgetKey, model) {
        debugPrint('Processing model, key: $widgetKey, model: ${model.runtimeType}');

        if (model is StickerModel && widgetKey is GlobalKey) {
          final RenderBox? widgetBox = widgetKey.currentContext?.findRenderObject() as RenderBox?;
          double xPosition = model.left.value;
          double yPosition = model.top.value;

          if (widgetBox != null) {
            final Offset widgetPosition = widgetBox.localToGlobal(Offset.zero);
            xPosition = widgetPosition.dx - canvasPosition.dx;
            yPosition = widgetPosition.dy - canvasPosition.dy;
            model.left.value = xPosition;
            model.top.value = yPosition;
            debugPrint('Sticker position: key=$widgetKey, x=$xPosition, y=$yPosition');
            _controller.xvalue.value = xPosition;
            _controller.yvalue.value = yPosition;
          } else {
            debugPrint('Warning: RenderBox for key $widgetKey is null, using model values');
          }

          stickerDataList.add({
            'path': model.path,
            'top': yPosition,
            'left': xPosition,
            'scale': model.scale.value,
            'rotation': model.rotation.value,
            'isFlipped': model.isFlipped.value,
          });
        } else {
          debugPrint('Skipping model, key: $widgetKey, type: ${model?.runtimeType ?? "null"}, isStickerModel: ${model is StickerModel}');
        }
      });

      final List<Map<String, dynamic>> textDataList = [];
      debugPrint('Total text models: ${textEditorControllerWidget.text.length}');

      textEditorControllerWidget.text.asMap().forEach((index, textModel) {
        debugPrint('Processing text model $index, type: ${textModel.runtimeType}');

        double xPosition = textModel.left.value;
        double yPosition = textModel.top.value;

        if (textModel.widgetKey != null) {
          final RenderBox? textBox = textModel.widgetKey!.currentContext?.findRenderObject() as RenderBox?;
          if (textBox != null) {
            final Offset textPosition = textBox.localToGlobal(Offset.zero);
            xPosition = textPosition.dx - canvasPosition.dx;
            yPosition = textPosition.dy - canvasPosition.dy;
            textModel.left.value = xPosition;
            textModel.top.value = yPosition;
            debugPrint('Text $index position: key=${textModel.widgetKey}, x=$xPosition, y=$yPosition');
            _controller.xvalue.value = xPosition;
            _controller.yvalue.value = yPosition;
          } else {
            debugPrint('Warning: RenderBox for text $index, key=${textModel.widgetKey} is null, using model values');
          }
        } else {
          debugPrint('Warning: No GlobalKey found for text $index, using model values');
          if (xPosition == 0.0 && yPosition == 0.0) {
            xPosition = 170.5;
            yPosition = 264.4;
            textModel.left.value = xPosition;
            textModel.top.value = yPosition;
            debugPrint('Using fallback position: x=$xPosition, y=$yPosition');
          }
        }

        textDataList.add({
          'text': textModel.text.value,
          'top': yPosition,
          'left': xPosition,
          'fontSize': textModel.fontSize.value,
          'fontFamily': textModel.fontFamily.value,
          'textColor': textModel.textColor.value.value.toRadixString(16).padLeft(8, '0'),
          'backgroundColor': textModel.backgroundColor.value.value.toRadixString(16).padLeft(8, '0'),
          'opacity': textModel.opacity.value,
          'isBold': textModel.isBold.value,
          'isItalic': textModel.isItalic.value,
          'isUnderline': textModel.isUnderline.value,
          'isStrikethrough': textModel.isStrikethrough.value,
          'shadowBlur': textModel.shadowBlur.value,
          'shadowColor': textModel.shadowColor.value.value.toRadixString(16).padLeft(8, '0'),
          'shadowOffsetX': textModel.shadowOffsetX.value,
          'shadowOffsetY': textModel.shadowOffsetY.value,
          'rotation': textModel.rotation.value,
          'isFlippedHorizontally': textModel.isFlippedHorizontally.value,
          'textAlign': textModel.textAlign.value.toString(),
        });
      });

      final editingState = {
        'imagePath': imageFile.path.toString(),
        'canvasSize': {'width': canvasSize.width, 'height': canvasSize.height},
        'stickers': stickerDataList,
        'text': textDataList,
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

      debugPrint('Editing state: $editingState');
      final dbHelper = DatabaseHelper.instance;
      await dbHelper.saveTemplate('Template_${DateTime.now().millisecondsSinceEpoch}', editingState, _controller.filePath.value.toString());
      Get.snackbar("Success", "Template saved successfully");
      Get.off(() => SavedImagesScreen());
    } catch (e) {
      Get.snackbar("Error", "Failed to save template: $e");
      debugPrint("Error saving template: $e");
    }
  }

  TextAlign _parseTextAlign(dynamic value) {
    if (value is String) {
      switch (value) {
        case 'TextAlign.left':
          return TextAlign.left;
        case 'TextAlign.center':
          return TextAlign.center;
        case 'TextAlign.right':
          return TextAlign.right;
        default:
          return TextAlign.left;
      }
    } else if (value is TextAlign) {
      return value;
    }
    return TextAlign.left;
  }

  int _parseColor(dynamic value, int defaultValue) {
    if (value is String) {
      final cleanedValue = value.replaceAll('0x', '');
      return int.tryParse(cleanedValue, radix: 16) ?? defaultValue;
    } else if (value is int) {
      return value;
    }
    return defaultValue;
  }

  void _loadSavedState(Map<String, dynamic> state) {
    final String imagePath = state['imagePath'] ?? '';
    final List<Map<String, dynamic>> stickers = List<Map<String, dynamic>>.from(state['stickers'] ?? []);
    final List<Map<String, dynamic>> texts = List<Map<String, dynamic>>.from(state['text'] ?? []);
    final Map<String, dynamic> filters = Map<String, dynamic>.from(state['filters'] ?? {});
    final Map<String, dynamic> transformations = Map<String, dynamic>.from(state['transformations'] ?? {});

    _controller.imagePath.value = imagePath;
    _controller.brightness.value = filters['brightness']?.toDouble() ?? 0.0;
    _controller.contrast.value = filters['contrast']?.toDouble() ?? 0.0;
    _controller.scale.value = transformations['scale']?.toDouble() ?? 1.0;
    _controller.offset.value = Offset(
      transformations['offset']?['dx']?.toDouble() ?? 0.0,
      transformations['offset']?['dy']?.toDouble() ?? 0.0,
    );

    _controller.lastValidCanvasSize = Size(
      state['canvasSize']?['width']?.toDouble() ?? _controller.canvasWidth.value,
      state['canvasSize']?['height']?.toDouble() ?? _controller.canvasHeight.value,
    );
    if (_controller.lastValidCanvasSize!.width == 0 || _controller.lastValidCanvasSize!.height == 0) {
      debugPrint('Warning: Using fallback canvas size (360x705)');
      _controller.lastValidCanvasSize = Size(360, 705);
    }

    final shapeSelectorController = Get.put(ShapeSelectorController(lindiController: _controller.controller, shapeCategories: _controller.shapeCategories));
    final textController = Get.put(TextEditorControllerWidget());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Clear existing widgets and models to prevent duplicates
      _controller.controller.widgets.clear();
      _controller.widgetModels.clear();
      stickerController.stickers.clear();
      textController.text.clear();
      debugPrint('Cleared all widgets and models before loading state');

      for (var sticker in stickers) {
        final stickerModel = StickerModel(
          path: sticker['path']?.toString() ?? '',
          top: (sticker['top']?.toDouble() ?? 0.0).obs,
          left: (sticker['left']?.toDouble() ?? 0.0).obs,
          scale: (sticker['scale']?.toDouble() ?? 1.0).obs,
          rotation: (sticker['rotation']?.toDouble() ?? 0.0).obs,
          isFlipped: sticker['isFlipped'] ?? false,
          widgetKey: GlobalKey(debugLabel: 'Sticker_${sticker['path']}_${DateTime.now().millisecondsSinceEpoch}'),
        );

        final stickerWidget = SvgPicture.asset(
          stickerModel.path,
          width: 100 * stickerModel.scale.value,
          height: 100 * stickerModel.scale.value,
        );

        final widget = Container(key: stickerModel.widgetKey, child: stickerWidget);
        _controller.controller.add(
          KeyedSubtree(key: stickerModel.widgetKey, child: widget),
          position: Alignment(
            (stickerModel.left.value / _controller.lastValidCanvasSize!.width) * 2 - 1,
            (stickerModel.top.value / _controller.lastValidCanvasSize!.height) * 2 - 1,
          ),
        );

        stickerController.stickers.add(stickerModel);
        _controller.widgetModels[stickerModel.widgetKey!] = stickerModel;
        debugPrint('Restoring sticker: path=${stickerModel.path}, key=${stickerModel.widgetKey}');
      }

      for (var text in texts) {
        final fontSize = int.tryParse(text['fontSize']?.toString() ?? '16') ?? 16;
        final textModel = EditableTextModel(
          text: (text['text']?.toString() ?? ''), // Reactive text
          top: text['top']?.toDouble() ?? 0.0, // Non-reactive double
          left: text['left']?.toDouble() ?? 0.0, // Non-reactive double
          fontSize: fontSize, // Non-reactive int
          fontFamily: (text['fontFamily']?.toString() ?? 'Roboto'), // Reactive fontFamily
          textColor: Color(_parseColor(text['textColor'], 0xFF000000)), // Non-reactive Color
          backgroundColor: Color(_parseColor(text['backgroundColor'], 0x00000000)), // Non-reactive Color
          opacity: text['opacity']?.toDouble() ?? 1.0, // Non-reactive double
          isBold: text['isBold'] ?? false, // Non-reactive bool
          isItalic: text['isItalic'] ?? false, // Non-reactive bool
          isUnderline: text['isUnderline'] ?? false, // Non-reactive bool
          isStrikethrough: text['isStrikethrough'] ?? false, // Non-reactive bool
          shadowBlur: text['shadowBlur']?.toDouble() ?? 0.0, // Non-reactive double
          shadowColor: Color(_parseColor(text['shadowColor'], 0xFF000000)), // Non-reactive Color
          shadowOffsetX: text['shadowOffsetX']?.toDouble() ?? 0.0, // Non-reactive double
          shadowOffsetY: text['shadowOffsetY']?.toDouble() ?? 0.0, // Non-reactive double
          rotation: text['rotation']?.toDouble() ?? 0.0, // Non-reactive double
          isFlippedHorizontally: text['isFlippedHorizontally'] ?? false, // Non-reactive bool
          textAlign: _parseTextAlign(text['textAlign']),
          widgetKey: GlobalKey(debugLabel: 'Text_${text['text']}_${DateTime.now().millisecondsSinceEpoch}'),
        );

        final textWidget = Container(
          key: textModel.widgetKey,
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Transform(
            transform: Matrix4.identity()
              ..rotateZ(textModel.rotation.value)
              ..scale(textModel.isFlippedHorizontally.value ? -1.0 : 1.0, 1.0),
            alignment: Alignment.center,
            child: Text(
              textModel.text.value,
              style: GoogleFonts.getFont(
                textModel.fontFamily.value,
                fontSize: textModel.fontSize.toDouble(),
                color: textModel.textColor.value.withOpacity(textModel.opacity.value),
                fontWeight: textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
                fontStyle: textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
                decoration: textModel.isUnderline.value
                    ? TextDecoration.underline
                    : (textModel.isStrikethrough.value ? TextDecoration.lineThrough : null),
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
        );

        _controller.controller.add(
          KeyedSubtree(key: textModel.widgetKey, child: textWidget),
          position: Alignment(
            (textModel.left / _controller.lastValidCanvasSize!.width) * 2 - 1,
            (textModel.top / _controller.lastValidCanvasSize!.height) * 2 - 1,
          ),
        );

        textController.text.add(textModel);
        _controller.widgetModels[textModel.widgetKey!] = textModel;
        debugPrint('Restoring text: text=${textModel.text.value}, key=${textModel.widgetKey}');
      }

      debugPrint('Loaded state with ${stickers.length} stickers and ${texts.length} texts');
      debugPrint('Widget keys after loading state: ${_controller.widgetModels.keys.map((k) => k.toString()).toList()}');
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

    // Defer _loadSavedState
    if (savedState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadSavedState(savedState!);
      });
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
                          debugPrint("Error sharing image: $e");
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
              final RenderBox? renderBox = _controller.imageKey.currentContext?.findRenderObject() as RenderBox?;
              if (renderBox != null) {
                final position = renderBox.localToGlobal(Offset.zero);
                final size = renderBox.size;
                _controller.canvasWidth.value = size.width;
                _controller.canvasHeight.value = size.height;
                _controller.lastValidCanvasSize = size;
                debugPrint('Image bounds: position=($position), size=($size)');
              }
            });
            return Obx(() {
              final Uint8List? editedMemoryImage = _controller.editedImageBytes.value;
              final File? editedFileImage = _controller.editedImage.value;
              debugPrint('Rebuilding ImageEditorScreen UI, text count: ${textEditorControllerWidget.text.length}');
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
                                        transform:
                                        Matrix4.translationValues(0, isAnyEditOpen ? 20 : 0, 0)
                                          ..scale(isAnyEditOpen ? 0.94 : 1.0),
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(horizontal: 10),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap:(){
                                                  _controller.controller.clearAllBorders();
                                                },
                                                child: Container(
                                                  key: _controller.imageKey,
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
                                                      errorBuilder:
                                                          (context, error, stackTrace) => Text(
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
                              Flexible(
                                child: SingleChildScrollView(
                                  child: _controller.TextEditControls(constraints, _controller.imageKey),
                                ),
                              ),
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
                                    transform:
                                    Matrix4.translationValues(0, isAnyEditOpen ? 20 : 0, 0)
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
                                              final newScale =
                                              (_controller.baseScale.value * details.scale).clamp(1.0, 5.0);
                                              _controller.scale.value = newScale;
                                            },
                                            child: Obx(() {
                                              return Transform.translate(
                                                offset: _controller.offset.value,
                                                child: Transform.scale(
                                                  scale: _controller.scale.value,
                                                  child: Container(
                                                    key: _controller.imageKey,
                                                    child: ColorFiltered(
                                                      colorFilter: ColorFilter.matrix(
                                                        _controller.calculateColorMatrix(),
                                                      ),
                                                      child: editedMemoryImage != null
                                                          ? Image.memory(
                                                        editedMemoryImage,
                                                        fit: BoxFit.contain,
                                                      )
                                                          : (editedFileImage != null &&
                                                          editedFileImage.path.isNotEmpty
                                                          ? Image.file(
                                                        editedFileImage,
                                                        fit: BoxFit.contain,
                                                        errorBuilder: (context, error, stackTrace) =>
                                                            Text(
                                                              "Error loading image",
                                                              style: TextStyle(color: Colors.white),
                                                            ),
                                                      )
                                                          : (memoryImage != null
                                                          ? Image.memory(
                                                        memoryImage,
                                                        fit: BoxFit.contain,
                                                      )
                                                          : (fileImage != null &&
                                                          fileImage.path.isNotEmpty
                                                          ? Image.file(
                                                        fileImage,
                                                        fit: BoxFit.contain,
                                                        errorBuilder:
                                                            (context, error, stackTrace) =>
                                                            Text(
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
                                                ),
                                              );
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
                          Flexible(
                            child: SingleChildScrollView(
                              child: _controller.TextEditControls(constraints, _controller.imageKey),
                            ),
                          ),
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
            _controller.buildToolButton('Presets', 'assets/presets.png', () {
              _controller.showPresetsEditOptions.value = true;
            }),
          ],
        ),
      ),
    );
  }
}