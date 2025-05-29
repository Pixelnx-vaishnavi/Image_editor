import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_update/in_app_update.dart';

class AppUpdateService{
  static Future<void> checkForUpdateAndPrompt() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        await _showUpdateDialog(); // Await the result if needed
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }
  }


  static Future<bool> _showUpdateDialog() async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        title: const Text("Update Available"),
        content: const Text("A new version is available. Update now?"),
        actions: [
          TextButton(
            child: const Text("Later"),
            onPressed: () => Get.back(result: false),
          ),
          ElevatedButton(
            child: const Text("Update"),
            onPressed: () {
              Get.back(result: true); // Return true for update
              InAppUpdate.performImmediateUpdate()
                  .catchError((e) => Get.snackbar("Update Failed", e.toString()));
            },
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

}