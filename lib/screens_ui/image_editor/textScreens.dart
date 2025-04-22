import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/Text/Text_controller.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';



class TextUIWithTabsScreen extends StatefulWidget {
  @override
  _TextUIWithTabsScreenState createState() => _TextUIWithTabsScreenState();
}

class _TextUIWithTabsScreenState extends State<TextUIWithTabsScreen> {
  final ImageEditorController _controller = Get.put(ImageEditorController());

  final TextEditingController _textController = TextEditingController();
  final TextEditorController TextController = TextEditorController();
  final TextEditingController _fontSizeController = TextEditingController(text: '16');
  String selectedTab = 'Font';



  @override
  void dispose() {
    _textController.dispose();
    _fontSizeController.dispose();
    super.dispose();
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
                 Text("Alignment",style: TextStyle(fontSize: 14,color: Colors.white),),
                  SizedBox(width: 16),
                  Container(
                    decoration: BoxDecoration(
                      color:Colors.grey[800] ,
                      borderRadius: BorderRadius.circular(5)
                    ),
                    height: 40,
                      width: 40,
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Image.asset('assets/text/textAlignment_horizontal.png'),
                      )),
                  SizedBox(width: 20,),
                  Container(
                      decoration: BoxDecoration(
                          color:Colors.grey[800] ,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      height: 40,
                      width: 40,
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Image.asset('assets/text/textAlignment_vertical.png'),
                      )),

                ],
              ),
            ),
            SizedBox(height: 17,),
            Padding(
              padding: const EdgeInsets.only(left: 10),
              child: Row(
                children: [
                  Text("Text Align",style: TextStyle(fontSize: 14,color: Colors.white),),
                  SizedBox(width: 16),
                  Container(
                      decoration: BoxDecoration(
                          color:Colors.grey[800] ,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      height: 40,
                      width: 40,
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Image.asset('assets/text/centertext.png'),
                      )),
                  SizedBox(width: 20,),
                  Container(
                      decoration: BoxDecoration(
                          color:Colors.grey[800] ,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      height: 40,
                      width: 40,
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Image.asset('assets/text/leftText.png'),
                      )),
                  SizedBox(width: 20,),
                  Container(
                      decoration: BoxDecoration(
                          color:Colors.grey[800] ,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      height: 40,
                      width: 40,
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Image.asset('assets/text/centerAlignText.png'),
                      )),
                  SizedBox(width: 20,),
                  Container(
                      decoration: BoxDecoration(
                          color:Colors.grey[800] ,
                          borderRadius: BorderRadius.circular(5)
                      ),
                      height: 40,
                      width: 40,
                      child: Padding(
                        padding:  EdgeInsets.all(8.0),
                        child: Image.asset('assets/text/rightText.png'),
                      )),
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
                    onPressed: () {},
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
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey[800],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    onPressed: () {},
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
            SizedBox(height: 16,),
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
            SizedBox(height: 16,),
            _buildSlider("Opacity",_controller.opacity.value , -100, 100, (v) {
              setState(() {
                _controller.opacity.value = v;
              });
            }),
          ],
        );
      case 'Shadow':
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSliderShadow("Blur",_controller.opacity.value , -100, 100, (v) {
          setState(() {
            _controller.opacity.value = v;
          });}),
            _buildSliderShadow("Offset X",_controller.opacity.value , -100, 100, (v) {
              setState(() {
                _controller.opacity.value = v;
              });}),
            _buildSliderShadow("Offset Y",_controller.opacity.value , -100, 100, (v) {
              setState(() {
                _controller.opacity.value = v;
              });}),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:Color(ColorConst.bottomBarcolor),
      body: Stack(
        children: [
          // Background Image
          // Container(
          //   decoration: BoxDecoration(
          //     image: DecorationImage(
          //       image: AssetImage('assets/medical_exam.jpg'),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          // ),
          // Overlay with Controls
          SafeArea(
            child: Padding(
              padding:  EdgeInsets.all(5.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    onTap: () {
                      TextController.updateText(_textController.text);
                    },
                    onChanged: (value) {
                      print('============value===========');
                      print(value);
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
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  SizedBox(height: 16),
                  // Toggle Buttons (Alignment, Font, Color, Shadow)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _controller.isAlignmentText.value = true;
                          selectedTab = 'Alignment';
                        }
                            ),
                        child: Text('Alignmet'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedTab == 'Alignment' ?  Color.fromRGBO(140, 97, 255, 0.4) : Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _controller.isAlignmentText.value = false;
                          selectedTab = 'Font';
                        }),
                        child: Text('Font'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedTab == 'Font' ? Color.fromRGBO(140, 97, 255, 0.4) : Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _controller.isAlignmentText.value = false;
                          selectedTab = 'Color';
                        }),
                        child: Text('Color'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedTab == 'Color' ?  Color.fromRGBO(140, 97, 255, 0.4) : Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => setState(() {
                          _controller.isAlignmentText.value = false;
                          selectedTab = 'Shadow';
                        }),
                        child: Text('Shadow'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedTab == 'Shadow' ?  Color.fromRGBO(140, 97, 255, 0.4) : Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  // Dynamic Content Based on Selected Tab
                  _buildTabContent(),
                  SizedBox(height: 12),
                  // Bottom Buttons (Cancel, Text, OK)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.white),
                        onPressed: () {},
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
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: Icon(Icons.check, color: Colors.white),
                        onPressed: () {},
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

  Widget _buildSlider(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Text(title, style:  TextStyle(color: Colors.white70, fontSize: 16)),
        Spacer(),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
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
              value.toInt().toString(),
              style:  TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
  Widget _buildSliderShadow(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Text(title, style:  TextStyle(color: Colors.white70, fontSize: 16)),
        Spacer(),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
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
              value.toInt().toString(),
              style:  TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
        SizedBox(width: 6,),
        Text('px', style:  TextStyle(color: Colors.white70, fontSize: 16)),
      ],
    );
  }
}