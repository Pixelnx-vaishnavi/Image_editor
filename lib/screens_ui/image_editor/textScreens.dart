import 'dart:async';
import 'dart:math';
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
  final bool isAddingNewText;
  final EditableTextModel? selectedTextModel;

  TextUIWithTabsScreen({
    super.key,
    required this.constraints,
    required this.imageKey,
    this.isAddingNewText = false,
    this.selectedTextModel,
  }) {
    print('TextUIWithTabsScreen initialized with constraints: ${constraints.maxWidth}x${constraints.maxHeight}, isAddingNewText: $isAddingNewText, selectedTextModel text: ${selectedTextModel?.text?.value ?? 'null'}');
    if (!isAddingNewText && selectedTextModel != null) {
      textController.selectText(selectedTextModel!);
      _controller.textController.value.text = selectedTextModel!.text.value;
      _fontSizeController.text = selectedTextModel!.fontSize.value.toString();
      print('Initialized with selectedTextModel: text=${selectedTextModel!.text.value}, fontSize=${selectedTextModel!.fontSize.value}');
    } else if (isAddingNewText) {
      _controller.textController.value.text = '';
      _fontSizeController.text = '16';
      textController.clearSelection();
      print('Initialized for new text: cleared textController and selection');
    }
  }

  final ImageEditorController _controller = Get.find<ImageEditorController>();
  final TextEditorControllerWidget textController = Get.find<TextEditorControllerWidget>();

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
        textController.updateText(value);
        print('Debounced text update: $value');

    });
  }

  void _createNewTextModel(String text) {
    if (text.isEmpty) {
      print('Text is empty, skipping creation');
      return;
    }

    final canvasSize = _controller.lastValidCanvasSize ?? Size(constraints.maxWidth, constraints.maxHeight);
    final uniqueId = 'Text_${DateTime.now().millisecondsSinceEpoch}_${text.hashCode}_${Random().nextInt(1000)}';
    final newKey = GlobalKey(debugLabel: 'NewText_$uniqueId');

    // Check for duplicate text and key
    if (textController.text.any((model) => model.text.value == text && model.widgetKey == newKey)) {
      print('Text model with text "$text" and key $newKey already exists, skipping creation');
      return;
    }

    final newTextModel = EditableTextModel(
      text: text,
      top: canvasSize.height * 0.5,
      left: canvasSize.width * 0.5,
      fontSize: 17,
      fontFamily: 'Roboto',
      textColor: Colors.black,
      backgroundColor: Colors.transparent,
      opacity: 1.0,
      isBold: false,
      isItalic: false,
      isUnderline: false,
      isStrikethrough: false,
      shadowBlur: 0.0,
      shadowColor: Colors.black,
      shadowOffsetX: 0.0,
      shadowOffsetY: 0.0,
      rotation: 0.0,
      isFlippedHorizontally: false,
      textAlign: TextAlign.left,
      widgetKey: newKey,
    );

    final textWidget = Container(
      // key: newKey,
      padding:  EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: newTextModel.backgroundColor.value,
        borderRadius:  BorderRadius.all(Radius.circular(20)),
      ),
      constraints:  BoxConstraints(minWidth: 50, minHeight: 20),
      child: Transform(
        transform: Matrix4.identity()
          ..rotateZ(newTextModel.rotation.value)
          ..scale(newTextModel.isFlippedHorizontally.value ? -1.0 : 1.0, 1.0),
        alignment: Alignment.center,
        child: Text(
          newTextModel.text.value.isEmpty ? ' ' : newTextModel.text.value,
          style: GoogleFonts.getFont(
            newTextModel.fontFamily.value,
            fontSize: newTextModel.fontSize.value.toDouble(),
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

    try {
      _controller.addWidget(
        textWidget,
        Offset(newTextModel.left.value, newTextModel.top.value),
        model: newTextModel,
      );
      textController.selectText(newTextModel);
      print('Created new text model: $text at position: top=${newTextModel.top}, left=${newTextModel.left}, key=${newTextModel.widgetKey}');

      WidgetsBinding.instance.addPostFrameCallback((_) {
        final renderBox = newTextModel.widgetKey.currentContext?.findRenderObject() as RenderBox?;
        if (renderBox != null) {
          print('RenderBox for new text: size=${renderBox.size}, position=${renderBox.localToGlobal(Offset.zero)}');
        } else {
          print('RenderBox still null for key: ${newTextModel.widgetKey}');
        }

      });
    } catch (e, stackTrace) {
      print('Error creating text model: $e');
      print(stackTrace);
    }
  }

  void _debouncedUpdateFontSize(int value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 300), () {
      if (textController.selectedText.value != null) {
        textController.updateFontSize(value);
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
                    textController.updateFontFamily(font.fontFamily!);
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
              initialFontFamily: textController.selectedText.value?.fontFamily.value ?? 'Roboto',
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
      BuildContext context, Color initialColor, Function(Color) onColorSelected, String title)
  {
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
    print('Selected text model: ${textController.selectedText.value?.text.value ?? 'null'}');
    return GestureDetector(
      onTap: _unfocus,
      child: Scaffold(
        // resizeToAvoidBottomInset: true,
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
                        final selectedText = textController.selectedText.value;

                        if (!isAddingNewText && selectedTextModel != null && selectedText != selectedTextModel) {
                          textController.selectText(selectedTextModel!);
                          _controller.textController.value.text = selectedTextModel!.text.value;
                          _fontSizeController.text = selectedTextModel!.fontSize.value.toString();
                          print('Synced TextField with selectedTextModel: ${selectedTextModel!.text.value}, fontSize: ${selectedTextModel!.fontSize.value}');
                        } else if (selectedText != null && _controller.textController.value.text != selectedText.text.value) {
                          _controller.textController.value.text = selectedText.text.value;
                          _fontSizeController.text = selectedText.fontSize.value.toString();
                          print('Synced TextField with selectedText: ${selectedText.text.value}, fontSize: ${selectedText.fontSize.value}');
                        } else if (!isAddingNewText && selectedText == null) {
                          _controller.textController.value.text = '';
                          _fontSizeController.text = '16';
                          print('No selected text, initialized TextField with empty text');
                        }
                        return TextFormField(

                          undoController: _controller.undoController.value,
                          focusNode: _textFocusNode,
                          onTap: () {
                            _controller.isSelectingText.value = true;
                            if (!isAddingNewText && textController.selectedText.value == null && textController.text.isNotEmpty) {
                              textController.selectText(textController.text.first);
                              _controller.textController.value.text = textController.text.first.text.value;
                              _fontSizeController.text = textController.text.first.fontSize.value.toString();
                              print('Auto-selected first text model: ${textController.text.first.text.value}');
                            }
                            print('TextFormField tapped, isSelectingText: ${_controller.isSelectingText.value}');
                          },

                          onFieldSubmitted: (value) {
    if (_isSelectingFont.value) {
    print('OK blocked: Font selection in progress');
    return;
    }
    print('OK pressed, saving text: ${_controller.textController.value.text}');
    _debounceTimer?.cancel();
    _unfocus();

    final text = _controller.textController.value.text;
    if (!isAddingNewText && selectedTextModel != null) {
    // Update existing text model
    textController.selectText(selectedTextModel!);
    textController.updateText(text);

    if (selectedTextModel!.widgetKey == null) {
    print('Error: widgetKey is null for selectedTextModel');
    return;
    }

    final updatedWidget = Container(
    key: selectedTextModel!.widgetKey,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: selectedTextModel!.backgroundColor.value,
    borderRadius: const BorderRadius.all(Radius.circular(20)),
    ),
    constraints: const BoxConstraints(minWidth: 50, minHeight: 20),
    child: Transform(
    transform: Matrix4.identity()
    ..rotateZ(selectedTextModel!.rotation.value)
    ..scale(selectedTextModel!.isFlippedHorizontally.value ? -1.0 : 1.0, 1.0),
    alignment: Alignment.center,
    child: Text(
    value,
    style: GoogleFonts.getFont(
    selectedTextModel!.fontFamily.value,
    fontSize: selectedTextModel!.fontSize.value.toDouble(),
    color: selectedTextModel!.textColor.value.withOpacity(selectedTextModel!.opacity.value),
    fontWeight: selectedTextModel!.isBold.value ? FontWeight.bold : FontWeight.normal,
    fontStyle: selectedTextModel!.isItalic.value ? FontStyle.italic : FontStyle.normal,
    decoration: selectedTextModel!.isUnderline.value
    ? TextDecoration.underline
        : (selectedTextModel!.isStrikethrough.value ? TextDecoration.lineThrough : null),
    shadows: [
    Shadow(
    blurRadius: selectedTextModel!.shadowBlur.value,
    color: selectedTextModel!.shadowColor.value,
    offset: Offset(
    selectedTextModel!.shadowOffsetX.value,
    selectedTextModel!.shadowOffsetY.value,
    ),
    ),
    ],
    ),
    textAlign: selectedTextModel!.textAlign.value,
    ),
    ),
    );

    try {
    _controller.editWidget(
    updatedWidget,
    Offset(selectedTextModel!.left.value, selectedTextModel!.top.value),
    );
    print('Updated selectedTextModel: ${selectedTextModel!.text.value}');
    WidgetsBinding.instance.addPostFrameCallback((_) {
    // Close TextUIWithTabsScreen
    });
    }
    catch (e, stackTrace) {
    print('Error updating text model: $e');
    print(stackTrace);
    }
    }
    else if (isAddingNewText && text.isNotEmpty) {
    _createNewTextModel(value);
    } else {
    print('No action: empty text or invalid state');
    // Get.back();
    }

    _controller.isSelectingText.value = false;
    _controller.TextEditOptions.value = false;
    SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.edgeToEdge,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

                            // _unfocus();
                          },
                          onChanged: (value) {
                            print('TextField changed: $value');
                              // _debouncedUpdateText(value);
                          },
                          controller: _controller.textController.value,
                          style: GoogleFonts.getFont(
                            textController.selectedText.value?.fontFamily.value ?? 'Roboto',
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
                              if (textController.selectedText.value != null) {
                                if (isAddingNewText) {
                                  textController.updateText('');
                                }
                                textController.clearSelection();
                              }
                              _controller.isSelectingText.value = false;
                              _controller.TextEditOptions.value = false;
                              SystemChrome.setEnabledSystemUIMode(
                                SystemUiMode.edgeToEdge,
                                overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
                              );
                              // Get.back();
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

                              final text = _controller.textController.value.text;
                              if (!isAddingNewText && selectedTextModel != null) {
                                // Update existing text model
                                textController.selectText(selectedTextModel!);
                                textController.updateText(text);

                                if (selectedTextModel!.widgetKey == null) {
                                  print('Error: widgetKey is null for selectedTextModel');
                                  return;
                                }

                                final updatedWidget = Container(
                                  key: selectedTextModel!.widgetKey,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: selectedTextModel!.backgroundColor.value,
                                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                                  ),
                                  constraints: const BoxConstraints(minWidth: 50, minHeight: 20),
                                  child: Transform(
                                    transform: Matrix4.identity()
                                      ..rotateZ(selectedTextModel!.rotation.value)
                                      ..scale(selectedTextModel!.isFlippedHorizontally.value ? -1.0 : 1.0, 1.0),
                                    alignment: Alignment.center,
                                    child: Text(
                                      selectedTextModel!.text.value.isEmpty ? ' ' : selectedTextModel!.text.value,
                                      style: GoogleFonts.getFont(
                                        selectedTextModel!.fontFamily.value,
                                        fontSize: selectedTextModel!.fontSize.value.toDouble().clamp(10, 100),
                                        color: selectedTextModel!.textColor.value.withOpacity(selectedTextModel!.opacity.value),
                                        fontWeight: selectedTextModel!.isBold.value ? FontWeight.bold : FontWeight.normal,
                                        fontStyle: selectedTextModel!.isItalic.value ? FontStyle.italic : FontStyle.normal,
                                        decoration: selectedTextModel!.isUnderline.value
                                            ? TextDecoration.underline
                                            : (selectedTextModel!.isStrikethrough.value ? TextDecoration.lineThrough : null),
                                        shadows: [
                                          Shadow(
                                            blurRadius: selectedTextModel!.shadowBlur.value,
                                            color: selectedTextModel!.shadowColor.value,
                                            offset: Offset(
                                              selectedTextModel!.shadowOffsetX.value,
                                              selectedTextModel!.shadowOffsetY.value,
                                            ),
                                          ),
                                        ],
                                      ),
                                      textAlign: selectedTextModel!.textAlign.value,
                                    ),
                                  ),
                                );

                                try {
                                  _controller.editWidget(
                                    updatedWidget,
                                    Offset(selectedTextModel!.left.value, selectedTextModel!.top.value),
                                  );
                                  print('Updated selectedTextModel: ${selectedTextModel!.text.value}');
                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                    // Close TextUIWithTabsScreen
                                  });
                                }
                                catch (e, stackTrace) {
                                  print('Error updating text model: $e');
                                  print(stackTrace);
                                }
                              }
                              else if (isAddingNewText && text.isNotEmpty) {
                                // _createNewTextModel(text);
                              } else {
                                print('No action: empty text or invalid state');
                                // Get.back();
                              }

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
                    final textModel = textController.selectedText.value;

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
                            textController.centerTextHorizontally(imageLeft, imageWidth, textWidth);
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
                            textController.centerTextVertically(imageTop, imageHeight, textHeight);
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
                      textController.updateTextAlign(TextAlign.center);
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
                      textController.updateTextAlign(TextAlign.left);
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
                      textController.updateTextAlign(TextAlign.center);
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
                      textController.updateTextAlign(TextAlign.right);
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
                      textController.selectedText.value?.fontFamily.value ?? 'Roboto',
                      style: GoogleFonts.getFont(
                        textController.selectedText.value?.fontFamily.value ?? 'Roboto',
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
                          color: textController.selectedText.value?.isBold.value ?? false
                              ? Colors.purpleAccent
                              : Colors.white),
                      onPressed: () {
                        _unfocus();
                        textController.toggleBold();
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
                          color: textController.selectedText.value?.isItalic.value ?? false
                              ? Colors.purpleAccent
                              : Colors.white),
                      onPressed: () {
                        _unfocus();
                        textController.toggleItalic();
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
                          color: textController.selectedText.value?.isUnderline.value ?? false
                              ? Colors.purpleAccent
                              : Colors.white),
                      onPressed: () {
                        _unfocus();
                        textController.toggleUnderline();
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
                          color: textController.selectedText.value?.isStrikethrough.value ?? false
                              ? Colors.purpleAccent
                              : Colors.white),
                      onPressed: () {
                        _unfocus();
                        textController.toggleStrikethrough();
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
            SizedBox(height: 20),
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
                Obx(() => GestureDetector(
                  onTap: () {
                    _openColorPicker(
                      context,
                      textController.selectedText.value?.textColor.value ?? Colors.black,
                          (color) {
                        textController.updateTextColor(color);
                        print('Text color changed: $color');
                      },
                      'Text Color',
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: textController.selectedText.value?.textColor.value ?? Colors.black,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                )),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Background Color',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 16),
                Obx(() => GestureDetector(
                  onTap: () {
                    _openColorPicker(
                      context,
                      textController.selectedText.value?.backgroundColor.value ?? Colors.transparent,
                          (color) {
                        textController.updateBackgroundColor(color);
                        print('Background color changed: $color');
                      },
                      'Background Color',
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: textController.selectedText.value?.backgroundColor.value ?? Colors.transparent,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                )),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Opacity',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Obx(() => Slider(
                    value: textController.selectedText.value?.opacity.value ?? 1.0,
                    min: 0.0,
                    max: 1.0,
                    onChanged: (value) {
                      textController.updateOpacity(value);
                      print('Opacity changed: $value');
                    },
                    activeColor: Colors.purpleAccent,
                    inactiveColor: Colors.grey,
                  )),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        );
      case 'Shadow':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Shadow Color',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 16),
                Obx(() => GestureDetector(
                  onTap: () {
                    _openColorPicker(
                      context,
                      textController.selectedText.value?.shadowColor.value ?? Colors.black,
                          (color) {
                        textController.updateShadowColor(color);
                        print('Shadow color changed: $color');
                      },
                      'Shadow Color',
                    );
                  },
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: textController.selectedText.value?.shadowColor.value ?? Colors.black,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: Colors.white, width: 1),
                    ),
                  ),
                )),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Shadow Blur',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Obx(() => Slider(
                    value: textController.selectedText.value?.shadowBlur.value ?? 0.0,
                    min: 0.0,
                    max: 20.0,
                    onChanged: (value) {
                      textController.updateShadowBlur(value);
                      print('Shadow blur changed: $value');
                    },
                    activeColor: Colors.purpleAccent,
                    inactiveColor: Colors.grey,
                  )),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Shadow Offset X',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Obx(() => Slider(
                    value: textController.selectedText.value?.shadowOffsetX.value ?? 0.0,
                    min: -10.0,
                    max: 10.0,
                    onChanged: (value) {
                      textController.updateShadowOffsetX(value);
                      print('Shadow offset X changed: $value');
                    },
                    activeColor: Colors.purpleAccent,
                    inactiveColor: Colors.grey,
                  )),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Text(
                  'Shadow Offset Y',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Obx(() => Slider(
                    value: textController.selectedText.value?.shadowOffsetY.value ?? 0.0,
                    min: -10.0,
                    max: 10.0,
                    onChanged: (value) {
                      textController.updateShadowOffsetY(value);
                      print('Shadow offset Y changed: $value');
                    },
                    activeColor: Colors.purpleAccent,
                    inactiveColor: Colors.grey,
                  )),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        );
      default:
        return SizedBox.shrink();
    }
  }
}