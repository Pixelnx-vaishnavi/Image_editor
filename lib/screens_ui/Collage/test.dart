import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_collage_widget/image_collage_widget.dart';
import 'package:image_collage_widget/utils/collage_type.dart';
import 'package:image_collage_widget/model/images.dart';
import 'package:image_editor/screens_ui/Collage/collage_controller.dart';
import 'package:image_editor/screens_ui/Collage/collage_sample.dart';
import 'package:image_editor/screens_ui/Text/fadeout.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Test extends StatelessWidget {
  Test({super.key});

  final CollageController controller = Get.put(CollageController());

  void _showCollageBottomSheet() {
    Get.bottomSheet(
      isScrollControlled: true,
      Container(
        decoration:  BoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding:  EdgeInsets.all(16),
        child: Obx(() => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
             Text(
              'Collage Maker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
             SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: Obx(() => ImageCollageWidget(
                key: ValueKey(controller.selectedCollageType.value),
                // images: [
                //   Images(id: 2, imageUrl: controller.file2.value),
                //   Images(id: 3, imageUrl: controller.file3.value),
                // ],
                collageType: controller.selectedCollageType.value,
                withImage: false,

              )),
            ),
            if (controller.text.value.isNotEmpty)
              Positioned(
                bottom: 10,
                left: 10,
                right: 10,
                child: Container(
                  padding:  EdgeInsets.all(8),
                  color: Colors.black54,
                  child: Text(
                    controller.text.value,
                    style:  TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
             SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCollageButton('Two Horizontal', CollageType.hSplit),
                  _buildCollageButton('Three Vertical', CollageType.threeVertical),
                  _buildCollageButton('Grid 2x2', CollageType.fourSquare),
                  _buildCollageButton('Left', CollageType.leftBig),
                ],
              ),
            ),
             SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (
                    controller.file2.value != null) {
                  Get.to(
                        () => CollageSample(
                      controller.selectedCollageType.value,
                      [
                        Images(id: 2, imageUrl: controller.file2.value),
                        Images(id: 3, imageUrl: controller.file3.value),
                      ],
                    ),
                    transition: Transition.fade,
                  );
                  // controller.clear();
                  // Get.back();
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Create Collage'),
            ),
            const SizedBox(height: 16),
          ],
        )),
      ),
    );
  }

  Widget _buildCollageButton(String text, CollageType type) {
    return Obx(() => ElevatedButton(
      // onPressed: () => controller.selectCollageType(type),
      onPressed: (){
        controller.selectedCollageType.value = type;
        controller.selectedCollageType.refresh();
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: controller.selectedCollageType.value == type
            ? Colors.blue
            : Colors.grey[700],
        foregroundColor: controller.selectedCollageType.value == type
            ? Colors.white
            : Colors.white70,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(text),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Example"),
      ),
      body: Center(
        child: Obx(() {
          if (
              controller.file2.value == null ||
              controller.file3.value == null) {
            controller.generateData();
            return const CircularProgressIndicator();
          }
          return ElevatedButton(
            onPressed: _showCollageBottomSheet,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Collage'),
          );
        }),
      ),
    );
  }
}