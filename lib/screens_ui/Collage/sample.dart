import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:screenshot/screenshot.dart';


class CollageSlot {
  final double left;
  final double top;
  final double width;
  final double height;

  CollageSlot({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}

class CollageTemplate {
  final String name;
  final List<CollageSlot> slots;

  CollageTemplate({
     this.name = '',
    required this.slots,
  });
}

List<CollageTemplate> collageTemplates = [
  CollageTemplate(
    name: 'Two Images Side by Side',
    slots: [
      CollageSlot(left: 0, top: 0, width: 0.5, height: 1),
      CollageSlot(left: 0.5, top: 0, width: 0.5, height: 1),
    ],
  ),
  CollageTemplate(
    name: 'Four Grid',
    slots: [
      CollageSlot(left: 0, top: 0, width: 0.5, height: 0.5),
      CollageSlot(left: 0.5, top: 0, width: 0.5, height: 0.5),
      CollageSlot(left: 0, top: 0.5, width: 0.5, height: 0.5),
      CollageSlot(left: 0.5, top: 0.5, width: 0.5, height: 0.5),
    ],
  ),
  CollageTemplate(
    name: 'Top Big, Bottom Two Small',
    slots: [
      CollageSlot(left: 0, top: 0, width: 1, height: 0.6),
      CollageSlot(left: 0, top: 0.6, width: 0.5, height: 0.4),
      CollageSlot(left: 0.5, top: 0.6, width: 0.5, height: 0.4),
    ],
  ),
  CollageTemplate(
    name: 'Three Vertical',
    slots: [
      CollageSlot(left: 0, top: 0, width: 1, height: 0.33),
      CollageSlot(left: 0, top: 0.33, width: 1, height: 0.34),
      CollageSlot(left: 0, top: 0.67, width: 1, height: 0.33),
    ],
  ),
  CollageTemplate(
    name: 'Diagonal Split',
    slots: [
      CollageSlot(left: 0, top: 0, width: 1, height: 0.5),
      CollageSlot(left: 0, top: 0.5, width: 1, height: 0.5),
    ],
  ),
];




class CollagePickerScreen extends StatelessWidget {
  const CollagePickerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick a Collage Layout')),
      body: ListView.builder(
        itemCount: collageTemplates.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(collageTemplates[index].name),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CollageMakerScreen(template: collageTemplates[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}






class CollageMakerScreen extends StatefulWidget {
  final CollageTemplate template;

  const CollageMakerScreen({super.key, required this.template});

  @override
  State<CollageMakerScreen> createState() => _CollageMakerScreenState();
}

class _CollageMakerScreenState extends State<CollageMakerScreen> {
  final picker = ImagePicker();
  late List<File?> images;
  ScreenshotController screenshotController = ScreenshotController();
  late CollageTemplate selectedTemplate;
  bool iselected = false;

  @override
  void initState() {
    super.initState();
    selectedTemplate = widget.template;
    images = List<File?>.filled(selectedTemplate.slots.length, null);
  }

  Future<void> pickImage(int index) async {
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        images[index] = File(picked.path);
      });
    }
  }

  Future<void> saveCollage() async {
    final image = await screenshotController.capture();
    if (image != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SavedCollageScreen(image: image),
        ),
      );
    }
  }

  Widget showTemplatePickerBottomSheet() {

    return Container(
      height: 550, // Same height as your collage bottom sheet
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius:  BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding:  EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
           SizedBox(height: 16),

          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: List.generate(selectedTemplate.slots.length, (index) {
                      final slot = selectedTemplate.slots[index];
                      return Positioned(
                        left: slot.left * constraints.maxWidth,
                        top: slot.top * constraints.maxHeight,
                        width: slot.width * constraints.maxWidth,
                        height: slot.height * constraints.maxHeight,
                        child: GestureDetector(
                          onTap: () => pickImage(index),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            color: Colors.grey.shade300,
                            child: images[index] != null
                                ? ClipRect(
                              child: InteractiveViewer(
                                child: Image.file(
                                  images[index]!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            )
                                : const Center(child: Icon(Icons.add, size: 40)),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),

          Expanded( // Use Expanded for the template list to scroll
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(collageTemplates.length, (index) {
                  final template = collageTemplates[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedTemplate = template;
                        images = List<File?>.filled(selectedTemplate.slots.length, null);
                        // iselected = false;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      width: 120,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            template.name,
                            style:  TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white, // if background is dark
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),

          const SizedBox(height: 26),

          // Bottom Bar: Cross - Title - Right Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {

                },
                child: SizedBox(
                  height: 30,
                  child: Image.asset('assets/cross.png'),
                ),
              ),
              const Text(
                'Templates',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
              GestureDetector(
                onTap: () {
                  // Maybe apply selected template or just close

                },
                child: SizedBox(
                  height: 30,
                  child: Image.asset('assets/right.png'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Collage'),
        actions: [
          IconButton(
            icon: const Icon(Icons.grid_view),
            onPressed: () {
              setState(() {
                iselected = !iselected;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveCollage,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: List.generate(selectedTemplate.slots.length, (index) {
                      final slot = selectedTemplate.slots[index];
                      return Positioned(
                        left: slot.left * constraints.maxWidth,
                        top: slot.top * constraints.maxHeight,
                        width: slot.width * constraints.maxWidth,
                        height: slot.height * constraints.maxHeight,
                        child: GestureDetector(
                          onTap: () => pickImage(index),
                          child: Container(
                            margin: const EdgeInsets.all(2),
                            color: Colors.grey.shade300,
                            child: images[index] != null
                                ? ClipRect(
                              child: InteractiveViewer(
                                child: Image.file(
                                  images[index]!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                            )
                                : const Center(child: Icon(Icons.add, size: 40)),
                          ),
                        ),
                      );
                    }),
                  );
                },
              ),
            ),
          ),

          // If iselected is true, show the picker
          if (iselected)
            SizedBox(
              height: 300, // or whatever height you want
              child: showTemplatePickerBottomSheet(),
            ),
        ],
      ),
    );
  }
}





class SavedCollageScreen extends StatelessWidget {
  final Uint8List image;

  const SavedCollageScreen({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Collage')),
      body: Center(
        child: Image.memory(image),
      ),
    );
  }
}

