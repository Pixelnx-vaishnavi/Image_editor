import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
import 'package:lindi_sticker_widget/draggable_widget.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class WidgetWithPosition {
  final DraggableWidget widget;
  final Offset position;
  final GlobalKey globalKey;

  WidgetWithPosition({
    required this.widget,
    required this.position,
    required this.globalKey,
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
  final showStickerEditOptions = false.obs;
  final showEditOptions = false.obs;
  final editedImage = Rxn<File>();
  final editedImageBytes = Rxn<List<int>>();
  final flippedBytes = Rxn<List<int>>();
  final editorController = Get.put(ImageEditorController());

  final _undoStack = <WidgetWithPosition>[].obs;
  final _redoStack = <WidgetWithPosition>[].obs;

  var canvasWidth = 300.0.obs;
  var canvasHeight = 300.0.obs;

  @override
  void onInit() {
    super.onInit();
    // Update canvas size dynamically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stickerWidgetBox = LindiStickerWidget.globalKey.currentContext
          ?.findRenderObject() as RenderBox?;
      if (stickerWidgetBox != null) {
        canvasWidth.value = stickerWidgetBox.size.width;
        canvasHeight.value = stickerWidgetBox.size.height;
      }
    });
  }

  void addWidget(Widget sticker, Offset position) {
    try {
      final alignment = Alignment(
        (position.dx / canvasWidth.value) * 2 - 1,
        (position.dy / canvasHeight.value) * 2 - 1,
      );

      // Add to LindiController
      lindiController!.add(sticker, position: alignment);

      // Get the added DraggableWidget
      final addedWidget = lindiController!.widgets.last;

      // Add to undo stack
      _undoStack.add(WidgetWithPosition(
        widget: addedWidget,
        position: position,
        globalKey: GlobalKey(),
      ));

      _redoStack.clear(); // Clear redo stack on new action
      print('Added widget at $position, undoStack length: ${_undoStack.length}');
      lindiController!.notifyListeners();
    } catch (e, stackTrace) {
      print('Error adding widget: $e');
      print(stackTrace);
    }
  }

  void undo() {
    if (_undoStack.isEmpty) {
      lindiController!.widgets.last.delete();
      print('Undo stack is empty');
      return;
    }

    try {
      print('Undo called, undoStack length: ${_undoStack.length}');
      final undoneWidgetWithPosition = _undoStack.removeLast();
      final undoneWidget = undoneWidgetWithPosition.widget;
      final currentPosition = undoneWidgetWithPosition.position;

      // Find the widget in controller.widgets
      int index = -1;
      for (int i = 0; i < lindiController!.widgets.length; i++) {
        if (lindiController!.widgets[i].key == undoneWidget.key) {
          index = i;
          break;
        }
      }

      if (index != -1) {
        print('Found widget at index $index, key: ${undoneWidget.key}');
        // Delete the widget
        lindiController!.widgets.removeAt(index);
        // Convert Offset to Alignment for re-addition
        final alignment = Alignment(
          (currentPosition.dx / canvasWidth.value) * 2 - 1,
          (currentPosition.dy / canvasHeight.value) * 2 - 1,
        );
        // Re-add the widget at the same position
        lindiController!.add(undoneWidget.child, position: alignment);
        // Get the new DraggableWidget
        final newWidget = lindiController!.widgets.last;
        // Add to redo stack
        _redoStack.add(WidgetWithPosition(
          widget: newWidget,
          position: currentPosition,
          globalKey: undoneWidgetWithPosition.globalKey,
        ));
        print('Deleted and re-added widget at index $index, redoStack length: ${_redoStack.length}');
      } else {
        print('Warning: Widget with key ${undoneWidget.key} not found in controller.widgets');
      }

      lindiController!.notifyListeners();
    } catch (e, stackTrace) {
      print('Error during undo: $e');
      print(stackTrace);
    }
  }

  void redo() {
    if (_redoStack.isEmpty) {
      print('Redo stack is empty');
      return;
    }

    try {
      print('Redo called, redoStack length: ${_redoStack.length}');
      final redoWidgetWithPosition = _redoStack.removeLast();
      final redoWidget = redoWidgetWithPosition.widget;
      final position = redoWidgetWithPosition.position;

      // Convert Offset to Alignment
      final alignment = Alignment(
        (position.dx / canvasWidth.value) * 2 - 1,
        (position.dy / canvasHeight.value) * 2 - 1,
      );

      // Re-add to LindiController
      lindiController!.add(redoWidget.child, position: alignment);

      // Get the new DraggableWidget
      final newWidget = lindiController!.widgets.last;

      // Add to undo stack
      _undoStack.add(WidgetWithPosition(
        widget: newWidget,
        position: position,
        globalKey: redoWidgetWithPosition.globalKey,
      ));

      print('Redo completed, undoStack length: ${_undoStack.length}');
      lindiController!.notifyListeners();
    } catch (e, stackTrace) {
      print('Error during redo: $e');
      print(stackTrace);
    }
  }

  void triggerUndoRedoProgrammatically() {
    undo();
    print('Undo triggered programmatically');
    Future.delayed(const Duration(seconds: 1), () {
      redo();
      print('Redo triggered programmatically');
    });
  }

  void clearAll() {
    stickerController.clearStickers();
    editorController.flippedBytes.value = null;
    editorController.showStickerEditOptions.value = false;
    editedImageBytes.value = null;
    editorController.undoStack.clear();
    editorController.redoStack.clear();
    editorController.controller!.widgets.clear();
    editorController.controller!.clearAllBorders();
    editorController.controller!.notifyListeners();
  }

  Future<void> confirmImage() async {
    editorController.showEditOptions.value = false;
    editorController.showStickerEditOptions.value = false;
    if (editorController.flippedBytes.value != null) {
      final tempDir = await getTemporaryDirectory();
      final path =
          '${tempDir.path}/confirmed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(path);
      await file.writeAsBytes(editorController.flippedBytes.value!);
      editorController.editedImage.value = file;
      editorController.editedImageBytes.value = null;
      editorController.flippedBytes.value = null;
    }
    Get.toNamed('/ImageEditorScreen', arguments: editorController.editedImage.value);
  }

  @override
  void onClose() {
    lindiController!.close();
    super.onClose();
  }
}