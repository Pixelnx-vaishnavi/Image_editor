import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter_image_filters/flutter_image_filters.dart';
import 'dart:ui' as ui;

class ImageFilterController extends GetxController {
  final brightness = 0.0.obs;
  final contrast = 1.0.obs;
  final saturation = 1.0.obs;

  final filteredImageBytes = Rxn<Uint8List>();
  final isLoading = false.obs;



  Future<void> applyFilters(Uint8List inputBytes) async {
    try {
      isLoading.value = true;

      final config = GroupShaderConfiguration()
        ..add(BrightnessShaderConfiguration()..brightness = brightness.value)
        ..add(ContrastShaderConfiguration()..contrast = contrast.value)
        ..add(SaturationShaderConfiguration()..saturation = saturation.value);

      final source = await TextureSource.fromMemory(inputBytes);
      final ui.Image resultImage = await config.export(source, source.size);

      final ByteData? byteData = await resultImage.toByteData(format: ui.ImageByteFormat.png);
      if (byteData != null) {
        filteredImageBytes.value = byteData.buffer.asUint8List();
      } else {
        print("Error: ByteData is null");
      }
    } catch (e) {
      print("Error applying filter: $e");
    } finally {
      isLoading.value = false;
    }
  }

}
