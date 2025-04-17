import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/Const/routes_const.dart';
import 'package:image_picker/image_picker.dart';

class BottomSheetController extends GetxController {

  void showCreateTemplateSheet() {
    Get.bottomSheet(
      Padding(
        padding:  EdgeInsets.only(bottom: 24),
        child: Container(
          margin:  EdgeInsets.symmetric(horizontal: 16),
          padding:  EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: Offset(0, -2),
              ),
            ],
          ),
          child: Wrap(
            children: [
              //
               Padding(
                 padding: EdgeInsets.only(left: 5,right: 5,top: 15,bottom: 8),
                 child: Center(
                   child: Text(
                    'Create New Template',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Outfit',
                    ),
                                 ),
                 ),
               ),
               SizedBox(height: 25),

               Padding(
                 padding:  EdgeInsets.only(left: 2,right: 2,top: 25,bottom: 8),
                 child: Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: [
                     GestureDetector(
                       onTap: () {
                         Get.find<BottomSheetController>().pickImageFromCamera();
                       },
                       child: Container(
                         height: 120,
                         width: 130,
                         decoration: BoxDecoration(
                             borderRadius: BorderRadius.circular(10),
                             // gradient: LinearGradient(
                             //   begin: Alignment.topCenter,
                             //   end: Alignment.bottomCenter,
                             //   colors: [
                             //     Color(ColorConst.skyBlue),
                             //     Color(ColorConst.lightpurple),
                             //   ],
                             // ),
                           border: Border.all(color: Color(ColorConst.lightishbordercolorgrey))
                         ),
                         child: Center(
                           child: Column(
                             mainAxisAlignment: MainAxisAlignment.center,
                             children: [
                              Image.asset('assets/addsquare.png'),
                               SizedBox(height: 7,),
                               Text(
                                 'Create From Camera',
                                 style: TextStyle(
                                   color: Color(ColorConst.textblackcolor),
                                   fontFamily: 'Outfit',
                                   fontWeight: FontWeight.w400,
                                   fontSize: 12,
                                   height: 1.0, // Line height 100%
                                   letterSpacing: 0.0,
                                 ),
                               )

                             ],
                           ),
                         ),
                       ),
                     ),
                     SizedBox(width: 10,),
                     Container(
                       height: 120,
                       width: 130,
                       decoration: BoxDecoration(
                           borderRadius: BorderRadius.circular(10),
                           // gradient: LinearGradient(
                           //   begin: Alignment.topCenter,
                           //   end: Alignment.bottomCenter,
                           //   colors: [
                           //     Color(ColorConst.skyBlue),
                           //     Color(ColorConst.lightpurple),
                           //   ],
                           // ),
                           border: Border.all(color: Color(ColorConst.lightishbordercolorgrey))
                       ),
                       child: Center(
                         child: Column(
                           mainAxisAlignment: MainAxisAlignment.center,
                           children: [
                           Image.asset('assets/magicpen.png'),
                             SizedBox(height: 7,),
                             Text(
                               'Create From Gallery',
                               style: TextStyle(
                                 color: Color(ColorConst.textblackcolor),
                                 fontFamily: 'Outfit',
                                 fontWeight: FontWeight.w400,
                                 fontSize: 12,
                                 height: 1.0, // Line height 100%
                                 letterSpacing: 0.0,
                               ),
                             )

                           ],
                         ),
                       ),
                     ),
                   ],
                 ),
               ),

              Center(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 120,
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        // gradient: LinearGradient(
                        //   begin: Alignment.topCenter,
                        //   end: Alignment.bottomCenter,
                        //   colors: [
                        //     Color(ColorConst.skyBlue),
                        //     Color(ColorConst.lightpurple),
                        //   ],
                        // ),
                        border: Border.all(color: Color(ColorConst.lightishbordercolorgrey))
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset('assets/category.png'),
                          SizedBox(height: 7,),
                          Text(
                            'Create From Templates',
                            style: TextStyle(
                              color: Color(ColorConst.textblackcolor),
                              fontFamily: 'Outfit',
                              fontWeight: FontWeight.w400,
                              // fontSize: 12,
                              height: 1.0,
                              letterSpacing: 0.0,
                            ),
                          )

                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }


  final ImagePicker _picker = ImagePicker();

  Future<void> pickImageFromCamera() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      Get.back();
      Get.toNamed(Consts.ImageEditorScreen, arguments: imageFile);

    } else {
      Get.snackbar('Cancelled', 'No image selected');
    }
  }
}
