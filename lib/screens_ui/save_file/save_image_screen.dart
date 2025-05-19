import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_editor/screens_ui/image_editor/image_editor_screen.dart';
import 'package:image_editor/screens_ui/save_file/saved_image_model.dart';
import 'package:path/path.dart' as path;

class SavedImagesScreen extends StatelessWidget {
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Saved Templates'),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      backgroundColor: Colors.black,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getTemplates(), // Fetch only templates
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No templates found', style: TextStyle(color: Colors.white)));
          }

          final templates = snapshot.data!;

          return GridView.builder(
            padding: EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.0, // Square tiles for images
            ),
            itemCount: templates.length,
            itemBuilder: (context, index) {
              final template = templates[index];
              final templateState = jsonDecode(template['state']) as Map<String, dynamic>;

              return GestureDetector(
                onTap: () {
                  print('=====state=======${templateState}');
                  Get.to(() => ImageEditorScreen(), arguments: templateState); // Pass full template state
                },
                child: Card(
                  color: Colors.grey[900],
                  clipBehavior: Clip.antiAlias, // Prevent image overflow
                  child: Image.file(
                    File(template['filePath'] as String? ?? ''),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Icon(
                      Icons.broken_image,
                      color: Colors.white,
                      size: 50,
                    ),
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