
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Placeholder for ColorConst (replace with your actual ColorConst class)
class ColorConst {
static const int purplecolor = 0xFF8C61FF;
static const int bottomBarcolor = 0xFF1C1C1E;
}

// Placeholder for ImageEditorController (replace with your actual implementation)
class ImageEditorControllerScreen extends GetxController {
Rx<Uint8List?> editedImageBytes = Rx<Uint8List?>(null);
Rx<File?> editedImage = Rx<File?>(null);
RxBool showEditOptions = false.obs;
RxBool showFilterEditOptions = false.obs;
RxBool showStickerEditOptions = false.obs;
RxBool showtuneOptions = false.obs;
RxBool TextEditOptions = false.obs;
RxBool isFlipping = false.obs;
RxBool isAlignmentText = false.obs;
RxDouble opacity = 0.0.obs;

void setInitialImage(File image) {}
void decodeEditedImage() {}
Matrix4 calculateColorMatrix() => Matrix4.identity();
Widget buildEditControls() => Container();
Widget buildShapeSelectorSheet() => Container();
Widget TuneEditControls() => Container();
TextEditControls() => Get.to(() => TextUIWithTabsScreen());
Widget buildFilterControlsSheet({required VoidCallback onClose}) => Container();
Widget buildToolButton(String label, String asset, VoidCallback onTap) {
return GestureDetector(
onTap: onTap,
child: Column(
children: [
Image.asset(asset, width: 24, height: 24),
SizedBox(height: 4),
Text(label, style: TextStyle(color: Colors.white)),
],
),
);
}
void pickAndCropImage() {}
}

// Placeholder for ImageFilterController (replace with your actual implementation)
class ImageFilterController extends GetxController {
void setInitialImage(File image) {}
}

// Placeholder for StickerController (replace with your actual implementation)
class Sticker {
RxDouble top = 0.0.obs;
RxDouble left = 0.0.obs;
RxDouble rotation = 0.0.obs;
RxDouble scale = 1.0.obs;
RxBool isFlipped = false.obs;
String path;

Sticker(this.path);
}

class StickerController extends GetxController {
RxList<Sticker> stickers = <Sticker>[].obs;
Rx<Sticker?> selectedSticker = Rx<Sticker?>(null);
GlobalKey imagekey = GlobalKey();

void selectSticker(Sticker sticker) {
selectedSticker.value = sticker;
}

void moveSticker(DragUpdateDetails details) {
if (selectedSticker.value != null) {
selectedSticker.value!.top.value += details.delta.dy;
selectedSticker.value!.left.value += details.delta.dx;
}
}

void rotateSticker(double angle) {
if (selectedSticker.value != null) {
selectedSticker.value!.rotation.value += angle;
}
}

void resizeSticker(double delta) {
if (selectedSticker.value != null) {
selectedSticker.value!.scale.value += delta;
}
}

void flipSticker() {
if (selectedSticker.value != null) {
selectedSticker.value!.isFlipped.value = !selectedSticker.value!.isFlipped.value;
}
}

void removeSticker(Sticker sticker) {
stickers.remove(sticker);
selectedSticker.value = null;
}
}

// EditableTextModel for text properties
class EditableTextModel {
RxString text;
RxDouble top;
RxDouble left;
RxDouble fontSize;
Rx<Color> textColor;

EditableTextModel({
required String text,
required double top,
required double left,
double fontSize = 24.0,
Color textColor = Colors.white,
})  : text = text.obs,
top = top.obs,
left = left.obs,
fontSize = fontSize.obs,
textColor = textColor.obs;
}

// TextEditorControllerWidget for managing text state
class TextEditorControllerWidget extends GetxController {
RxList<EditableTextModel> text = <EditableTextModel>[].obs;
Rx<EditableTextModel?> selectedText = Rx<EditableTextModel?>(null);

void updateText(String newText) {
if (newText.isEmpty) return;

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
print("Text list updated: ${text.length}");
text.forEach((e) => print("Text: ${e.text.value}, Top: ${e.top.value}, Left: ${e.left.value}"));
}

void selectText(EditableTextModel textModel) {
selectedText.value = textModel;
}

void clearSelection() {
selectedText.value = null;
}

void updateFontSize(double fontSize) {
if (selectedText.value != null) {
selectedText.value!.fontSize.value = fontSize;
}
}

void updateTextColor(Color color) {
if (selectedText.value != null) {
selectedText.value!.textColor.value = color;
}
}
}

// ImageEditorScreen
class ImageEditorScreenSecond extends StatelessWidget {
final ImageEditorControllerScreen _controller = Get.put(ImageEditorControllerScreen());
final ImageFilterController filtercontroller = Get.put(ImageFilterController());
final StickerController stickerController = Get.put(StickerController());
final TextEditorControllerWidget textEditorControllerWidget = Get.put(TextEditorControllerWidget());

@override
Widget build(BuildContext context) {
final File image = Get.arguments;
_controller.setInitialImage(image);
_controller.decodeEditedImage();
filtercontroller.setInitialImage(image);

return SafeArea(
bottom: true,
child: Scaffold(
resizeToAvoidBottomInset: true,
backgroundColor: Colors.black,
appBar: AppBar(
backgroundColor: Colors.black,
elevation: 0,
leading: IconButton(
icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
onPressed: () => Get.back(),
),
actions: [
Padding(
padding: const EdgeInsets.only(right: 20),
child: Row(
children: [
SizedBox(height: 20, child: Image.asset('assets/Save.png')),
SizedBox(width: 15),
SizedBox(height: 20, child: Image.asset('assets/Export.png')),
],
),
)
],
),
body: Obx(() {
final Uint8List? memoryImage = _controller.editedImageBytes.value;
final File? fileImage = _controller.editedImage.value;
return Stack(
children: [
Column(
children: [
Expanded(
child: Obx(() {
bool isAnyEditOpen = _controller.showEditOptions.value ||
_controller.showFilterEditOptions.value ||
_controller.showStickerEditOptions.value ||
_controller.showtuneOptions.value;

return AnimatedContainer(
duration: Duration(milliseconds: 200),
curve: Curves.easeInOut,
transform: Matrix4.translationValues(0, isAnyEditOpen ? 20 : 0, 0)
..scale(isAnyEditOpen ? 0.94 : 1.0),
child: Padding(
padding: EdgeInsets.symmetric(horizontal: 10),
child: Stack(
alignment: Alignment.center,
children: [
ClipRRect(
borderRadius: BorderRadius.circular(5),
child: Container(
key: stickerController.imagekey,
child: memoryImage != null
? Image.memory(memoryImage, fit: BoxFit.contain)
    : (fileImage != null && fileImage.path.isNotEmpty
? Image.file(fileImage, fit: BoxFit.contain)
    : Text("No image loaded")),
),
),
],
),
),
);
}),
),
SizedBox(height: 15),
if (!_controller.showEditOptions.value &&
!_controller.showFilterEditOptions.value &&
!_controller.showStickerEditOptions.value &&
!_controller.showtuneOptions.value &&
!_controller.TextEditOptions.value)
_buildToolBar(context),

if (_controller.showEditOptions.value) _controller.buildEditControls(),
if (_controller.showStickerEditOptions.value) _controller.buildShapeSelectorSheet(),
if (_controller.showtuneOptions.value) _controller.TuneEditControls(),
if (_controller.TextEditOptions.value) _controller.TextEditControls(),
if (_controller.showFilterEditOptions.value)
_controller.buildFilterControlsSheet(onClose: () {
_controller.showFilterEditOptions.value = false;
}),
],
),
Obx(() => Stack(
children: stickerController.stickers.map((sticker) {
final isSelected = sticker == stickerController.selectedSticker.value;
return Positioned(
top: sticker.top.value,
left: sticker.left.value,
child: GestureDetector(
onTap: () => stickerController.selectSticker(sticker),
onPanUpdate: (details) {
if (isSelected) {
stickerController.moveSticker(details);
}
},
child: Transform(
alignment: Alignment.center,
transform: Matrix4.identity()
..rotateZ(sticker.rotation.value)
..scale(
sticker.isFlipped.value ? -1.0 : 1.0,
1.0,
),
child: Stack(
clipBehavior: Clip.none,
alignment: Alignment.center,
children: [
Container(
width: 60 * sticker.scale.value,
height: 60 * sticker.scale.value,
decoration: BoxDecoration(
border: isSelected
? Border.all(color: Color(ColorConst.purplecolor), width: 2)
    : null,
borderRadius: BorderRadius.circular(8),
),
child: Padding(
padding: const EdgeInsets.all(8.0),
child: SvgPicture.asset(
width: 10,
height: 10,
sticker.path,
fit: BoxFit.contain,
),
),
),
if (isSelected) ...[
Positioned(
top: -3,
left: -3,
child: Transform.rotate(
angle: sticker.rotation.value,
child: _cornerControl(
icon: Icons.rotate_right,
color: Color(ColorConst.purplecolor),
scale: sticker.scale.value,
onPanUpdate: (details) => stickerController.rotateSticker(0.03),
),
),
),
Positioned(
top: -3,
right: -3,
child: Transform.rotate(
angle: sticker.rotation.value,
child: _cornerControl(
icon: Icons.close,
color: Color(ColorConst.purplecolor),
scale: sticker.scale.value,
onTap: () => stickerController.removeSticker(sticker),
),
),
),
Positioned(
bottom: -3,
left: -3,
child: Transform.rotate(
angle: sticker.rotation.value,
child: _cornerControl(
icon: Icons.flip,
color: Color(ColorConst.purplecolor),
scale: sticker.scale.value,
onTap: stickerController.flipSticker,
),
),
),
Positioned(
bottom: -3,
right: -3,
child: Transform.rotate(
angle: sticker.rotation.value,
child: _cornerControl(
icon: Icons.zoom_out_map,
color: Color(ColorConst.purplecolor),
scale: sticker.scale.value,
onPanUpdate: (details) =>
stickerController.resizeSticker(details.delta.dy * 0.01),
),
),
),
]
],
),
),
),
);
}).toList(),
)),
Obx(() {
print('Rendering text list: ${textEditorControllerWidget.text.length}');
return Stack(
children: textEditorControllerWidget.text.map((textModel) {
final isSelected = textModel == textEditorControllerWidget.selectedText.value;
return Positioned(
top: textModel.top.value,
left: textModel.left.value,
child: GestureDetector(
onTap: () => textEditorControllerWidget.selectText(textModel),
onPanUpdate: (details) {
if (isSelected) {
textModel.top.value += details.delta.dy;
textModel.left.value += details.delta.dx;
}
},
child: Container(
decoration: BoxDecoration(
border: isSelected
? Border.all(color: Color(ColorConst.purplecolor), width: 2)
    : null,
borderRadius: BorderRadius.circular(8),
),
padding: EdgeInsets.all(8),
child: Text(
textModel.text.value,
style: TextStyle(
fontSize: textModel.fontSize.value,
color: textModel.textColor.value,
),
),
),
),
);
}).toList(),
);
}),
if (_controller.isFlipping.value == true)
Positioned.fill(
child: Container(
color: Colors.black.withOpacity(0.8),
child: Center(
child: CircularProgressIndicator(
strokeWidth: 6.0,
valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
),
),
),
),
],
);
}),
),
);
}

Widget _cornerControl({
required IconData icon,
required Color color,
required double scale,
void Function()? onTap,
void Function(DragUpdateDetails)? onPanUpdate,
}) {
return GestureDetector(
onTap: onTap,
onPanUpdate: onPanUpdate,
behavior: HitTestBehavior.translucent,
child: Container(
width: 18,
height: 18,
decoration: BoxDecoration(
color: color.withOpacity(0.9),
shape: BoxShape.circle,
),
child: Icon(icon, size: 12, color: Colors.white),
),
);
}

Widget _buildToolBar(BuildContext context) {
return Container(
width: double.infinity,
padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
decoration: BoxDecoration(
color: Color(ColorConst.bottomBarcolor),
borderRadius: BorderRadius.only(
topLeft: Radius.circular(20),
topRight: Radius.circular(20),
),
),
child: SingleChildScrollView(
scrollDirection: Axis.horizontal,
child: Row(
children: [
_controller.buildToolButton('Rotate', 'assets/rotate.png', () {
_controller.showEditOptions.value = true;
}),
SizedBox(width: 40),
_controller.buildToolButton('Tune', 'assets/tune.png', () {
_controller.showtuneOptions.value = true;
}),
SizedBox(width: 40),
_controller.buildToolButton('Crop', 'assets/crop.png', () {
SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
_controller.pickAndCropImage();
}),
SizedBox(width: 40),
_controller.buildToolButton('Text', 'assets/text.png', () {
_controller.TextEditOptions.value = true;
}),
SizedBox(width: 40),
_controller.buildToolButton('Camera', 'assets/camera.png', () {}),
SizedBox(width: 40),
_controller.buildToolButton('Filter', 'assets/filter.png', () {
_controller.showFilterEditOptions.value = true;
}),
SizedBox(width: 40),
_controller.buildToolButton('Sticker', 'assets/elements.png', () {
_controller.showStickerEditOptions.value = true;
}),
],
),
),
);
}
}

// TextUIWithTabsScreen
class TextUIWithTabsScreen extends StatelessWidget {
TextUIWithTabsScreen({super.key});
final ImageEditorControllerScreen _controller = Get.find<ImageEditorControllerScreen>();
final TextEditorControllerWidget textController = Get.find<TextEditorControllerWidget>();
final TextEditingController _textController = TextEditingController();
final TextEditingController _fontSizeController = TextEditingController(text: '24');
String selectedTab = 'Font';

@override
Widget build(BuildContext context) {
// Initialize text field with selected text if available
if (textController.selectedText.value != null) {
_textController.text = textController.selectedText.value!.text.value;
_fontSizeController.text = textController.selectedText.value!.fontSize.value.toString();
}

return Scaffold(
backgroundColor: Color(ColorConst.bottomBarcolor),
body: SafeArea(
child: Padding(
padding: EdgeInsets.all(5.0),
child: Column(
mainAxisAlignment: MainAxisAlignment.end,
crossAxisAlignment: CrossAxisAlignment.stretch,
children: [
TextField(
controller: _textController,
style: TextStyle(color: Colors.white),
decoration: InputDecoration(
filled: true,
fillColor: Colors.black54,
hintText: 'Enter text here...',
hintStyle: TextStyle(color: Colors.white70),
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
borderSide: BorderSide.none,
),
contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
),
onChanged: (value) {
print('TextField changed: $value');
textController.updateText(value);
},
),
SizedBox(height: 16),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
ElevatedButton(
onPressed: () {
selectedTab = 'Alignment';
},
child: Text('Alignment'),
style: ElevatedButton.styleFrom(
backgroundColor: selectedTab == 'Alignment' ? Color.fromRGBO(140, 97, 255, 0.4) : Colors.grey[800],
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
),
),
ElevatedButton(
onPressed: () {
selectedTab = 'Font';
},
child: Text('Font'),
style: ElevatedButton.styleFrom(
backgroundColor: selectedTab == 'Font' ? Color.fromRGBO(140, 97, 255, 0.4) : Colors.grey[800],
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
),
),
ElevatedButton(
onPressed: () {
selectedTab = 'Color';
},
child: Text('Color'),
style: ElevatedButton.styleFrom(
backgroundColor: selectedTab == 'Color' ? Color.fromRGBO(140, 97, 255, 0.4) : Colors.grey[800],
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
),
),
ElevatedButton(
onPressed: () {
selectedTab = 'Shadow';
},
child: Text('Shadow'),
style: ElevatedButton.styleFrom(
backgroundColor: selectedTab == 'Shadow' ? Color.fromRGBO(140, 97, 255, 0.4) : Colors.grey[800],
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
),
),
],
),
SizedBox(height: 5),
_buildTabContent(),
SizedBox(height: 12),
Row(
mainAxisAlignment: MainAxisAlignment.spaceBetween,
children: [
IconButton(
icon: Icon(Icons.close, color: Colors.white),
onPressed: () {
textController.clearSelection();
_controller.TextEditOptions.value = false;
Get.back();
},
style: IconButton.styleFrom(
backgroundColor: Colors.grey[800],
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
padding: EdgeInsets.all(12),
),
),
Text(
'Text',
style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
),
IconButton(
icon: Icon(Icons.check, color: Colors.white),
onPressed: () {
textController.updateText(_textController.text);
_controller.TextEditOptions.value = false;
// Get.back();
},
style: IconButton.styleFrom(
backgroundColor: Colors.grey[800],
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
padding: EdgeInsets.all(12),
),
),
],
),
],
),
),
),
);
}

Widget _buildTabContent() {
switch (selectedTab) {
case 'Alignment':
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
SizedBox(height: 16),
Padding(
padding: const EdgeInsets.only(left: 10),
child: Row(
children: [
Text("Alignment", style: TextStyle(fontSize: 14, color: Colors.white)),
SizedBox(width: 16),
Container(
decoration: BoxDecoration(
color: Colors.grey[800],
borderRadius: BorderRadius.circular(5),
),
height: 40,
width: 40,
child: Padding(
padding: EdgeInsets.all(8.0),
child: Image.asset('assets/text/textAlignment_horizontal.png'),
),
),
SizedBox(width: 20),
Container(
decoration: BoxDecoration(
color: Colors.grey[800],
borderRadius: BorderRadius.circular(5),
),
height: 40,
width: 40,
child: Padding(
padding: EdgeInsets.all(8.0),
child: Image.asset('assets/text/textAlignment_vertical.png'),
),
),
],
),
),
SizedBox(height: 17),
Padding(
padding: const EdgeInsets.only(left: 10),
child: Row(
children: [
Text("Text Align", style: TextStyle(fontSize: 14, color: Colors.white)),
SizedBox(width: 16),
Container(
decoration: BoxDecoration(
color: Colors.grey[800],
borderRadius: BorderRadius.circular(5),
),
height: 40,
width: 40,
child: Padding(
padding: EdgeInsets.all(8.0),
child: Image.asset('assets/text/centertext.png'),
),
),
SizedBox(width: 20),
Container(
decoration: BoxDecoration(
color: Colors.grey[800],
borderRadius: BorderRadius.circular(5),
),
height: 40,
width: 40,
child: Padding(
padding: EdgeInsets.all(8.0),
child: Image.asset('assets/text/leftText.png'),
),
),
SizedBox(width: 20),
Container(
decoration: BoxDecoration(
color: Colors.grey[800],
borderRadius: BorderRadius.circular(5),
),
height: 40,
width: 40,
child: Padding(
padding: EdgeInsets.all(8.0),
child: Image.asset('assets/text/centerAlignText.png'),
),
),
SizedBox(width: 20),
Container(
decoration: BoxDecoration(
color: Colors.grey[800],
borderRadius: BorderRadius.circular(5),
),
height: 40,
width: 40,
child: Padding(
padding: EdgeInsets.all(8.0),
child: Image.asset('assets/text/rightText.png'),
),
),
],
),
),
],
);
case 'Font':
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Text(
'Font',
style: TextStyle(color: Colors.white70, fontSize: 16),
),
SizedBox(width: 16),
Expanded(
child: ElevatedButton(
onPressed: () {
// Implement font selection
},
child: Text('Select Font'),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey[800],
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
padding: EdgeInsets.symmetric(vertical: 12),
),
),
),
],
),
SizedBox(height: 16),
Row(
children: [
Text(
'Font Size',
style: TextStyle(color: Colors.white70, fontSize: 16),
),
SizedBox(width: 16),
Expanded(
child: TextField(
controller: _fontSizeController,
style: TextStyle(color: Colors.white),
keyboardType: TextInputType.number,
decoration: InputDecoration(
filled: true,
fillColor: Colors.grey[800],
border: OutlineInputBorder(
borderRadius: BorderRadius.circular(10),
borderSide: BorderSide.none,
),
contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
),
onChanged: (value) {
final fontSize = double.tryParse(value) ?? 24.0;
textController.updateFontSize(fontSize);
},
),
),
],
),
SizedBox(height: 16),
Row(
children: [
Text(
'Font Style',
style: TextStyle(color: Colors.white70, fontSize: 16),
),
SizedBox(width: 16),
Row(
children: [
IconButton(
icon: Icon(Icons.format_bold, color: Colors.white),
onPressed: () {},
style: IconButton.styleFrom(
backgroundColor: Colors.grey[800],
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
padding: EdgeInsets.all(8),
),
),
SizedBox(width: 8),
IconButton(
icon: Icon(Icons.format_italic, color: Colors.white),
onPressed: () {},
style: IconButton.styleFrom(
backgroundColor: Colors.grey[800],
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
padding: EdgeInsets.all(8),
),
),
SizedBox(width: 8),
IconButton(
icon: Icon(Icons.format_underline, color: Colors.white),
onPressed: () {},
style: IconButton.styleFrom(
backgroundColor: Colors.grey[800],
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
padding: EdgeInsets.all(8),
),
),
SizedBox(width: 8),
IconButton(
icon: Icon(Icons.format_strikethrough, color: Colors.white),
onPressed: () {},
style: IconButton.styleFrom(
backgroundColor: Colors.grey[800],
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
padding: EdgeInsets.all(8),
),
),
],
),
],
),
],
);
case 'Color':
return Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Row(
children: [
Text(
'Text Color',
style: TextStyle(color: Colors.white70, fontSize: 16),
),
SizedBox(width: 16),
Expanded(
child: ElevatedButton(
onPressed: () {
// Implement color picker
textController.updateTextColor(Colors.blue); // Example
},
child: Text('Select Text Color'),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey[800],
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
padding: EdgeInsets.symmetric(vertical: 12),
),
),
),
],
),
SizedBox(height: 16),
Row(
children: [
Text(
'BG Color',
style: TextStyle(color: Colors.white70, fontSize: 16),
),
SizedBox(width: 16),
Expanded(
child: ElevatedButton(
onPressed: () {},
child: Text('Select BG Color'),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey[800],
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
padding: EdgeInsets.symmetric(vertical: 12),
),
),
),
],
),
SizedBox(height: 16),
_buildSlider("Opacity", _controller.opacity.value, 0, 1, (v) {
_controller.opacity.value = v;
}),
],
);
case 'Shadow':
return Column(
mainAxisSize: MainAxisSize.min,
crossAxisAlignment: CrossAxisAlignment.start,
children: [
_buildSliderShadow("Blur", _controller.opacity.value, 0, 10, (v) {
_controller.opacity.value = v;
}),
_buildSliderShadow("Offset X", _controller.opacity.value, -10, 10, (v) {
_controller.opacity.value = v;
}),
_buildSliderShadow("Offset Y", _controller.opacity.value, -10, 10, (v) {
_controller.opacity.value = v;
}),
Row(
children: [
Text(
'Shadow Color',
style: TextStyle(color: Colors.white70, fontSize: 16),
),
SizedBox(width: 16),
Expanded(
child: ElevatedButton(
onPressed: () {},
child: Text('Select Shadow Color'),
style: ElevatedButton.styleFrom(
backgroundColor: Colors.grey[800],
foregroundColor: Colors.white,
shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
padding: EdgeInsets.symmetric(vertical: 12),
),
),
),
],
),
],
);
default:
return SizedBox.shrink();
}
}

Widget _buildSlider(String title, double value, double min, double max, ValueChanged<double> onChanged) {
return Row(
children: [
Text(title, style: TextStyle(color: Colors.white70, fontSize: 16)),
Spacer(),
Slider(
value: value,
min: min,
max: max,
divisions: ((max - min) * 100).toInt(),
onChanged: onChanged,
activeColor: Colors.purpleAccent,
inactiveColor: Colors.white24,
),
Container(
height: 25,
width: 35,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(5),
color: Colors.white10,
),
child: Center(
child: Text(
value.toStringAsFixed(2),
style: TextStyle(color: Colors.white, fontSize: 12),
),
),
),
],
);
}

Widget _buildSliderShadow(String title, double value, double min, double max, ValueChanged<double> onChanged) {
return Row(
children: [
Text(title, style: TextStyle(color: Colors.white70, fontSize: 16)),
Spacer(),
Slider(
value: value,
min: min,
max: max,
divisions: ((max - min) * 100).toInt(),
onChanged: onChanged,
activeColor: Colors.purpleAccent,
inactiveColor: Colors.white24,
),
Container(
height: 25,
width: 35,
decoration: BoxDecoration(
borderRadius: BorderRadius.circular(5),
color: Colors.white10,
),
child: Center(
child: Text(
value.toStringAsFixed(2),
style: TextStyle(color: Colors.white, fontSize: 12),
),
),
),
SizedBox(width: 6),
Text('px', style: TextStyle(color: Colors.white70, fontSize: 16)),
],
);
}
}
