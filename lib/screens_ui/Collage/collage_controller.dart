import 'dart:typed_data';
import 'dart:ui';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:image_collage_widget/image_collage_widget.dart';
import 'package:image_collage_widget/utils/collage_type.dart';
import 'package:image_collage_widget/model/images.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/Collage/collage_controller.dart';
import 'package:image_editor/screens_ui/Collage/collage_sample.dart';
import 'package:image_editor/screens_ui/Collage/sample.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';

class CollageController extends GetxController {
  final ImageEditorController imagecontroller =
      Get.put(ImageEditorController());

  var text = ''.obs;
  var selectedCollageType = CollageType.hSplit.obs;
  var selectedfile = Rx<File?>(null);
  var file2 = Rx<File?>(null);
  var file3 = Rx<File?>(null);
  RxBool showCollageOption = false.obs;
  final selectedImages = <Images>[].obs;
  final GlobalKey collageKey = GlobalKey();
  final picker = ImagePicker().obs;
  late RxList<File?> images;
  ScreenshotController screenshotController = ScreenshotController();
  late CollageTemplate selectedTemplate;
  RxBool iselected = false.obs;

  void updateText(String newText) => text.value = newText;

  void selectCollageType(CollageType type) {
    print('object type');
    selectedCollageType.value = type;
    print(selectedCollageType.value);
    update();
    refresh();
  }

  void clear() {
    text.value = '';
    selectedCollageType.value = CollageType.hSplit;
  }

  Future<void> generateData() async {
    file2.value = await getImageFileFromAssets('assets/templates_image.png');
    file3.value = await getImageFileFromAssets('assets/templates_image.png');
  }

  Future<File> getImageFileFromAssets(String path) async {
    final byteData = await DefaultAssetBundle.of(Get.context!).load(path);
    final file = File('${(await getTemporaryDirectory()).path}/$path');
    await file.create(recursive: true);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
    return file;
  }

  Widget showCollageBottomSheet() {
    print('enter in bottomsheet');
    return Container(
      height: 550,
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(left: 8, right: 8),
      child: Column(
        children: [
          SizedBox(height: 16),
          Obx(() {
            return Container(
              height: 400,
              child: RepaintBoundary(
                key: collageKey,
                child: ImageCollageWidget(
                  key: ValueKey(selectedCollageType.value),
                  collageType: selectedCollageType.value,
                  withImage: false,
                  images: selectedImages,
                ),
              ),
            );
          }),
          SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildCollageButton('Two Horizontal', CollageType.hSplit),
                SizedBox(
                  width: 5,
                ),
                _buildCollageButton(
                    'Three Vertical', CollageType.threeVertical),
                SizedBox(
                  width: 5,
                ),
                _buildCollageButton('Grid 2x2', CollageType.fourSquare),
                SizedBox(
                  width: 5,
                ),
                _buildCollageButton('Left', CollageType.leftBig),
                SizedBox(
                  width: 5,
                ),
                _buildCollageButton('NineSquare', CollageType.nineSquare),
                SizedBox(
                  width: 5,
                ),
                _buildCollageButton('Vsplit', CollageType.vSplit),
                SizedBox(
                  width: 5,
                ),
                _buildCollageButton('RightBig', CollageType.rightBig),
                SizedBox(
                  width: 5,
                ),
                _buildCollageButton('FourLeftBig', CollageType.fourLeftBig),
                SizedBox(
                  width: 5,
                ),
                _buildCollageButton('VMiddleTwo', CollageType.vMiddleTwo),
                SizedBox(
                  width: 5,
                ),
                _buildCollageButton('CenterBig', CollageType.centerBig),
              ],
            ),
          ),
          SizedBox(height: 26),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: SizedBox(
                  height: 30,
                  child: Image.asset('assets/cross.png'),
                ),
              ),
              Text(
                'Collage',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              Obx(() {
                bool isButtonEnabled = selectedImages.isNotEmpty;
                return GestureDetector(
                  onTap: () {
                    _capturePng();
                  },
                  child: Opacity(
                    opacity: 1.0,
                    child: SizedBox(
                      height: 30,
                      child: Image.asset('assets/right.png'),
                    ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCollageButton(String text, CollageType type) {
    return Obx(() => ElevatedButton(
          onPressed: () {
            selectCollageType(type);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedCollageType.value == type
                ? Color(ColorConst.lightpurple)
                : Color(ColorConst.greycontainer),
            foregroundColor: selectedCollageType.value == type
                ? Colors.white
                : Colors.white70,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: Text(text),
        ));
  }

  Future<Uint8List> _capturePng() async {
    try {
      Directory dir;
      RenderRepaintBoundary? boundary = collageKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary?;
      await Future.delayed(Duration(milliseconds: 1000));
      if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      } else {
        dir = (await getExternalStorageDirectory())!;
      }
      var image = await boundary?.toImage();
      var byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
      selectedfile.value =
          File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}.png');
      await selectedfile.value!.writeAsBytes(byteData!.buffer.asUint8List());

      Get.to(
        () => CollageSample(selectedCollageType.value, selectedfile.value!),
        transition: Transition.fade,
      );
      // imagecontroller.editedImageBytes.value = selectedfile.value!.readAsBytesSync();
      // imagecontroller.editedImage.value = selectedfile.value!;
      // showCollageOption.value = false;
      return byteData.buffer.asUint8List();
    } catch (e) {
      print("Capture Image Exception Main : $e");
      throw Exception();
    }
  }

  Future<void> pickImage(int index) async {
    final picked = await picker.value.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      images[index] = File(picked.path);
    }
  }

  Widget showTemplatePickerBottomSheet() {
    selectedTemplate = collageTemplates[1];
    // images.value = List<File?>.filled(collageTemplates.length, null);
    return Container(
      height: 550,
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          SizedBox(height: 16),
          // Expanded(
          //   child: Screenshot(
          //     controller: screenshotController,
          //     child: LayoutBuilder(
          //       builder: (context, constraints) {
          //         return Stack(
          //           children: List.generate(selectedTemplate.slots.length, (index) {
          //             final slot = selectedTemplate.slots[index];
          //             return Positioned(
          //               left: slot.left * constraints.maxWidth,
          //               top: slot.top * constraints.maxHeight,
          //               width: slot.width * constraints.maxWidth,
          //               height: slot.height * constraints.maxHeight,
          //               child: GestureDetector(
          //                 onTap: () => pickImage(index),
          //                 child: Container(
          //                   margin:  EdgeInsets.all(2),
          //                   color: Colors.grey.shade300,
          //                   child: images[index] != null
          //                       ? ClipRect(
          //                     child: InteractiveViewer(
          //                       child: Image.file(
          //                         images[index]!,
          //                         fit: BoxFit.cover,
          //                         width: double.infinity,
          //                         height: double.infinity,
          //                       ),
          //                     ),
          //                   )
          //                       :  Center(child: Icon(Icons.add, size: 40)),
          //                 ),
          //               ),
          //             );
          //           }),
          //         );
          //       },
          //     ),
          //   ),
          // ),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(collageTemplates.length, (index) {
                  final template = collageTemplates[index];
                  return GestureDetector(
                    onTap: () {
                      selectedTemplate = template;
                      images.value = List<File?>.filled(
                          selectedTemplate.slots.length, null);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              border: Border.all(color: Colors.white, width: 2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                return Stack(
                                  children: List.generate(template.slots.length,
                                      (slotIndex) {
                                    final slot = template.slots[slotIndex];
                                    return Positioned(
                                      left: slot.left * constraints.maxWidth,
                                      top: slot.top * constraints.maxHeight,
                                      width: slot.width * constraints.maxWidth,
                                      height:
                                          slot.height * constraints.maxHeight,
                                      child: Container(
                                        margin: const EdgeInsets.all(1),
                                        decoration: BoxDecoration(
                                          color: Colors.blueAccent
                                              .withOpacity(0.5),
                                          border: Border.all(
                                              color: Colors.white, width: 1),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                      ),
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedTemplate == template
                                  ? Color(ColorConst.lightpurple)
                                  : Color(ColorConst.greycontainer),
                              foregroundColor: selectedTemplate == template
                                  ? Colors.white
                                  : Colors.white70,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                            ),
                            onPressed: () {},
                            child: Text(
                              template.name.value,
                            ),
                          ),
                          // const SizedBox(height: 8),
                          // Text(
                          //   template.name.value,
                          //   style: const TextStyle(
                          //     fontSize: 14,
                          //     fontWeight: FontWeight.bold,
                          //     color: Colors.white,
                          //   ),
                          //   textAlign: TextAlign.center,
                          // ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          SizedBox(height: 26),

          // Bottom Bar: Cross - Title - Right Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {},
                child: SizedBox(
                  height: 30,
                  child: Image.asset('assets/cross.png'),
                ),
              ),
              const Text(
                'Templates',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Maybe apply selected template or just close
                },
                child: SizedBox(
                  height: 30,
                  child: Image.asset('assets/right.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Example Models
class CollageSlot {
  final double left;
  final double top;
  final double width;
  final double height;

  CollageSlot(
      {required this.left,
      required this.top,
      required this.width,
      required this.height});
}

class CollageTemplate {
  final RxString name;
  final List<CollageSlot> slots;

  CollageTemplate({required this.name, required this.slots});
}

List<CollageTemplate> collageTemplates = [
  // Existing ones...

  // 1. Big Left, Two Right (Right Stacked)
  CollageTemplate(
    name: 'Left Big'.obs,
    slots: [
      CollageSlot(left: 0, top: 0, width: 0.6, height: 1),
      CollageSlot(left: 0.6, top: 0, width: 0.4, height: 0.5),
      CollageSlot(left: 0.6, top: 0.5, width: 0.4, height: 0.5),
    ].obs,
  ),

  // 2. Two Top, Big Bottom
  CollageTemplate(
    name: 'Bottom Big'.obs,
    slots: [
      CollageSlot(left: 0, top: 0, width: 0.5, height: 0.4),
      CollageSlot(left: 0.5, top: 0, width: 0.5, height: 0.4),
      CollageSlot(left: 0, top: 0.4, width: 1, height: 0.6),
    ].obs,
  ),

  // 3. Center Big (Surround)
  CollageTemplate(
    name: 'Center Big'.obs,
    slots: [
      CollageSlot(left: 0.33, top: 0.33, width: 0.34, height: 0.34), // center
      CollageSlot(left: 0, top: 0, width: 0.33, height: 0.33),
      CollageSlot(left: 0.67, top: 0, width: 0.33, height: 0.33),
      CollageSlot(left: 0, top: 0.67, width: 0.33, height: 0.33),
      CollageSlot(left: 0.67, top: 0.67, width: 0.33, height: 0.33),
    ].obs,
  ),

  // 4. 2x3 Vertical Grid
  CollageTemplate(
    name: '2x3 Grid'.obs,
    slots: [
      CollageSlot(left: 0, top: 0, width: 0.5, height: 1 / 3),
      CollageSlot(left: 0.5, top: 0, width: 0.5, height: 1 / 3),
      CollageSlot(left: 0, top: 1 / 3, width: 0.5, height: 1 / 3),
      CollageSlot(left: 0.5, top: 1 / 3, width: 0.5, height: 1 / 3),
      CollageSlot(left: 0, top: 2 / 3, width: 0.5, height: 1 / 3),
      CollageSlot(left: 0.5, top: 2 / 3, width: 0.5, height: 1 / 3),
    ].obs,
  ),

  // 5. Nine Square
  CollageTemplate(
    name: '3x3 Grid'.obs,
    slots: List.generate(
        3,
        (i) => List.generate(
            3,
            (j) => CollageSlot(
                  left: j * (1 / 3),
                  top: i * (1 / 3),
                  width: 1 / 3,
                  height: 1 / 3,
                ))).expand((e) => e).toList().obs,
  ),

  // 6. Left Top Big (L shape)
  CollageTemplate(
    name: 'Four Left Big'.obs,
    slots: [
      CollageSlot(left: 0, top: 0, width: 0.66, height: 0.66),
      CollageSlot(left: 0.66, top: 0, width: 0.34, height: 0.33),
      CollageSlot(left: 0.66, top: 0.33, width: 0.34, height: 0.33),
      CollageSlot(left: 0, top: 0.66, width: 1, height: 0.34),
    ].obs,
  ),

  // 7. V Middle Two
  CollageTemplate(
    name: 'V Middle Two'.obs,
    slots: [
      CollageSlot(left: 0, top: 0, width: 1, height: 0.3),
      CollageSlot(left: 0, top: 0.3, width: 0.5, height: 0.4),
      CollageSlot(left: 0.5, top: 0.3, width: 0.5, height: 0.4),
      CollageSlot(left: 0, top: 0.7, width: 1, height: 0.3),
    ].obs,
  ),

  // 8. Cross Split (like a plus)
  CollageTemplate(
    name: 'Cross Split'.obs,
    slots: [
      CollageSlot(left: 0.33, top: 0, width: 0.34, height: 1), // vertical bar
      CollageSlot(left: 0, top: 0.33, width: 1, height: 0.34), // horizontal bar
    ].obs,
  ),

  // 9. 5 Slots Random (common freestyle)
  CollageTemplate(
    name: 'Freestyle Five'.obs,
    slots: [
      CollageSlot(left: 0.05, top: 0.05, width: 0.4, height: 0.4),
      CollageSlot(left: 0.55, top: 0.1, width: 0.4, height: 0.3),
      CollageSlot(left: 0.1, top: 0.55, width: 0.3, height: 0.35),
      CollageSlot(left: 0.6, top: 0.5, width: 0.35, height: 0.4),
      CollageSlot(left: 0.35, top: 0.35, width: 0.3, height: 0.3),
    ].obs,
  ),
];


class TemplateController extends GetxController {
  final ImageEditorController imagecontroller =
  Get.put(ImageEditorController());
  final CollageController collageController = Get.put(CollageController());

  CollageTemplate selectedTemplate = collageTemplates[0];
  List<File?> images = [];
  final GlobalKey collageKey = GlobalKey();
  var selectedfile = Rx<File?>(null);
  final RxInt selectedSlotIndex = (-1).obs;

  // var selectedSlotIndex = RxInt(-1);
  var isDragging = false.obs;

  @override
  void onInit() {
    super.onInit();
    images = List<File?>.filled(selectedTemplate.slots.length, null);
  }

  void selectTemplate(CollageTemplate template) {
    selectedTemplate = template;
    images = List<File?>.filled(template.slots.length, null);
    selectedSlotIndex.value = -1;
    update();
  }

  void showTemplatePicker() {
    Get.bottomSheet(
      openTemplatePickerBottomSheet(),
      isScrollControlled: true,
    );
  }

  Widget openTemplatePickerBottomSheet() {
    return GetBuilder<TemplateController>(
      builder: (controller) {
        final template = controller.selectedTemplate;
        final anyImageSelected = controller.images.any((img) => img != null);
        return Container(
          height: 550,
          decoration: BoxDecoration(
            color: Color(ColorConst.bottomBarcolor),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 8),
          margin: EdgeInsets.only(bottom: 10, top: 10),
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(top: 25, left: 5, right: 5),
                  child: RepaintBoundary(
                    key: controller.collageKey,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children:
                          List.generate(template.slots.length, (index) {
                            final slot = template.slots[index];
                            final isSelected =
                                controller.selectedSlotIndex.value == index;

                            return Positioned(
                              left: slot.left * constraints.maxWidth,
                              top: slot.top * constraints.maxHeight,
                              width: slot.width * constraints.maxWidth,
                              height: slot.height * constraints.maxHeight,
                              child: DragTarget<int>(
                                onWillAccept: (data) {
                                  controller.isDragging.value = true;
                                  return true;
                                },
                                onLeave: (data) {
                                  controller.isDragging.value = false;
                                },
                                onAccept: (fromIndex) {
                                  final temp = controller.images[index];
                                  controller.images[index] =
                                  controller.images[fromIndex];
                                  controller.images[fromIndex] = temp;
                                  controller.isDragging.value = false;
                                  controller.update();
                                },
                                builder:
                                    (context, candidateData, rejectedData) {
                                  return Draggable<int>(
                                    data: index,
                                    feedback: controller.buildImageContainer(
                                        index,
                                        isDragging: true),
                                    childWhenDragging: Container(
                                      margin: EdgeInsets.all(2),
                                      color: Colors.grey.shade300,
                                      child: Center(
                                          child: Icon(Icons.add, size: 40)),
                                    ),
                                    child: GestureDetector(
                                      onTap: () {
                                        controller.selectedSlotIndex.value =
                                            index;
                                        controller.pickImage(index);
                                      },
                                      child: Container(
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.yellowAccent
                                                  : Colors.transparent,
                                              width: 3,
                                            ),
                                          ),
                                          child: Stack(
                                            children: [
                                              controller
                                                  .buildImageContainer(index),
                                              controller.images[index] != null
                                                  ? Text('')
                                                  : Positioned(
                                                left: 20,
                                                top: 160,
                                                child: Center(
                                                  child: isSelected
                                                      ? Text(
                                                    'Tap to add image',
                                                    style: TextStyle(
                                                        color: Colors
                                                            .yellow,
                                                        fontWeight:
                                                        FontWeight
                                                            .bold,
                                                        fontSize:
                                                        15),
                                                  )
                                                      : Icon(Icons.add,
                                                      size: 40,
                                                      color: Colors
                                                          .white24),
                                                ),
                                              ),
                                            ],
                                          )

                                        // child: controller.images[index] != null
                                        //     ? controller.buildImageContainer(index)
                                        //     : Center(
                                        //   child: isSelected
                                        //       ? Text(
                                        //     'Tap to add image',
                                        //     style: TextStyle(color: Colors.white70),
                                        //   )
                                        //       : Icon(Icons.add, size: 40, color: Colors.white24),
                                        // ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(collageTemplates.length, (index) {
                      final template = collageTemplates[index];
                      return GestureDetector(
                        onTap: () {
                          controller.selectTemplate(template);
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 8),
                          width: 120,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                  controller.selectedTemplate == template
                                      ? Color(ColorConst.lightpurple)
                                      : Color(ColorConst.greycontainer),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed: () {
                                  controller.selectTemplate(template);
                                },
                                child: Text(template.name.value),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      collageController.showCollageOption.value = false;

                    },
                    child: SizedBox(
                      height: 30,
                      child: Image.asset('assets/cross.png'),
                    ),
                  ),
                  const Text(
                    'Collages',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  GestureDetector(
                    onTap: anyImageSelected
                        ? () {
                      controller._capturePng();
                      controller.selectedSlotIndex.value =
                      -1; // Deselect slot
                      controller.update();
                    }
                        : null,
                    child: Opacity(
                      opacity: anyImageSelected ? 1.0 : 0.5,
                      child: SizedBox(
                        height: 30,
                        child: Image.asset('assets/right.png'),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30,)
            ],
          ),
        );
      },
    );
  }

  Widget buildImageContainer(int index, {bool isDragging = false}) {
    return Container(
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
      ),
      child: images.length > index && images[index] != null
          ? ClipRect(
        child: Image.file(
          images[index]!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
        ),
      )
          : Center(child: Icon(Icons.add, size: 40)),
    );
  }

  Future<void> pickImage(int index) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      images[index] = File(pickedFile.path);
      update();
    }
  }

  Future<Uint8List> _capturePng() async {
    try {
      RenderRepaintBoundary? boundary = collageKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) throw Exception("Boundary is null");

      await Future.delayed(Duration(milliseconds: 300));


      double pixelRatio = ui.window.devicePixelRatio * 2;

      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) throw Exception("Failed to get image bytes");

      Directory dir = Platform.isIOS
          ? await getApplicationDocumentsDirectory()
          : (await getExternalStorageDirectory())!;

      File outputFile = File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}.png');
      await outputFile.writeAsBytes(byteData.buffer.asUint8List());

      selectedfile.value = outputFile;
      imagecontroller.editedImageBytes.value = outputFile.readAsBytesSync();
      imagecontroller.editedImage.value = outputFile;
      collageController.showCollageOption.value = false;

      return byteData.buffer.asUint8List();
    } catch (e) {
      print("Capture Image Exception: $e");
      rethrow;
    }
  }

}
// class TemplatePickerScreen extends StatelessWidget {
//   final TemplateController controller = Get.put(TemplateController());
//
//   TemplatePickerScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: showTemplatePickerBottomSheet(),
//     );
//   }
//
//   Widget showTemplatePickerBottomSheet() {
//     return Container(
//       height: 550,
//       decoration: const BoxDecoration(
//         color: Colors.black,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       padding: const EdgeInsets.symmetric(horizontal: 8),
//       child: Column(
//         children: [
//           const SizedBox(height: 16),
//
//           // Main Template Preview
//           Expanded(
//             child: Obx(
//                   () => LayoutBuilder(
//                 builder: (context, constraints) {
//                   final template = controller.selectedTemplate.value;
//                   return Stack(
//                     children: List.generate(template.slots.length, (index) {
//                       final slot = template.slots[index];
//                       return Positioned(
//                         left: slot.left * constraints.maxWidth,
//                         top: slot.top * constraints.maxHeight,
//                         width: slot.width * constraints.maxWidth,
//                         height: slot.height * constraints.maxHeight,
//                         child: GestureDetector(
//                           onTap: () {
//                             // pickImage(index); // You can add image picking here
//                           },
//                           child: Container(
//                             margin: const EdgeInsets.all(2),
//                             color: Colors.grey.shade300,
//                             child: controller.images.length > index && controller.images[index] != null
//                                 ? ClipRect(
//                               child: Image.file(
//                                 controller.images[index]!,
//                                 fit: BoxFit.cover,
//                               ),
//                             )
//                                 : const Center(child: Icon(Icons.add, size: 40)),
//                           ),
//                         ),
//                       );
//                     }),
//                   );
//                 },
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           // Templates list
//           SizedBox(
//             height: 150,
//             child: SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children: List.generate(collageTemplates.length, (index) {
//                   final template = collageTemplates[index];
//                   return GestureDetector(
//                     onTap: () {
//                       controller.selectTemplate(template);
//                     },
//                     child: Container(
//                       margin: const EdgeInsets.symmetric(horizontal: 8),
//                       width: 120,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Container(
//                             width: 100,
//                             height: 100,
//                             decoration: BoxDecoration(
//                               color: Colors.grey.shade200,
//                               border: Border.all(color: Colors.white, width: 2),
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                             child: LayoutBuilder(
//                               builder: (context, constraints) {
//                                 return Stack(
//                                   children: List.generate(template.slots.length, (slotIndex) {
//                                     final slot = template.slots[slotIndex];
//                                     return Positioned(
//                                       left: slot.left * constraints.maxWidth,
//                                       top: slot.top * constraints.maxHeight,
//                                       width: slot.width * constraints.maxWidth,
//                                       height: slot.height * constraints.maxHeight,
//                                       child: Container(
//                                         margin: const EdgeInsets.all(1),
//                                         decoration: BoxDecoration(
//                                           color: Colors.blueAccent.withOpacity(0.5),
//                                           border: Border.all(color: Colors.white, width: 1),
//                                           borderRadius: BorderRadius.circular(4),
//                                         ),
//                                       ),
//                                     );
//                                   }),
//                                 );
//                               },
//                             ),
//                           ),
//                           const SizedBox(height: 8),
//                           Text(
//                             template.name.value,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.white,
//                             ),
//                             textAlign: TextAlign.center,
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 }),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 16),
//
//           // Bottom Bar
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               GestureDetector(
//                 onTap: () {
//                   Get.back();
//                 },
//                 child: SizedBox(
//                   height: 30,
//                   child: Image.asset('assets/cross.png'),
//                 ),
//               ),
//               const Text(
//                 'Templates',
//                 style: TextStyle(
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   fontSize: 20,
//                 ),
//               ),
//               GestureDetector(
//                 onTap: () {
//                   // Maybe apply selected template or just close
//                   Get.back();
//                 },
//                 child: SizedBox(
//                   height: 30,
//                   child: Image.asset('assets/right.png'),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
