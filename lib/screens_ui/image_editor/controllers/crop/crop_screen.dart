// import 'dart:typed_data';
//
// import 'package:flutter/material.dart';
// import 'package:crop_your_image/crop_your_image.dart';
//
// class CropPage extends StatefulWidget {
//   final Uint8List imageBytes;
//
//   const CropPage({super.key, required this.imageBytes});
//
//   @override
//   State<CropPage> createState() => _CropPageState();
// }
//
// class _CropPageState extends State<CropPage> {
//   final _cropController = CropController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Crop Image")),
//       body: Column(
//         children: [
//           Expanded(
//             child: Crop(
//               image: widget.imageBytes,
//               controller: _cropController,
//               onCropped: (croppedData) {
//                 // do something with cropped image bytes
//               },
//               withCircleUi: false,
//               // fixArea: false, // Allows free cropping
//               interactive: true,
//               // initialSize: 0.8,
//               baseColor: Colors.black,
//               maskColor: Colors.black.withOpacity(0.5),
//               cornerDotBuilder: (size, edgeAlignment) => DotControl(color: Colors.white),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => _cropController.crop(),
//             child: Text("Crop"),
//           ),
//         ],
//       ),
//     );
//   }
// }
