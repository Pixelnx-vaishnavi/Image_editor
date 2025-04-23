
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class EditableTextModel {
RxString text;
RxDouble top;
RxDouble left;
RxDouble fontSize;
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

EditableTextModel({
required String text,
required double top,
required double left,
double fontSize = 24.0,
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
shadowColor = shadowColor.obs;
}

class TextEditorControllerWidget extends GetxController {
RxList<EditableTextModel> text = <EditableTextModel>[].obs;
Rx<EditableTextModel?> selectedText = Rx<EditableTextModel?>(null);

void updateText(String newText) {
print('updateText called with: $newText');
if (newText.isEmpty) {
print('Empty text, skipping update');
return;
}
if (selectedText.value != null) {
selectedText.value!.text.value = newText;
} else {
final newModel = EditableTextModel(
text: newText,
left: 50,
top: 50,
fontSize: 24.0,
textColor: Colors.white,
);
text.add(newModel);
selectedText.value = newModel;
}
text.refresh();
print('Text list updated: ${text.length} items');
text.forEach((e) => print('Text: ${e.text.value}, Top: ${e.top.value}, Left: ${e.left.value}, '
'FontSize: ${e.fontSize.value}, Color: ${e.textColor.value}, '
'Font: ${e.fontFamily.value}, Bold: ${e.isBold.value}, '
'Align: ${e.textAlign.value}, Opacity: ${e.opacity.value}'));
}

void selectText(EditableTextModel textModel) {
selectedText.value = textModel;
print('Selected text: ${textModel.text.value}');
}

void clearSelection() {
selectedText.value = null;
print('Cleared text selection');
}

void updateFontSize(double fontSize) {
if (selectedText.value != null) {
selectedText.value!.fontSize.value = fontSize;
print('Updated font size: $fontSize');
text.refresh();
}
}

void updateTextColor(Color color) {
if (selectedText.value != null) {
selectedText.value!.textColor.value = color;
print('Updated text color: $color');
text.refresh();
}
}

void updateBackgroundColor(Color color) {
if (selectedText.value != null) {
selectedText.value!.backgroundColor.value = color;
print('Updated background color: $color');
text.refresh();
}
}

void updateFontFamily(String fontFamily) {
if (selectedText.value != null) {
selectedText.value!.fontFamily.value = fontFamily;
print('Updated font family: $fontFamily');
text.refresh();
}
}

void toggleBold() {
if (selectedText.value != null) {
selectedText.value!.isBold.value = !selectedText.value!.isBold.value;
print('Toggled bold: ${selectedText.value!.isBold.value}');
text.refresh();
}
}

void toggleItalic() {
if (selectedText.value != null) {
selectedText.value!.isItalic.value = !selectedText.value!.isItalic.value;
print('Toggled italic: ${selectedText.value!.isItalic.value}');
text.refresh();
}
}

void toggleUnderline() {
if (selectedText.value != null) {
selectedText.value!.isUnderline.value = !selectedText.value!.isUnderline.value;
print('Toggled underline: ${selectedText.value!.isUnderline.value}');
text.refresh();
}
}

void toggleStrikethrough() {
if (selectedText.value != null) {
selectedText.value!.isStrikethrough.value = !selectedText.value!.isStrikethrough.value;
print('Toggled strikethrough: ${selectedText.value!.isStrikethrough.value}');
text.refresh();
}
}

void updateOpacity(double opacity) {
if (selectedText.value != null) {
selectedText.value!.opacity.value = opacity;
print('Updated opacity: $opacity');
text.refresh();
}
}

void updateTextAlign(TextAlign align) {
if (selectedText.value != null) {
selectedText.value!.textAlign.value = align;
print('Updated text align: $align');
text.refresh();
}
}

void updateShadowBlur(double blur) {
if (selectedText.value != null) {
selectedText.value!.shadowBlur.value = blur;
print('Updated shadow blur: $blur');
text.refresh();
}
}

void updateShadowOffsetX(double offsetX) {
if (selectedText.value != null) {
selectedText.value!.shadowOffsetX.value = offsetX;
print('Updated shadow offset X: $offsetX');
text.refresh();
}
}

void updateShadowOffsetY(double offsetY) {
if (selectedText.value != null) {
selectedText.value!.shadowOffsetY.value = offsetY;
print('Updated shadow offset Y: $offsetY');
text.refresh();
}
}

void updateShadowColor(Color color) {
if (selectedText.value != null) {
selectedText.value!.shadowColor.value = color;
print('Updated shadow color: $color');
text.refresh();
}
}
}
