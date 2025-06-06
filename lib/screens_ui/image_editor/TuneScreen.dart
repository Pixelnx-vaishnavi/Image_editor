import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_editor/Const/color_const.dart';
import 'package:image_editor/screens_ui/image_editor/controllers/image_editor_controller.dart';

class TuneControlsPanel extends StatefulWidget {

  final Function(double contrast, double brightness) onTuneChanged;

   TuneControlsPanel({
    super.key,
    required this.onTuneChanged,
  });

  @override
  State<TuneControlsPanel> createState() => _TuneControlsPanelState();
}

class _TuneControlsPanelState extends State<TuneControlsPanel> {
  final ImageEditorController _controller = Get.put(ImageEditorController());

  double brushSize = 50;



  void _updateTune() {
    widget.onTuneChanged(_controller.contrast.value, _controller.brightness.value);
    // _controller.applyTune(_controller.contrast.value, _controller.brightness.value);
    _controller.saveImageState(contrast: _controller.contrast.value, brightness: _controller.brightness.value);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
        child: Column(
          children: [
            Center(
              child: Row(
                children: [
                  _toggleButton("All", !_controller.isBrushSelected.value, Icon(Icons.grid_view_outlined, color: Colors.white, size: 15)),
                  // SizedBox(width: 8),
                  // _toggleButton("Brush", _controller.isBrushSelected.value, Icon(Icons.brush, color: Colors.white, size: 15)),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Show sliders based on the selection
            // if (_controller.isBrushSelected.value) ...[
            //   _buildSlider("Brush size", brushSize, 0, 100, (v) {
            //     setState(() => brushSize = v);
            //   }),
            // ],
            _buildSlider("Contrast", _controller.contrast.value, -100, 100, (v) {
              setState(() {
                _controller.contrast.value = v;
                _updateTune();
              });
            }),
            _buildSlider("Brightness", _controller.brightness.value, -100, 100, (v) {
              setState(() {
                _controller.brightness.value = v;
                _updateTune();
              });
            }),
            SizedBox(height: 20),
            Divider(color: Colors.grey.shade600,),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    _controller.contrast.value = 0;
                    _controller.brightness.value = 0;
                    _updateTune();
                    _controller.showtuneOptions.value = false;
                  },
                  child: SizedBox(
                    height: 36,
                    child: Image.asset('assets/cross.png'),
                  ),
                ),
                // _iconBox(Icons.close, () {
                //   setState(() {
                //     _controller.contrast.value = 0;
                //     _controller.brightness.value = 0;
                //     _updateTune();
                //     _controller.showtuneOptions.value = false;
                //   });
                // }),
                Text("Tune", style: TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.bold)),
                GestureDetector(
                  onTap: () async {
    _controller.showtuneOptions.value = false;
    },

                  child: SizedBox(
                    height: 36,
                    child: Image.asset('assets/right.png'),
                  ),
                ),
                // _iconBox(Icons.check, () {
                //   _controller.showtuneOptions.value = false;
                // }),
              ],
            ),
          ],
        ),
    );
  }

  Widget _iconBox(IconData icon,var tap) {
    return GestureDetector(
      onTap: tap,
      child: Container(
        height: 27,
        width: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2),
          color: Colors.white10,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }

  Widget _toggleButton(String title, bool isSelected, Icon icon) {
    return GestureDetector(
      onTap: () => setState(() => _controller.isBrushSelected.value = title == "Brush"),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.deepPurple : Colors.white10,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 5),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[300],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String title, double value, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Text(title, style: TextStyle(color: Colors.white)),
        Spacer(),
        SizedBox(
          width: 250, // Adjust this value to increase/decrease the slider width
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: (max - min).toInt(),
            onChanged: onChanged,
            activeColor: Colors.purpleAccent,
            inactiveColor: Colors.white24,
          ),
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
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }
}

