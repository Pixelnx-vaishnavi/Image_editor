import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:path_provider/path_provider.dart';

class ShapeSelectorSheet extends StatefulWidget {
  final LindiController controller;
  final Map<String, List<String>> shapeCategories;

  const ShapeSelectorSheet({
    Key? key,
    required this.controller,
    required this.shapeCategories,
  }) : super(key: key);

  @override
  _ShapeSelectorSheetState createState() => _ShapeSelectorSheetState();
}

class _ShapeSelectorSheetState extends State<ShapeSelectorSheet> {
  final selectedTabIndex = ValueNotifier<int>(0);
  final selectedimagelayer = ValueNotifier<List<String>>([]);
  final stickerController = Get.find<StickerController>();
  final showStickerEditOptions = ValueNotifier<bool>(false);
  final showEditOptions = ValueNotifier<bool>(false);
  final editedImage = ValueNotifier<File?>(null);
  final editedImageBytes = ValueNotifier<List<int>?>(null);
  final flippedBytes = ValueNotifier<List<int>?>(null);

  final List<Widget> _undoStack = [];
  final List<Widget> _redoStack = [];

  void _addWidget(Widget widgets) {
    widget.controller.add(widgets);
    _undoStack.add(widgets);
    _redoStack.clear();
    setState(() {});
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      final widgets = _undoStack.removeLast();
      widget.controller.widgets.remove(widgets);
      _redoStack.add(widgets);
      setState(() {});
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      final widgets = _redoStack.removeLast();
      widget.controller.add(widgets);
      _undoStack.add(widgets);
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: widget.shapeCategories.keys.length,
      child: Container(
        decoration: BoxDecoration(
          color: Color(ColorConst.bottomBarcolor),
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
                    padding: EdgeInsets.all(12),
                    itemCount: imagePaths.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final path = imagePaths[index];
                      return GestureDetector(
                        onTap: () {
                          selectedimagelayer.value.add(path);
                          print('Selected: ${selectedimagelayer.value}');
                          Widget widget = Container(
                            height: 100,
                            width: 100,
                            padding: EdgeInsets.all(12),
                            child: SvgPicture.asset(path),
                          );
                          _addWidget(widget);
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              padding: EdgeInsets.all(6),
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
                  onTap: (index) {
                    selectedTabIndex.value = index;
                  },
                  isScrollable: true,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8),
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  tabs: widget.shapeCategories.keys.toList().asMap().entries.map((entry) {
                    final index = entry.key;
                    final category = entry.value;
                    return Tab(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: index == currentIndex
                              ? Color(ColorConst.tabhighlightbutton)
                              : Color(ColorConst.tabdefaultcolor),
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
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _undoStack.isNotEmpty ? _undo : null,
                        child: Opacity(
                          opacity: _undoStack.isNotEmpty ? 1.0 : 0.5,
                          child: SizedBox(
                            height: 40,
                            child: Image.asset('assets/undo.png'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: _redoStack.isNotEmpty ? _redo : null,
                        child: Opacity(
                          opacity: _redoStack.isNotEmpty ? 1.0 : 0.5,
                          child: SizedBox(
                            height: 40,
                            child: Image.asset('assets/redo.png'),
                          ),
                        ),
                      ),
                      SizedBox(width: 10),
                      GestureDetector(
                        onTap: () {
                          stickerController.clearStickers();
                          flippedBytes.value = null;
                          showStickerEditOptions.value = false;
                          editedImageBytes.value = null;
                          _undoStack.clear();
                          _redoStack.clear();
                          setState(() {});
                        },
                        child: SizedBox(
                          height: 40,
                          child: Image.asset('assets/cross.png'),
                        ),
                      ),
                    ],
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
                    onTap: () async {
                      showEditOptions.value = false;
                      showStickerEditOptions.value = false;

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