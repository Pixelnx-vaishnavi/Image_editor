import 'dart:io';
import 'package:flutter/material.dart';
import 'package:crop_image/crop_image.dart';
import 'package:get/get.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/Const/routes_const.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:path_provider/path_provider.dart';

class CropImageScreen extends StatefulWidget {
  final File imageFile;

  const CropImageScreen({super.key, required this.imageFile});

  @override
  State<CropImageScreen> createState() => _CropImageScreenState();
}

class _CropImageScreenState extends State<CropImageScreen> {
  final controller = CropController(
    aspectRatio: 0.7, // Default aspect ratio
    defaultCrop: const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9),
  );

  // Track the selected aspect ratio
  double? _selectedAspectRatio = 0.7; // Initialize with default aspect ratio
  double? _originalAspectRatio; // Store the original image aspect ratio

  @override
  void initState() {
    super.initState();
    // Validate image file and calculate original aspect ratio
    if (!widget.imageFile.existsSync()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image file not found')),
        );
        Navigator.pop(context);
      });
    } else {
      // Load image to get its dimensions
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final imageBytes = await widget.imageFile.readAsBytes();
        final decodedImage = img.decodeImage(imageBytes);
        if (decodedImage != null) {
          _originalAspectRatio = decodedImage.width / decodedImage.height;
          setState(() {}); // Update UI if needed
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(ColorConst.bottomBarcolor),
      body: SafeArea(
        child: Column(
          children: [
            // CropImage widget for manual cropping
            Expanded(
              child: CropImage(
                controller: controller,
                image: Image.file(
                  widget.imageFile,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Text(
                      'Failed to load image',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),
                paddingSize: 25.0,
                alwaysMove: true,
                minimumImageSize: 100,
                maximumImageSize: 1000,
              ),
            ),
            // Aspect ratio options
            Container(
              decoration: BoxDecoration(
                color: Color(ColorConst.bottomBarcolor),
                borderRadius: BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _aspectRatioChip(context, 'Free', -1.0, 'assets/cropimages/freeform.png'),
                        _aspectRatioChip(context, 'Original', 0.0, 'assets/cropimages/original.png'),
                        _aspectRatioChip(context, '1:1', 1.0, 'assets/cropimages/1ratio1.png'),
                        _aspectRatioChip(context, '2:4', 2.4, 'assets/cropimages/3ratio4.png'),
                        _aspectRatioChip(context, '4:3', 4 / 3, 'assets/cropimages/4ratio3.png'),
                        _aspectRatioChip(context, '4:5', 4.0 / 5.0, 'assets/cropimages/4ratio5.png'),
                        _aspectRatioChip(context, '5:4', 5.0 / 4.0, 'assets/cropimages/4ratio5.png'),
                        _aspectRatioChip(context, '9:16', 9.0 / 16.0, 'assets/cropimages/4ratio5.png'),
                        _aspectRatioChip(context, '16:9', 16.0 / 9.0, 'assets/cropimages/5ratio4.png'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          controller.rotation = CropRotation.up;
                          controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
                          controller.aspectRatio = 1.0;
                          _selectedAspectRatio = 1.0; // Reset selected aspect ratio
                          Get.back(); // Return to previous screen
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      ),
                      IconButton(
                        onPressed: _resetToOriginal,
                        icon: Icon(
                          Icons.rotate_left,
                          color: _selectedAspectRatio == 0.0 ? Colors.grey : Colors.white,
                        ),
                      ),
                      TextButton(
                        onPressed: () => _finished(context),
                        child: const Text(
                          'Done',
                          style: TextStyle(color: Colors.white, fontSize: 18),
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

  Widget _aspectRatioChip(BuildContext context, String label, double value, String image) {
    // Determine if this chip is selected
    bool isSelected = _selectedAspectRatio == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAspectRatio = value;
            if (value == 0.0 && _originalAspectRatio != null) {
              // Use original image aspect ratio
              controller.aspectRatio = _originalAspectRatio;
              controller.crop = const Rect.fromLTRB(0, 0, 1, 1); // Full image
            } else {
              controller.aspectRatio = value == -1 ? null : value;
              controller.crop = const Rect.fromLTRB(0.1, 0.1, 0.9, 0.9);
            }
          });
        },
        child: Container(
          height: 70,
          width: 90,
          decoration: BoxDecoration(
            color: isSelected
                ? Color(ColorConst.purplecolor)
                : Color(ColorConst.defaultcontainer),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                image,
                height: 25,
                width: 25,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.broken_image,
                  color: Colors.red,
                  size: 40,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _resetToOriginal() {
    setState(() {
      // _selectedAspectRatio = 0.0; // Select "Original" chip
      if (_originalAspectRatio != null) {
        controller.aspectRatio = _originalAspectRatio;
        controller.crop = const Rect.fromLTRB(0, 0, 1, 1); // Full image
      }
    });
  }

  Future<void> _finished(BuildContext context) async {
    try {
      final croppedImage = await _cropImageFile();
      if (croppedImage != null && croppedImage.existsSync()) {
        print('Cropped image file exists: ${croppedImage.path}, size: ${await croppedImage.length()} bytes');
        final imageEditorController = Get.put(ImageEditorController());
        // imageEditorController.editedImage.value = croppedImage;
        // imageEditorController.editedImageBytes.value = await croppedImage.readAsBytes();
        imageEditorController.setInitialImage(croppedImage);
        Get.back();
      } else {
        throw Exception('Cropped image is null or does not exist');
      }
    } catch (e, stackTrace) {
      print('Error in _finished: $e\nStackTrace: $stackTrace');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to crop image: $e')),
        );
        Get.back(result: null);
      }
    }
  }

  Future<File?> _cropImageFile() async {
    try {
      final imageBytes = await widget.imageFile.readAsBytes();
      final decodedImage = img.decodeImage(imageBytes);
      if (decodedImage == null) {
        print('Failed to decode image');
        return null;
      }

      final cropRect = controller.crop;
      final imageWidth = decodedImage.width;
      final imageHeight = decodedImage.height;

      final left = (cropRect.left * imageWidth).round();
      final top = (cropRect.top * imageHeight).round();
      final width = (cropRect.width * imageWidth).round();
      final height = (cropRect.height * imageHeight).round();

      if (left < 0 || top < 0 || left + width > imageWidth || top + height > imageHeight) {
        print('Invalid crop dimensions: left=$left, top=$top, width=$width, height=$height');
        return null;
      }

      final croppedImage = img.copyCrop(decodedImage, left, top, width, height);
      final resizedImage = img.copyResize(croppedImage, width: 1280, interpolation: img.Interpolation.average);

      final tempDir = await getTemporaryDirectory();
      final tempPath = '${tempDir.path}/cropped_image_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(tempPath);
      await file.writeAsBytes(img.encodePng(resizedImage, level: 6));
      print('Cropped image saved to: $tempPath, file size: ${await file.length()} bytes');
      return file;
    } catch (e, stackTrace) {
      print('Error cropping image file: $e\nStackTrace: $stackTrace');
      return null;
    }
  }
}