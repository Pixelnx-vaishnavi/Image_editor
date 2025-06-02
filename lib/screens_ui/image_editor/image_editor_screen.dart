import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/Const/routes_const.dart';
import 'package:image_editor/screens_ui/Collage/collage_controller.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/crop/crop_screen.dart';
import 'package:image_editor/screens_ui/dashboard/dashboard_screen.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_filter.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stciker_model.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
import 'package:image_editor/screens_ui/image_editor/textScreens.dart';
import 'package:image_editor/screens_ui/presets/presets_model.dart';
import 'package:image_editor/screens_ui/save_file/save_image_screen.dart';
import 'package:image_editor/screens_ui/save_file/saved_image_model.dart';
import 'package:image_editor/undo_redo_add/sticker_screen.dart';
import 'package:image_editor/undo_redo_add/undo_redo_controller.dart';
import 'package:lindi_sticker_widget/draggable_widget.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_icon.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photofilters/filters/filters.dart';
import 'package:photofilters/filters/preset_filters.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

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
  bool _hideBorders = false; // Flag to control border visibility during capture
  static const _tapDurationThreshold = Duration(milliseconds: 300);
  static const _tapDistanceThreshold = 5.0;

  @override
  void initState() {
    super.initState();
    _repaintKey = GlobalKey();

    // Initialize widgetList in controller
    _controller.widgetList.value = [];

    // Initialize LindiController
    _controller.controller = LindiController(
      borderColor: Colors.blue,
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
            final selectedWidget = _controller.controller.selectedWidget;
            if (selectedWidget != null) {
              final model = _controller.widgetModels[selectedWidget.key];
              if (model is StickerModel) {
                stickerController.stickers.remove(model);
                _controller.widgetList.removeWhere((item) => item['model'] == model);
              } else if (model is EditableTextModel) {
                textEditorControllerWidget.text.remove(model);
                _controller.widgetList.removeWhere((item) => item['model'] == model);
              }
              _controller.widgetModels.remove(selectedWidget.key);
              selectedWidget.delete();
              _controller.controller.notifyListeners();
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

    // Initialize canvas size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateCanvasSize();
    });

    // Set up position change listener
    _controller.controller.onPositionChange((index) {
      print('Position change for widget index: $index');
      _controller.controller.clearAllBorders();

      if (index < 0 || index >= _controller.controller.widgets.length) {
        print('Invalid widget index: $index');
        return;
      }
      if (index >= _controller.widgetList.length) {
        print('Widget index $index exceeds widgetList length: ${_controller.widgetList.length}');
        return;
      }

      final DraggableWidget widget = _controller.controller.widgets[index];
      final Map<String, dynamic> widgetItem = _controller.widgetList[index];
      final GlobalKey widgetKey = widget.centerKey;
      final model = widgetItem['model'];

      if (model == null) {
        print('No model found for widget at index $index');
        return;
      }

      final RenderBox? canvasBox = _controller.imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (canvasBox == null) {
        print('Canvas RenderBox is null');
        return;
      }
      final Size canvasSize = canvasBox.size;
      if (canvasSize.width <= 0 || canvasSize.height <= 0) {
        print('Invalid canvas size: $canvasSize');
        return;
      }
      _controller.lastValidCanvasSize = canvasSize;
      final Offset canvasPosition = canvasBox.localToGlobal(Offset.zero);

      final RenderBox? widgetBox = widgetKey.currentContext?.findRenderObject() as RenderBox?;
      if (widgetBox == null) {
        print('Widget RenderBox is null for key: $widgetKey');
        return;
      }
      final Offset widgetPosition = widgetBox.localToGlobal(Offset.zero);
      final double x = widgetPosition.dx - canvasPosition.dx;
      final double y = widgetPosition.dy - canvasPosition.dy;

      if (_interactionStartTime == null) {
        _interactionStartTime = DateTime.now();
        _lastPosition = Offset(x, y);
      }

      model.left.value = x;
      model.top.value = y;

      if (model is StickerModel) {
        stickerController.selectSticker(model);
        textEditorControllerWidget.clearSelection();
        _controller.textController.value.text = '';
        _controller.isSelectingText.value = false;
        _controller.TextEditOptions.value = false;
        print('Sticker selected: ${model.path}, text cleared');
      } else if (model is EditableTextModel) {
        textEditorControllerWidget.selectText(model);
        stickerController.selectedSticker.value = null;
        _controller.textController.value.text = model.text.value;
        _controller.isSelectingText.value = true;
        print('Text selected: "${model.text.value}" at position: ($x, $y)');

        final duration = DateTime.now().difference(_interactionStartTime!);
        final distance = (_lastPosition! - Offset(x, y)).distance;

        if (duration < _tapDurationThreshold && distance < _tapDistanceThreshold) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            print('Navigating to TextUIWithTabsScreen with text: ${model.text.value}');
            // Navigate to text editing screen if needed
            // Get.to(() => TextUIWithTabsScreen());
          });
        }

        _lastPosition = Offset(x, y);
        _controller.textController.value.notifyListeners();

        Future.delayed(_tapDurationThreshold, () {
          if (_interactionStartTime != null &&
              DateTime.now().difference(_interactionStartTime!) >= _tapDurationThreshold) {
            _interactionStartTime = null;
            _lastPosition = null;
          }
        });
      }
    });
  }

  void _updateCanvasSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      int retries = 5;
      while (retries > 0) {
        final RenderBox? canvasBox = _controller.imageKey.currentContext?.findRenderObject() as RenderBox?;
        if (canvasBox != null && canvasBox.hasSize && canvasBox.size.width > 0 && canvasBox.size.height > 0) {
          final size = canvasBox.size;
          _controller.canvasWidth.value = size.width;
          _controller.canvasHeight.value = size.height;
          _controller.lastValidCanvasSize = size;
          print('Canvas size updated: ${size.width}x${size.height}');
          return;
        }
        print('Canvas box not ready, retrying... ($retries retries left)');
        await Future.delayed(const Duration(milliseconds: 100));
        retries--;
      }
      _controller.lastValidCanvasSize = Size(360, 705);
      print('Canvas box not found after retries, using default: 360x705');
    });
  }

  @override
  void dispose() {
    _controller.isBottomSheetOpen = false; // Reset the flag
    _controller.controller.widgets.clear();
    _controller.widgetModels.clear();
    _controller.widgetList.clear();
    stickerController.stickers.clear();
    textEditorControllerWidget.text.clear();
    _controller.controller.clearAllBorders();
    _controller.brightness.value = 0.0;
    _controller.contrast.value = 0.0;


    super.dispose();
  }

  Future<Uint8List?> captureView({bool applyFilter = false, bool applyPreset = false}) async {
    try {
      if (!_controller.TextEditOptions.value) {
        stickerController.selectedSticker.value = null;
        textEditorControllerWidget.clearSelection();
      }

      await Future.delayed(const Duration(milliseconds: 600)); // Delay for UI stability

      // If only filter or preset is applied (no overlays), use editedImageBytes directly
      if ((applyFilter || applyPreset) && _controller.widgetList.isEmpty) {
        Uint8List? imageBytes = _controller.editedImageBytes.value;
        if (imageBytes == null) {
          print('Edited image bytes are null, falling back to capture');
          Get.snackbar("Error", "Failed to get filtered/preset image");
          return null;
        }
        print('Using editedImageBytes directly for filter/preset (no overlays)');
        return imageBytes;
      }

      final RenderRepaintBoundary? boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        Get.snackbar("Error", "Failed to find render boundary");
        print('Render boundary not found');
        return null;
      }
      print('Capturing image, hideBorders: $_hideBorders');
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      Get.snackbar("Error", "Failed to capture view: $e");
      print('Capture error: $e');
      return null;
    }
  }

  Future<void> saveImage() async {

    try {
      // Check if a filter is applied
      final bool hasFilter = _controller.selectedFilter.value != null &&
          _controller.selectedFilter.value!.name != 'NoFilter';
      final bool hasOverlays = _controller.widgetList.isNotEmpty; // Stickers or text

      Uint8List? finalImageBytes;

      if (hasFilter && !hasOverlays) {
        // If only a filter is applied (no stickers or text), use editedImageBytes directly
        finalImageBytes = _controller.editedImageBytes.value;
        if (finalImageBytes == null) {
          Get.snackbar("Error", "Filtered image bytes are null");
          print('Filtered image bytes are null');
          return;
        }
        print('Using filtered image directly from editedImageBytes');
      } else {
        // Hide borders for capture
        setState(() {
          _hideBorders = true;
        });
        _controller.controller.showBorders = false;
        _controller.controller.notifyListeners();
        print('Hiding borders for capture, showBorders: ${_controller.controller.showBorders}, hideBorders: $_hideBorders');
        await Future.delayed(Duration(milliseconds: 200));

        // Capture the view (includes stickers, text, and base image)
        finalImageBytes = await captureView();
        if (finalImageBytes == null) {
          Get.snackbar("Error", "Failed to capture image");
          print('Failed to capture image');
          return;
        }
        print('Image captured from view');
      }

      // Save the captured or filtered image
      final directory = await getApplicationDocumentsDirectory();
      final filePath = path.join(directory.path, 'image_${DateTime.now().millisecondsSinceEpoch}.png');
      final file = File(filePath);
      await file.writeAsBytes(finalImageBytes);

      final dbHelper = DatabaseHelper.instance;
      await dbHelper.saveImage(filePath);
      Get.snackbar("Success", "Image saved successfully");
      // Get.off(() => SavedImagesScreen());
    } catch (e) {
      Get.snackbar("Error", "Failed to save image: $e");
      print('Save image error: $e');
    } finally {
      if (_hideBorders) {
        setState(() {
          _hideBorders = false;
        });
        _controller.controller.showBorders = true;
        _controller.controller.notifyListeners();
        print('Borders restored, showBorders: ${_controller.controller.showBorders}, hideBorders: $_hideBorders');
      }
    }
  }

  Future<void> saveTemplate() async {
    try {
      print('Saving template: Borders cleared, showBorders: ${_controller.controller.showBorders}, hideBorders: $_hideBorders');
      await Future.delayed(const Duration(milliseconds: 600)); // Ensure UI stability

      // Check if filter, preset, or overlays are applied
      final bool hasFilter = _controller.selectedFilter.value != null &&
          _controller.selectedFilter.value!.name != 'NoFilter';
      final bool hasPreset = _controller.selectedPreset.value != null;
      final bool hasOverlays = _controller.widgetList.isNotEmpty; // Stickers or text
      print('Filter applied: $hasFilter, Preset applied: $hasPreset, Overlays present: $hasOverlays');

      Uint8List? previewImageBytes;
      Uint8List? originalImageBytes;
      String? previewFilePath;
      String? filePath;

      // Get directory for saving images
      final directory = await getApplicationDocumentsDirectory();

      // Capture preview image
      if ((hasFilter || hasPreset) && !hasOverlays) {
        // Use editedImageBytes directly if only filter or preset is applied
        previewImageBytes = await captureView(applyFilter: hasFilter, applyPreset: hasPreset);
        if (previewImageBytes == null) {
          Get.snackbar("Error", "Failed to capture preview image");
          print('Failed to capture preview image');
          return;
        }
        print('Using filtered/preset image bytes for preview (no overlays)');
      } else {
        // Capture view with filter, preset, text, and stickers
        previewImageBytes = await captureView(applyFilter: false, applyPreset: false);
        if (previewImageBytes == null) {
          Get.snackbar("Error", "Failed to capture preview image");
          print('Failed to capture preview image');
          return;
        }
        print('Preview image captured with filter, preset, and overlays');
      }

      // Save preview image
      previewFilePath = path.join(directory.path, 'preview_template_${DateTime.now().millisecondsSinceEpoch}.png');
      final previewFile = File(previewFilePath);
      await previewFile.writeAsBytes(previewImageBytes);
      print('Preview image saved at: $previewFilePath');

      // Handle original image (no filter, no preset, no overlays)
      originalImageBytes = _controller.originalImageBytes.value;
      if (originalImageBytes == null) {
        Get.snackbar("Error", "Original image bytes are null");
        print('Original image bytes are null');
        return;
      }
      print('Using original image bytes directly');

      // Save original image
      filePath = path.join(directory.path, 'template_${DateTime.now().millisecondsSinceEpoch}.png');
      final originalFile = File(filePath);
      await originalFile.writeAsBytes(originalImageBytes);
      _controller.filePath.value = filePath;
      print('Original image saved at: $filePath');

      // Verify image files
      if (!previewFile.existsSync()) {
        Get.snackbar("Error", "Preview image file not found");
        print('Preview image file not found at: $previewFilePath');
        return;
      }
      if (!originalFile.existsSync()) {
        Get.snackbar("Error", "Original image file not found");
        print('Original image file not found at: $filePath');
        return;
      }

      // Get canvas information
      final RenderBox? canvasBox = _controller.imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (canvasBox == null || !canvasBox.hasSize) {
        Get.snackbar("Error", "Failed to get canvas information");
        print('Canvas box not found or has no size');
        return;
      }
      final Size canvasSize = canvasBox.size;
      final Offset canvasPosition = canvasBox.localToGlobal(Offset.zero);
      print('Canvas size: $canvasSize, position: $canvasPosition');

      final List<Map<String, dynamic>> stickerDataList = [];
      final List<Map<String, dynamic>> textDataList = [];

      print('Processing widget list: ${_controller.widgetList.length} items');
      await WidgetsBinding.instance.waitUntilFirstFrameRasterized;

      for (var item in _controller.widgetList) {
        final model = item['model'];
        final GlobalKey? widgetKey = item['key'] as GlobalKey? ?? model.widgetKey;

        if (widgetKey == null) {
          print('Skipping item with null widgetKey: $item');
          continue;
        }

        double xPosition = model.left.value;
        double yPosition = model.top.value;

        final RenderBox? widgetBox = widgetKey.currentContext?.findRenderObject() as RenderBox?;
        if (widgetBox != null && widgetBox.hasSize && widgetBox.attached) {
          final widgetPosition = widgetBox.localToGlobal(Offset.zero);
          xPosition = widgetPosition.dx - canvasPosition.dx;
          yPosition = widgetPosition.dy - canvasPosition.dy;
          if (xPosition.isFinite && yPosition.isFinite) {
            model.left.value = xPosition;
            model.top.value = yPosition;
            print('Widget ${model.runtimeType} updated position: ($xPosition, $yPosition)');
          } else {
            print('Invalid position for ${model.runtimeType}: ($xPosition, $yPosition), using saved: (${model.left.value}, ${model.top.value})');
            xPosition = model.left.value.isFinite ? model.left.value : 0.0;
            yPosition = model.top.value.isFinite ? model.top.value : 0.0;
          }
        } else {
          print('RenderBox null or invalid for key: $widgetKey, using saved position: ($xPosition, $yPosition)');
          xPosition = xPosition.isFinite ? xPosition : 0.0;
          yPosition = yPosition.isFinite ? yPosition : 0.0;
        }

        if (model is StickerModel) {
          stickerDataList.add({
            'path': model.path,
            'top': yPosition,
            'left': xPosition,
            'scale': model.scale.value,
            'rotation': model.rotation.value,
            'isFlipped': model.isFlipped.value,
          });
        } else if (model is EditableTextModel) {
          textDataList.add({
            'text': model.text.value,
            'top': yPosition,
            'left': xPosition,
            'fontSize': model.fontSize.value,
            'fontFamily': model.fontFamily.value,
            'textColor': model.textColor.value.value.toRadixString(16).padLeft(8, '0'),
            'backgroundColor': model.backgroundColor.value.value.toRadixString(16).padLeft(8, '0'),
            'opacity': model.opacity.value,
            'isBold': model.isBold.value,
            'isItalic': model.isItalic.value,
            'isUnderline': model.isUnderline.value,
            'isStrikethrough': model.isStrikethrough.value,
            'shadowBlur': model.shadowBlur.value,
            'shadowColor': model.shadowColor.value.value.toRadixString(16).padLeft(8, '0'),
            'shadowOffsetX': model.shadowOffsetX.value,
            'shadowOffsetY': model.shadowOffsetY.value,
            'rotation': model.rotation.value,
            'isFlippedHorizontally': model.isFlippedHorizontally.value,
            'textAlign': model.textAlign.value.toString(),
          });
        }
      }

      final editingState = {
        'imagePath': filePath, // Original image for loading
        'previewFilePath': previewFilePath, // Preview image for dashboard
        'canvasSize': {'width': canvasSize.width, 'height': canvasSize.height},
        'stickers': stickerDataList,
        'text': textDataList,
        'filters': {
          'brightness': _controller.brightness.value,
          'contrast': _controller.contrast.value,
          'filterName': _controller.selectedFilter.value?.name ?? 'NoFilter',
          'filterCategory': _controller.selectedCategory.value,
        },
        'presets': {
          'presetName': _controller.selectedPreset.value?.name ?? 'NoPreset',
        },
        'transformations': {
          'scale': _controller.scale.value,
          'offset': {
            'dx': _controller.offset.value.dx,
            'dy': _controller.offset.value.dy,
          },
        },
      };

      print('Editing state saved: $editingState');

      final dbHelper = DatabaseHelper.instance;
      await dbHelper.saveTemplate('Template_${DateTime.now().millisecondsSinceEpoch}', editingState, filePath, previewFilePath);
      Get.snackbar("Success", "Template saved successfully");
      print('=========after save template=========');
      Get.off(() => DashboardScreen());
    } catch (e) {
      print("Failed to save template: $e");
      Get.snackbar("Error", "Failed to save template: $e");
    } finally {
      setState(() {
        _hideBorders = false;
      });
      _controller.controller.showBorders = true;
      _controller.controller.notifyListeners();
      print('Borders restored, showBorders: ${_controller.controller.showBorders}, hideBorders: $_hideBorders');
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

  void _loadSavedState(Map<String, dynamic> state, {Offset? checkPosition}) {
    final String imagePath = state['imagePath'] ?? '';
    final List<Map<String, dynamic>> stickers = List<Map<String, dynamic>>.from(state['stickers'] ?? []);
    final List<Map<String, dynamic>> texts = List<Map<String, dynamic>>.from(state['text'] ?? []);
    final Map<String, dynamic> filters = Map<String, dynamic>.from(state['filters'] ?? {});
    final Map<String, dynamic> presets = Map<String, dynamic>.from(state['presets'] ?? {});
    final Map<String, dynamic> transformations = Map<String, dynamic>.from(state['transformations'] ?? {});

    _controller.imagePath.value = imagePath;
    _controller.brightness.value = filters['brightness']?.toDouble() ?? 0.0;
    _controller.contrast.value = filters['contrast']?.toDouble() ?? 0.0;
    _controller.scale.value = transformations['scale']?.toDouble() ?? 1.0;
    _controller.offset.value = Offset(
      transformations['offset']?['dx']?.toDouble() ?? 0.0,
      transformations['offset']?['dy']?.toDouble() ?? 0.0,
    );

    // Load filter and category
    final String filterName = filters['filterName'] ?? 'NoFilter';
    final String filterCategory = filters['filterCategory'] ?? 'Natural';
    _controller.selectedCategory.value = filterCategory;

    // Find the saved filter
    Filter? savedFilter;
    for (var categoryFilters in _controller.filterCategories.values) {
      savedFilter = categoryFilters.firstWhere(
            (filter) => filter.name == filterName,
        orElse: () => NoFilter(),
      );
      if (savedFilter.name == filterName) break;
    }

    // Load preset
    final String presetName = presets['presetName'] ?? 'NoPreset';
    ImagePreset? savedPreset;
    for (var categoryPresets in _controller.presetCategories.values) {
      savedPreset = categoryPresets.firstWhere(
            (preset) => preset.name == presetName,
        orElse: () => ImagePreset(name: 'NoPreset', filters: [],),
      );
      if (savedPreset.name == presetName) break;
    }

    print('Loading filter: $filterName from category: $filterCategory, preset: $presetName');
    if (savedFilter == null || savedFilter.name == 'NoFilter') {
      print('No valid filter found, defaulting to NoFilter');
    }
    if (savedPreset == null || savedPreset.name == 'NoPreset') {
      print('No valid preset found, defaulting to NoPreset');
    }

    _controller.lastValidCanvasSize = Size(
      state['canvasSize']?['width']?.toDouble() ?? 360,
      state['canvasSize']?['height']?.toDouble() ?? 705,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller.controller.widgets.clear();
      _controller.widgetModels.clear();
      _controller.widgetList.clear();
      stickerController.stickers.clear();
      textEditorControllerWidget.text.clear();
      _controller.controller.clearAllBorders();

      // Apply the saved filter and preset to the image
      if (imagePath.isNotEmpty) {
        File imageFile = File(imagePath);
        if (imageFile.existsSync()) {
          print('Image file exists at: $imagePath');
          // Set initial image
          await _controller.setInitialImage(imageFile);
          print('Initial image set');

          // Apply filter if present
          if (savedFilter != null && savedFilter.name != 'NoFilter') {
            print('Applying filter: ${savedFilter.name}');
            await Future.delayed(Duration(milliseconds: 100));
            await _controller.applyFullResolutionFilter(savedFilter);
            print('Filter applied: ${savedFilter.name}');
          } else {
            print('No filter to apply, setting NoFilter');
            _controller.selectedFilter.value = NoFilter();
          }

          // Apply preset if present
          if (savedPreset != null && savedPreset.name != 'NoPreset') {
            print('Applying preset: ${savedPreset.name}');
            await Future.delayed(Duration(milliseconds: 100));
            _controller.applyPreset(savedPreset);
            print('Preset applied: ${savedPreset.name}');
            _controller.selectedPreset.value = savedPreset;
          } else {
            print('No preset to apply, setting null');
            _controller.selectedPreset.value = null;
          }

          // Force update editedImageBytes
          _controller.editedImageBytes.value = _controller.editedImageBytes.value;
        } else {
          print('Image file not found at path: $imagePath');
          _controller.selectedFilter.value = NoFilter();
          _controller.selectedPreset.value = null;
          Get.snackbar('Error', 'Image file not found at $imagePath');
        }
      } else {
        print('No image path provided, setting NoFilter and NoPreset');
        _controller.selectedFilter.value = NoFilter();
        _controller.selectedPreset.value = null;
      }

      final canvasBox = _controller.imageKey.currentContext?.findRenderObject() as RenderBox?;
      final canvasPosition = canvasBox != null ? canvasBox.localToGlobal(Offset.zero) : Offset.zero;
      final canvasSize = canvasBox?.size ?? _controller.lastValidCanvasSize;

      print('Loading template with canvas size: $canvasSize, position: $canvasPosition');

      final uuid = Uuid();

      for (var sticker in stickers) {
        final stickerPath = sticker['path']?.toString() ?? '';
        final double top = sticker['top']?.toDouble() ?? 0.0;
        final double left = sticker['left']?.toDouble() ?? 0.0;
        final stickerKey = GlobalKey(debugLabel: 'Sticker_${stickerPath}_${uuid.v4()}');
        final stickerModel = StickerModel(
          path: stickerPath,
          top: top,
          left: left,
          scale: sticker['scale']?.toDouble() ?? 1.0,
          rotation: sticker['rotation']?.toDouble() ?? 0.0,
          isFlipped: RxBool(sticker['isFlipped'] ?? false),
          widgetKey: stickerKey,
        );

        final stickerWidget = DraggableWidget(
          key: stickerKey,
          icons: _controller.controller.icons,
          position: Alignment.topLeft,
          borderColor: _controller.controller.borderColor,
          borderWidth: 2.0,
          showBorders: _controller.controller.showBorders,
          shouldMove: true,
          shouldRotate: _controller.controller.shouldRotate,
          shouldScale: true,
          minScale: 0.5,
          maxScale: 2.0,
          insidePadding: 8.0,
          onBorder: (_) {},
          onDelete: (_) {},
          onLayer: (_) {},
          child: Transform.translate(
            offset: Offset(left, top),
            child: Transform.scale(
              scale: stickerModel.scale.value,
              child: Transform.rotate(
                angle: stickerModel.rotation.value,
                child: Transform.flip(
                  flipX: stickerModel.isFlipped.value,
                  child: Container(
                    child: SvgPicture.asset(
                      stickerModel.path,
                      width: 60,
                      height: 60,
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        Widget Stickerwidget = Container(
          alignment: Alignment(top, left),
          child: SvgPicture.asset(
            stickerModel.path,
            width: 60,
            height: 60,
          ),
        );
        _controller.controller.add(Stickerwidget);
        stickerController.stickers.add(stickerModel);
        _controller.widgetModels[stickerKey] = stickerModel;
        _controller.widgetList.add({
          'widget': stickerWidget,
          'model': stickerModel,
          'key': stickerKey,
        });
        print('Loaded sticker: ${stickerModel.path} at position: (${left}, ${top})');
      }

      EditableTextModel? selectedTextModel;
      for (var text in texts) {
        final textContent = text['text']?.toString() ?? '';
        final double top = text['top']?.toDouble() ?? 0.0;
        final double left = text['left']?.toDouble() ?? 0.0;
        final textKey = GlobalKey(debugLabel: 'Text_${textContent.replaceAll(' ', '_')}_${uuid.v4()}');
        final fontSize = int.tryParse(text['fontSize']?.toString() ?? '16') ?? 16;

        final textModel = EditableTextModel(
          text: textContent,
          top: top,
          left: left,
          fontSize: fontSize,
          fontFamily: text['fontFamily']?.toString() ?? 'Roboto',
          textColor: Color(_parseColor(text['textColor'], 0xFF000000)),
          backgroundColor: Color(_parseColor(text['backgroundColor'], 0x00000000)),
          opacity: text['opacity']?.toDouble() ?? 1.0,
          isBold: text['isBold'] ?? false,
          isItalic: text['isItalic'] ?? false,
          isUnderline: text['isUnderline'] ?? false,
          isStrikethrough: text['isStrikethrough'] ?? false,
          shadowBlur: text['shadowBlur']?.toDouble() ?? 0.0,
          shadowColor: Color(_parseColor(text['shadowColor'], 0xFF000000)),
          shadowOffsetX: text['shadowOffsetX']?.toDouble() ?? 0.0,
          shadowOffsetY: text['shadowOffsetY']?.toDouble() ?? 0.0,
          rotation: text['rotation']?.toDouble() ?? 0.0,
          isFlippedHorizontally: text['isFlippedHorizontally'] ?? false,
          textAlign: _parseTextAlign(text['textAlign']),
          widgetKey: textKey,
        );

        final textWidget = DraggableWidget(
          key: textKey,
          icons: _controller.controller.icons,
          position: Alignment.topLeft,
          borderColor: _controller.controller.borderColor,
          borderWidth: 2.0,
          showBorders: _controller.controller.showBorders,
          shouldMove: true,
          shouldRotate: _controller.controller.shouldRotate,
          shouldScale: true,
          minScale: 0.5,
          maxScale: 2.0,
          insidePadding: 8.0,
          onBorder: (_) {},
          onDelete: (_) {},
          onLayer: (_) {},
          child: Transform.translate(
            offset: Offset(left, top),
            child: Transform.scale(
              scale: 1.0,
              child: Transform.rotate(
                angle: textModel.rotation.value,
                child: Transform.flip(
                  flipX: textModel.isFlippedHorizontally.value,
                  child: Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: textModel.backgroundColor.value,
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                    ),
                    child: Text(
                      textContent,
                      style: GoogleFonts.getFont(
                        textModel.fontFamily.value,
                        fontSize: textModel.fontSize.value.toDouble(),
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
                ),
              ),
            ),
          ),
        );

        Widget Textwidget = Container(
          alignment: Alignment(top, left),
          child: Text(
            textContent,
            style: GoogleFonts.getFont(
              textModel.fontFamily.value,
              fontSize: textModel.fontSize.value.toDouble(),
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
        );

        _controller.controller.add(Textwidget);
        textEditorControllerWidget.text.add(textModel);
        _controller.widgetModels[textKey] = textModel;
        _controller.widgetList.add({
          'widget': textWidget,
          'model': textModel,
          'key': textKey,
        });
        print('Loaded text: "$textContent" at position: (${left}, ${top})');

        if (checkPosition != null) {
          final textRect = Rect.fromLTWH(left, top, 100, 50);
          if (textRect.contains(checkPosition)) {
            selectedTextModel = textModel;
          }
        } else if (selectedTextModel == null) {
          selectedTextModel = textModel;
        }
      }

      if (selectedTextModel != null) {
        textEditorControllerWidget.selectText(selectedTextModel);
        print('Selected text: "${selectedTextModel.text.value}" at position: (${selectedTextModel.left.value}, ${selectedTextModel.top.value})');
      } else {
        textEditorControllerWidget.clearSelection();
        print('No text model selected for prefilling');
      }

      _controller.controller.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dynamic imageArg = Get.arguments;
    File? fileImage;
    Uint8List? memoryImage;
    Map<String, dynamic>? savedState;

    // Handle the arguments
    if (imageArg is File) {
      fileImage = imageArg;
      if (fileImage.existsSync()) {
        print('Received cropped image file: ${fileImage.path}');
        _controller.setInitialImage(fileImage);
        _controller.decodeEditedImage();
        filterController.setInitialImage(fileImage);
      } else {
        print('Cropped image file does not exist: ${fileImage.path}');
        Get.snackbar('Error', 'Cropped image file not found');
        fileImage = null;
      }
    } else if (imageArg is Uint8List) {
      memoryImage = imageArg;
      _controller.setInitialImage(File(''));
      _controller.editedImageBytes.value = memoryImage;
      filterController.setInitialImage(File(''));
    } else if (imageArg is Map<String, dynamic>) {
      savedState = imageArg;
      fileImage = File(savedState['imagePath'] ?? '');
      if (fileImage.existsSync()) {
        _controller.setInitialImage(fileImage);
        _controller.decodeEditedImage();
        filterController.setInitialImage(fileImage);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadSavedState(savedState!);
        });
      } else {
        print('Saved state image file not found: ${fileImage.path}');
        Get.snackbar('Error', 'Image file not found at ${fileImage.path}');
      }
    } else {
      print('No valid image argument provided');
      _controller.setInitialImage(File(''));
      _controller.decodeEditedImage();
      filterController.setInitialImage(File(''));
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
              padding: EdgeInsets.only(right: 0),
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
                      onTap: () {
                        _controller.controller.clearAllBorders();
                        print('====Save Template=========');
                        saveTemplate();
                      },
                      child: Icon(Icons.save, color: Colors.white),
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
                          print('Share error: $e');
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
              _updateCanvasSize();
            });
            return Obx(() {
              final Uint8List? editedMemoryImage = _controller.editedImageBytes.value;
              final File? editedFileImage = _controller.editedImage.value;
              if (_controller.TextEditOptions.value && !_controller.isBottomSheetOpen) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _controller.isBottomSheetOpen = true;
                  _controller.showTextEditorBottomSheet(constraints, _controller.imageKey, context);
                });
              } else if (_controller.showPresetsEditOptions.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _controller.showFilterControlsBottomSheet(context, () {
                    _controller.showFilterEditOptions.value = false;
                  });
                });
              } else if (_controller.showFilterEditOptions.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _controller.buildFilterControlsSheet(onClose: () {
                    _controller.showFilterEditOptions.value = false;
                  });
                });
              } else if (_controller.CameraEditSticker.value) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _controller.buildEditCamera();
                });
              }
              else if (_controller.showStickerEditOptions.value){
                WidgetsBinding.instance.addPostFrameCallback((_){
                  _controller.StickerOption();
                });}
               else if (_controller.showtuneOptions.value){
                 WidgetsBinding.instance.addPostFrameCallback((_){
                   _controller.showTuneEditBottomSheet();
                 });
              }
             else if (_controller.showEditOptions.value){
                WidgetsBinding.instance.addPostFrameCallback((_){
                  _controller.buildEditControls();
                });
              }
             else if (_controller.showImageLayer.value){
               WidgetsBinding.instance.addPostFrameCallback((_){
                 _controller.buildImageLayerSheet();
               });
              }

              return Stack(
                children: [
                  Container(
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
                                          GestureDetector(
                                            onScaleStart: (details) {
                                              _controller.baseScale.value = _controller.scale.value;
                                            },
                                            onScaleUpdate: (details) {
                                              final newScale =
                                              (_controller.baseScale.value * details.scale).clamp(1.0, 5.0);
                                              _controller.scale.value = newScale;
                                            },
                                            onTap: () {
                                              _controller.controller.clearAllBorders();
                                              _controller.textController.value.text = '';
                                              _controller.isSelectingText.value = false;
                                              textEditorControllerWidget.clearSelection();
                                              _controller.TextEditOptions.value = false;
                                            },
                                            child: Obx(() {
                                              return Transform.translate(
                                                offset: _controller.offset.value,
                                                child: Transform.scale(
                                                  scale: _controller.scale.value,
                                                  child: Center(
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
                                                          errorBuilder: (context, error, stackTrace) =>
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



                        // if (_controller.showtuneOptions.value) _controller.TuneEditControls(),
                        // if (_controller.TextEditOptions.value)
                        //   _controller.showTextEditorBottomSheet(constraints, _controller.imageKey,context),

                        // if (collageController.showCollageOption.value)
                        //   collageTemplateController.openTemplatePickerBottomSheet(),

                        // if (_controller.showFilterEditOptions.value)
                        //   _controller.buildFilterControlsSheet(onClose: () {
                        //     _controller.showFilterEditOptions.value = false;
                        //   }),

                        // if (_controller.showPresetsEditOptions.value)
                        //   _controller.showFilterControlsBottomSheet(context, () {
                        //     _controller.showFilterEditOptions.value = false;
                        //   }),
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
              final File? currentImage = _controller.editedImage.value;
              print('====CurrentImage=======${currentImage}');
              if (currentImage != null && currentImage.existsSync()) {
                SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
             Get.to( CropImageScreen(imageFile: currentImage));
              } else {
                Get.snackbar('Error', 'No image available to crop');
              }
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
            // SizedBox(width: 40),
            // _controller.buildToolButton('Collage', 'assets/collage.png', () {
            //   collageController.showCollageOption.value = true;
            // }),
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