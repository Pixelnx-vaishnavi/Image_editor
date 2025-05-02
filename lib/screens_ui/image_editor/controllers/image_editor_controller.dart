import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stickers_controller.dart';
import 'package:image_editor/screens_ui/image_editor/textScreens.dart';
import 'package:image_editor/screens_ui/image_layer/image_layer_screen.dart';
import 'package:image_editor/screens_ui/presets/presets_model.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photofilters/photofilters.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:share_plus/share_plus.dart';


class ImageEditorController extends GetxController {
  Rx<File> editedImage = File('').obs;
  Rx<File> LogoStcikerImage = File('').obs;
  final RxBool isSelectingText = false.obs;

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
  RxBool selectedtapped = false.obs;
  RxBool isAlignmentText = false.obs;
  final Rx<Uint8List?> flippedBytes = Rx<Uint8List?>(null);
  final RxBool isFlipping = false.obs;
  Rxn<img.Image> decodedImage = Rxn<img.Image>();
  var contrast = 0.0.obs;
  var brightness = 0.0.obs;
  var opacity = 0.0.obs;

  String? fileName;
  List<Filter> filters = presetFiltersList;
  final picker = ImagePicker();
  File? selectedImage;
  final Rxn<String> selectedimage = Rxn<String>();
  final originalImageBytes = Rxn<Uint8List>();
  final selectedFilter = Rxn<Filter>();
  final ValueNotifier<String> selectedCategory = ValueNotifier<String>("Natural");
  final Rxn<Uint8List> thumbnailBytes = Rxn<Uint8List>();
  final StickerController stickerController = Get.put(StickerController());
  RxBool isBrushSelected = true.obs;
  final RxString selectedTab = 'Font'.obs;
  late LindiController controller;
  final GlobalKey globalkey = GlobalKey();

  final Rxn<ImagePreset> selectedPreset = Rxn<ImagePreset>();
  final ImageProcessor processor = ImageProcessor();
  // RxBool isFlipping = false.obs;

  final Map<String, List<ImagePreset>> presetCategories = {
    for (var category in PresetCategory.allCategories) category.name: category.presets
  };
  // late FilterPreset selectedPreset;

  // final selectedPresetsCategory= ValueNotifier<String>('Creative');
  String selectedPresetsCategory = "Natural";  // Default category

  // // The current selected filter preset
  // FilterPreset selectedPreset = FilterPreset(name:"Creative", filters: []);
  //
  //  List<Map<String, dynamic>> presetCategories = [
  //   {
  //     "name": "Creative",
  //     "presets": [
  //       {
  //         "name": "Vintage Glow",
  //         "filters": [
  //           {"name": "CISepiaTone", "inputIntensity": 0.7},
  //           {
  //             "name": "CIColorControls",
  //             "inputBrightness": 0.1,
  //             "inputContrast": 1.1,
  //             "inputSaturation": 0.9
  //           },
  //           {"name": "CIVignette", "inputIntensity": 1.0, "inputRadius": 1.5},
  //         ],
  //       },
  //       {
  //         "name": "Dreamy Haze",
  //         "filters": [
  //           {"name": "CIGaussianBlur", "inputRadius": 2.0},
  //           {
  //             "name": "CIColorControls",
  //             "inputBrightness": 0.2,
  //             "inputSaturation": 0.8
  //           },
  //           {"name": "CIOverlayBlendMode", "inputBackgroundImage": "white_overlay"},
  //         ],
  //       },
  //       {
  //         "name": "Pop Art",
  //         "filters": [
  //           {"name": "CIColorPosterize", "inputLevels": 6.0},
  //           {
  //             "name": "CIColorControls",
  //             "inputContrast": 1.3,
  //             "inputSaturation": 1.5
  //           },
  //         ],
  //       },
  //       {
  //         "name": "Surreal",
  //         "filters": [
  //           {"name": "CIKaleidoscope", "inputCount": 8, "inputAngle": 0.2},
  //           {"name": "CIColorControls", "inputSaturation": 1.2},
  //         ],
  //       },
  //       {
  //         "name": "Comic Effect",
  //         "filters": [
  //           {"name": "CIComicEffect"},
  //           {"name": "CIColorControls", "inputBrightness": 0.1, "inputContrast": 1.1},
  //         ],
  //       },
  //     ],
  //   },
  //   {
  //     "name": "Natural",
  //     "presets": [
  //       {
  //         "name": "No Filter",
  //         "filters": [],
  //       },
  //       {
  //         "name": "Aden",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": 0.1, "inputSaturation": 1.2},
  //         ],
  //       },
  //       {
  //         "name": "Amaro",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": -0.2, "inputSaturation": 0.8},
  //         ],
  //       },
  //     ],
  //   },
  //   {
  //     "name": "Warm",
  //     "presets": [
  //       {
  //         "name": "Mayfair",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": 0.3, "inputSaturation": 1.5},
  //         ],
  //       },
  //       {
  //         "name": "Rise",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": 0.0, "inputSaturation": 1.0},
  //         ],
  //       },
  //       {
  //         "name": "Valencia",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": 0.2, "inputSaturation": 1.3},
  //         ],
  //       },
  //     ],
  //   },
  //   {
  //     "name": "Cool",
  //     "presets": [
  //       {
  //         "name": "Hudson",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": -0.1, "inputSaturation": 1.1},
  //         ],
  //       },
  //       {
  //         "name": "Inkwell",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": 0.0, "inputSaturation": 0.9},
  //         ],
  //       },
  //       {
  //         "name": "Lo-Fi",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": 0.2, "inputSaturation": 1.0},
  //         ],
  //       },
  //     ],
  //   },
  //   {
  //     "name": "Vivid",
  //     "presets": [
  //       {
  //         "name": "X-Pro II",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": 0.4, "inputSaturation": 1.6},
  //         ],
  //       },
  //       {
  //         "name": "Nashville",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": 0.3, "inputSaturation": 1.2},
  //         ],
  //       },
  //       {
  //         "name": "Earlybird",
  //         "filters": [
  //           {"name": "CIColorControls", "inputBrightness": -0.1, "inputSaturation": 1.4},
  //         ],
  //       },
  //     ],
  //   },
  // ];


  void setInitialImage(File image) async {
    editedImage.value = image;
    editedImageBytes.value = null;

    final bytes = await image.readAsBytes();
    originalImageBytes.value = bytes;

    final img.Image? decoded = img.decodeImage(bytes);
    if (decoded != null) {
      final img.Image thumb = img.copyResize(decoded, width: 100); // Smaller thumbnail
      thumbnailBytes.value = Uint8List.fromList(img.encodeJpg(thumb));
    }
  }

  void applyPreset(ImagePreset preset) {
    selectedPreset.value = preset;
    if (editedImage.value == null) {
      Get.snackbar("Error", "No image loaded");
      return;
    }

    final img.Image? image = img.decodeImage(editedImage.value.readAsBytesSync());
    if (image == null) {
      isFlipping.value = false;
      Get.snackbar("Error", "Failed to decode image");
      return;
    }

    final processedImage = processor.applyPreset(preset, image);
    final resultBytes = Uint8List.fromList(img.encodeJpg(processedImage));
    editedImageBytes.value = resultBytes;
    update();
    //
    // getTemporaryDirectory().then((tempDir) {
    //   final path = '${tempDir.path}/preset_${DateTime.now().microsecondsSinceEpoch}.jpg';
    //   final file = File(path);
    //   file.writeAsBytes(resultBytes).then((_) {
    //     editedImage.value = file;
    //     isFlipping.value = false;
    //     update(); // Notify GetBuilder
    //   });
    // });
  }

  Uint8List? generatePresetThumbnail(ImagePreset preset) {
    final thumb = img.decodeImage(thumbnailBytes.value!);
    if (thumb == null) return null;

    final processedThumb = processor.applyPreset(preset, thumb);
    return Uint8List.fromList(img.encodeJpg(processedThumb));}

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
    'banners':[
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
      'assets/banners/sales-05.svg'
      'assets/banners/sales-06.svg'
      'assets/banners/sales-07.svg'
      'assets/banners/sales-08.svg'
      'assets/banners/sales-09.svg'
      'assets/banners/sales-10.svg'
      'assets/banners/sales-11.svg'
      'assets/banners/sales-12.svg'
      'assets/banners/sales-13.svg'
      'assets/banners/sales-14.svg'
      'assets/banners/sales-15.svg'
      'assets/banners/sales-16.svg'
      'assets/banners/sales-17.svg'
      'assets/banners/sales-18.svg'
      'assets/banners/sales-19.svg'
      'assets/banners/sales-20.svg'
      'assets/banners/sales-21.svg'
      'assets/banners/sales-22.svg'
      'assets/banners/sales-23.svg'
      'assets/banners/sales-24svg'
      'assets/banners/sales-25.svg'
      'assets/banners/sales-26.svg'
      'assets/banners/sales-27.svg'
      'assets/banners/sales-28.svg'
      'assets/banners/sales-29svg'
      'assets/banners/sales-30.svg'
      'assets/banners/sales-31.svg'
      'assets/banners/sales-32.svg'
      'assets/banners/sales-33.svg'
      'assets/banners/sales-34.svg'
      'assets/banners/sales-35.svg'
    ],
    'basic_shapes':[
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


  // void setInitialImage(File image) async {
  //   editedImage.value = image;
  //   editedImageBytes.value = null;
  //
  //   final bytes = await image.readAsBytes();
  //   originalImageBytes.value = bytes;
  //
  //   final img.Image? decoded = img.decodeImage(bytes);
  //   if (decoded != null) {
  //     final img.Image thumb = img.copyResize(decoded, width: 120);
  //     thumbnailBytes.value = Uint8List.fromList(img.encodeJpg(thumb));
  //   }
  // }

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
    if (originalImageBytes.value == null) return;
    print('entered');


    final img.Image? image = img.decodeImage(originalImageBytes.value!);
    if (image == null) return;

    // final image = img.decodeImage(originalImageBytes.value!);
    final resized = img.copyResize(image, width: 400);
    final pixels = resized.getBytes();
    filter.apply(pixels, resized.width, resized.height);

    // final Uint8List pixels = image.getBytes();
    // filter.apply(pixels, image.width, image.height);

    final img.Image filteredImage = img.Image.fromBytes( resized.width,  resized.height,pixels);
    final Uint8List resultBytes = Uint8List.fromList(img.encodeJpg(filteredImage));

    editedImageBytes.value = resultBytes;
    selectedFilter.value = filter;
    isFlipping.value = false;
  }

//==================ROTATE==============
  Future<void> rotateImage() async {
    final Uint8List input = editedImageBytes.value ?? await editedImage.value.readAsBytes();

    final Uint8List? result = await FlutterImageCompress.compressWithList(
      input,
      rotate: 90,
      format: CompressFormat.jpeg,
    );

    if (result != null) {
      editedImageBytes.value = result;
    }
  }


//=============FLIP===IMAGE============
  Uint8List flipImageBytes(Uint8List input) {
    final img.Image? original = img.decodeImage(input);
    if (original == null) return input;

    final img.Image resized = img.copyResize(original, width: 1080);
    final img.Image flipped = img.flipHorizontal(resized);

    return Uint8List.fromList(img.encodeJpg(flipped, quality: 80));
  }

//=================MIRRORIMAGE=================
  Future<void> mirrorImage() async {
    try {
      isFlipping.value = true;

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
      isFlipping.value = false; // Stop loader
    }
  }


  //====================FILTERSIMAGE===============
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
              // appBarColor: Color(ColorConst.),
              title:  Text("Apply Filters",style: TextStyle(color: Colors.white),),
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

  Widget buildFilterControlsSheet({required VoidCallback onClose}) {
    return Container(
      decoration:  BoxDecoration(
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
            padding:  EdgeInsets.only(left: 10,top: 30,right: 10,bottom: 10),
            child: ValueListenableBuilder(
              valueListenable: selectedCategory,
              builder: (context, category, _) {
                final filters = filterCategories[category]!;

                return SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding:  EdgeInsets.symmetric(horizontal: 12),
                    itemCount: filters.length,
                    separatorBuilder: (_, __) =>  SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final filter = filters[index];
                      var isSelected = index == filter;

                      final img.Image? thumb = img.decodeImage(thumbnailBytes.value!);
                      if (thumb == null) return  SizedBox();

                      final Uint8List thumbPixels = thumb.getBytes();
                      filter.apply(thumbPixels, thumb.width, thumb.height);
                      final img.Image filteredThumb = img.Image.fromBytes( thumb.width,  thumb.height, thumbPixels);
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
                                // borderRadius: BorderRadius.circular(20),
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
                              style:  TextStyle(fontSize: 12, color: Colors.white,fontWeight: ui.FontWeight.bold),
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
            padding:  EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: filterCategories.keys.length,
                      separatorBuilder: (_, __) =>  SizedBox(width: 12),
                      itemBuilder: (context, index) {
                        final categoryName = filterCategories.keys.elementAt(index);
                        return ValueListenableBuilder(
                          valueListenable: selectedCategory,
                          builder: (context, value, _) {
                            final isSelected = value == categoryName;
                            return GestureDetector(
                              onTap: () => selectedCategory.value = categoryName,
                              child: Container(
                                padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                // IconButton(
                //   icon:  Icon(Icons.close, color: Colors.white),
                //   onPressed: onClose,
                // ),
              ],
            ),
          ),
          Padding(
            padding:  EdgeInsets.symmetric(horizontal: 18, vertical: 22),
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
          SizedBox(height: 20,)
        ],
      ),
    );
  }


  Widget buildPresetsControlsSheet({required VoidCallback onClose}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:  EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: filterCategories.keys.length,
                    separatorBuilder: (_, __) =>  SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final categoryName = filterCategories.keys.elementAt(index);
                      return ValueListenableBuilder(
                        valueListenable: selectedCategory,
                        builder: (context, value, _) {
                          final isSelected = value == categoryName;
                          return GestureDetector(
                            onTap: () => selectedCategory.value = categoryName,
                            child: Container(
                              padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.grey[800],
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
              IconButton(
                icon:  Icon(Icons.close, color: Colors.white),
                onPressed: onClose,
              ),
            ],
          ),
        ),

        SizedBox(height: 12),

        // Filters based on selected category
        ValueListenableBuilder(
          valueListenable: selectedCategory,
          builder: (context, category, _) {
            final filters = filterCategories[category]!;
            return SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:  EdgeInsets.symmetric(horizontal: 12),
                itemCount: filters.length,
                separatorBuilder: (_, __) =>  SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final filter = filters[index];
                  final img.Image? thumb = img.decodeImage(thumbnailBytes.value!);
                  if (thumb == null) return  SizedBox();

                  final Uint8List thumbPixels = thumb.getBytes();
                  filter.apply(thumbPixels, thumb.width, thumb.height);
                  final img.Image filteredThumb = img.Image.fromBytes(  thumb.width, thumb.height,  thumbPixels);
                  final Uint8List filteredBytes = Uint8List.fromList(img.encodeJpg(filteredThumb));

                  return GestureDetector(
                    onTap: () {
                      applyFullResolutionFilter(filter);
                    },
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            filteredBytes,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          filter.name,
                          style:  TextStyle(fontSize: 12, color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }


  Widget showFilterControlsBottomSheet(BuildContext context, VoidCallback onClose) {
    return Container(
      child: FilterControlsWidget(),
    );

      showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: MediaQuery.of(context).viewInsets,
          child: FilterControlsWidget(),
        );
      },
    );
  }


/////////////SHAPE========SELECTOR======IMAGE
  Widget buildShapeSelectorSheet() {
    final selectedTabIndex = ValueNotifier<int>(0);

    return DefaultTabController(
      length: shapeCategories.keys.length,
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
                children: shapeCategories.values.map((imagePaths) {
                  return GridView.builder(
                    padding:  EdgeInsets.all(12),
                    itemCount: imagePaths.length,
                    gridDelegate:  SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      final path = imagePaths[index];
                      return GestureDetector(
                        onTap: () {
                          selectedimage.value = path;
                          print('Selected: ${selectedimage.value}');
                          // stickerController.addSticker(path);
                          Widget widget = Container(
                            height: 100,
                            width: 100,
                            padding: EdgeInsets.all(12),
                            child: SvgPicture.asset(path),
                          );
                          controller.add(widget);
                          // Add to canvas here
                        },
                        child: Column(
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              padding:  EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade800,
                              ),
                              child:  SvgPicture.asset(
                                path,
                              ),
                            ),
                            // const SizedBox(height: 4),
                            // Text(
                            //   path.split('/').last,
                            //   style: const TextStyle(fontSize: 12, color: Colors.white),
                            //   overflow: TextOverflow.ellipsis,
                            // ),
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
                  labelPadding:  EdgeInsets.symmetric(horizontal: 8),
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  tabs: shapeCategories.keys.toList().asMap().entries.map((entry) {
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
                          // border: Border.all(
                          //   color: index == currentIndex ? Colors.purple.withOpacity(0.4) : Colors.grey,
                          // ),
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
                  GestureDetector(
                    onTap: () {
                      // controller.deleted;
                      stickerController.clearStickers();
                      // Get.toNamed('/ImageEditorScreen', arguments: editedImage.value);
                      flippedBytes.value = null;
                      showStickerEditOptions.value = false;
                      editedImageBytes.value = null;
                    },
                    child: SizedBox(
                      height: 40,
                      child: Image.asset('assets/cross.png'),
                    ),
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
      child: ImageLayerWidget()
    );
  }


////////////===========ROTATE AND MIRROR BOTTOM SHEET=============
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
                    // editedImageBytes.value = flippedBytes.value;
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
          )
        ],
      ),
    );
  }


  ///////===================brightnedd $ Contrast

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.black,
  //     body: Column(
  //       children: [
  //         Expanded(
  //           child: Center(
  //             child: Text("Image/Editor Area", style: TextStyle(color: Colors.white)),
  //           ),
  //         ),
  //         const TuneControlsPanel(), // This is the fixed panel
  //       ],
  //     ),
  //   );
  // }


  /// camera sticker===================

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
                    print('${ LogoStcikerImage.value}');
                    Widget widget = Container(
                      height: 100,
                      width: 100,
                      padding: EdgeInsets.all(12),
                      child: Image.file( LogoStcikerImage.value),
                    );
                    controller.add(widget);
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
                print('${ LogoStcikerImage.value}');
                Widget widget = Container(
                  height: 100,
                  width: 100,
                  padding: EdgeInsets.all(12),
                  child: Image.file( LogoStcikerImage.value),
                );
                controller.selectedWidget!.edit(widget);
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
          )
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
    return AnimatedContainer(
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
                brightness = brightness;
              },
            ),
          ],
        ),
      ),
    );
  }


  Widget TextEditControls(contrainsts,imagekey) {
    return Container(
        height:  340,
        // height: (isAlignmentText.value == true) ? 320 : 400,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Color(ColorConst.bottomBarcolor),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: TextUIWithTabsScreen(constraints: contrainsts,imageKey: imagekey,));
  }


  // Widget TuneEditControls() {
  //   return Column(
  //     children: [
  //       Slider(
  //         value: contrast.value,
  //         min: -100,
  //         max: 100,
  //         label: "Contrast",
  //         onChanged: (val) => contrast.value = val,
  //       ),
  //       Slider(
  //         value: brightness.value,
  //         min: -100,
  //         max: 100,
  //         label: "Brightness",
  //         onChanged: (val) => brightness.value = val,
  //       ),
  //     ],
  //   );
  // }


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

  Widget _buildCameraButton(String text, Color color, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(10)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon(icon, color: Colors.white),
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

    // SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
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

      // selectedfile.value = outputFile;
     editedImageBytes.value = outputFile.readAsBytesSync();
      editedImage.value = outputFile;
      // final controller = Get.find<ImageEditorController>();
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



  //
  // void applyPreset(FilterPreset preset) {
  //   selectedPreset = preset;
  // }
  //
  // List<FilterPreset> getPresetsByCategory(String categoryName) {
  //   final category = presetCategories.firstWhere(
  //         (cat) => cat["name"] == categoryName,
  //     orElse: () => {"presets": []},
  //   );
  //
  //   return List<Map<String, dynamic>>.from(category["presets"])
  //       .map((presetMap) => FilterPreset(
  //     name: presetMap["name"],
  //     filters: List<Map<String, dynamic>>.from(presetMap["filters"]),
  //   ))
  //       .toList();
  // }
  //
  // List<String> get allCategories =>
  //     presetCategories.map((e) => e['name'].toString()).toList();

}



class FilterControlsWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<ImageEditorController>(
      builder: (controller) {
        return DefaultTabController(
          length: controller.presetCategories.keys.length,
          child: Container(
            decoration:  BoxDecoration(
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
                  padding:  EdgeInsets.only(top: 30,right: 10),
                  child: SizedBox(
                    height: 120,
                    child: TabBarView(
                      children: controller.presetCategories.values.map((presets) {
                        return ListView.separated(
                          scrollDirection: Axis.horizontal,
                          padding:  EdgeInsets.symmetric(horizontal: 12),
                          itemCount: presets.length + 1,
                          separatorBuilder: (_, __) =>  SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            if (index == 0) {
                              // Original image option
                              return GestureDetector(
                                onTap: () {
                                  controller.editedImageBytes.value =
                                      controller.originalImageBytes.value;
                                  controller.selectedPreset.value = null;
                                  controller.update();
                                },
                                child: Column(
                                  children: [
                                    // ClipRRect(
                                    //   borderRadius: BorderRadius.circular(8),
                                    //   child: controller.thumbnailBytes.value != null
                                    //       ? Image.memory(
                                    //     controller.thumbnailBytes.value!,
                                    //     width: 60,
                                    //     height: 60,
                                    //     fit: BoxFit.cover,
                                    //   )
                                    //       : Container(
                                    //     width: 60,
                                    //     height: 60,
                                    //     color: Colors.grey,
                                    //   ),
                                    // ),
                                    //  SizedBox(height: 4),
                                    Container(
                                      height: 90,
                                      width: 150,
                                      decoration: BoxDecoration(
                                        color: Color(ColorConst.defaultcontainer),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: Colors.transparent)
                                      ),
                                      child:  Center(
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
                                  // ClipRRect(
                                  //   borderRadius: BorderRadius.circular(8),
                                  //   child: thumbnailBytes != null
                                  //       ? Image.memory(
                                  //     thumbnailBytes,
                                  //     width: 60,
                                  //     height: 60,
                                  //     fit: BoxFit.cover,
                                  //   )
                                  //       : Container(
                                  //     width: 60,
                                  //     height: 60,
                                  //     color: Colors.grey,
                                  //     child: const Center(
                                  //       child: Text(
                                  //         'N/A',
                                  //         style: TextStyle(color: Colors.white),
                                  //       ),
                                  //     ),
                                  //   ),
                                  // ),
                                   SizedBox(height: 4),
                                  Container(
                                    height: 90,
                                    width: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                        color: Color(ColorConst.defaultcontainer),
                                      border: Border.all(color: Colors.transparent)
                                    ),
                                    child: Center(
                                      child: Text(
                                        preset.name,
                                        style:  TextStyle(fontSize: 16, color: Colors.white),
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
                  labelPadding:  EdgeInsets.symmetric(horizontal: 8),
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  tabs: controller.presetCategories.keys.map((category) {
                    return Tab(
                      child: Container(
                        padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: controller.selectedCategory.value == category
                              ? Color(ColorConst.lightpurple)
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: controller.selectedCategory.value == category
                                ? Colors.black
                                : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                  onTap: (index) {
                    controller.selectedCategory.value =
                        controller.presetCategories.keys.elementAt(index);
                    controller.update();
                  },
                ),
                // Bottom controls
                Padding(
                  padding:  EdgeInsets.symmetric(horizontal: 18, vertical: 22),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          controller.showPresetsEditOptions.value = false;
                          // controller.editedImageBytes.value =
                          //     controller.originalImageBytes.value;
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






