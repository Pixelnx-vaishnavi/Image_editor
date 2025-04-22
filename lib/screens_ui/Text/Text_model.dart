import 'dart:ui';

import 'package:flutter/material.dart';

class TextOverlayModel {
  String id;
  String text;
  double fontSize;
  String fontFamily;
  TextAlign textAlign;
  Color textColor;
  double opacity;
  List<Shadow> shadows;
  double top;
  double left;
  double rotation;
  bool isSelected;

  TextOverlayModel({
    required this.id,
    required this.text,
    this.fontSize = 24,
    this.fontFamily = 'Roboto',
    this.textAlign = TextAlign.center,
    this.textColor = Colors.white,
    this.opacity = 1.0,
    this.shadows = const [],
    this.top = 100,
    this.left = 100,
    this.rotation = 0,
    this.isSelected = false,
  });
}
