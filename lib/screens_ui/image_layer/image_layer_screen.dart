import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';

class ImageLayerWidget extends StatelessWidget {
  final StickerController stickerController = Get.find<StickerController>();
  final ImageEditorController _controller = Get.find<ImageEditorController>();

  ImageLayerWidget({super.key});

  Widget _buildLayerWidget(dynamic assetPath) {
    if (assetPath is File) {
      return Center(
        child: Image.file(
          assetPath,
          height: 40,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
          const Icon(Icons.broken_image),
        ),
      );
    } else if (assetPath is String) {
      if (assetPath.endsWith('.svg')) {
        return Center(
          child: SvgPicture.asset(
            assetPath,
            height: 40,
            placeholderBuilder: (context) => CircularProgressIndicator(),
          ),
        );
      }

      if (assetPath.startsWith('http')) {
        return Center(
          child: Image.network(
            assetPath,
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.broken_image),
          ),
        );
      }

      if (assetPath.endsWith('.png') ||
          assetPath.endsWith('.jpg') ||
          assetPath.endsWith('.jpeg')) {
        return Center(
          child: Image.asset(
            assetPath,
            height: 40,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                Icon(Icons.broken_image),
          ),
        );
      }

      return Center(
        child: Text(
          assetPath,
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      );
    }

    return Icon(Icons.error_outline, color: Colors.red);
  }

  void onReorderReal(int from, int to) {
    final layerList = _controller.selectedimagelayer.value;
    final widgetList = _controller.controller.widgets;

    if (from < 0 || to < 0 || from >= layerList.length || to >= layerList.length) return;

    final movedLayer = layerList.removeAt(from);
    layerList.insert(to, movedLayer);

    if (widgetList.length == layerList.length) {
      final movedWidget = widgetList.removeAt(from);
      widgetList.insert(to, movedWidget);
    } else {
      debugPrint(
          'Warning: Widget list length (${widgetList.length}) does not match layer list length (${layerList.length})');
    }

    _controller.selectedimagelayer.value = List.from(layerList);
    _controller.controller.onPositionChange((index) {
      _controller.indexlayer.value = index;
      _controller.indexlayer.notifyListeners();
    });
  }

  void removeLayer(int index) {
    if (index < _controller.selectedimagelayer.value.length) {
      _controller.selectedimagelayer.value.removeAt(index);
      _controller.selectedimagelayer.refresh();
      if (_controller.selectedIndex.value == index) {
        _controller.selectedIndex.value = -1;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(ColorConst.bottomBarcolor),
      body: Obx(() {
        final originalLayers = _controller.selectedimagelayer.value;
        final reversedLayers = originalLayers.reversed.toList();

        // Ensure editedImage is always at the end and not draggable
        final displayLayers = List.from(reversedLayers);
        final editedImage = _controller.editedImage.value;
        if (!displayLayers.contains(editedImage)) {
          displayLayers.add(editedImage);
        }

        final totalCount = displayLayers.length;

        return ReorderableListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: totalCount,
          buildDefaultDragHandles: false,
          proxyDecorator: (child, index, animation) {
            return Material(
              color: Colors.transparent,
              elevation: 6,
              child: Opacity(opacity: 0.7, child: child),
            );
          },
          onReorder: (oldIndex, newIndex) {
            if (oldIndex == totalCount - 1 || newIndex == totalCount) return;

            if (newIndex > oldIndex) newIndex -= 1;
            final from = originalLayers.length - 1 - oldIndex;
            final to = originalLayers.length - 1 - newIndex;
            onReorderReal(from, to);
          },
          itemBuilder: (context, index) {
            final assetPath = displayLayers[index];
            final isFile = assetPath is File;
            final isEditedImage = assetPath == editedImage;
            final originalIndex = originalLayers.length - 1 - index;

            final widget = _buildLayerWidget(assetPath);


            return ReorderableDragStartListener(
            key: ValueKey('image-$index'),
            index: index,
            enabled: !isEditedImage,
            child: GestureDetector(
            onTap: () {
            if (!isFile && !isEditedImage) {
            _controller.controller.clearAllBorders();
            if (originalIndex >= 0 &&
            originalIndex < _controller.controller.widgets.length) {
            _controller.controller.widgets[originalIndex].showBorder(true);
            _controller.selectedIndex.value = originalIndex;
            }
            }
            },

              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: (_controller.selectedIndex.value == originalIndex)
                        ? Colors.blue
                        : Colors.grey.shade400,
                    width: isEditedImage
                        ? 0
                        : (_controller.selectedIndex.value == originalIndex ? 3.0 : 1.0),
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset('assets/widget_image_layer_icon.png'),
                    widget,
                    Row(
                      children: [
                        if (!isFile && !isEditedImage)
                          GestureDetector(
                            onTap: () {
                              _controller.controller.widgets[originalIndex].delete();
                              removeLayer(originalIndex);
                            },
                            child: Icon(Icons.delete, color: Colors.red),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ));
          },
        );
      }),
    );
  }
}
