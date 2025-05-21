import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image/image.dart' as img;
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/image_editor/TuneScreen.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/crop/crop_screen.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stciker_model.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
import 'package:image_editor/screens_ui/image_editor/textScreens.dart';
import 'package:image_editor/screens_ui/image_layer/image_layer_screen.dart';
import 'package:image_editor/screens_ui/presets/presets_model.dart';
import 'package:image_editor/screens_ui/save_file/saved_image_model.dart';
import 'package:image_editor/test.dart';
import 'package:image_editor/undo_redo_add/sticker_screen.dart';
import 'package:image_editor/undo_redo_add/undo_redo_controller.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';

class ImageState {
  final Uint8List? imageBytes; // Stores editedImageBytes
  final File? imageFile; // Stores editedImage
  final Filter? filter; // Stores applied filter (if any)
  final ImagePreset? preset; // Stores applied preset (if any)
  final double? contrast; // Stores tune contrast (if any)
  final double? brightness; // Stores tune brightness (if any)

  ImageState({
    this.imageBytes,
    this.imageFile,
    this.filter,
    this.preset,
    this.contrast,
    this.brightness,
  });
}

class ImageEditorController extends GetxController {
  Rx<File> editedImage = File('').obs;
  Rx<File> LogoStcikerImage = File('').obs;
  final RxBool isSelectingText = false.obs;
  Rx<UndoHistoryController> undoController = UndoHistoryController().obs;

  Rx<Uint8List?> editedImageBytes = Rx<Uint8List?>(null);
  Rx<Uint8List?> flippedImageBytes = Rx<Uint8List?>(null);
  RxBool showEditOptions = false.obs;
  RxBool TextEditOptions = false.obs;
  RxBool CameraEditSticker = false.obs;
  RxBool showStickerEditOptions = false.obs;
  RxBool showImageLayer = false.obs;
  RxBool showFilterEditOptions = false.obs;
  RxBool showPresetsEditOptions = false.obs;
  RxBool showtuneOptions = false.obs;
  var indexvalueOnChange = 0.obs;
  RxBool selectedtapped = false.obs;
  RxBool isAlignmentText = false.obs;
  final Rx<Uint8List?> flippedBytes = Rx<Uint8List?>(null);
  final RxBool isFlipping = false.obs;
  Rxn<img.Image> decodedImage = Rxn<img.Image>();
  var contrast = 0.0.obs;
  var xvalue = 0.0.obs;
  var yvalue = 0.0.obs;

  var brightness = 0.0.obs;
  var opacity = 0.0.obs;
var filePath =''.obs;
  String? fileName;
  List<Filter> filters = presetFiltersList;
  final picker = ImagePicker();
  File? selectedImage;
  RxList selectedimagelayer = [].obs;
  final selectedIndex = RxInt(-1);
  final originalImageBytes = Rxn<Uint8List>();
  final selectedFilter = Rxn<Filter>();
  final ValueNotifier<String> selectedCategory = ValueNotifier<String>("Natural");
  final Rxn<Uint8List> thumbnailBytes = Rxn<Uint8List>();
  final StickerController stickerController = Get.put(StickerController());
  RxBool isBrushSelected = true.obs;
  final RxString selectedTab = 'Font'.obs;
  final indexlayer = ValueNotifier<int>(0);
  late LindiController controller;
  final GlobalKey globalkey = GlobalKey();

  final Rxn<ImagePreset> selectedPreset = Rxn<ImagePreset>();
  final ImageProcessor processor = ImageProcessor();

  final Map<String, List<ImagePreset>> presetCategories = {
    for (var category in PresetCategory.allCategories) category.name: category.presets
  };
  RxDouble scale = 1.0.obs;
  RxDouble baseScale = 1.0.obs;

  // Rx<Offset> offset = Offset.zero.obs;

   Rx<TextEditingController> textController = TextEditingController().obs;
  final offset = Offset.zero.obs;
  final RxList<WidgetWithPosition> undoStack = <WidgetWithPosition>[].obs;
  final RxList<WidgetWithPosition> redoStack = <WidgetWithPosition>[].obs;
  final RxList<ImageState> imageUndoStack = <ImageState>[].obs;
  final RxList<ImageState> imageRedoStack = <ImageState>[].obs;
  var canvasWidth = 300.0.obs;
  var canvasHeight = 300.0.obs;
  int _redoIndex = 0;
  final Map<Key, dynamic> widgetModels = {};


  final Map<String, List<Filter>> filterCategories = {
    "Natural": [
      NoFilter(),
      AdenFilter(),
      AmaroFilter(),
      PerpetuaFilter(),
      WillowFilter(),
      GinghamFilter(),
    ],
    "Warm": [
      MayfairFilter(),
      RiseFilter(),
      ValenciaFilter(),
      HefeFilter(),
      SutroFilter(),
      SierraFilter(),
    ],
    "Cool": [
      HudsonFilter(),
      InkwellFilter(),
      LoFiFilter(),
      MoonFilter(),
      ClarendonFilter(),
      AshbyFilter(),
    ],
    "Vivid": [
      XProIIFilter(),
      NashvilleFilter(),
      EarlybirdFilter(),
      LarkFilter(),
      VesperFilter(),
    ],
    "Soft": [
      SierraFilter(),
      ToasterFilter(),
      BrannanFilter(),
      ReyesFilter(),
      SlumberFilter(),
      JunoFilter(),
    ],
    "Mono": [
      InkwellFilter(),
      WillowFilter(),
      MoonFilter(),
      MavenFilter(),
    ],
    "Vintage": [
      BrooklynFilter(),
      KelvinFilter(),
      WaldenFilter(),
      StinsonFilter(),
    ]
  };

  final Map<String, List<String>> shapeCategories = {
    'abstract_shapes': [
      'assets/abstract_shapes/ab-1.svg',
      'assets/abstract_shapes/ab-2.svg',
      'assets/abstract_shapes/ab-3.svg',
      'assets/abstract_shapes/ab-4.svg',
      'assets/abstract_shapes/ab-5.svg',
      'assets/abstract_shapes/ab-6.svg',
      'assets/abstract_shapes/ab-7.svg',
      'assets/abstract_shapes/ab-8.svg',
      'assets/abstract_shapes/ab-9.svg',
      'assets/abstract_shapes/ab-10.svg',
      'assets/abstract_shapes/ab-11.svg',
      'assets/abstract_shapes/ab-12.svg',
      'assets/abstract_shapes/ab-13.svg',
      'assets/abstract_shapes/ab-14.svg',
      'assets/abstract_shapes/ab-15.svg',
      'assets/abstract_shapes/ab-16.svg',
      'assets/abstract_shapes/ab-17.svg',
    ],
    'arrow': [
      'assets/arrow/arrow01.svg',
      'assets/arrow/arrow02.svg',
      'assets/arrow/arrow03.svg',
      'assets/arrow/arrow04.svg',
      'assets/arrow/arrow05.svg',
      'assets/arrow/arrow06.svg',
      'assets/arrow/arrow07.svg',
      'assets/arrow/arrow08.svg',
      'assets/arrow/arrow09.svg',
      'assets/arrow/arrow010.svg',
      'assets/arrow/arrow011.svg',
      'assets/arrow/arrow012.svg',
      'assets/arrow/arrow013.svg',
      'assets/arrow/arrow014.svg',
      'assets/arrow/arrow015.svg',
      'assets/arrow/arrow016.svg',
      'assets/arrow/arrow017.svg',
      'assets/arrow/arrow018.svg',
      'assets/arrow/arrow019.svg',
      'assets/arrow/arrow020.svg',
      'assets/arrow/arrow021svg',
      'assets/arrow/arrow022.svg',
      'assets/arrow/arrow023.svg',
      'assets/arrow/arrow024.svg',
      'assets/arrow/arrow025.svg',
      'assets/arrow/arrow026.svg',
      'assets/arrow/arrow027.svg',
      'assets/arrow/arrow028.svg',
      'assets/arrow/arrow029svg',
      'assets/arrow/arrow030.svg',
    ],
    'badges': [
      'assets/badges/Badge(1).svg',
      'assets/badges/Badge(2).svg',
      'assets/badges/Badge(3).svg',
      'assets/badges/Badge(4).svg',
      'assets/badges/Badge(5).svg',
      'assets/badges/Badge(6).svg',
      'assets/badges/Badge(7).svg',
      'assets/badges/Badge(8).svg',
      'assets/badges/Badge(9).svg',
      'assets/badges/Badge(10).svg',
      'assets/badges/Badge(11).svg',
      'assets/badges/Badge(12).svg',
      'assets/badges/Badge(13).svg',
      'assets/badges/Badge(14).svg',
      'assets/badges/Badge(15).svg',
      'assets/badges/Badge(16).svg',
      'assets/badges/best offer.svg',
      'assets/badges/best price.svg',
      'assets/badges/Best-price.svg',
      'assets/badges/big sale.svg',
      'assets/badges/big-stock.svg'
    ],
    'banners': [
      'assets/banners/best offer.svg',
      'assets/banners/Big-sale.svg',
      'assets/banners/mega sale.svg',
      'assets/banners/offer-1.svg',
      'assets/banners/offer-01.svg',
      'assets/banners/offer-2.svg',
      'assets/banners/offer-02.svg',
      'assets/banners/sale...svg',
      'assets/banners/Sale.svg',
      'assets/banners/sale 40.svg',
      'assets/banners/sales-01.svg',
      'assets/banners/sales-02.svg',
      'assets/banners/sales-03.svg',
      'assets/banners/sales-04.svg',
      'assets/banners/sales-05.svg',
      'assets/banners/sales-06.svg',
      'assets/banners/sales-07.svg',
      'assets/banners/sales-08.svg',
      'assets/banners/sales-09.svg',
      'assets/banners/sales-10.svg',
      'assets/banners/sales-11.svg',
      'assets/banners/sales-12.svg',
      'assets/banners/sales-13.svg',
      'assets/banners/sales-14.svg',
      'assets/banners/sales-15.svg',
      'assets/banners/sales-16.svg',
      'assets/banners/sales-17.svg',
      'assets/banners/sales-18.svg',
      'assets/banners/sales-19.svg',
      'assets/banners/sales-20.svg',
      'assets/banners/sales-21.svg',
      'assets/banners/sales-22.svg',
      'assets/banners/sales-23.svg',
      'assets/banners/sales-24svg',
      'assets/banners/sales-25.svg',
      'assets/banners/sales-26.svg',
      'assets/banners/sales-27.svg',
      'assets/banners/sales-28.svg',
      'assets/banners/sales-29svg',
      'assets/banners/sales-30.svg',
      'assets/banners/sales-31.svg',
      'assets/banners/sales-32.svg',
      'assets/banners/sales-33.svg',
      'assets/banners/sales-34.svg',
      'assets/banners/sales-35.svg',
    ],
    'basic_shapes': [
      'assets/basic_shapes/add27.svg',
      'assets/basic_shapes/add 27.svg',
      'assets/basic_shapes/adjust contrast 22.svg',
      'assets/basic_shapes/bars 34.svg',
      'assets/basic_shapes/bell.svg',
      'assets/basic_shapes/bookmark 15.svg',
      'assets/basic_shapes/border01.svg',
      'assets/basic_shapes/Box_stroke.svg',
      'assets/basic_shapes/c6ef7fb8.svg',
      'assets/basic_shapes/c6ef7fb81.svg',
      'assets/basic_shapes/Circle.svg',
      'assets/basic_shapes/Circle_stroke.svg',
      'assets/basic_shapes/Circle_with_stroke.svg',
      'assets/basic_shapes/Close.svg',
      'assets/basic_shapes/correct-symbol.svg',
      'assets/basic_shapes/Cube.svg',
      'assets/basic_shapes/dots 35.svg',
      'assets/basic_shapes/download 26.svg',
      'assets/basic_shapes/Forbidden.svg',
      'assets/basic_shapes/half-circle.svg',
    ]
  };

  // final RxList<SavedImage> savedImages = <SavedImage>[].obs;

  @override
  void onInit() async {
    super.onInit();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stickerWidgetBox = LindiStickerWidget.globalKey.currentContext
          ?.findRenderObject() as RenderBox?;
      if (stickerWidgetBox != null) {
        canvasWidth.value = stickerWidgetBox.size.width;
        canvasHeight.value = stickerWidgetBox.size.height;
      }
    });
  }


   saveImageState({
    Filter? filter,
    ImagePreset? preset,
    double? contrast,
    double? brightness,
  }) {
    if (imageUndoStack.length >= 10) {
      imageUndoStack.removeAt(0);
    }
    imageUndoStack.add(ImageState(
      imageBytes: editedImageBytes.value,
      imageFile: editedImage.value.path.isNotEmpty ? editedImage.value : null,
      filter: filter ?? selectedFilter.value,
      preset: preset ?? selectedPreset.value,
      contrast: contrast ?? this.contrast.value,
      brightness: brightness ?? this.brightness.value,
    ));
    imageRedoStack.clear();
    print('Saved image state, imageUndoStack length: ${imageUndoStack.length}');
  }

  void addWidget(Widget sticker, Offset position, var path) {
    try {
      final alignment = Alignment(
        (position.dx / canvasWidth.value) * 2 - 1,
        (position.dy / canvasHeight.value) * 2 - 1,
      );
      final stickerModel = StickerModel(
        path: path,
        top: RxDouble(position.dy),
        left: RxDouble(position.dx),
        scale: RxDouble(1.0),
        rotation: RxDouble(0.0),
        isFlipped: RxBool(false),
      );
      final widgetKey = GlobalKey();

      // Wrap the sticker widget with a Container and assign the GlobalKey
      final wrappedSticker = Container(
        key: widgetKey,
        child: sticker,
      );

      // Add the widget to the controller
      controller.add(wrappedSticker, position: alignment);

      // Store the StickerModel in _widgetModels
      stickerController.stickers.add(stickerModel);
      widgetModels[widgetKey] = stickerModel;

      final addedWidget = controller.widgets.last;
      if (addedWidget.key != widgetKey) {
        debugPrint('Warning: Added widget key differs, forcing GlobalKey');
        // Update the key if necessary (this may require custom logic in LindiController)
      }

      undoStack.add(WidgetWithPosition(
        widget: addedWidget,
        position: position,
        globalKey: widgetKey,
      ));

      redoStack.clear();
      print('Added widget at $position, undoStack length: ${undoStack.length}');
      print('StickerModel added to _widgetModels, key: $widgetKey');
      controller.notifyListeners();
    } catch (e, stackTrace) {
      print('Error adding widget: $e');
      print(stackTrace);
    }
  }

  void editWidget(Widget sticker, Offset position) {
    try {
      final alignment = Alignment(
        (position.dx / canvasWidth.value) * 2 - 1,
        (position.dy / canvasHeight.value) * 2 - 1,
      );

      controller.selectedWidget!.edit(sticker);

      final addedWidget = controller.widgets.last;

      undoStack.add(WidgetWithPosition(
        widget: addedWidget,
        position: position,
        globalKey: GlobalKey(),
      ));

      redoStack.clear();
      print('Edited widget at $position, undoStack length: ${undoStack.length}');
      controller.notifyListeners();
    } catch (e, stackTrace) {
      print('Error editing widget: $e');
      print(stackTrace);
    }
  }

  void undo() {
    if (imageUndoStack.isNotEmpty) {
      final undoneState = imageUndoStack.removeLast();
      imageRedoStack.add(ImageState(
        imageBytes: editedImageBytes.value,
        imageFile: editedImage.value.path.isNotEmpty ? editedImage.value : null,
        filter: selectedFilter.value,
        preset: selectedPreset.value,
        contrast: contrast.value,
        brightness: brightness.value,
      ));

      editedImageBytes.value = undoneState.imageBytes;
      if (undoneState.imageFile != null) {
        editedImage.value = undoneState.imageFile!;
      }
      selectedFilter.value = undoneState.filter;
      selectedPreset.value = undoneState.preset;
      contrast.value = undoneState.contrast ?? 0.0;
      brightness.value = undoneState.brightness ?? 0.0;

      print('Undid image transformation, imageUndoStack length: ${imageUndoStack.length}');
      update();
    }
    else if (undoStack.isNotEmpty) {
      try {
        print('Undo called, undoStack length: ${undoStack.length}');
        final undoneWidgetWithPosition = undoStack.removeLast();
        final undoneWidget = undoneWidgetWithPosition.widget;
        final currentPosition = undoneWidgetWithPosition.position;

        int index = -1;
        for (int i = 0; i < controller.widgets.length; i++) {
          if (controller.widgets[i].key == undoneWidget.key) {
            index = i;
            break;
          }
        }

        if (index != -1) {
          controller.widgets.removeAt(index);
          final alignment = Alignment(
            (currentPosition.dx / canvasWidth.value) * 2 - 1,
            (currentPosition.dy / canvasHeight.value) * 2 - 1,
          );
          controller.add(undoneWidget.child, position: alignment);
          final newWidget = controller.widgets.last;
          redoStack.add(WidgetWithPosition(
            widget: newWidget,
            position: currentPosition,
            globalKey: undoneWidgetWithPosition.globalKey,
          ));
          print('Deleted and re-added widget at index $index, redoStack length: ${redoStack.length}');
        } else {
          print('Warning: Widget with key ${undoneWidget.key} not found in controller.widgets');
        }

        controller.notifyListeners();
      } catch (e, stackTrace) {
        print('Error during widget undo: $e');
        print(stackTrace);
      }
    }
    else {
      controller!.widgets.last.delete();
      print('Nothing to undo');
    }
  }

  void redo() {
    if (imageRedoStack.isNotEmpty) {
      final redoState = imageRedoStack.removeLast();
      imageUndoStack.add(ImageState(
        imageBytes: editedImageBytes.value,
        imageFile: editedImage.value.path.isNotEmpty ? editedImage.value : null,
        filter: selectedFilter.value,
        preset: selectedPreset.value,
        contrast: contrast.value,
        brightness: brightness.value,
      ));

      editedImageBytes.value = redoState.imageBytes;
      if (redoState.imageFile != null) {
        editedImage.value = redoState.imageFile!;
      }
      selectedFilter.value = redoState.filter;
      selectedPreset.value = redoState.preset;
      contrast.value = redoState.contrast ?? 0.0;
      brightness.value = redoState.brightness ?? 0.0;

      print('Redid image transformation, imageRedoStack length: ${imageRedoStack.length}');
      update();
    } else if (redoStack.isNotEmpty) {
      try {
        print('Redo called, redoStack length: ${redoStack.length}');
        final redoWidgetWithPosition = redoStack.removeLast();
        final redoWidget = redoWidgetWithPosition.widget;
        final position = redoWidgetWithPosition.position;

        final alignment = Alignment(
          (position.dx / canvasWidth.value) * 2 - 1,
          (position.dy / canvasHeight.value) * 2 - 1,
        );

        controller.add(redoWidget.child, position: alignment);
        final newWidget = controller.widgets.last;

        undoStack.add(WidgetWithPosition(
          widget: newWidget,
          position: position,
          globalKey: redoWidgetWithPosition.globalKey,
        ));

        print('Redo completed, undoStack length: ${undoStack.length}');
        controller.notifyListeners();
      } catch (e, stackTrace) {
        print('Error during widget redo: $e');
        print(stackTrace);
      }
    } else {
      print('Nothing to redo');
    }
  }

  void setInitialImage(File image)  {
    SchedulerBinding.instance.addPostFrameCallback((_) async {
    editedImage.value = image;
    editedImageBytes.value = null;

    final bytes = await image.readAsBytes();
    originalImageBytes.value = bytes;

    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final img.Image thumb = img.copyResize(decoded, width: 100);
      thumbnailBytes.value = Uint8List.fromList(img.encodeJpg(thumb));
    }; });
  }

  void applyPreset(ImagePreset preset) {
    saveImageState(preset: selectedPreset.value);

    selectedPreset.value = preset;
    if (editedImage.value.path.isEmpty) {
      Get.snackbar("Error", "No image loaded");
      return;
    }

    final img.Image? image = img.decodeImage(editedImage.value.readAsBytesSync());
    if (image == null) {
      Get.snackbar("Error", "Failed to decode image");
      return;
    }

    final processedImage = processor.applyPreset(preset, image);
    final resultBytes = Uint8List.fromList(img.encodeJpg(processedImage));
    editedImageBytes.value = resultBytes;
    update();
  }

  Uint8List? generatePresetThumbnail(ImagePreset preset) {
    final thumb = img.decodeImage(thumbnailBytes.value!);
    if (thumb == null) return null;

    final processedThumb = processor.applyPreset(preset, thumb);
    return Uint8List.fromList(img.encodeJpg(processedThumb));
  }

  List<double> calculateColorMatrix() {
    final c = 1 + contrast.value / 100;
    final b = brightness.value * 255 / 100;

    return [
      c, 0, 0, 0, b,
      0, c, 0, 0, b,
      0, 0, c, 0, b,
      0, 0, 0, 1, 0,
    ];
  }

  Future<void> decodeEditedImage() async {
    if (editedImage.value.path.isNotEmpty) {
      final bytes = await editedImage.value.readAsBytes();
      originalImageBytes.value = bytes;
    }
  }

  void applyFullResolutionFilter(Filter filter) {
    isFlipping.value = true;
    saveImageState(filter: selectedFilter.value);

    if (originalImageBytes.value == null) {
      isFlipping.value = false;
      return;
    }

    final img.Image? image = img.decodeImage(originalImageBytes.value!);
    if (image == null) {
      isFlipping.value = false;
      return;
    }

    final img.Image resized = img.copyResize(image, width: 400);
    final Uint8List pixels = resized.getBytes();
    filter.apply(pixels, resized.width, resized.height);

    final img.Image filteredImage = img.Image.fromBytes(resized.width, resized.height, pixels);
    final Uint8List resultBytes = Uint8List.fromList(img.encodeJpg(filteredImage));

    editedImageBytes.value = resultBytes;
    selectedFilter.value = filter;
    isFlipping.value = false;
    update();
  }

  void applyTune(double contrast, double brightness) {
    saveImageState(contrast: this.contrast.value, brightness: this.brightness.value);

    this.contrast.value = contrast;
    this.brightness.value = brightness;

    if (originalImageBytes.value == null) return;

    final img.Image? image = img.decodeImage(originalImageBytes.value!);
    if (image == null) return;

    final img.Image adjusted = img.adjustColor(
      image,
      contrast: 1 + contrast / 100,
      brightness: brightness / 100,
    );

    final Uint8List resultBytes = Uint8List.fromList(img.encodeJpg(adjusted, quality: 80));
    editedImageBytes.value = resultBytes;
    update();
  }

  Future<void> rotateImage() async {
    saveImageState();

    final Uint8List input = editedImageBytes.value ?? await editedImage.value.readAsBytes();

    final Uint8List? result = await FlutterImageCompress.compressWithList(
      input,
      rotate: 90,
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      editedImageBytes.value = result;
      update();
    }
  }

  Future<void> mirrorImage() async {
    try {
      isFlipping.value = true;
      saveImageState();

      final Uint8List inputBytes = editedImageBytes.value ?? await editedImage.value.readAsBytes();
      final img.Image? original = img.decodeImage(inputBytes);
      if (original == null) {
        print("Failed to decode image");
        isFlipping.value = false;
        return;
      }

      final img.Image resized = img.copyResize(original, width: 1080);
      final img.Image flipped = img.flipHorizontal(resized);

      final Uint8List result = Uint8List.fromList(img.encodeJpg(flipped, quality: 80));
      flippedBytes.value = result;

      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/mirrored_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final file = File(path);
      await file.writeAsBytes(result);

      editedImageBytes.value = result;
      print("Mirror applied and saved");
    } catch (e, stackTrace) {
      print("Mirror error: $e");
      print("StackTrace: $stackTrace");
    } finally {
      isFlipping.value = false;
      update();
    }
  }

  Uint8List flipImageBytes(Uint8List input) {
    final img.Image? original = img.decodeImage(input);
    if (original == null) return input;

    final img.Image resized = img.copyResize(original, width: 1080);
    final img.Image flipped = img.flipHorizontal(resized);

    return Uint8List.fromList(img.encodeJpg(flipped, quality: 80));
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
              title: Text("Apply Filters", style: TextStyle(color: Colors.white)),
              image: image!,
              filters: filters,
              filename: fileName!,
              loader: Center(child: CircularProgressIndicator()),
              fit: BoxFit.contain,
            ),
          ),
        );

        if (filteredResult != null && filteredResult.containsKey('image_filtered')) {
          final File filteredFile = filteredResult['image_filtered'];
          final Uint8List resultBytes = await filteredFile.readAsBytes();
          editedImageBytes.value = resultBytes;
          update();
        }
      }
    }
  }

  Widget buildFilterControlsSheet({required VoidCallback onClose}) {
    return Container(
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10, top: 30, right: 10, bottom: 10),
            child: ValueListenableBuilder(
              valueListenable: selectedCategory,
              builder: (context, category, _) {
                final filters = filterCategories[category]!;

                return SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filters.length,
                    separatorBuilder: (_, __) => SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      var isSelected = selectedFilter.value == filter;

                      final img.Image? thumb = img.decodeImage(thumbnailBytes.value!);
                      if (thumb == null) return SizedBox();

                      final Uint8List thumbPixels = thumb.getBytes();
                      filter.apply(thumbPixels, thumb.width, thumb.height);
                      final img.Image filteredThumb = img.Image.fromBytes(thumb.width, thumb.height, thumbPixels);
                      final Uint8List filteredBytes = Uint8List.fromList(img.encodeJpg(filteredThumb));

                      return GestureDetector(
                        onTap: () {
                          isSelected = true;
                          applyFullResolutionFilter(filter);
                        },
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Color(ColorConst.primaryColor) : Color(ColorConst.greycontainer),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: Image.memory(
                                  filteredBytes,
                                  width: 75,
                                  height: 75,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Text(
                              filter.name,
                              style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: ui.FontWeight.bold),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filterCategories.keys.length,
                      separatorBuilder: (_, __) => SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final categoryName =   filterCategories.keys.elementAt(index);
                        return ValueListenableBuilder(
                          valueListenable: selectedCategory,
                          builder: (context, value, _) {
                            final isSelected = value == categoryName;
                            return GestureDetector(
                              onTap: () => selectedCategory.value = categoryName,
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected ? Color(ColorConst.primaryColor) : Color(ColorConst.greycontainer),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  categoryName,
                                  style: TextStyle(
                                    color: isSelected ? Colors.black : Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 22),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    editedImageBytes.value = originalImageBytes.value;
                    selectedFilter.value = NoFilter();
                    showFilterEditOptions.value = false;
                  },
                  child: SizedBox(
                    height: 30,
                    child: Image.asset('assets/cross.png'),
                  ),
                ),
                Text(
                  'Filters',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20,
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: SizedBox(
                    height: 30,
                    child: Image.asset('assets/right.png'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget buildPresetsControlsSheet({required VoidCallback onClose}) {
    return GetBuilder<ImageEditorController>(
      builder: (controller) {
        return DefaultTabController(
          length: controller.presetCategories.keys.length,
          child: Container(
            decoration: BoxDecoration(
              color: Color(ColorConst.bottomBarcolor),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30, right: 10),
                  child: SizedBox(
                    height: 120,
                    child: TabBarView(
                      children: controller.presetCategories.values.map((presets) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          itemCount: presets.length + 1,
                          separatorBuilder: (_, __) => SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () {
                                  controller.editedImageBytes.value = controller.originalImageBytes.value;
                                  controller.selectedPreset.value = null;
                                  controller.update();
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Color(ColorConst.defaultcontainer),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.transparent),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Original",
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final preset = presets[index - 1];
                            final thumbnailBytes = controller.generatePresetThumbnail(preset);
                            return GestureDetector(
                              onTap: () {
                                controller.applyPreset(preset);
                              },
                              child: Column(
                                children: [
                                  SizedBox(height: 4),
                                  Container(
                                    height: 90,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color(ColorConst.defaultcontainer),
                                      border: Border.all(color: Colors.transparent),
                                    ),
                                    child: Center(
                                      child: Text(
                                        preset.name,
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8),
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  tabs: controller.presetCategories.keys.map((category) {
                    return Tab(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: controller.selectedCategory.value == category
                              ? Color(ColorConst.lightpurple)
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: controller.selectedCategory.value == category ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onTap: (index) {
                    controller.selectedCategory.value = controller.presetCategories.keys.elementAt(index);
                    controller.update();
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.showPresetsEditOptions.value = false;
                          controller.selectedPreset.value = null;
                          controller.update();
                        },
                        child: SizedBox(
                          height: 30,
                          child: Image.asset('assets/cross.png'),
                        ),
                      ),
                      Text(
                        'Presets',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.showPresetsEditOptions.value = false;
                        },
                        child: SizedBox(
                          height: 30,
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
      },
    );
  }

  Widget showFilterControlsBottomSheet(BuildContext context, VoidCallback onClose) {
    return Container(
      child: FilterControlsWidget(),
    );
  }

  Widget buildShapeSelectorSheet() {
    final selectedTabIndex = ValueNotifier<int>(0);

    return ShapeSelectorSheet(controller: controller, shapeCategories: shapeCategories);
  }

  Widget buildImageLayerSheet() {
    final selectedTabIndex = ValueNotifier<int>(0);
    return Container(
      height: 300,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(20),
          topLeft: Radius.circular(20),
        ),
      ),
      child: ImageLayerWidget(),
    );
  }

  Widget buildEditControls() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          _buildActionButton(
            "Mirror Photo",
            Colors.cyan,
            Icons.flip,
                () async {
              await mirrorImage();
            },
          ),
          SizedBox(height: 10),
          _buildActionButton(
            "Rotate",
            Colors.deepPurpleAccent,
            Icons.rotate_right,
                () => rotateImage(),
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  flippedBytes.value = null;
                  showEditOptions.value = false;
                  editedImageBytes.value = null;
                },
                child: SizedBox(
                  height: 30,
                  child: Image.asset('assets/cross.png'),
                ),
              ),
              Text(
                'Rotate',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  showEditOptions.value = false;

                  if (flippedBytes.value != null) {
                    final tempDir = await getTemporaryDirectory();
                    final path = '${tempDir.path}/confirmed_${DateTime.now().millisecondsSinceEpoch}.jpg';
                    final file = File(path);
                    await file.writeAsBytes(flippedBytes.value!);

                    editedImage.value = file;
                    editedImageBytes.value = null;
                    flippedBytes.value = null;
                  }

                  Get.toNamed('/ImageEditorScreen', arguments: editedImage.value);
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

  Widget buildEditCamera() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 20),
          _buildCameraButton(
            "Select Image",
            Colors.cyan,
            Icons.flip,
                () async {
              final ImagePicker picker = ImagePicker();
              final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
              if (photo != null) {
                LogoStcikerImage.value = File(photo.path);
                print('${LogoStcikerImage.value}');
                Widget widget = Container(
                  height: 100,
                  width: 100,
                  padding: EdgeInsets.all(12),
                  child: Image.file(LogoStcikerImage.value),
                );
              }
            },
                (details) async {
              final ImagePicker picker = ImagePicker();
              final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
              if (photo != null) {
                LogoStcikerImage.value = File(photo.path);
                print('${LogoStcikerImage.value}');
                Widget widget = Container(
                  height:  100,
                  width: 100,
                  padding: EdgeInsets.all(12),
                  child: Image.file(LogoStcikerImage.value),
                );
                selectedimagelayer.add(LogoStcikerImage.value);
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
                addWidget(widget, tapPosition,LogoStcikerImage.value);
              }
            },
          ),
          SizedBox(height: 10),
          _buildCameraButton(
            "Change Image",
            Colors.deepPurpleAccent,
            Icons.rotate_right,
                () async {
              final ImagePicker picker = ImagePicker();
              final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
              if (photo != null) {
                LogoStcikerImage.value = File(photo.path);
                print('${LogoStcikerImage.value}');
                Widget widget = Container(
                  height: 100,
                  width: 100,
                  padding: EdgeInsets.all(12),
                  child: Image.file(LogoStcikerImage.value),
                );
              }
            },
                (details) async {
              final ImagePicker picker = ImagePicker();
              final XFile? photo = await picker.pickImage(source: ImageSource.gallery);
              if (photo != null) {
                LogoStcikerImage.value = File(photo.path);
                print('${LogoStcikerImage.value}');
                Widget widget = Container(
                  height: 100,
                  width: 100,
                  padding: EdgeInsets.all(12),
                  child: Image.file(LogoStcikerImage.value),
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
                editWidget(widget, tapPosition);
              }
            },
          ),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  controller.selectedWidget!.delete();
                  CameraEditSticker.value = false;
                },
                child: SizedBox(
                  height: 30,
                  child: Image.asset('assets/cross.png'),
                ),
              ),
              Text(
                'Camera',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  CameraEditSticker.value = false;
                  controller.clearAllBorders();
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

  Future<void> buildCameraStciker() async {
    final ImagePicker picker = ImagePicker();
    final XFile? photo = await picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      File imageFile = File(photo.path);
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        child: Image.file(imageFile),
      );
      controller.add(widget);
    }
  }

  Widget TuneEditControls() {
    return Obx(() => AnimatedContainer(
      duration: Duration(seconds: 1),
      curve: Curves.easeInOut,
      height: (isBrushSelected.value == true) ? 300 : 250,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 50.0, end: 0.0),
        duration: Duration(milliseconds: 400),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return Opacity(
            opacity: (50.0 - value) / 50.0,
            child: Transform.translate(
              offset: Offset(0, value),
              child: child,
            ),
          );
        },
        child: ListView(
          children: [
            TuneControlsPanel(
              onTuneChanged: (double contrast, double brightness) {
                contrast = contrast;
                brightness = brightness;              },
            ),
          ],
        ),
      ),
    ));
  }

  Widget TextEditControls(constraints, imagekey) {
    return Container(
      height: 340,
      padding: EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: TextUIWithTabsScreen(constraints: constraints, imageKey: imagekey),
    );
  }

  Widget buildToolButton(String label, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(height: 22, child: Image.asset(imagePath)),
          SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Outfit')),
        ],
      ),
    );
  }

  Widget _buildActionButton(String text, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white),
            SizedBox(width: 10),
            Text(text, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraButton(String text, Color color, IconData icon, VoidCallback onTap, Function(TapDownDetails) onTapDown) {
    return GestureDetector(
      onTap: onTap,
      onTapDown: onTapDown,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Text(text, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Future<void> pickAndCropImage() async {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: editedImage.value.path,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: '',
          toolbarColor: Color(ColorConst.purplecolor),
          toolbarWidgetColor: Colors.white,
          statusBarColor: Color(ColorConst.textblackcolor),
          activeControlsWidgetColor: Color(ColorConst.purplecolor),
          cropFrameColor: Colors.white,
          cropGridColor: Colors.grey,
          hideBottomControls: false,
          showCropGrid: true,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
        ),
        IOSUiSettings(
          title: 'Crop Image',
        ),
      ],
    );

    if (croppedFile != null) {
      editedImage.value = File(croppedFile.path);
    }
  }

  Future<Uint8List> capturePng() async {
    try {
      RenderRepaintBoundary? boundary = globalkey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
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

      editedImageBytes.value = outputFile.readAsBytesSync();
      editedImage.value = outputFile;

      final Uint8List? memoryImage = editedImageBytes.value;
      final File? fileImage = editedImage.value;

      try {
        if (memoryImage != null) {
          final tempDir = await getTemporaryDirectory();
          final file = await File('${tempDir.path}/shared_image.png').create();
          await file.writeAsBytes(memoryImage);

          await Share.shareXFiles(
            [XFile(file.path)],
            text: 'Check out my edited image!',
          );
        } else if (fileImage != null && await fileImage.exists()) {
          await Share.shareXFiles(
            [XFile(fileImage.path)],
            text: 'Check out my image!',
          );
        } else {
          Get.snackbar("Error", "No image available to share");
        }
      } catch (e) {
        Get.snackbar("Error", "Failed to share image: $e");
      }

      return byteData.buffer.asUint8List();
    } catch (e) {
      print("Capture Image Exception: $e");
      rethrow;
    }
  }
}

class FilterControlsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      builder: (controller) {
        return DefaultTabController(
          length: controller.presetCategories.keys.length,
          child: Container(
            decoration: BoxDecoration(
              color: Color(ColorConst.bottomBarcolor),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 30, right: 10),
                  child: SizedBox(
                    height: 120,
                    child: TabBarView(
                      children: controller.presetCategories.values.map((presets) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          itemCount: presets.length + 1,
                          separatorBuilder: (_, __) => SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              return GestureDetector(
                                onTap: () {
                                  controller.editedImageBytes.value = controller.originalImageBytes.value;
                                  controller.selectedPreset.value = null;
                                  controller.update();
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 90,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Color(ColorConst.defaultcontainer),
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.transparent),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Original",
                                          style: TextStyle(fontSize: 16, color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }

                            final preset = presets[index - 1];
                            final thumbnailBytes = controller.generatePresetThumbnail(preset);
                            return GestureDetector(
                              onTap: () {
                                controller.applyPreset(preset);
                              },
                              child: Column(
                                children: [
                                  SizedBox(height: 4),
                                  Container(
                                    height: 90,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Color(ColorConst.defaultcontainer),
                                      border: Border.all(color: Colors.transparent),
                                    ),
                                    child: Center(
                                      child: Text(
                                        preset.name,
                                        style: TextStyle(fontSize: 16, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
                TabBar(
                  isScrollable: true,
                  labelPadding: EdgeInsets.symmetric(horizontal: 8),
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  tabs: controller.presetCategories.keys.map((category) {
                    return Tab(
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: controller.selectedCategory.value == category
                              ? Color(ColorConst.lightpurple)
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: controller.selectedCategory.value == category ? Colors.black : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onTap: (index) {
                    controller.selectedCategory.value = controller.presetCategories.keys.elementAt(index);
                    controller.update();
                  },
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.showPresetsEditOptions.value = false;
                          controller.selectedPreset.value = null;
                          controller.update();
                        },
                        child: SizedBox(
                          height: 30,
                          child: Image.asset('assets/cross.png'),
                        ),
                      ),
                      Text(
                        'Presets',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.showPresetsEditOptions.value = false;
                        },
                        child: SizedBox(
                          height: 30,
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
      },
    );
  }
}



