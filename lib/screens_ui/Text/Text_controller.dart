import 'package:get/get.dart';
import 'package:flutter/material.dart';

class TextEditorModel {
  var text;
  double fontSize;
  Color textColor;
  Color backgroundColor;
  double opacity;
  double shadowBlur;
  double shadowOffsetX;
  double shadowOffsetY;
  Color shadowColor;
  var textTop ;
  var textLeft ;


  TextEditorModel({
     this.text ='',
    this.fontSize = 16,
    this.textColor = Colors.black,
    this.backgroundColor = Colors.transparent,
    this.opacity = 1.0,
    this.shadowBlur = 0.0,
    this.shadowOffsetX = 0.0,
    this.shadowOffsetY = 0.0,
    this.shadowColor = Colors.black,
    this.textLeft = 100.0,
    this.textTop = 100.0,
  });
}

class TextEditorController extends GetxController {
  var model = TextEditorModel().obs;

  void updateText(String newText) {
    model.update((val) {
      if (val != null) {
        val.text = newText;
        print('Updated: ${val.text}');
      }
    });
  }



  void updateFontSize(double newSize) {
    model.update((val) {
      val?.fontSize = newSize;
    });
  }

  void updateTextColor(Color newColor) {
    model.update((val) {
      val?.textColor = newColor;
    });
  }

  void updateBackgroundColor(Color newColor) {
    model.update((val) {
      val?.backgroundColor = newColor;
    });
  }

  void updateOpacity(double newOpacity) {
    model.update((val) {
      val?.opacity = newOpacity;
    });
  }

  void updateShadow({
    required double blur,
    required double offsetX,
    required double offsetY,
    required Color color,
  }) {
    model.update((val) {
      val?.shadowBlur = blur;
      val?.shadowOffsetX = offsetX;
      val?.shadowOffsetY = offsetY;
      val?.shadowColor = color;
    });
  }
}
