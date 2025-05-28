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
      body:  FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getTemplates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print('Error loading templates: ${snapshot.error}');
            return const Center(child: Text('Error loading templates'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            print('No templates found');
            return const Center(child: Text('No templates found'));
          }
          final templates = snapshot.data!;
          return Expanded(
            child: ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final template = templates[index];
                final Map<String, dynamic> state = jsonDecode(template['state']);
                final String displayImagePath = template['previewFilePath'];
                return ListTile(
                  leading: displayImagePath.isNotEmpty && File(displayImagePath).existsSync()
                      ? Image.file(
                    File(displayImagePath),
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading image: $displayImagePath, error: $error');
                      return const Icon(Icons.broken_image);
                    },
                  )
                      : const Icon(Icons.image_not_supported),
                  title: Text(template['name']),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () async {
                      try {
                        await dbHelper.deleteTemplate(template['id']);
                        print('Deleted template: ${template['name']}');
                        (context as Element).markNeedsBuild();
                      } catch (e) {
                        print('Error deleting template: $e');
                        Get.snackbar('Error', 'Failed to delete template: $e');
                      }
                    },
                  ),
                  onTap: () {
                    print('Loading template: ${template['name']}');
                    Get.to(() => ImageEditorScreen(), arguments: state);
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}

