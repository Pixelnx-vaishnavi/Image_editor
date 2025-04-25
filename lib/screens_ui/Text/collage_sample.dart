import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_collage_widget/image_collage_widget.dart';
import 'package:image_collage_widget/model/images.dart';
import 'package:image_collage_widget/utils/collage_type.dart';
import 'package:path_provider/path_provider.dart';

class CollageSample extends StatefulWidget {
  final CollageType collageType;
  final List<Images> images;
  final String text;

  const CollageSample(
      this.collageType,
      this.images, {
        super.key,
        this.text = '',
      });

  @override
  State<StatefulWidget> createState() {
    return _CollageSample();
  }
}

class _CollageSample extends State<CollageSample> {
  final GlobalKey _screenshotKey = GlobalKey();
  bool _startLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () => Get.back(),
          child: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
        ),
        title: const Text(
          "Collage Maker",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        actions: <Widget>[
          GestureDetector(
            onTap: () => _capturePng(),
            child: const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  "Share",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          RepaintBoundary(
            key: _screenshotKey,
            child: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: ImageCollageWidget(
                    images: widget.images,
                    collageType: widget.collageType,
                    withImage: true,
                  ),
                ),
                if (widget.text.isNotEmpty)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      color: Colors.black54,
                      child: Text(
                        widget.text,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_startLoading)
            SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Future<Uint8List> _capturePng() async {
    try {
      setState(() {
        _startLoading = true;
      });
      // ... (rest of the _capturePng method remains the same as before)
      Directory dir;
      RenderRepaintBoundary? boundary =
      _screenshotKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
      await Future.delayed(const Duration(milliseconds: 2000));
      if (Platform.isIOS) {
        dir = await getApplicationDocumentsDirectory();
      } else {
        dir = (await getExternalStorageDirectory())!;
      }
      var image = await boundary?.toImage();
      var byteData = await image?.toByteData(format: ui.ImageByteFormat.png);
      File screenshotImageFile =
      File('${dir.path}/${DateTime.now().microsecondsSinceEpoch}.png');
      await screenshotImageFile.writeAsBytes(byteData!.buffer.asUint8List());
      _shareScreenShot(screenshotImageFile.path);
      return byteData.buffer.asUint8List();
    } catch (e) {
      setState(() {
        _startLoading = false;
      });
      print("Capture Image Exception Main : $e");
      throw Exception();
    }
  }

  _shareScreenShot(String imgpath) async {
    setState(() {
      _startLoading = false;
    });
    try {
      // Share.shareXFiles([XFile(imgpath)]);
    } catch (e) {
      print("Share Exception: $e");
    }
  }
}