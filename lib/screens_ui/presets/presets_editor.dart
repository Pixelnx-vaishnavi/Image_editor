// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:image/image.dart' as img;
//
// // Assume ImagePreset, PresetCategory, and ImageProcessor are defined
//
// class ImageEditorController extends GetxController {
//   Rx<File> editedImage = File('').obs;
//   Rx<Uint8List?> editedImageBytes = Rx<Uint8List?>(null);
//   RxBool showPresetsEditOptions = false.obs;
//   final originalImageBytes = Rxn<Uint8List>();
//   final Rxn<Uint8List> thumbnailBytes = Rxn<Uint8List>();
//   final ValueNotifier<String> selectedCategory = ValueNotifier("Creative");
//   final Rxn<ImagePreset> selectedPreset = Rxn<ImagePreset>();
//   final ImageProcessor processor = ImageProcessor();
//
//   final Map<String, List<ImagePreset>> presetCategories = {
//     for (var category in PresetCategory.allCategories) category.name: category.presets
//   };
//
//   @override
//   void onInit() {
//     super.onInit();
//     selectedCategory.value = PresetCategory.allCategories.first.name;
//   }
//
//   void setInitialImage(File image) async {
//     editedImage.value = image;
//     editedImageBytes.value = null;
//
//     final bytes = await image.readAsBytes();
//     originalImageBytes.value = bytes;
//
//     final img.Image? decoded = img.decodeImage(bytes);
//     if (decoded != null) {
//       final img.Image thumb = img.copyResize(decoded, width: 120);
//       thumbnailBytes.value = Uint8List.fromList(img.encodeJpg(thumb));
//     }
//   }
//
//   Future<void> applyPreset(ImagePreset preset) async {
//     isFlipping.value = true;
//     if (originalImageBytes.value == null) {
//       isFlipping.value = false;
//       return;
//     }
//
//     final img.Image? image = img.decodeImage(originalImageBytes.value!);
//     if (image == null) {
//       isFlipping.value = false;
//       return;
//     }
//
//     final resized = img.copyResize(image, width: 400);
//     final processedImage = await processor.applyPreset(preset, resized);
//     if (processedImage == null) {
//       isFlipping.value = false;
//       return;
//     }
//
//     final resultBytes = Uint8List.fromList(img.encodeJpg(processedImage));
//     editedImageBytes.value = resultBytes;
//     selectedPreset.value = preset;
//     isFlipping.value = false;
//   }
//
//   Future<Uint8List?> generatePresetThumbnail(ImagePreset preset) async {
//     final thumb = img.decodeImage(thumbnailBytes.value!);
//     if (thumb == null) return null;
//
//     final processedThumb = await processor.applyPreset(preset, thumb);
//     if (processedThumb == null) return null;
//
//     return Uint8List.fromList(img.encodeJpg(processedThumb));
//   }
//
// // Other existing methods (e.g., applyFullResolutionFilter, rotateImage) remain unchanged
// }