// import 'dart:async';
// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:image_editor/Const/color_const.dart';
// import 'package:image_editor/screens_ui/Collage/collage_controller.dart';
// import 'package:image_editor/screens_ui/Text/Text_controller.dart';
// import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
// import 'package:image_editor/screens_ui/image_editor/controllers/image_filter.dart';
// import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
// import 'package:image_editor/screens_ui/presets/presets_model.dart';
// import 'package:image_editor/screens_ui/save_file/save_image_screen.dart';
// import 'package:image_editor/screens_ui/save_file/saved_image_model.dart';
// import 'package:image_editor/undo_redo_add/sticker_screen.dart';
// import 'package:image_editor/undo_redo_add/undo_redo_controller.dart';
// import 'package:lindi_sticker_widget/draggable_widget.dart';
// import 'package:lindi_sticker_widget/lindi_controller.dart';
// import 'package:lindi_sticker_widget/lindi_sticker_icon.dart';
// import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:share_plus/share_plus.dart';
//
//
// class ImageEditorScreen extends StatelessWidget {
//   final ImageEditorController _controller = Get.put(ImageEditorController());
//   final ImageFilterController filtercontroller = Get.put(ImageFilterController());
//   final StickerController stickerController = Get.put(StickerController());
//   final CollageController collageController = Get.put(CollageController());
//   final TextEditorControllerWidget textEditorControllerWidget = Get.put(TextEditorControllerWidget());
//   final TemplateController CollageTemplatecontroller = Get.put(TemplateController());
//   final GlobalKey _imageKey = GlobalKey();
//   final GlobalKey _repaintKey = GlobalKey();
//
//   Future<Uint8List?> captureView() async {
//     try {
//       print('Stickers: ${stickerController.stickers.length}, Text: ${textEditorControllerWidget.text.length}');
//       print('LindiController widgets: ${_controller.controller.widgets.length}');
//
//       stickerController.selectedSticker.value = null;
//       textEditorControllerWidget.clearSelection();
//
//       await Future.delayed(Duration(milliseconds: 200));
//
//       final RenderRepaintBoundary? boundary = _repaintKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
//       if (boundary == null) {
//         Get.snackbar("Error", "Failed to find render boundary");
//         return null;
//       }
//       final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
//       final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
//       return byteData?.buffer.asUint8List();
//     } catch (e) {
//       Get.snackbar("Error", "Failed to capture view: $e");
//       return null;
//     }
//   }
//
//   Future<void> saveImage() async {
//     try {
//       final Uint8List? capturedImage = await captureView();
//       if (capturedImage != null) {
//         final dbHelper = DatabaseHelper.instance;
//         await dbHelper.saveImage(capturedImage);
//         Get.snackbar("Success", "Image saved successfully");
//         Get.to(() => SavedImagesScreen());
//       } else {
//         Get.snackbar("Error", "Failed to capture image");
//       }
//     } catch (e) {
//       Get.snackbar("Error", "Failed to save image: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final File image = Get.arguments;
//     _controller.setInitialImage(image);
//     _controller.decodeEditedImage();
//     filtercontroller.setInitialImage(image);
//
//     _controller.controller = LindiController(
//       borderColor: Colors.blue,
//       shouldRotate: true,
//       showBorders: true,
//       icons: [
//         LindiStickerIcon(
//           icon: Icons.rotate_90_degrees_ccw,
//           iconColor: Colors.purple,
//           alignment: Alignment.topRight,
//           type: IconType.resize,
//         ),
//         LindiStickerIcon(
//           icon: Icons.lock_open,
//           alignment: Alignment.topCenter,
//           onTap: () {
//             _controller.controller.clearAllBorders();
//           },
//         ),
//         LindiStickerIcon(
//           icon: Icons.close,
//           alignment: Alignment.topLeft,
//           onTap: () {
//             _controller.controller.selectedWidget!.delete();
//           },
//         ),
//         LindiStickerIcon(
//           icon: Icons.flip,
//           alignment: Alignment.bottomLeft,
//           onTap: () {
//             _controller.controller.selectedWidget!.flip();
//           },
//         ),
//         LindiStickerIcon(
//           icon: Icons.crop_free,
//           alignment: Alignment.bottomRight,
//           type: IconType.resize,
//         ),
//       ],
//     );
//
//     _controller.controller.onPositionChange((index) {
//       debugPrint("widgets size: ${_controller.controller.widgets.length}, current index: $index");
//     });
//
//     return SafeArea(
//       bottom: true,
//       child: Scaffold(
//         resizeToAvoidBottomInset: true,
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           elevation: 0,
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
//             onPressed: () => Get.back(),
//           ),
//           actions: [
//             Padding(
//               padding: EdgeInsets.only(right: 20),
//               child: Row(
//                 children: [
//                   IconButton(
//                     onPressed: () {
//                       _controller.undo();
//                     },
//                     icon: Icon(Icons.undo, color: Colors.white),
//                   ),
//                   SizedBox(width: 10),
//                   IconButton(
//                     onPressed: () {
//                       _controller.redo();
//                     },
//                     icon: Icon(Icons.redo, color: Colors.white),
//                   ),
//                   SizedBox(width: 25),
//                   GestureDetector(
//                     onTap: () {
//                       _controller.showImageLayer.value = true;
//                     },
//                     child: SizedBox(
//                       height: 20,
//                       child: Image.asset('assets/image_layer.png'),
//                     ),
//                   ),
//                   SizedBox(width: 25),
//                   SizedBox(
//                     height: 20,
//                     child: GestureDetector(
//                       onTap: saveImage,
//                       child: Image.asset('assets/Save.png'),
//                     ),
//                   ),
//                   SizedBox(width: 25),
//                   SizedBox(
//                     height: 20,
//                     child: GestureDetector(
//                       onTap: () async {
//                         try {
//                           final Uint8List? capturedImage = await captureView();
//                           if (capturedImage != null) {
//                             final tempDir = await getTemporaryDirectory();
//                             final file = await File('${tempDir.path}/shared_image.png').create();
//                             await file.writeAsBytes(capturedImage);
//
//                             await Share.shareXFiles(
//                               [XFile(file.path)],
//                               text: 'Check out my edited image!',
//                             );
//                           } else {
//                             Get.snackbar("Error", "Failed to capture image");
//                           }
//                         } catch (e) {
//                           Get.snackbar("Error", "Failed to share image: $e");
//                           print("Error sharing image: $e");
//                         }
//                       },
//                       child: Image.asset('assets/Export.png'),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//         body: LayoutBuilder(
//           builder: (context, constraints) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
//
//               if (renderBox != null) {
//                 final position = renderBox.localToGlobal(Offset.zero);
//                 final size = renderBox.size;
//                 print('Image bounds: position=($position), size=($size)');
//               }
//             });
//             return Obx(() {
//               final Uint8List? memoryImage = _controller.editedImageBytes.value;
//               final File? fileImage = _controller.editedImage.value;
//               print('Rebuilding ImageEditorScreen UI, text count: ${textEditorControllerWidget.text.length}');
//               return Stack(
//                 children: [
//                   Container(
//                     height: 700,
//                     child: (_controller.isSelectingText.value == true)
//                         ? SingleChildScrollView(
//                       child: Container(
//                         height: 700,
//                         child: Column(
//                           children: [
//                             Expanded(
//                               child: Obx(() {
//                                 bool isAnyEditOpen = _controller.showEditOptions.value ||
//                                     _controller.showFilterEditOptions.value ||
//                                     _controller.showStickerEditOptions.value ||
//                                     _controller.showtuneOptions.value;
//                                 return RepaintBoundary(
//                                   key: _repaintKey,
//                                   child: LindiStickerWidget(
//                                     controller: _controller.controller,
//                                     child: AnimatedContainer(
//                                       duration: Duration(milliseconds: 200),
//                                       curve: Curves.easeInOut,
//                                       transform: Matrix4.translationValues(0, isAnyEditOpen ? 20 : 0, 0)
//                                         ..scale(isAnyEditOpen ? 0.94 : 1.0),
//                                       child: Padding(
//                                         padding: EdgeInsets.symmetric(horizontal: 10),
//                                         child: Stack(
//                                           alignment: Alignment.center,
//                                           children: [
//                                             Container(
//                                               key: _imageKey,
//                                               child: ColorFiltered(
//                                                 colorFilter: ColorFilter.matrix(
//                                                   _controller.calculateColorMatrix(),
//                                                 ),
//                                                 child: memoryImage != null
//                                                     ? Image.memory(
//                                                   memoryImage,
//                                                   fit: BoxFit.contain,
//                                                 )
//                                                     : (fileImage != null && fileImage.path.isNotEmpty
//                                                     ? Image.file(
//                                                   fileImage,
//                                                   fit: BoxFit.contain,
//                                                 )
//                                                     : Text(
//                                                   "No image loaded",
//                                                   style: TextStyle(color: Colors.white),
//                                                 )),
//                                               ),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ),
//                                   ),
//                                 );
//                               }),
//                             ),
//                             const SizedBox(height: 15),
//                             if (!_controller.showEditOptions.value &&
//                                 !_controller.showFilterEditOptions.value &&
//                                 !_controller.showStickerEditOptions.value &&
//                                 !_controller.showtuneOptions.value &&
//                                 !_controller.TextEditOptions.value &&
//                                 !_controller.CameraEditSticker.value &&
//                                 !collageController.showCollageOption.value &&
//                                 !_controller.showPresetsEditOptions.value &&
//                                 !_controller.showImageLayer.value)
//                               _buildToolBar(context),
//                             if (_controller.showEditOptions.value) _controller.buildEditControls(),
//                             if (_controller.showStickerEditOptions.value)
//                               ShapeSelectorSheet(
//                                 controller: _controller.controller,
//                                 shapeCategories: _controller.shapeCategories,
//                               ),
//                             if (_controller.showImageLayer.value) _controller.buildImageLayerSheet(),
//                             if (_controller.showtuneOptions.value) _controller.TuneEditControls(),
//                             if (_controller.TextEditOptions.value)
//                               _controller.TextEditControls(constraints, _imageKey),
//                             if (_controller.CameraEditSticker.value) _controller.buildEditCamera(),
//                             if (collageController.showCollageOption.value)
//                               CollageTemplatecontroller.openTemplatePickerBottomSheet(),
//                             if (_controller.showFilterEditOptions.value)
//                               _controller.buildFilterControlsSheet(onClose: () {
//                                 _controller.showFilterEditOptions.value = false;
//                               }),
//                             if (_controller.showPresetsEditOptions.value)
//                               _controller.showFilterControlsBottomSheet(context, () {
//                                 _controller.showFilterEditOptions.value = false;
//                               }),
//                           ],
//                         ),
//                       ),
//                     )
//                         : Column(
//                       children: [
//                         Expanded(
//                           child: Obx(() {
//                             bool isAnyEditOpen = _controller.showEditOptions.value ||
//                                 _controller.showFilterEditOptions.value ||
//                                 _controller.showStickerEditOptions.value ||
//                                 _controller.showtuneOptions.value;
//                             return RepaintBoundary(
//                               key: _repaintKey,
//                               child: LindiStickerWidget(
//                                 controller: _controller.controller,
//                                 child: AnimatedContainer(
//                                   duration: Duration(milliseconds: 200),
//                                   curve: Curves.easeInOut,
//                                   transform: Matrix4.translationValues(0, isAnyEditOpen ? 20 : 0, 0)
//                                     ..scale(isAnyEditOpen ? 0.94 : 1.0),
//                                   child: Padding(
//                                     padding: EdgeInsets.symmetric(horizontal: 10),
//                                     child: Stack(
//                                       alignment: Alignment.center,
//                                       children: [
//                                         GestureDetector(
//                                           onScaleStart: (details) {
//                                             _controller.baseScale.value = _controller.scale.value;
//                                           },
//                                           onScaleUpdate: (details) {
//                                             final newScale = (_controller.baseScale.value * details.scale).clamp(1.0, 5.0);
//                                             _controller.scale.value = newScale;
//                                           },
//                                           child: Obx(() {
//                                             return Transform.translate(
//                                               offset: _controller.offset.value,
//                                               child: Transform.scale(
//                                                 scale: _controller.scale.value,
//                                                 child: Container(
//                                                   key: _imageKey,
//                                                   child: ColorFiltered(
//                                                     colorFilter: ColorFilter.matrix(
//                                                       _controller.calculateColorMatrix(),
//                                                     ),
//                                                     child: memoryImage != null
//                                                         ? Image.memory(
//                                                       memoryImage,
//                                                       fit: BoxFit.contain,
//                                                     )
//                                                         : (fileImage != null && fileImage.path.isNotEmpty
//                                                         ? Image.file(
//                                                       fileImage,
//                                                       fit: BoxFit.contain,
//                                                     )
//                                                         : Text(
//                                                       "No image loaded",
//                                                       style: TextStyle(color: Colors.white),
//                                                     )),
//                                                   ),
//                                                 ),
//                                               ),
//                                             );
//                                           }),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             );
//                           }),
//                         ),
//                         SizedBox(height: 15),
//                         if (!_controller.showEditOptions.value &&
//                             !_controller.showFilterEditOptions.value &&
//                             !_controller.showStickerEditOptions.value &&
//                             !_controller.showtuneOptions.value &&
//                             !_controller.TextEditOptions.value &&
//                             !_controller.CameraEditSticker.value &&
//                             !collageController.showCollageOption.value &&
//                             !_controller.showPresetsEditOptions.value &&
//                             !_controller.showImageLayer.value)
//                           _buildToolBar(context),
//                         if (_controller.showEditOptions.value) _controller.buildEditControls(),
//                         if (_controller.showStickerEditOptions.value)
//                           ShapeSelectorSheet(
//                             controller: _controller.controller,
//                             shapeCategories: _controller.shapeCategories,
//                           ),
//                         if (_controller.showImageLayer.value) _controller.buildImageLayerSheet(),
//                         if (_controller.showtuneOptions.value) _controller.TuneEditControls(),
//                         if (_controller.TextEditOptions.value)
//                           _controller.TextEditControls(constraints, _imageKey),
//                         if (_controller.CameraEditSticker.value) _controller.buildEditCamera(),
//                         if (collageController.showCollageOption.value)
//                           CollageTemplatecontroller.openTemplatePickerBottomSheet(),
//                         if (_controller.showFilterEditOptions.value)
//                           _controller.buildFilterControlsSheet(onClose: () {
//                             _controller.showFilterEditOptions.value = false;
//                           }),
//                         if (_controller.showPresetsEditOptions.value)
//                           _controller.showFilterControlsBottomSheet(context, () {
//                             _controller.showFilterEditOptions.value = false;
//                           }),
//                       ],
//                     ),
//                   ),
//                   if (_controller.isFlipping.value)
//                     Positioned.fill(
//                       child: Container(
//                         color: Colors.black.withOpacity(0.8),
//                         child: const Center(
//                           child: CircularProgressIndicator(
//                             strokeWidth: 6.0,
//                             valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
//                           ),
//                         ),
//                       ),
//                     ),
//                 ],
//               );
//             });
//           },
//         ),
//       ),
//     );
//   }
//
//   Widget _cornerControl({
//     required IconData icon,
//     required Color color,
//     void Function()? onTap,
//     void Function(DragUpdateDetails)? onPanUpdate,
//     double scale = 1.0,
//   }) {
//     return GestureDetector(
//       onTap: onTap,
//       onPanUpdate: onPanUpdate,
//       behavior: HitTestBehavior.translucent,
//       child: Container(
//         width: 24 * scale,
//         height: 24 * scale,
//         decoration: BoxDecoration(
//           color: color.withOpacity(0.9),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, size: 16 * scale, color: Colors.white),
//       ),
//     );
//   }
//
//   Widget _buildToolBar(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       decoration: BoxDecoration(
//         color: Color(ColorConst.bottomBarcolor),
//         borderRadius: BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: SingleChildScrollView(
//         scrollDirection: Axis.horizontal,
//         child: Row(
//           children: [
//             _controller.buildToolButton('Rotate', 'assets/rotate.png', () {
//               _controller.showEditOptions.value = true;
//             }),
//             SizedBox(width: 40),
//             _controller.buildToolButton('Tune', 'assets/tune.png', () {
//               _controller.showtuneOptions.value = true;
//             }),
//             SizedBox(width: 40),
//             _controller.buildToolButton('Crop', 'assets/crop.png', () {
//               SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
//               _controller.pickAndCropImage();
//             }),
//             SizedBox(width: 40),
//             _controller.buildToolButton('Text', 'assets/text.png', () {
//               _controller.TextEditOptions.value = true;
//             }),
//             SizedBox(width: 40),
//             _controller.buildToolButton('Camera', 'assets/camera.png', () {
//               _controller.CameraEditSticker.value = true;
//             }),
//             SizedBox(width: 40),
//             _controller.buildToolButton('Filter', 'assets/filter.png', () {
//               _controller.showFilterEditOptions.value = true;
//             }),
//             SizedBox(width: 40),
//             _controller.buildToolButton('Sticker', 'assets/elements.png', () {
//               _controller.showStickerEditOptions.value = true;
//             }),
//             SizedBox(width: 40),
//             _controller.buildToolButton('Collage', 'assets/collage.png', () {
//               collageController.showCollageOption.value = true;
//             }),
//             SizedBox(width: 40),
//             _controller.buildToolButton('Presets', 'assets/presets.png', () {
//               _controller.showPresetsEditOptions.value = true;
//             }),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class Sticker {
//   final String path;
//   final RxDouble top;
//   final RxDouble left;
//   final RxDouble scale;
//   final RxDouble rotation;
//   final RxBool isFlipped;
//
//   Sticker({
//     required this.path,
//     required this.top,
//     required this.left,
//     required this.scale,
//     required this.rotation,
//     required this.isFlipped,
//   });
// }