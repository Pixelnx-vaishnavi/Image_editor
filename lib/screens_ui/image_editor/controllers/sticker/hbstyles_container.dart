// lib/widgets/hb_styled_container.dart
import 'package:flutter/material.dart';

class HBStyledContainer extends StatelessWidget {
  final Widget child;
  final Color firstColor;
  final Color secondColor;
  final bool horizontalGradient;
  final double borderWidth;
  final Color borderColor;
  final double cornerRadius;
  final double shadowOpacity;
  final Color shadowColor;
  final double shadowRadius;
  final double shadowOffsetY;

  const HBStyledContainer({
    Key? key,
    required this.child,
    this.firstColor = Colors.white,
    this.secondColor = Colors.white,
    this.horizontalGradient = false,
    this.borderWidth = 0.0,
    this.borderColor = Colors.transparent,
    this.cornerRadius = 0.0,
    this.shadowOpacity = 0.0,
    this.shadowColor = Colors.transparent,
    this.shadowRadius = 0.0,
    this.shadowOffsetY = 0.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: horizontalGradient ? Alignment.centerLeft : Alignment.topCenter,
          end: horizontalGradient ? Alignment.centerRight : Alignment.bottomCenter,
          colors: [firstColor, secondColor],
        ),
        border: Border.all(color: borderColor, width: borderWidth),
        borderRadius: BorderRadius.circular(cornerRadius),
        boxShadow: [
          if (shadowOpacity > 0)
            BoxShadow(
              color: shadowColor.withOpacity(shadowOpacity),
              blurRadius: shadowRadius,
              offset: Offset(0, shadowOffsetY),
            ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: child,
      ),
    );
  }
}
