import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TextUIWithTabsScreen extends StatelessWidget {
  final BoxConstraints constraints;
  final GlobalKey imageKey;

  TextUIWithTabsScreen(
      {super.key, required this.constraints, required this.imageKey}) {
    print(
        'TextUIWithTabsScreen initialized with constraints: ${constraints.maxWidth}x${constraints.maxHeight}');
  }

  final ImageEditorController _controller = Get.find<ImageEditorController>();
  final TextEditorControllerWidget TextController =
      Get.find<TextEditorControllerWidget>();
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _fontSizeController = TextEditingController();
  final RxString selectedTab = 'Font'.obs;
  final FocusNode _textFocusNode = FocusNode();
  final FocusNode _textFontsizeFocusNode = FocusNode();
  Timer? _debounceTimer;
  final RxBool _isSelectingFont = false.obs;

  final List<String> availableFonts = [
    'Roboto',
    'Open Sans',
    'Lato',
    'Montserrat',
    'Poppins',
    'Raleway',
  ];

  void _debouncedUpdateText(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      TextController.updateText(value);
      print('Debounced text update: $value');
    });
  }

  void _debouncedUpdateFontSize(int value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      TextController.updateFontSize(value);
      print('Debounced font size update: $value');
    });
  }

  void _unfocus() {
    _textFocusNode.unfocus();
    _textFontsizeFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    print('Unfocused all text fields');
  }

  void _openFontPicker(BuildContext parentContext) {
    _isSelectingFont.value = true;
    _unfocus();
    print('Opening FontPicker dialog');
    showDialog(
      context: parentContext,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: const Text('Select Font', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Container(
            height: 800,
            child: FontPicker(
              onFontChanged: (PickerFont font) {
                if (font.fontFamily != null) {
                  try {
                    TextController.updateFontFamily(font.fontFamily!);
                    print('Font selected: ${font.fontFamily}');
                    Future.delayed(const Duration(milliseconds: 100), () {
                      Navigator.of(dialogContext).pop();
                      print('FontPicker dialog closed');
                      _isSelectingFont.value = false;
                    });
                  } catch (e) {
                    print('Error updating font: $e');
                    _isSelectingFont.value = false;
                  }
                }
              },
              recentsCount: 3,
              googleFonts: availableFonts,
              initialFontFamily:
                  TextController.selectedText.value?.fontFamily.value ??
                      'Roboto',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('FontPicker dialog cancelled');
              Navigator.of(dialogContext).pop();
              _isSelectingFont.value = false;
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openColorPicker(BuildContext context, Color initialColor,
      Function(Color) onColorSelected, String title) {
    _unfocus();
    print('Opening ColorPicker dialog for $title');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text('Pick $title', style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: (color) {
              onColorSelected(color);
            },
            showLabel: true,
            pickerAreaHeightPercent: 0.8,
            enableAlpha: true,
            displayThumbColor: true,
            paletteType: PaletteType.hueWheel,
            labelTextStyle: const TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('ColorPicker dialog cancelled');
              Navigator.of(dialogContext).pop();
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              print('ColorPicker dialog confirmed');
              Navigator.of(dialogContext).pop();
            },
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(
        'TextUIWithTabsScreen build called, current route: ${Get.currentRoute}');
    if (TextController.selectedText.value != null) {
      _textController.text = TextController.selectedText.value!.text.value;
      _fontSizeController.text =
          TextController.selectedText.value!.fontSize.value.toString();
      print(
          'Initialized TextField with: ${_textController.text}, fontSize: ${_fontSizeController.text}');
    }

    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        backgroundColor: const Color(ColorConst.bottomBarcolor),
        body: Stack(
          children: [
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(5.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Obx(() => TextFormField(
                          focusNode: _textFocusNode,
                          onChanged: (value) {
                            print('TextField changed: $value');
                            _debouncedUpdateText(value);
                          },
                          controller: _textController,
                          style: GoogleFonts.getFont(
                            TextController
                                    .selectedText.value?.fontFamily.value ??
                                'Roboto',
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.black54,
                            hintText: 'Enter text here...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                          ),
                        )),
                     SizedBox(height: 16),
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                _unfocus();
                                _controller.isAlignmentText.value = true;
                                selectedTab.value = 'Alignment';
                                print('Switched to Alignment tab');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedTab.value ==
                                        'Alignment'
                                    ?  Color.fromRGBO(140, 97, 255, 0.4)
                                    : Colors.grey[800],
                                foregroundColor: Colors.white,
                                shape:  RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                padding:  EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child:  Text('Alignment'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _unfocus();
                                _controller.isAlignmentText.value = false;
                                selectedTab.value = 'Font';
                                print('Switched to Font tab');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedTab.value == 'Font'
                                    ? const Color.fromRGBO(140, 97, 255, 0.4)
                                    : Colors.grey[800],
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Font'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _unfocus();
                                _controller.isAlignmentText.value = false;
                                selectedTab.value = 'Color';
                                print('Switched to Color tab');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedTab.value == 'Color'
                                    ? const Color.fromRGBO(140, 97, 255, 0.4)
                                    : Colors.grey[800],
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Color'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _unfocus();
                                _controller.isAlignmentText.value = false;
                                selectedTab.value = 'Shadow';
                                print('Switched to Shadow tab');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedTab.value == 'Shadow'
                                    ? const Color.fromRGBO(140, 97, 255, 0.4)
                                    : Colors.grey[800],
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Shadow'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                _unfocus();
                                _controller.isAlignmentText.value = false;
                                selectedTab.value = 'Transform';
                                print('Switched to Transform tab');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: selectedTab.value ==
                                        'Transform'
                                    ? const Color.fromRGBO(140, 97, 255, 0.4)
                                    : Colors.grey[800],
                                foregroundColor: Colors.white,
                                shape: const RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(15)),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                              ),
                              child: const Text('Transform'),
                            ),
                          ],
                        )),
                    const SizedBox(height: 5),
                    Obx(() => _buildTabContent(context)),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () {
                            if (_isSelectingFont.value) {
                              print(
                                  'Cancel blocked: Font selection in progress');
                              return;
                            }
                            print('Cancel pressed, navigating back');
                            _debounceTimer?.cancel();
                            _unfocus();
                            TextController.clearSelection();
                            _controller.TextEditOptions.value = false;
                            Get.back();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                        const Text(
                          'Text',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.check, color: Colors.white),
                          onPressed: () {
                            if (_isSelectingFont.value) {
                              print('OK blocked: Font selection in progress');
                              return;
                            }
                            print(
                                'OK pressed, saving text: ${_textController.text}');
                            _debounceTimer?.cancel();
                            _unfocus();
                            TextController.updateText(_textController.text);
                            final fontSize =
                                int.tryParse(_fontSizeController.text) ?? 24;
                            TextController.updateFontSize(
                                fontSize.clamp(10, 100));
                            _controller.TextEditOptions.value = false;
                            print('Navigating back from OK');
                            Get.back();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape: const RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8)),
                            ),
                            padding: const EdgeInsets.all(12),
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
      ),
    );
  }

  Widget _buildTabContent(BuildContext context) {
    final double canvasWidth = constraints.maxWidth - 20;
    final double canvasHeight = constraints.maxHeight - 100;

    switch (selectedTab.value) {
      case 'Alignment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const Text("Alignment",
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                  const SizedBox(width: 16),
                  Obx(() {
                    final textModel = TextController.selectedText.value;
                    if (textModel == null) {
                      return const SizedBox.shrink();
                    }
                    final textPainter = TextPainter(
                      text: TextSpan(
                        text: textModel.text.value.isEmpty
                            ? 'Empty'
                            : textModel.text.value,
                        style: GoogleFonts.getFont(
                          textModel.fontFamily.value,
                          fontSize: textModel.fontSize.value.toDouble(),
                          fontWeight: textModel.isBold.value
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontStyle: textModel.isItalic.value
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                      textDirection: TextDirection.ltr,
                      textAlign: textModel.textAlign.value,
                    )..layout(maxWidth: canvasWidth);

                    final textWidth = textPainter.width + 16;
                    final textHeight = textPainter.height;

                    final RenderBox? renderBox = imageKey.currentContext
                        ?.findRenderObject() as RenderBox?;
                    double imageLeft = 0;
                    double imageTop = 0;
                    double imageWidth = canvasWidth;
                    double imageHeight = canvasHeight;

                    if (renderBox != null) {
                      final position = renderBox.localToGlobal(Offset.zero);
                      final size = renderBox.size;
                      imageLeft = position.dx;
                      imageTop = position.dy;
                      imageWidth = size.width;
                      imageHeight = size.height;
                      print(
                          'Image bounds for centering: position=($imageLeft, $imageTop), size=($imageWidth, $imageHeight)');
                    } else {
                      print(
                          'Warning: Image RenderBox not found, using canvas bounds');
                    }

                    return Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            _unfocus();
                            TextController.centerTextHorizontally(
                                imageLeft, imageWidth, textWidth);
                            print('Centered text horizontally');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(5)),
                            height: 40,
                            width: 40,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                  'assets/text/textAlignment_horizontal.png'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            _unfocus();
                            TextController.centerTextVertically(
                                imageTop, imageHeight, textHeight);
                            print('Centered text vertically');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.grey[800],
                                borderRadius: BorderRadius.circular(5)),
                            height: 40,
                            width: 40,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                  'assets/text/textAlignment_vertical.png'),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 17),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  const Text("Text Align",
                      style: TextStyle(fontSize: 14, color: Colors.white)),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      _unfocus();
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
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/text/centertext.png'),
                        )),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      _unfocus();
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
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/text/leftText.png'),
                        )),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      _unfocus();
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
                          padding: const EdgeInsets.all(8.0),
                          child: Image.asset('assets/text/centerAlignText.png'),
                        )),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      _unfocus();
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
                          padding: const EdgeInsets.all(8.0),
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
                const Text(
                  'Font',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(() => ElevatedButton(
                        onPressed: () {
                          _unfocus();
                          _openFontPicker(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                        child: Text(
                          TextController.selectedText.value?.fontFamily.value ??
                              'Roboto',
                          style: GoogleFonts.getFont(
                            TextController
                                    .selectedText.value?.fontFamily.value ??
                                'Roboto',
                            color: Colors.white,
                          ),
                        ),
                      )),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'Font Size',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    focusNode: _textFontsizeFocusNode,
                    controller: _fontSizeController,
                    style: const TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final fontSize = int.tryParse(value) ?? 24;
                      _debouncedUpdateFontSize(fontSize.clamp(10, 100));
                      print('Font size changed: $fontSize');
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
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
                            _unfocus();
                            TextController.toggleBold();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape:  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            padding:  EdgeInsets.all(8),
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
                            _unfocus();
                            TextController.toggleItalic();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape:  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            padding:  EdgeInsets.all(8),
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
                            _unfocus();
                            TextController.toggleUnderline();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape:  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            padding:  EdgeInsets.all(8),
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
                            _unfocus();
                            TextController.toggleStrikethrough();
                          },
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.grey[800],
                            shape:  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                            padding:  EdgeInsets.all(8),
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
                Obx(() => _buildColorPickerButton(
                      context,
                      TextController.selectedText.value?.textColor.value ??
                          Colors.white,
                      (color) {
                        TextController.updateTextColor(color);
                        print('Text color set to $color');
                      },
                      'Text Color',
                    )),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text(
                  'BG Color',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(width: 16),
                Obx(() => _buildColorPickerButton(
                      context,
                      TextController
                              .selectedText.value?.backgroundColor.value ??
                          Colors.transparent,
                      (color) {
                        TextController.updateBackgroundColor(color);
                        print('BG color set to $color');
                      },
                      'Background Color',
                    )),
              ],
            ),
            const SizedBox(height: 16),
            _buildSlider(
                "Opacity",
                TextController.selectedText.value?.opacity.value ?? 1.0,
                0,
                1, (v) {
              _unfocus();
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
              _unfocus();
              TextController.updateShadowBlur(v);
              print('Shadow blur changed: $v');
            }),
            _buildSlider(
                "Offset X",
                TextController.selectedText.value?.shadowOffsetX.value ?? 0.0,
                -20,
                20, (v) {
              _unfocus();
              TextController.updateShadowOffsetX(v);
              print('Shadow offset X changed: $v');
            }),
            _buildSlider(
                "Offset Y",
                TextController.selectedText.value?.shadowOffsetY.value ?? 0.0,
                -20,
                20, (v) {
              _unfocus();
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
                Obx(() => _buildColorPickerButton(
                      context,
                      TextController.selectedText.value?.shadowColor.value ??
                          Colors.black,
                      (color) {
                        TextController.updateShadowColor(color);
                        print('Shadow color set to $color');
                      },
                      'Shadow Color',
                    )),
              ],
            ),
          ],
        );
      case 'Transform':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSlider(
              "Rotation",
              TextController.selectedText.value?.rotation.value ?? 0.0,
              -100,
              100,
              (v) {
                _unfocus();
                TextController.updateRotation(v);
                print('Rotation changed: $v radians');
              },
            ),
             SizedBox(height: 16),
            Row(
              children: [
                 Text(
                  'Flip',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                 SizedBox(width: 16),
                Obx(() => IconButton(
                      icon: Icon(
                        Icons.flip,
                        color: TextController.selectedText.value
                                    ?.isFlippedHorizontally.value ??
                                false
                            ? Colors.purpleAccent
                            : Colors.white,
                      ),
                      onPressed: () {
                        _unfocus();
                        TextController.toggleFlipHorizontally();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape:  RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        padding:  EdgeInsets.all(8),
                      ),
                    )),
                 SizedBox(width: 8),
                Obx(() => IconButton(
                      icon: Icon(
                        Icons.flip,
                        color: TextController.selectedText.value
                                    ?.isFlippedVertically.value ??
                                false
                            ? Colors.purpleAccent
                            : Colors.white,
                      ),
                      onPressed: () {
                        _unfocus();
                        TextController.toggleFlipVertically();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape:  RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        padding:  EdgeInsets.all(8),
                      ),
                    )),
              ],
            ),
          ],
        );
      default:
        return  SizedBox.shrink();
    }
  }

  Widget _buildColorPickerButton(BuildContext context, Color currentColor,
      Function(Color) onColorSelected, String title) {
    return Expanded(
      child: ElevatedButton(
        onPressed: () {
          _openColorPicker(context, currentColor, onColorSelected, title);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          shape:  RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding:  EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          title,
          style:  TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSlider(String title, double value, double min, double max,
      ValueChanged<double> onChanged) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(color: Colors.white70, fontSize: 16)),
        const Spacer(),
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
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}
