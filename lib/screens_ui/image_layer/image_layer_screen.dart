import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';

class ImageLayerWidget extends StatelessWidget {
  final TextEditorControllerWidget textEditorControllerWidget = Get.find<TextEditorControllerWidget>();
  final StickerController stickerController = Get.find<StickerController>();
  final ImageEditorController _controller = Get.find<ImageEditorController>();

  final Rx<dynamic> selectedLayer = Rx<dynamic>(null);
  final RxString selectedType = ''.obs; // 'text' or 'image'

  ImageLayerWidget({super.key});

  Widget _buildLayerWidget(String assetPath) {
    if (assetPath.endsWith('.svg')) {
      return SvgPicture.asset(
        assetPath,
        height: 40,
        placeholderBuilder: (context) => const CircularProgressIndicator(),
      );
    } else if (assetPath.endsWith('.png') ||
        assetPath.endsWith('.jpg') ||
        assetPath.endsWith('.jpeg') ||
        assetPath.startsWith('http')) {
      return Image.asset(
        assetPath,
        height: 40,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.broken_image),
      );
    } else {
      return Text(
        assetPath,
        style: const TextStyle(fontSize: 16, color: Colors.black),
      );
    }
  }

  void onReorder(int oldIndex, int newIndex) {
    final textList = textEditorControllerWidget.text;
    final imageList = _controller.selectedimagelayer;

    final combined = [
      ...textList.map((t) => {'type': 'text', 'data': t}),
      ...imageList.map((i) => {'type': 'image', 'data': i}),
    ].reversed.toList();

    final item = combined.removeAt(oldIndex);
    combined.insert(newIndex, item);

    final updated = combined.reversed.toList();

    final newTextList = <dynamic>[];
    final newImageList = <String>[];

    for (var layer in updated) {
      if (layer['type'] == 'text') {
        newTextList.add(layer['data']);
      } else if (layer['type'] == 'image') {
        newImageList.add(layer['data']);
      }
    }

    textEditorControllerWidget.text.value = newTextList.cast();
    _controller.selectedimagelayer.value = newImageList;

    textEditorControllerWidget.text.refresh();
    _controller.selectedimagelayer.refresh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Layers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            _controller.showImageLayer.value = false;
          },
        ),
      ),
      body: Obx(() {
        final textCount = textEditorControllerWidget.text.length;
        final imageLayerCount = _controller.selectedimagelayer.value.length;

        // If no layers available
        if (textCount == 0 && imageLayerCount == 0) {
          return const Center(
            child: Text(
              'No layers available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        final List<Map<String, dynamic>> combinedLayers = [];

        for (int i = 0; i < textCount; i++) {
          combinedLayers.add({
            'type': 'text',
            'widget': Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                textEditorControllerWidget.text[i].text.value.isEmpty
                    ? 'Empty Text'
                    : textEditorControllerWidget.text[i].text.value,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            'data': textEditorControllerWidget.text[i],
          });
        }

        for (int i = 0; i < imageLayerCount; i++) {
          combinedLayers.add({
            'type': 'image',
            'widget': _buildLayerWidget(_controller.selectedimagelayer.value[i]),
            'data': _controller.selectedimagelayer.value[i],
          });
        }

        final reversedLayers = combinedLayers.reversed.toList();

        return ReorderableListView.builder(
          padding:  EdgeInsets.all(16),
          itemCount: reversedLayers.length,
          onReorder: onReorder,
          itemBuilder: (context, index) {
            final layer = reversedLayers[index];
            final Widget widget = layer['widget'];
            final dynamic data = layer['data'];
            final String type = layer['type'];

            return KeyedSubtree(
              key: ValueKey('$index-$type'),
              child: Obx(() {
                bool isSelected = selectedLayer.value == data;

                return Container(
                  margin:  EdgeInsets.symmetric(vertical: 8),
                  padding:  EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: isSelected ? Colors.blue : Colors.grey.shade400, width: 2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: GestureDetector(
                    onTap: () {
                      selectedLayer.value = data;
                      selectedType.value = type;
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        widget,
                        if (isSelected)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Colors.green),
                                onPressed: () {
                                  if (type == 'text') {
                                    // Add text editing logic here
                                  }
                                },
                              ),
                              IconButton(
                                icon:  Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  if (type == 'text') {
                                    textEditorControllerWidget.text.remove(data);
                                    textEditorControllerWidget.text.refresh();
                                  } else {
                                    _controller.selectedimagelayer.value.remove(data);
                                    _controller.selectedimagelayer.refresh();
                                  }
                                  selectedLayer.value = null;
                                  selectedType.value = '';
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_upward, color: Colors.blue),
                                onPressed: () {
                                  if (type == 'text') {
                                    textEditorControllerWidget.text.remove(data);
                                    textEditorControllerWidget.text.add(data);
                                    textEditorControllerWidget.text.refresh();
                                  } else {
                                    _controller.selectedimagelayer.value.remove(data);
                                    _controller.selectedimagelayer.value.add(data);
                                    _controller.selectedimagelayer.refresh();
                                  }
                                },
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                );
              }),
            );

          },
        );
      }),
    );
  }
}
