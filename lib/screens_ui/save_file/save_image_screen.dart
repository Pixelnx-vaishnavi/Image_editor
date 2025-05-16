import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor/screens_ui/image_editor/image_editor_screen.dart';
import 'package:image_editor/screens_ui/save_file/saved_image_model.dart';


class SavedImagesScreen extends StatelessWidget {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Images'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _dbHelper.getImages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading images', style: TextStyle(color: Colors.white)));
          }
          final images = snapshot.data ?? [];
          if (images.isEmpty) {
            return Center(child: Text('No saved images', style: TextStyle(color: Colors.white)));
          }
          return GridView.builder(
            padding: EdgeInsets.all(10),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: images.length,
            itemBuilder: (context, index) {
              final filePath = images[index]['file_path'] as String;
              final file = File(filePath);
              return GestureDetector(
                onTap: () {
                  if (file.existsSync()) {
                    Get.to(() => ImageEditorScreen(), arguments: file);
                  } else {
                    Get.snackbar("Error", "Image file not found");
                  }
                },
                child: Image.file(
                  file,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.grey,
                    child: Center(child: Text('Image not found', style: TextStyle(color: Colors.white))),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}