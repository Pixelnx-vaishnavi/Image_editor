import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/dashboard/dashboard_controller.dart';
import 'package:image_editor/screens_ui/image_editor/image_editor_screen.dart';
import 'package:image_editor/screens_ui/save_file/saved_image_model.dart';

class DashboardScreen extends StatelessWidget {

   DashboardScreen({super.key});
  final BottomSheetController _bottomSheetController = Get.put(BottomSheetController());
   final DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 40),
            const SizedBox(width: 4),
            const Text(
              'Image',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'Editor',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(ColorConst.primaryColor),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.search,
              color: Color(ColorConst.serachgreycolor),
              size: 30,
            ),
            onPressed: () {},
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              radius: 18,
              backgroundImage: AssetImage('assets/profile.png'),
              backgroundColor: Colors.grey[300], // fallback color
            ),
          ),
        ],
      ),


      body: Container(
        color: Colors.white60,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Container(
                height: 65,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(ColorConst.skyBlue),
                      Color(ColorConst.lightpurple),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    _bottomSheetController.showCreateTemplateSheet();
                  },
                  child:  Center(
                    child: Text(
                      '+ Create New Template',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Outfit',
                        fontWeight: FontWeight.w600,
                        fontSize: 21,
                        height: 1.0,
                        letterSpacing: 0.0,
                      ),
                    ),
                  ),
                ),
              ),
               SizedBox(height: 16),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: dbHelper.getTemplates(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    print('no Templates');
                    return Padding(
                      padding: const EdgeInsets.only(top: 90),
                      child: Center(
                          child: Text('No templates found', style: TextStyle(color: Colors.black,fontSize: 18,fontWeight: FontWeight.bold))
                      ),
                    );
                  }

                  final templates = snapshot.data!;

                  return Expanded(
                    child: GridView.builder(
                      padding: EdgeInsets.all(0),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.0, // Square tiles for images
                      ),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        final template = templates[index];
                        final Map<String, dynamic> state = jsonDecode(template['state']);
                        final String displayImagePath = template['previewFilePath'];

                        return GestureDetector(
                          onTap: () {
                            print('=====state=======${displayImagePath}');
                            Get.to(() => ImageEditorScreen(), arguments: state); // Pass full template state
                          },
                          child: Card(
                            color: Colors.grey[900],
                            clipBehavior: Clip.antiAlias, // Prevent image overflow
                            child: Image.file(
                              File(displayImagePath as String? ?? ''),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.broken_image,
                                color: Colors.white,
                                size: 50,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              // Expanded(
              //   child: GridView.builder(
              //     itemCount: 8,
              //     gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              //       crossAxisCount: 2,
              //       crossAxisSpacing: 12,
              //       mainAxisSpacing: 12,
              //       childAspectRatio: 3 / 4,
              //     ),
              //     itemBuilder: (context, index) {
              //       return Column(
              //         crossAxisAlignment: CrossAxisAlignment.center,
              //         children: [
              //           Expanded(
              //             child: ClipRRect(
              //               borderRadius: BorderRadius.circular(8),
              //               child: Image.asset(
              //                 'assets/templates_image.png',
              //                 width: double.infinity,
              //                 fit: BoxFit.cover,
              //               ),
              //             ),
              //           ),
              //            SizedBox(height: 8),
              //            Text(
              //             'Template Name',
              //             style: TextStyle(
              //               fontSize: 16,
              //               fontFamily: 'Outfit',
              //               fontWeight: FontWeight.w500,
              //             ),
              //           ),
              //         ],
              //       );
              //     },
              //   ),
              // ),

            ],
          ),
        ),
      ),


    );
  }
}
