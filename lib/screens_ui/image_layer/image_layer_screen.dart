import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';

class ImageLayerWidget extends StatelessWidget {
  final TextEditorControllerWidget textEditorControllerWidget = Get.find<TextEditorControllerWidget>();
  final StickerController stickerController = Get.find<StickerController>();
  final ImageEditorController _controller = Get.put(ImageEditorController());


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Layers'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        final textCount = textEditorControllerWidget.text.length;
        final stickerCount = stickerController.stickers.length;

        if (textCount == 0 && stickerCount == 0) {
          return const Center(
            child: Text(
              'No layers available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: textCount + stickerCount,
          itemBuilder: (context, index) {
            // Handle text items
            if (index < textCount) {
              final textModel = textEditorControllerWidget.text[index];
              return Column(
                children: [
                Container(
                  child: Text(
                    textModel.text.value.isEmpty ? 'Empty Text' : textModel.text.value,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                 if(_controller.selectedimage.value != null)
                 Container(
                   height: 40,
                   child: SvgPicture.asset(_controller.selectedimage.value!),
                 )
                ],
              );
            }
            // Handle sticker items

          },
        );
      }),
    );
  }
}