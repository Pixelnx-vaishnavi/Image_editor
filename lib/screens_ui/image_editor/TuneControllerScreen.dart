import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/image_editor/TuneScreen.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';

class TuneEditControls extends StatefulWidget {
  @override
  _TuneEditControlsState createState() => _TuneEditControlsState();
}

class _TuneEditControlsState extends State<TuneEditControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final ImageEditorController _controllerimage = Get.put(ImageEditorController());

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 1), // starts off-screen below
      end: Offset.zero,    // slides to normal position
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _controller.forward(); // start the animation on init
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      height: (_controllerimage.isBrushSelected.value == true) ? 300 : 250,
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Color(ColorConst.bottomBarcolor),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: ListView(
            children: [
              TuneControlsPanel(
                onTuneChanged: (double contrast, double brightness) {
                  contrast = contrast;
                  brightness = brightness;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
