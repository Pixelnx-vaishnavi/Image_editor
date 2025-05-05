import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';

class EditableTextModel {
  RxString text;
  RxDouble top;
  RxDouble left;
  RxInt fontSize;
  Rx<Color> textColor;
  Rx<Color> backgroundColor;
  RxString fontFamily;
  RxBool isBold;
  RxBool isItalic;
  RxBool isUnderline;
  RxBool isStrikethrough;
  RxDouble opacity;
  Rx<TextAlign> textAlign;
  RxDouble shadowBlur;
  RxDouble shadowOffsetX;
  RxDouble shadowOffsetY;
  Rx<Color> shadowColor;
  RxDouble rotation;
  RxBool isFlippedHorizontally;
  RxBool isFlippedVertically;

  EditableTextModel({
    required String text,
    required double top,
    required double left,
    int fontSize = 15,
    Color textColor = Colors.white,
    Color backgroundColor = Colors.transparent,
    String fontFamily = 'Roboto',
    bool isBold = false,
    bool isItalic = false,
    bool isUnderline = false,
    bool isStrikethrough = false,
    double opacity = 1.0,
    TextAlign textAlign = TextAlign.left,
    double shadowBlur = 0.0,
    double shadowOffsetX = 0.0,
    double shadowOffsetY = 0.0,
    Color shadowColor = Colors.black,
    double rotation = 0.0,
    bool isFlippedHorizontally = false,
    bool isFlippedVertically = false,
  })  : text = text.obs,
        top = top.obs,
        left = left.obs,
        fontSize = fontSize.obs,
        textColor = textColor.obs,
        backgroundColor = backgroundColor.obs,
        fontFamily = fontFamily.obs,
        isBold = isBold.obs,
        isItalic = isItalic.obs,
        isUnderline = isUnderline.obs,
        isStrikethrough = isStrikethrough.obs,
        opacity = opacity.obs,
        textAlign = textAlign.obs,
        shadowBlur = shadowBlur.obs,
        shadowOffsetX = shadowOffsetX.obs,
        shadowOffsetY = shadowOffsetY.obs,
        shadowColor = shadowColor.obs,
        rotation = rotation.obs,
        isFlippedHorizontally = isFlippedHorizontally.obs,
        isFlippedVertically = isFlippedVertically.obs;
}

class TextEditorControllerWidget extends GetxController {
  RxList<EditableTextModel> text = <EditableTextModel>[].obs;
  Rx<EditableTextModel?> selectedText = Rx<EditableTextModel?>(null);
  final ImageEditorController _controller = Get.put(ImageEditorController());

  Timer? _debounce;
  final Map<EditableTextModel, Size> _textSizes = {};

  // Debounce helper to limit state updates
  void _debouncedUpdate(void Function() callback) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 10),
        callback); // ~100 FPS for smoother response
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }

  Size getTextSize(EditableTextModel textModel) {
    if (_textSizes.containsKey(textModel)) return _textSizes[textModel]!;

    final textPainter = TextPainter(
      text: TextSpan(
        text: textModel.text.value.isEmpty ? 'Empty' : textModel.text.value,
        style: GoogleFonts.getFont(
          textModel.fontFamily.value,
          fontSize: textModel.fontSize.value.toDouble(),
          fontWeight:
              textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
          fontStyle:
              textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: textModel.textAlign.value,
    )..layout(maxWidth: double.infinity);

    final size = Size(textPainter.width + 16, textPainter.height);
    _textSizes[textModel] = size;
    return size;
  }

  void updateTextSize(EditableTextModel textModel) {
    _textSizes.remove(textModel);
    getTextSize(textModel);
  }

  void updateText(String newText) {
    print('updateText called with: $newText');
    if (text.length >= 20) {
      Get.snackbar('Limit Reached', 'Cannot add more than 20 text items');
      return;
    }
    if (selectedText.value != null) {
      if (newText.isEmpty) {
        selectedText.value!.text.value = '';
        print('Cleared text for selected item');
      } else {
        selectedText.value!.text.value = newText;
        final textModel = selectedText.value;
        Widget widget = Container(
          padding: EdgeInsets.all(12),
          decoration:
          BoxDecoration(
              color: textModel!.backgroundColor.value,
              borderRadius: BorderRadius.all(Radius.circular(20))),
          child: Text(
            selectedText.value!.text.value,
            textAlign: textModel!.textAlign.value,
            style: GoogleFonts.getFont(
              textModel.fontFamily.value.isEmpty
                  ? 'Roboto'
                  : textModel.fontFamily.value,
              fontSize: textModel.fontSize.value.toDouble(),
              color: textModel.textColor.value.withOpacity(textModel.opacity.value),
              fontWeight:
              textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
              fontStyle:
              textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
              decoration: textModel.isUnderline.value
                  ? TextDecoration.underline
                  : (textModel.isStrikethrough.value
                  ? TextDecoration.lineThrough
                  : null),
              shadows: [
                Shadow(
                  blurRadius: textModel.shadowBlur.value,
                  color: textModel.shadowColor.value,
                  offset: Offset(
                    textModel.shadowOffsetX.value,
                    textModel.shadowOffsetY.value,
                  ),
                ),
              ],
            ),
          ),
        );
        _controller.controller.selectedWidget!.edit(widget);

      }
      updateTextSize(selectedText.value!);
    } else if (newText.isNotEmpty) {
      final newModel = EditableTextModel(
        text: newText,
        left: 50,
        top: 50,
        fontSize: 15,
        textColor: Colors.white,
      );
      text.add(newModel);
      selectedText.value = newModel;
      updateTextSize(newModel);
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(
            color: textModel!.backgroundColor.value,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.add(widget);
      _controller.selectedimagelayer.value.add(selectedText.value!.text.value);
      print('Created new text model: $newText');
    }
    update();
  }

  void selectText(EditableTextModel textModel) {
    print('Selected text: ${textModel.text.value}');
    selectedText.value = textModel;

    update();
  }

  void clearSelection() {
    print('Cleared text selection');
    selectedText.value = null;
    update();
  }

  void updateFontSize(int fontSize) {
    if (selectedText.value != null) {
      selectedText.value!.fontSize.value = fontSize.clamp(10, 100);
      updateTextSize(selectedText.value!);
      print('Updated font size: $fontSize');
      final textModel = selectedText.value;
      Widget widget = Container(
        width: 250,
        height: 50,
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void updateTextColor(Color color) {
    if (selectedText.value != null) {
      selectedText.value!.textColor.value = color;
      print('Updated text color: $color');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void updateBackgroundColor(Color color) {
    if (selectedText.value != null) {
      selectedText.value!.backgroundColor.value = color;
      print('Updated background color: $color');
      final textModel = selectedText.value;
      Widget widget = Container(

        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(
          color: textModel!.backgroundColor.value,
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void updateFontFamily(String fontFamily) {
    if (selectedText.value != null) {
      selectedText.value!.fontFamily.value = fontFamily;
      updateTextSize(selectedText.value!);
      print('Updated font family: $fontFamily');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void toggleBold() {
    if (selectedText.value != null) {
      selectedText.value!.isBold.value = !selectedText.value!.isBold.value;
      updateTextSize(selectedText.value!);
      print('Toggled bold: ${selectedText.value!.isBold.value}');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void toggleItalic() {
    if (selectedText.value != null) {
      selectedText.value!.isItalic.value = !selectedText.value!.isItalic.value;
      updateTextSize(selectedText.value!);
      print('Toggled italic: ${selectedText.value!.isItalic.value}');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void toggleUnderline() {
    if (selectedText.value != null) {
      selectedText.value!.isUnderline.value =
          !selectedText.value!.isUnderline.value;
      print('Toggled underline: ${selectedText.value!.isUnderline.value}');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void toggleStrikethrough() {
    if (selectedText.value != null) {
      selectedText.value!.isStrikethrough.value =
          !selectedText.value!.isStrikethrough.value;
      print(
          'Toggled strikethrough: ${selectedText.value!.isStrikethrough.value}');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void updateOpacity(double opacity) {
    if (selectedText.value != null) {
      selectedText.value!.opacity.value = opacity.clamp(0.0, 1.0);
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      print('Updated opacity: $opacity');
      update();
    }
  }

  void updateTextAlign(TextAlign align) {
    if (selectedText.value != null) {
      selectedText.value!.textAlign.value = align;
      updateTextSize(selectedText.value!);
      print('Updated text align: $align');
      final textModel = selectedText.value;
      Widget widget = Align(
        alignment: Alignment.bottomRight,
        child: Container(
          height: 50,
          width: 100,
          // color: Colors.red,
          child: Text(
            selectedText.value!.text.value,
            textAlign: textModel!.textAlign.value,
            style: GoogleFonts.getFont(
              textModel.fontFamily.value.isEmpty
                  ? 'Roboto'
                  : textModel.fontFamily.value,
              fontSize: textModel.fontSize.value.toDouble(),
              color: textModel.textColor.value.withOpacity(textModel.opacity.value),
              fontWeight:
              textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
              fontStyle:
              textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
              decoration: textModel.isUnderline.value
                  ? TextDecoration.underline
                  : (textModel.isStrikethrough.value
                  ? TextDecoration.lineThrough
                  : null),
              shadows: [
                Shadow(
                  blurRadius: textModel.shadowBlur.value,
                  color: textModel.shadowColor.value,
                  offset: Offset(
                    textModel.shadowOffsetX.value,
                    textModel.shadowOffsetY.value,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void centerTextHorizontally(
      double imageLeft, double imageWidth, double textWidth) {
    if (selectedText.value != null) {
      selectedText.value!.left.value = imageLeft + (imageWidth - textWidth) / 2;
      print(
          'Centered text horizontally: left=${selectedText.value!.left.value}');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void centerTextVertically(
      double imageTop, double imageHeight, double textHeight) {
    if (selectedText.value != null) {
      selectedText.value!.top.value = imageTop + (imageHeight - textHeight) / 2;
      print('Centered text vertically: top=${selectedText.value!.top.value}');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void updateShadowBlur(double blur) {
    if (selectedText.value != null) {
      selectedText.value!.shadowBlur.value = blur.clamp(0.0, 50.0);
      print('Updated shadow blur: $blur');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void updateShadowOffsetX(double offsetX) {
    if (selectedText.value != null) {
      selectedText.value!.shadowOffsetX.value = offsetX;
      print('Updated shadow offset X: $offsetX');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void updateShadowOffsetY(double offsetY) {
    if (selectedText.value != null) {
      selectedText.value!.shadowOffsetY.value = offsetY;
      print('Updated shadow offset Y: $offsetY');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void updateShadowColor(Color color) {
    if (selectedText.value != null) {
      selectedText.value!.shadowColor.value = color;
      print('Updated shadow color: $color');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  // void updateRotation(double delta) {
  //   if (selectedText.value != null) {
  //     _debouncedUpdate(() {
  //       selectedText.value!.rotation.value += delta;
  //       selectedText.value!.rotation.value %= 2 * 3.14159; // Normalize to [0, 2π]
  //       print('Updated rotation: ${selectedText.value!.rotation.value} radians');
  //       update();
  //     });
  //   }
  // }

  void toggleFlipHorizontally() {
    if (selectedText.value != null) {
      selectedText.value!.isFlippedHorizontally.value =
          !selectedText.value!.isFlippedHorizontally.value;
      print(
          'Toggled horizontal flip: ${selectedText.value!.isFlippedHorizontally.value}');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void toggleFlipVertically() {
    if (selectedText.value != null) {
      selectedText.value!.isFlippedVertically.value =
          !selectedText.value!.isFlippedVertically.value;
      print(
          'Toggled vertical flip: ${selectedText.value!.isFlippedVertically.value}');
      final textModel = selectedText.value;
      Widget widget = Container(
        padding: EdgeInsets.all(12),
        decoration:
        BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(20))),
        child: Text(
          selectedText.value!.text.value,
          textAlign: textModel!.textAlign.value,
          style: GoogleFonts.getFont(
            textModel.fontFamily.value.isEmpty
                ? 'Roboto'
                : textModel.fontFamily.value,
            fontSize: textModel.fontSize.value.toDouble(),
            color: textModel.textColor.value.withOpacity(textModel.opacity.value),
            fontWeight:
            textModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle:
            textModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: textModel.isUnderline.value
                ? TextDecoration.underline
                : (textModel.isStrikethrough.value
                ? TextDecoration.lineThrough
                : null),
            shadows: [
              Shadow(
                blurRadius: textModel.shadowBlur.value,
                color: textModel.shadowColor.value,
                offset: Offset(
                  textModel.shadowOffsetX.value,
                  textModel.shadowOffsetY.value,
                ),
              ),
            ],
          ),
        ),
      );
      _controller.controller.selectedWidget!.edit(widget);
      update();
    }
  }

  void removeSelectedText() {
    if (selectedText.value != null) {
      text.remove(selectedText.value);
      selectedText.value = null;
      print('Removed selected text');
      update();
    }
  }

  void resizeText(double delta) {
    if (selectedText.value != null) {
      double newFontSize = selectedText.value!.fontSize.value + delta;

      // Clamp the font size to a reasonable range
      newFontSize = newFontSize.clamp(10.0, 100.0);

      selectedText.value!.fontSize.value = newFontSize.toInt();
      print('Resized text: fontSize=${selectedText.value!.fontSize.value}');
      update();
    }
  }

  void updateRotation(double delta) {
    if (selectedText.value != null) {
      selectedText.value!.rotation.value += delta;
      print('Updated rotation: ${selectedText.value!.rotation.value}');
      update();
    }
  }

// void resizeSticker(double delta) {
  //   final sticker = selectedText.value!.fontSize.value;
  //   if (sticker == null) return;
  //
  //   final newScale = (sticker.scale.value + delta).clamp(0.5, 3.0);
  //   sticker.scale.value = newScale;
  // }
}
