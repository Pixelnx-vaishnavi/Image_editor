import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stciker_model.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:lindi_sticker_widget/draggable_widget.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class WidgetWithPosition {
  final DraggableWidget widget;
  final Offset position;
  final GlobalKey globalKey;
  var model;

  WidgetWithPosition({
    required this.widget,
    required this.position,
    required this.globalKey,
     this.model,
  });
}

class ShapeSelectorController extends GetxController {
  LindiController lindiController;
  Map<String, List<String>> shapeCategories;

  ShapeSelectorController({
    required this.lindiController,
    required this.shapeCategories,
  });

  final selectedTabIndex = 0.obs;
  final selectedImageLayer = <String>[].obs;
  final stickerController = Get.find<StickerController>();
  TextEditorControllerWidget get textController => Get.find<TextEditorControllerWidget>();
  final showStickerEditOptions = false.obs;
  final showEditOptions = false.obs;
  final editedImage = Rxn<File>();
  final editedImageBytes = Rxn<List<int>>();
  final flippedBytes = Rxn<List<int>>();
  final editorController = Get.find<ImageEditorController>();

  final _undoStack = <WidgetWithPosition>[].obs;
  final _redoStack = <WidgetWithPosition>[].obs;

  var canvasWidth = 300.0.obs;
  var canvasHeight = 300.0.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stickerWidgetBox = LindiStickerWidget.globalKey.currentContext?.findRenderObject() as RenderBox?;
      if (stickerWidgetBox != null) {
        canvasWidth.value = stickerWidgetBox.size.width;
        canvasHeight.value = stickerWidgetBox.size.height;
        editorController.lastValidCanvasSize = stickerWidgetBox.size;
        debugPrint('ShapeSelectorController onInit: canvasWidth=${canvasWidth.value}, canvasHeight=${canvasHeight.value}');
      }
    });
  }

  void addToUndoStack({
    required DraggableWidget widget,
    required Offset position,
    required dynamic model,
  }) {
    _undoStack.add(WidgetWithPosition(
      widget: widget,
      position: position,
      globalKey: model.widgetKey,
      model: model,
    ));
    _redoStack.clear();
    debugPrint('Added to undo stack: model=${model.runtimeType}, position=$position, key=${model.widgetKey}, undoStack length: ${_undoStack.length}');
    lindiController.notifyListeners();
  }

  void addWidget(Widget sticker, Offset position, dynamic model) {
    try {
      final alignment = Alignment(
        (position.dx / canvasWidth.value) * 2 - 1,
        (position.dy / canvasHeight.value) * 2 - 1,
      );
      final globalKey = (model is StickerModel || model is EditableTextModel)
          ? model.widgetKey
          : GlobalKey(debugLabel: 'Shape_${DateTime.now().millisecondsSinceEpoch}');
      final wrappedWidget = KeyedSubtree(key: globalKey, child: sticker);
      lindiController.add(sticker, position: alignment);
      final addedWidget = lindiController.widgets.last;
      debugPrint('Added widget: key=${addedWidget.key}, model=${model.runtimeType}');

      _undoStack.add(WidgetWithPosition(
        widget: addedWidget,
        position: position,
        globalKey: model.widgetKey,
        model: model,
      ));

      _redoStack.clear();
      debugPrint('Added widget: model=${model.runtimeType}, position=$position, key=${model.widgetKey}, undoStack length: ${_undoStack.length}');

      // Defer RenderBox access
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final renderBox = model.widgetKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          debugPrint('RenderBox for ${model.runtimeType}: size=${renderBox.size}, position=${renderBox.localToGlobal(Offset.zero)}');
        } else {
          debugPrint('RenderBox still null for key: ${model.widgetKey}');
        }
      });

      lindiController.notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error adding widget: $e');
      debugPrint(stackTrace.toString());
    }
  }

  void undo() {
    if (_undoStack.isEmpty) {
      debugPrint('Undo stack is empty');
      return;
    }

    try {
      debugPrint('Undo called, undoStack length: ${_undoStack.length}');
      final undoneWidgetWithPosition = _undoStack.removeLast();
      final undoneWidget = undoneWidgetWithPosition.widget;
      final model = undoneWidgetWithPosition.model;

      int index = lindiController.widgets.indexWhere((w) => w.key == undoneWidget.key);
      if (index != -1) {
        lindiController.widgets.removeAt(index);
        if (model is StickerModel) {
          stickerController.stickers.remove(model);
          editorController.widgetModels.remove(model.widgetKey);
        } else if (model is EditableTextModel) {
          textController.text.remove(model);
          editorController.widgetModels.remove(model.widgetKey);
        }
        _redoStack.add(undoneWidgetWithPosition);
        debugPrint('Undid widget: model=${model.runtimeType}, index=$index, key=${undoneWidget.key}, redoStack length: ${_redoStack.length}');
      } else {
        debugPrint('Warning: Widget with key ${undoneWidget.key} not found in controller.widgets');
      }

      lindiController.notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error during undo: $e');
      debugPrint(stackTrace.toString());
    }
  }

  void redo() {
    if (_redoStack.isEmpty) {
      debugPrint('Redo stack is empty');
      return;
    }

    try {
      debugPrint('Redo called, redoStack length: ${_redoStack.length}');
      final redoWidgetWithPosition = _redoStack.removeLast();
      final redoWidget = redoWidgetWithPosition.widget;
      final position = redoWidgetWithPosition.position;
      final model = redoWidgetWithPosition.model;

      final alignment = Alignment(
        (position.dx / canvasWidth.value) * 2 - 1,
        (position.dy / canvasHeight.value) * 2 - 1,
      );

      lindiController.add(redoWidget.child, position: alignment);
      final newWidget = lindiController.widgets.last;

      if (model is StickerModel) {
        stickerController.stickers.add(model);
        editorController.widgetModels[model.widgetKey] = model;
      } else if (model is EditableTextModel) {
        textController.text.add(model);
        editorController.widgetModels[model.widgetKey] = model;
      }

      _undoStack.add(WidgetWithPosition(
        widget: newWidget,
        position: position,
        globalKey: redoWidgetWithPosition.globalKey,
        model: model,
      ));

      debugPrint('Redid widget: model=${model.runtimeType}, position=$position, key=${newWidget.key}, undoStack length: ${_undoStack.length}');

      // Defer RenderBox access
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final renderBox = model.widgetKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          debugPrint('RenderBox for ${model.runtimeType}: size=${renderBox.size}, position=${renderBox.localToGlobal(Offset.zero)}');
        } else {
          debugPrint('RenderBox still null for key: ${model.widgetKey}');
        }
      });

      lindiController.notifyListeners();
    } catch (e, stackTrace) {
      debugPrint('Error during redo: $e');
      debugPrint(stackTrace.toString());
    }
  }

  void triggerUndoRedoProgrammatically() {
    undo();
    debugPrint('Undo triggered programmatically');
    Future.delayed(const Duration(seconds: 1), () {
      redo();
      debugPrint('Redo triggered programmatically');
    });
  }

  void clearAll() {
    stickerController.clearStickers();
    textController.text.clear();
    editorController.flippedBytes.value = null;
    editorController.showStickerEditOptions.value = false;
    editedImageBytes.value = null;
    _undoStack.clear();
    _redoStack.clear();
    editorController.undoStack.clear();
    editorController.redoStack.clear();
    editorController.controller.widgets.clear();
    editorController.controller.clearAllBorders();
    editorController.controller.notifyListeners();
  }

  Future<void> confirmImage() async {
    editorController.showEditOptions.value = false;
    editorController.showStickerEditOptions.value = false;
    if (editorController.flippedBytes.value != null) {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/confirmed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(path);
      await file.writeAsBytes(editorController.flippedBytes.value!);
      editorController.editedImage.value = file;
      editorController.editedImageBytes.value = null;
      editorController.flippedBytes.value = null;
    }
    Get.toNamed('/ImageEditorScreen', arguments: editorController.editedImage.value);
    Get.back();
  }

  @override
  void onClose() {
    lindiController.close();
    super.onClose();
  }
}