


import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:image_editor/Const/routes_const.dart';
import 'package:image_editor/screens_ui/image_editor/image_editor_screen.dart';

class AppPages {
  static final pages = [
    GetPage(name: Consts.ImageEditorScreen, page: () => ImageEditorScreen(),  transition: Transition.fade,),
    // GetPage(name: Consts.ImageEditorScreenSecond, page: () => ImageEditorScreenSecond(),  transition: Transition.fade,),
  ];
}


