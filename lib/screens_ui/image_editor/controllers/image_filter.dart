import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';
import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:image/image.dart' as img;

class ImageFilterController extends GetxController {
  final brightness = 0.0.obs;
  final contrast = 1.0.obs;
  final saturation = 1.0.obs;

  final filteredImageBytes = Rxn<Uint8List>();
  final isLoading = false.obs;

  String? fileName;
  List<Filter> filters = presetFiltersList;
  final picker = ImagePicker();
  File? selectedImage;
  Rx<File> editedImage = File('').obs;
  Rx<Uint8List?> editedImageBytes = Rx<Uint8List?>(null);
  Rx<Uint8List?> flippedImageBytes = Rx<Uint8List?>(null);
  RxBool showEditOptions = false.obs;
  final Rx<Uint8List?> flippedBytes = Rx<Uint8List?>(null);
  final RxBool isFlipping = false.obs;
  Rxn<img.Image> decodedImage = Rxn<img.Image>();

  void setInitialImage(File image) {
    editedImage.value = image;
    editedImageBytes.value = null;
  }

  final originalImageBytes = Rxn<Uint8List>();
  final selectedFilter = Rxn<Filter>();
  final RxString selectedCategory = "Natural".obs;

  final Map<String, List<Filter>> filterCategories = {
    "Natural": [NoFilter(), AdenFilter(), AmaroFilter()],
    "Warm": [MayfairFilter(), RiseFilter(), ValenciaFilter()],
    "Cool": [HudsonFilter(), InkwellFilter(), LoFiFilter()],
    "Vivid": [XProIIFilter(), NashvilleFilter(), EarlybirdFilter()],
    "Soft": [SierraFilter(), ToasterFilter(), BrannanFilter()],
  };



  Future<void> decodeEditedImage() async {
    if (editedImage.value.path.isNotEmpty) {
      final bytes = await editedImage.value.readAsBytes();
      decodedImage.value = img.decodeImage(bytes);
    }
  }

  void applyFilter(Filter filter) {
    if (originalImageBytes.value == null) return;

    final img.Image? image = img.decodeImage(originalImageBytes.value!);
    if (image == null) return;

    final Uint8List pixels = image.getBytes();
    final int width = image.width;
    final int height = image.height;


    filter.apply(pixels, width, height);

    final img.Image filteredImage = img.Image.fromBytes(width, height, pixels);

    final Uint8List resultBytes = Uint8List.fromList(img.encodeJpg(filteredImage));

    editedImageBytes.value = resultBytes;
  }










  Future<void> applyFiltersToEditedImage(BuildContext context) async {
    final file = editedImage.value;

    if (file.path.isNotEmpty && await file.exists()) {
      fileName = basename(file.path);
      final imageBytes = await file.readAsBytes();
      var image = img.decodeImage(imageBytes);

      if (image != null) {
        image = img.copyResize(image, width: 600);

        final filteredResult = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PhotoFilterSelector(
              appBarColor: Colors.black,
              title:  Text("Filters"),
              image: image!,
              filters: filters,
              filename: fileName!,
              loader:  Center(child: CircularProgressIndicator()),
              fit: BoxFit.contain,

            ),
          ),
        );

        if (filteredResult != null && filteredResult.containsKey('image_filtered')) {
          final File filteredFile = filteredResult['image_filtered'];
          final Uint8List resultBytes = await filteredFile.readAsBytes();
          editedImageBytes.value = resultBytes;
        }
      }
    }
  }


}
