import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_filter.dart';

class ImageFilterEditor extends StatelessWidget {
  final Uint8List originalImageBytes;
  final ImageFilterController controller = Get.put(ImageFilterController());

  ImageFilterEditor({required this.originalImageBytes});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Apply Filters"),
      ),
      body: Column(
        children: [
          Obx(() {
            final filteredBytes = controller.filteredImageBytes.value;
            return filteredBytes != null
                ? Image.memory(filteredBytes)
                : Image.memory(originalImageBytes);
          }),

          Expanded(
            child: Column(
              children: [
                _buildSlider("Brightness", controller.brightness, -1, 1),
                _buildSlider("Contrast", controller.contrast, 0, 4),
                _buildSlider("Saturation", controller.saturation, 0, 2),
              ],
            ),
          ),

          ElevatedButton(
            onPressed: () {
              controller.applyFilters(originalImageBytes);
            },
            child: Text("Apply Filters"),
          ),
        ],
      ),
    );
  }

  Widget _buildSlider(String label, RxDouble value, double min, double max) {
    return Column(
      children: [
        Text(label),
        Slider(
          value: value.value,
          min: min,
          max: max,
          onChanged: (newValue) {
            value.value = newValue;
            controller.applyFilters(originalImageBytes);
          },
        ),
      ],
    );
  }
}
