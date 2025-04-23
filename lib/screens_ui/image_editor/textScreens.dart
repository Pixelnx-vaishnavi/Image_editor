import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';

class TextUIWithTabsScreen extends StatelessWidget {
  TextUIWithTabsScreen({super.key});
  final ImageEditorController _controller = Get.find<ImageEditorController>();
  final TextEditorControllerWidget TextController =
      Get.find<TextEditorControllerWidget>();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _fontSizeController =
      TextEditingController(text: '24');
  final RxString selectedTab = 'Font'.obs;

  @override
  Widget build(BuildContext context) {
    if (TextController.selectedText.value != null) {
      _textController.text = TextController.selectedText.value!.text.value;
      _fontSizeController.text =
          TextController.selectedText.value!.fontSize.value.toString();
      print(
          'Initialized TextField with: ${_textController.text}, fontSize: ${_fontSizeController.text}');
    }

    return Scaffold(
      backgroundColor: Color(ColorConst.bottomBarcolor),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    onTap: () {
                      TextController.updateText(_textController.text);
                      print(
                          'TextField tapped, current text: ${_textController.text}');
                    },
                    onChanged: (value) {
                      print('TextField changed: $value');
                      TextController.updateText(value);
                    },
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
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 16),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _controller.isAlignmentText.value = true;
                              selectedTab.value = 'Alignment';
                            },
                            child: Text('Alignment'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedTab.value == 'Alignment'
                                  ? Color.fromRGBO(140, 97, 255, 0.4)
                                  : Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _controller.isAlignmentText.value = false;
                              selectedTab.value = 'Font';
                            },
                            child: Text('Font'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedTab.value == 'Font'
                                  ? Color.fromRGBO(140, 97, 255, 0.4)
                                  : Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _controller.isAlignmentText.value = false;
                              selectedTab.value = 'Color';
                            },
                            child: Text('Color'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedTab.value == 'Color'
                                  ? Color.fromRGBO(140, 97, 255, 0.4)
                                  : Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _controller.isAlignmentText.value = false;
                              selectedTab.value = 'Shadow';
                            },
                            child: Text('Shadow'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedTab.value == 'Shadow'
                                  ? Color.fromRGBO(140, 97, 255, 0.4)
                                  : Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                            ),
                          ),
                        ],
                      )),
                  SizedBox(height: 5),
                  Obx(() => _buildTabContent()),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          print('Cancel pressed');
                          TextController.clearSelection();
                          _controller.TextEditOptions.value = false;
                          Get.back();
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(12),
                        ),
                      ),
                      Text(
                        'Text',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.white),
                        onPressed: () {
                          print(
                              'OK pressed, saving text: ${_textController.text}');
                          TextController.updateText(_textController.text);
                          final fontSize =
                              double.tryParse(_fontSizeController.text) ?? 24.0;
                          TextController.updateFontSize(
                              fontSize.clamp(10.0, 100.0));
                          _controller.TextEditOptions.value = false;

                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.all(12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (selectedTab.value) {
      case 'Alignment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text("Alignment",
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      TextController.updateTextAlign(TextAlign.start);
                      print('Set alignment to horizontal');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(5)),
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset(
                              'assets/text/textAlignment_horizontal.png'),
                        )),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      TextController.updateTextAlign(TextAlign.start);
                      print(
                          'Set alignment to vertical (not fully implemented)');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(5)),
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset(
                              'assets/text/textAlignment_vertical.png'),
                        )),
                  ),
                ],
              ),
            ),
            SizedBox(height: 17),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text("Text Align",
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      TextController.updateTextAlign(TextAlign.center);
                      print('Set text align to center');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(5)),
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset('assets/text/centertext.png'),
                        )),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      TextController.updateTextAlign(TextAlign.left);
                      print('Set text align to left');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(5)),
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset('assets/text/leftText.png'),
                        )),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      TextController.updateTextAlign(TextAlign.center);
                      print('Set text align to center (alternative icon)');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(5)),
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset('assets/text/centerAlignText.png'),
                        )),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      TextController.updateTextAlign(TextAlign.right);
                      print('Set text align to right');
                    },
                    child: Container(
                        decoration: BoxDecoration(
                            color: Colors.grey[800],
                            borderRadius: BorderRadius.circular(5)),
                        height: 40,
                        width: 40,
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Image.asset('assets/text/rightText.png'),
                        )),
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
                  child: DropdownButton<String>(
                    value:
                        TextController.selectedText.value?.fontFamily.value ??
                            'Roboto',
                    items: ['Roboto', 'OpenSans', 'Lato', 'Montserrat']
                        .map((font) {
                      return DropdownMenuItem<String>(
                        value: font,
                        child:
                            Text(font, style: TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        TextController.updateFontFamily(value);
                        print('Font changed to: $value');
                      }
                    },
                    dropdownColor: Colors.grey[800],
                    style: TextStyle(color: Colors.white),
                    underline: Container(),
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
                  child: TextFormField(
                    controller: _fontSizeController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final fontSize = double.tryParse(value) ?? 24.0;
                      TextController.updateFontSize(
                          fontSize.clamp(10.0, 100.0));
                      print('Font size changed: $fontSize');
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
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
                    Obx(() => IconButton(
                          icon: Icon(Icons.format_bold,
                              color: TextController
                                          .selectedText.value?.isBold.value ??
                                      false
                                  ? Colors.purpleAccent
                                  : Colors.white),
                          onPressed: () {
                            TextController.toggleBold();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(8),
                          ),
                        )),
                    SizedBox(width: 8),
                    Obx(() => IconButton(
                          icon: Icon(Icons.format_italic,
                              color: TextController
                                          .selectedText.value?.isItalic.value ??
                                      false
                                  ? Colors.purpleAccent
                                  : Colors.white),
                          onPressed: () {
                            TextController.toggleItalic();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(8),
                          ),
                        )),
                    SizedBox(width: 8),
                    Obx(() => IconButton(
                          icon: Icon(Icons.format_underline,
                              color: TextController.selectedText.value
                                          ?.isUnderline.value ??
                                      false
                                  ? Colors.purpleAccent
                                  : Colors.white),
                          onPressed: () {
                            TextController.toggleUnderline();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(8),
                          ),
                        )),
                    SizedBox(width: 8),
                    Obx(() => IconButton(
                          icon: Icon(Icons.format_strikethrough,
                              color: TextController.selectedText.value
                                          ?.isStrikethrough.value ??
                                      false
                                  ? Colors.purpleAccent
                                  : Colors.white),
                          onPressed: () {
                            TextController.toggleStrikethrough();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5)),
                            padding: EdgeInsets.all(8),
                          ),
                        )),
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
                  child: Row(
                    children: [
                      _buildColorButton(Colors.white, () {
                        TextController.updateTextColor(Colors.white);
                        print('Text color set to white');
                      }),
                      SizedBox(width: 8),
                      _buildColorButton(Colors.red, () {
                        TextController.updateTextColor(Colors.red);
                        print('Text color set to red');
                      }),
                      SizedBox(width: 8),
                      _buildColorButton(Colors.blue, () {
                        TextController.updateTextColor(Colors.blue);
                        print('Text color set to blue');
                      }),
                      SizedBox(width: 8),
                      _buildColorButton(Colors.yellow, () {
                        TextController.updateTextColor(Colors.yellow);
                        print('Text color set to yellow');
                      }),
                    ],
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
                  child: Row(
                    children: [
                      _buildColorButton(Colors.transparent, () {
                        TextController.updateBackgroundColor(
                            Colors.transparent);
                        print('BG color set to transparent');
                      }),
                      SizedBox(width: 8),
                      _buildColorButton(Colors.black, () {
                        TextController.updateBackgroundColor(Colors.black);
                        print('BG color set to black');
                      }),
                      SizedBox(width: 8),
                      _buildColorButton(Colors.white, () {
                        TextController.updateBackgroundColor(Colors.white);
                        print('BG color set to white');
                      }),
                      SizedBox(width: 8),
                      _buildColorButton(Colors.grey, () {
                        TextController.updateBackgroundColor(Colors.grey);
                        print('BG color set to grey');
                      }),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            _buildSlider(
                "Opacity",
                TextController.selectedText.value?.opacity.value ?? 1.0,
                0,
                1, (v) {
              TextController.updateOpacity(v);
              print('Opacity changed: $v');
            }),
          ],
        );
      case 'Shadow':
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSlider(
                "Blur",
                TextController.selectedText.value?.shadowBlur.value ?? 0.0,
                0,
                20, (v) {
              TextController.updateShadowBlur(v);
              print('Shadow blur changed: $v');
            }),
            _buildSlider(
                "Offset X",
                TextController.selectedText.value?.shadowOffsetX.value ?? 0.0,
                -20,
                20, (v) {
              TextController.updateShadowOffsetX(v);
              print('Shadow offset X changed: $v');
            }),
            _buildSlider(
                "Offset Y",
                TextController.selectedText.value?.shadowOffsetY.value ?? 0.0,
                -20,
                20, (v) {
              TextController.updateShadowOffsetY(v);
              print('Shadow offset Y changed: $v');
            }),
            Row(
              children: [
                Text(
                  'Shadow Color',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      _buildColorButton(Colors.black, () {
                        TextController.updateShadowColor(Colors.black);
                        print('Shadow color set to black');
                      }),
                      SizedBox(width: 8),
                      _buildColorButton(Colors.grey, () {
                        TextController.updateShadowColor(Colors.grey);
                        print('Shadow color set to grey');
                      }),
                      SizedBox(width: 8),
                      _buildColorButton(Colors.blue, () {
                        TextController.updateShadowColor(Colors.blue);
                        print('Shadow color set to blue');
                      }),
                      SizedBox(width: 8),
                      _buildColorButton(Colors.red, () {
                        TextController.updateShadowColor(Colors.red);
                        print('Shadow color set to red');
                      }),
                    ],
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

  Widget _buildColorButton(Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white, width: 1),
        ),
      ),
    );
  }

  Widget _buildSlider(String title, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Row(
      children: [
        Text(title, style: TextStyle(color: Colors.white70, fontSize: 16)),
        Spacer(),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: ((max - min) * 10).toInt(),
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
              value.toStringAsFixed(1),
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
