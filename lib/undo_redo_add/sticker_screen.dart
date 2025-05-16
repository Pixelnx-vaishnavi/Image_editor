import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
import 'package:image_editor/undo_redo_add/undo_redo_controller.dart';
import 'package:lindi_sticker_widget/draggable_widget.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';


class ShapeSelectorSheet extends StatelessWidget {
  final LindiController controller;
  final Map<String, List<String>> shapeCategories;
  final ImageEditorController _controller = Get.put(ImageEditorController());


  ShapeSelectorSheet({
    super.key,
    required this.controller,
    required this.shapeCategories,
  });

  @override
  Widget build(BuildContext context) {
    // final controller = Get.find<ShapeSelectorController>();
    final controller = Get.put(ShapeSelectorController(
      lindiController: this.controller,
      shapeCategories: shapeCategories,
    ));

    return DefaultTabController(
      length: shapeCategories.keys.length,
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
                children: shapeCategories.values.map((imagePaths) {
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
                          _controller.selectedimagelayer.add(path);
                          print('Selected: ${_controller.selectedimagelayer.length}');
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
                          _controller.addWidget(newWidget, tapPosition);
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
            Obx(() => TabBar(
              onTap: (index) => controller.selectedTabIndex.value = index,
              isScrollable: true,
              labelPadding: const EdgeInsets.symmetric(horizontal: 8),
              indicatorColor: Colors.transparent,
              dividerColor: Colors.transparent,
              tabs: shapeCategories.keys.map((category) {
                final index = shapeCategories.keys.toList().indexOf(category);
                return Tab(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: index == controller.selectedTabIndex.value
                          ? const Color(0xFF6200EE)
                          : const Color(0xFF424242),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: index == controller.selectedTabIndex.value ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            )),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [

                      // const SizedBox(width: 10),
                      GestureDetector(
                        onTap: controller.clearAll,
                        child: SizedBox(
                          height: 40,
                          child: Image.asset('assets/cross.png'),
                        ),
                      ),
                      Text(
                        'Sticker',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      GestureDetector(
                        onTap: controller.confirmImage,
                        child: SizedBox(
                          height: 40,
                          child: Image.asset('assets/right.png'),
                        ),
                      ),
                    ],
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