import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/sticker/stciker_model.dart';

class StickerController extends GetxController {
  RxList<StickerModel> stickers = <StickerModel>[].obs;
  Rx<StickerModel?> selectedSticker = Rx<StickerModel?>(null);
  Rx<GlobalKey> imagekey = GlobalKey().obs;
  RxBool selectedStickerTapped = false.obs;


  void addSticker(String path) {
    final renderBox = imagekey.value.currentContext?.findRenderObject() as RenderBox?;
    final size = renderBox?.size ?? Size(350, 300);

    // final newSticker = StickerModel(
    //   path: path,
    //   top: RxDouble(size.height / 2 - 40),
    //   left: RxDouble(size.width / 1- 90),
    //
    //   scale: 1.0.obs,
    //   rotation: 0.0.obs,
    //   isFlipped: false.obs,
    // );

    // stickers.add(newSticker);
    // selectedSticker.value = newSticker;
    selectedStickerTapped.value = true;
  }

  void selectSticker(StickerModel sticker) {
    selectedSticker.value = sticker;
    selectedStickerTapped.value = true;
  }

  void deselectSticker() {
    selectedSticker.value = null;
    selectedStickerTapped.value = false;
  }

  void moveSticker(DragUpdateDetails details) {
    final sticker = selectedSticker.value;
    if (sticker == null) return;

    final renderBox = imagekey.value.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final imagePosition = renderBox.localToGlobal(Offset.zero);
    final imageSize = renderBox.size;

    final newTop = sticker.top.value + details.delta.dy;
    final newLeft = sticker.left.value + details.delta.dx;

    const stickerSize = 80; // or dynamic if you support different sizes

    // Clamp within image bounds
    final minTop = 0.0;
    final maxTop = imageSize.height - stickerSize;
    final minLeft = 0.0;
    final maxLeft = imageSize.width - stickerSize;

    sticker.top.value = newTop.clamp(minTop, maxTop);
    sticker.left.value = newLeft.clamp(minLeft, maxLeft);
  }


  DateTime _lastRotationUpdate = DateTime.now();

  void rotateSticker(double delta) {
    if (selectedSticker.value != null) {
      selectedSticker.value!.rotation.value += delta;
    }
  }


  void resizeSticker(double delta) {
    final sticker = selectedSticker.value;
    if (sticker == null) return;

    final newScale = (sticker.scale.value + delta).clamp(0.5, 3.0);
    sticker.scale.value = newScale;
  }

  // void resizeSticker(double delta) {
  //   final sticker = selectedSticker.value;
  //   if (sticker == null) return;
  //
  //   sticker.scale.value = (sticker.scale.value + delta).clamp(0.5, 3.0);
  // }

   flipSticker() {
    final sticker = selectedSticker.value;
    if (sticker == null) return;

    sticker.isFlipped.value = !sticker.isFlipped.value;
  }

  void removeSticker(StickerModel sticker) {
    stickers.remove(sticker);
    if (selectedSticker.value == sticker) {
      deselectSticker();
    }
  }

  void clearStickers() {
    stickers.clear();
    deselectSticker();
  }
}
