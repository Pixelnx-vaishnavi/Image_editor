
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
int fontSize = 24,
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

void updateText(String newText) {
print('updateText called with: $newText');
if (selectedText.value != null) {
if (newText.isEmpty) {
selectedText.value!.text.value = '';
print('Cleared text for selected item');
} else {
selectedText.value!.text.value = newText;
}
} else if (newText.isNotEmpty) {
final newModel = EditableTextModel(
text: newText,
left: 50,
top: 50,
fontSize: 24,
textColor: Colors.white,
);
text.add(newModel);
selectedText.value = newModel;
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
selectedText.value!.fontSize.value = fontSize;
print('Updated font size: $fontSize');
update();
}
}

void updateTextColor(Color color) {
if (selectedText.value != null) {
selectedText.value!.textColor.value = color;
print('Updated text color: $color');
update();
}
}

void updateBackgroundColor(Color color) {
if (selectedText.value != null) {
selectedText.value!.backgroundColor.value = color;
print('Updated background color: $color');
update();
}
}

void updateFontFamily(String fontFamily) {
if (selectedText.value != null) {
selectedText.value!.fontFamily.value = fontFamily;
print('Updated font family: $fontFamily');
update();
}
}

void toggleBold() {
if (selectedText.value != null) {
selectedText.value!.isBold.value = !selectedText.value!.isBold.value;
print('Toggled bold: ${selectedText.value!.isBold.value}');
update();
}
}

void toggleItalic() {
if (selectedText.value != null) {
selectedText.value!.isItalic.value = !selectedText.value!.isItalic.value;
print('Toggled italic: ${selectedText.value!.isItalic.value}');
update();
}
}

void toggleUnderline() {
if (selectedText.value != null) {
selectedText.value!.isUnderline.value = !selectedText.value!.isUnderline.value;
print('Toggled underline: ${selectedText.value!.isUnderline.value}');
update();
}
}

void toggleStrikethrough() {
if (selectedText.value != null) {
selectedText.value!.isStrikethrough.value = !selectedText.value!.isStrikethrough.value;
print('Toggled strikethrough: ${selectedText.value!.isStrikethrough.value}');
update();
}
}

void updateOpacity(double opacity) {
if (selectedText.value != null) {
selectedText.value!.opacity.value = opacity;
print('Updated opacity: $opacity');
update();
}
}

void updateTextAlign(TextAlign align) {
if (selectedText.value != null) {
selectedText.value!.textAlign.value = align;
print('Updated text align: $align');
update();
}
}

void centerTextHorizontally(double imageLeft, double imageWidth, double textWidth) {
if (selectedText.value != null) {
selectedText.value!.left.value = imageLeft + (imageWidth - textWidth) / 2;
print('Centered text horizontally on image: left=${selectedText.value!.left.value}, imageLeft=$imageLeft, imageWidth=$imageWidth, textWidth=$textWidth');
update();
}
}

void centerTextVertically(double imageTop, double imageHeight, double textHeight) {
if (selectedText.value != null) {
selectedText.value!.top.value = imageTop + (imageHeight - textHeight) / 2;
print('Centered text vertically on image: top=${selectedText.value!.top.value}, imageTop=$imageTop, imageHeight=$imageHeight, textHeight=$textHeight');
update();
}
}

void updateShadowBlur(double blur) {
if (selectedText.value != null) {
selectedText.value!.shadowBlur.value = blur;
print('Updated shadow blur: $blur');
update();
}
}

void updateShadowOffsetX(double offsetX) {
if (selectedText.value != null) {
selectedText.value!.shadowOffsetX.value = offsetX;
print('Updated shadow offset X: $offsetX');
update();
}
}

void updateShadowOffsetY(double offsetY) {
if (selectedText.value != null) {
selectedText.value!.shadowOffsetY.value = offsetY;
print('Updated shadow offset Y: $offsetY');
update();
}
}

void updateShadowColor(Color color) {
if (selectedText.value != null) {
selectedText.value!.shadowColor.value = color;
print('Updated shadow color: $color');
update();
}
}

void updateRotation(double rotation) {
if (selectedText.value != null) {
selectedText.value!.rotation.value += rotation;
print('Updated rotation: $rotation radians');
// update();
}
}

void toggleFlipHorizontally() {
if (selectedText.value != null) {
selectedText.value!.isFlippedHorizontally.value = !selectedText.value!.isFlippedHorizontally.value;
print('Toggled horizontal flip: ${selectedText.value!.isFlippedHorizontally.value}');
update();
}
}

void toggleFlipVertically() {
if (selectedText.value != null) {
selectedText.value!.isFlippedVertically.value = !selectedText.value!.isFlippedVertically.value;
print('Toggled vertical flip: ${selectedText.value!.isFlippedVertically.value}');
update();
}
}

void resizeText(double delta) {
if (selectedText.value != null) {
int newFontSize = (selectedText.value!.fontSize.value + delta).round().clamp(10, 100);
selectedText.value!.fontSize.value = newFontSize;
print('Resized text: fontSize=$newFontSize');
update();
}
}
}
