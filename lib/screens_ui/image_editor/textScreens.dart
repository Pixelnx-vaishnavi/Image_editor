import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_font_picker/flutter_font_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_editor/undo_redo_add/undo_redo_controller.dart';

class TextUIWithTabsScreen extends StatelessWidget {
  final BoxConstraints constraints;
  final GlobalKey imageKey;
  final bool isAddingNewText; // Flag to indicate new text creation

  TextUIWithTabsScreen({
    super.key,
    required this.constraints,
    required this.imageKey,
    this.isAddingNewText = false,
  }) {
    print('TextUIWithTabsScreen initialized with constraints: ${constraints.maxWidth}x${constraints.maxHeight}, isAddingNewText: $isAddingNewText');
  }

  final ImageEditorController _controller = Get.find<ImageEditorController>();
  final TextEditorControllerWidget TextController = Get.find<TextEditorControllerWidget>();

  final TextEditingController _fontSizeController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  final FocusNode _textFontsizeFocusNode = FocusNode();
  Timer? _debounceTimer;
  final RxBool _isSelectingFont = false.obs;

  final List<String> availableFonts = [
    'Roboto', 'Open Sans', 'Lato', 'Montserrat', 'Poppins', 'Raleway', 'Arial',
    'Courier New', 'Georgia', 'Times New Roman', 'Verdana', 'Tahoma', 'Trebuchet MS',
    'Comic Sans MS', 'Ubuntu', 'Source Sans Pro', 'Noto Sans', 'Playfair Display',
    'Merriweather', 'Droid Sans', 'PT Sans', 'Lora', 'Oswald', 'Quicksand',
    'Fira Sans', 'Rubik', 'Inter', 'Bree Serif', 'Sora', 'Work Sans', 'Zilla Slab',
    'Nunito', 'Alegreya',
  ];

  void _debouncedUpdateText(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      if (TextController.selectedText.value != null && !isAddingNewText) {
        TextController.updateText(value);
        print('Debounced text update: $value');
      } else {
        _createNewTextModel(value);
      }
    });
  }

  void _createNewTextModel(String text) {
    if (text.isEmpty) return;
    final canvasSize = _controller.lastValidCanvasSize ?? Size(constraints.maxWidth, constraints.maxHeight);
    final newTextModel = EditableTextModel(
      text: text, // Reactive text
      top: canvasSize.height * 0.5, // Non-reactive double
      left: canvasSize.width * 0.5, // Non-reactive double
      fontSize: 16, // Non-reactive int
      fontFamily: 'Roboto', // Reactive fontFamily
      textColor: Colors.black, // Non-reactive Color
      backgroundColor: Colors.transparent, // Non-reactive Color
      opacity: 1.0, // Non-reactive double
      isBold: false, // Non-reactive bool
      isItalic: false, // Non-reactive bool
      isUnderline: false, // Non-reactive bool
      isStrikethrough: false, // Non-reactive bool
      shadowBlur: 0.0, // Non-reactive double
      shadowColor: Colors.black, // Non-reactive Color
      shadowOffsetX: 0.0, // Non-reactive double
      shadowOffsetY: 0.0, // Non-reactive double
      rotation: 0.0, // Non-reactive double
      isFlippedHorizontally: false, // Non-reactive bool
      textAlign: TextAlign.left,
      widgetKey: GlobalKey(debugLabel: 'NewText_${text}_${DateTime.now().millisecondsSinceEpoch}'),
    );

    final widget = Container(
      key: newTextModel.widgetKey,
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Transform(
        transform: Matrix4.identity()
          ..rotateZ(newTextModel.rotation.value)
          ..scale(newTextModel.isFlippedHorizontally.value ? -1.0 : 1.0, 1.0),
        alignment: Alignment.center,
        child: Text(
          newTextModel.text.value,
          style: GoogleFonts.getFont(
            newTextModel.fontFamily.value,
            fontSize: newTextModel.fontSize.toDouble(),
            color: newTextModel.textColor.value.withOpacity(newTextModel.opacity.value),
            fontWeight: newTextModel.isBold.value ? FontWeight.bold : FontWeight.normal,
            fontStyle: newTextModel.isItalic.value ? FontStyle.italic : FontStyle.normal,
            decoration: newTextModel.isUnderline.value
                ? TextDecoration.underline
                : (newTextModel.isStrikethrough.value ? TextDecoration.lineThrough : null),
            shadows: [
              Shadow(
                blurRadius: newTextModel.shadowBlur.value,
                color: newTextModel.shadowColor.value,
                offset: Offset(newTextModel.shadowOffsetX.value, newTextModel.shadowOffsetY.value),
              ),
            ],
          ),
          textAlign: newTextModel.textAlign.value,
        ),
      ),
    );

    // Clear existing selection to prevent conflicts
    TextController.clearSelection();
    _controller.controller.clearAllBorders();

    final shapeSelectorController = Get.put(ShapeSelectorController(lindiController: _controller.controller, shapeCategories: _controller.shapeCategories));
    shapeSelectorController.addWidget(
      widget,
      Offset(newTextModel.left.value, newTextModel.top.value),
      newTextModel,
    );

    TextController.text.add(newTextModel);
    _controller.widgetModels[newTextModel.widgetKey!] = newTextModel;
    TextController.selectText(newTextModel);
    debugPrint('Created new text model: $text at position: top=${newTextModel.top}, left=${newTextModel.left}, key=${newTextModel.widgetKey}');

    // Defer RenderBox access
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final renderBox = newTextModel.widgetKey!.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        debugPrint('RenderBox for new text: size=${renderBox.size}, position=${renderBox.localToGlobal(Offset.zero)}');
      } else {
        debugPrint('RenderBox still null for key: ${newTextModel.widgetKey}');
      }
    });
  }

  void _debouncedUpdateFontSize(int value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      if (TextController.selectedText.value != null) {
        TextController.updateFontSize(value);
        print('Debounced font size update: $value');
      }
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
        title: Text('Select Font', style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Container(
            height: 800,
            child: FontPicker(
              onFontChanged: (PickerFont font) {
                if (font.fontFamily != null) {
                  try {
                    TextController.updateFontFamily(font.fontFamily!);
                    print('Font selected: ${font.fontFamily}');
                    Navigator.of(dialogContext).pop();
                    _isSelectingFont.value = false;
                  } catch (e) {
                    print('Error updating font: $e');
                    _isSelectingFont.value = false;
                  }
                }
              },
              recentsCount: 3,
              googleFonts: availableFonts,
              initialFontFamily: TextController.selectedText.value?.fontFamily.value ?? 'Roboto',
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
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _openColorPicker(
      BuildContext context, Color initialColor, Function(Color) onColorSelected, String title) {
    _unfocus();
    print('Opening ColorPicker dialog for $title');
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text('Pick $title', style: TextStyle(color: Colors.white)),
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
            labelTextStyle: TextStyle(color: Colors.white),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              print('ColorPicker dialog cancelled');
              Navigator.of(dialogContext).pop();
            },
            child: Text('Cancel', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              print('ColorPicker dialog confirmed');
              Navigator.of(dialogContext).pop();
            },
            child: Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('TextUIWithTabsScreen build called, current route: ${Get.currentRoute}');
    print('Selected text model: ${TextController.selectedText.value?.text.value ?? 'null'}');
    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Color(ColorConst.bottomBarcolor),
        body: Stack(
          children: [
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Obx(() {
                        final selectedText = TextController.selectedText.value;
                        if (selectedText != null && _controller.textController.value.text != selectedText.text.value) {
                          _controller.textController.value.text = selectedText.text.value;
                          _fontSizeController.text = selectedText.fontSize.value.toString();
                          print('Synced TextField with: ${selectedText.text.value}, fontSize: ${selectedText.fontSize.value}');
                        } else if (selectedText == null) {
                          _controller.textController.value.text = '';
                          _fontSizeController.text = '16';
                          print('No selected text, initialized TextField with empty text');
                        }
                        return TextFormField(
                          undoController: _controller.undoController.value,
                          focusNode: _textFocusNode,
                          onTap: () {
                            _controller.isSelectingText.value = true;
                            if (!isAddingNewText && TextController.selectedText.value == null && TextController.text.isNotEmpty) {
                              TextController.selectText(TextController.text.first);
                              print('Auto-selected first text model: ${TextController.text.first.text.value}');
                            }
                            print('TextFormField tapped, isSelectingText: ${_controller.isSelectingText.value}');
                          },
                          onFieldSubmitted: (value) {
                            _unfocus();
                          },
                          onChanged: (value) {
                            print('TextField changed: $value');
                            _debouncedUpdateText(value);
                          },
                          controller: _controller.textController.value,
                          style: GoogleFonts.getFont(
                            TextController.selectedText.value?.fontFamily.value ?? 'Roboto',
                            color: Colors.white,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.black54,
                            hintText: 'Enter text here...',
                            hintStyle: TextStyle(color: Colors.white70),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.all(Radius.circular(10)),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          ),
                        );
                      }),
                      SizedBox(height: 5),
                      Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              _unfocus();
                              _controller.selectedTab.value = 'Alignment';
                              _controller.isAlignmentText.value = true;
                              print('Switched to Alignment tab');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _controller.selectedTab.value == 'Alignment'
                                  ? Color.fromRGBO(140, 97, 255, 0.4)
                                  : Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Text('Alignment'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _unfocus();
                              _controller.selectedTab.value = 'Font';
                              _controller.isAlignmentText.value = false;
                              print('Switched to Font tab');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _controller.selectedTab.value == 'Font'
                                  ? Color.fromRGBO(140, 97, 255, 0.4)
                                  : Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Text('Font'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _unfocus();
                              _controller.selectedTab.value = 'Color';
                              _controller.isAlignmentText.value = false;
                              print('Switched to Color tab');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _controller.selectedTab.value == 'Color'
                                  ? Color.fromRGBO(140, 97, 255, 0.4)
                                  : Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Text('Color'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              _unfocus();
                              _controller.selectedTab.value = 'Shadow';
                              _controller.isAlignmentText.value = false;
                              print('Switched to Shadow tab');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _controller.selectedTab.value == 'Shadow'
                                  ? Color.fromRGBO(140, 97, 255, 0.4)
                                  : Colors.grey[800],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.all(Radius.circular(15)),
                              ),
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                            child: Text('Shadow'),
                          ),
                        ],
                      )),
                      SizedBox(height: 5),
                      Obx(() => _buildTabContent(context)),
                      SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_isSelectingFont.value) {
                                print('Cancel blocked: Font selection in progress');
                                return;
                              }
                              print('Cancel pressed, resetting text');
                              _debounceTimer?.cancel();
                              _unfocus();
                              if (TextController.selectedText.value != null) {
                                TextController.updateText('');
                                TextController.clearSelection();
                              }
                              _controller.TextEditOptions.value = false;
                              SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.edgeToEdge,
                                overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
                              );
                            },
                            child: SizedBox(
                              height: 40,
                              child: Image.asset('assets/cross.png'),
                            ),
                          ),
                          Text(
                            'Text',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          GestureDetector(
                            onTap: () async {
                              if (_isSelectingFont.value) {
                                print('OK blocked: Font selection in progress');
                                return;
                              }
                              print('OK pressed, saving text: ${_controller.textController.value.text}');
                              _debounceTimer?.cancel();
                              _unfocus();
                              TextController.updateText(_controller.textController.value.text);
                              _controller.isSelectingText.value = false;
                              _controller.TextEditOptions.value = false;
                              SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.edgeToEdge,
                                overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
                              );
                            },
                            child: SizedBox(
                              height: 40,
                              child: Image.asset('assets/right.png'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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

    switch (_controller.selectedTab.value) {
      case 'Alignment':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text("Alignment", style: TextStyle(fontSize: 14, color: Colors.white)),
                  SizedBox(width: 16),
                  Obx(() {
                    final textModel = TextController.selectedText.value;

                    final textPainter = TextPainter(
                      text: TextSpan(
                        text: textModel?.text.value.isEmpty ?? true ? 'Empty' : textModel!.text.value,
                        style: GoogleFonts.getFont(
                          textModel?.fontFamily.value ?? 'Roboto',
                          fontSize: textModel?.fontSize.value.toDouble() ?? 14.0,
                          fontWeight: textModel?.isBold.value ?? false ? FontWeight.bold : FontWeight.normal,
                          fontStyle: textModel?.isItalic.value ?? false ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                      textDirection: TextDirection.ltr,
                      textAlign: textModel?.textAlign.value ?? TextAlign.left,
                    )..layout(maxWidth: canvasWidth);

                    final textWidth = textPainter.width + 16;
                    final textHeight = textPainter.height;

                    final RenderBox? renderBox = imageKey.currentContext?.findRenderObject() as RenderBox?;
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
                      print('Image bounds for centering: position=($imageLeft, $imageTop), size=($imageWidth, $imageHeight)');
                    } else {
                      print('Warning: Image RenderBox not found, using canvas bounds');
                    }

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            _unfocus();
                            TextController.centerTextHorizontally(imageLeft, imageWidth, textWidth);
                            print('Centered text horizontally');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            height: 40,
                            width: 40,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/text/textAlignment_horizontal.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        GestureDetector(
                          onTap: () {
                            _unfocus();
                            TextController.centerTextVertically(imageTop, imageHeight, textHeight);
                            print('Centered text vertically');
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(5),
                            ),
                            height: 40,
                            width: 40,
                            child: Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Image.asset(
                                'assets/text/textAlignment_vertical.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
            SizedBox(height: 23),
            Padding(
              padding: EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text("Text Align", style: TextStyle(fontSize: 14, color: Colors.white)),
                  SizedBox(width: 16),
                  GestureDetector(
                    onTap: () {
                      _unfocus();
                      TextController.updateTextAlign(TextAlign.center);
                      print('Set text align to center');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 40,
                      width: 40,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Image.asset('assets/text/centertext.png'),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      _unfocus();
                      TextController.updateTextAlign(TextAlign.left);
                      print('Set text align to left');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 40,
                      width: 40,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Image.asset('assets/text/leftText.png'),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      _unfocus();
                      TextController.updateTextAlign(TextAlign.center);
                      print('Set text align to center (alternative icon)');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 40,
                      width: 40,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Image.asset('assets/text/centerAlignText.png'),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      _unfocus();
                      TextController.updateTextAlign(TextAlign.right);
                      print('Set text align to right');
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      height: 40,
                      width: 40,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: Image.asset('assets/text/rightText.png'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
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
                Container(
                  height: 40,
                  width: 250,
                  child: Obx(() => ElevatedButton(
                    onPressed: () {
                      _unfocus();
                      _openFontPicker(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: Text(
                      TextController.selectedText.value?.fontFamily.value ?? 'Roboto',
                      style: GoogleFonts.getFont(
                        TextController.selectedText.value?.fontFamily.value ?? 'Roboto',
                        color: Colors.white,
                      ),
                    ),
                  )),
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
                Container(
                  height: 40,
                  width: 90,
                  child: TextField(
                    focusNode: _textFontsizeFocusNode,
                    controller: _fontSizeController,
                    style: TextStyle(color: Colors.white),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final fontSize = int.tryParse(value) ?? 16;
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
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
                          color: TextController.selectedText.value?.isBold.value ?? false
                              ? Colors.purpleAccent
                              : Colors.white),
                      onPressed: () {
                        _unfocus();
                        TextController.toggleBold();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        padding: EdgeInsets.all(8),
                      ),
                    )),
                    SizedBox(width: 8),
                    Obx(() => IconButton(
                      icon: Icon(Icons.format_italic,
                          color: TextController.selectedText.value?.isItalic.value ?? false
                              ? Colors.purpleAccent
                              : Colors.white),
                      onPressed: () {
                        _unfocus();
                        TextController.toggleItalic();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        padding: EdgeInsets.all(8),
                      ),
                    )),
                    SizedBox(width: 8),
                    Obx(() => IconButton(
                      icon: Icon(Icons.format_underline,
                          color: TextController.selectedText.value?.isUnderline.value ?? false
                              ? Colors.purpleAccent
                              : Colors.white),
                      onPressed: () {
                        _unfocus();
                        TextController.toggleUnderline();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
                        padding: EdgeInsets.all(8),
                      ),
                    )),
                    SizedBox(width: 8),
                    Obx(() => IconButton(
                      icon: Icon(Icons.format_strikethrough,
                          color: TextController.selectedText.value?.isStrikethrough.value ?? false
                              ? Colors.purpleAccent
                              : Colors.white),
                      onPressed: () {
                        _unfocus();
                        TextController.toggleStrikethrough();
                      },
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.grey[800],
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                        ),
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
                Obx(() => _buildColorPickerButton(
                  context,
                  TextController.selectedText.value?.textColor.value ?? Colors.white,
                      (color) {
                    TextController.updateTextColor(color);
                    print('Text color set to $color');
                  },
                  'Text Color',
                )),
              ],
            ),
            SizedBox(height: 9),
            Row(
              children: [
                Text(
                  'BG Color',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 25),
                Obx(() => _buildColorPickerButton(
                  context,
                  TextController.selectedText.value?.backgroundColor.value ?? Colors.transparent,
                      (color) {
                    TextController.updateBackgroundColor(color);
                    print('BG color set to $color');
                  },
                  'Background Color',
                )),
              ],
            ),
            SizedBox(height: 16),
            _buildSlider(
              "Opacity",
              TextController.selectedText.value?.opacity.value ?? 1.0,
              0,
              1,
                  (v) {
                _unfocus();
                TextController.updateOpacity(v);
                print('Opacity changed: $v');
              },
            ),
          ],
        );
      case 'Shadow':
        return Column(
          children: [
            _buildSlider(
              "Blur",
              TextController.selectedText.value?.shadowBlur.value ?? 0.0,
              0,
              20,
                  (v) {
                _unfocus();
                TextController.updateShadowBlur(v);
                print('Shadow blur changed: $v');
              },
            ),
            _buildSlider(
              "Offset X",
              TextController.selectedText.value?.shadowOffsetX.value ?? 0.0,
              -20,
              20,
                  (v) {
                _unfocus();
                TextController.updateShadowOffsetX(v);
                print('Shadow offset X changed: $v');
              },
            ),
            _buildSlider(
              "Offset Y",
              TextController.selectedText.value?.shadowOffsetY.value ?? 0.0,
              -20,
              20,
                  (v) {
                _unfocus();
                TextController.updateShadowOffsetY(v);
                print('Shadow offset Y changed: $v');
              },
            ),
            Row(
              children: [
                Text(
                  'Shadow Color',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 16),
                Obx(() => _buildColorPickerButton(
                  context,
                  TextController.selectedText.value?.shadowColor.value ?? Colors.black,
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
      default:
        return SizedBox.shrink();
    }
  }

  Widget _buildColorPickerButton(
      BuildContext context, Color currentColor, Function(Color) onColorSelected, String title) {
    return Container(
      height: 40,
      width: 200,
      child: ElevatedButton(
        onPressed: () {
          _openColorPicker(context, currentColor, onColorSelected, title);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.grey[800],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
        child: Text(
          title,
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Container(
      height: 39,
      child: Row(
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
      ),
    );
  }
}
