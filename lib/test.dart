import 'package:flutter/material.dart';
import 'package:lindi_sticker_widget/lindi_controller.dart';
import 'package:lindi_sticker_widget/lindi_sticker_widget.dart';

class StickerWidgetExample extends StatefulWidget {
  @override
  _StickerWidgetExampleState createState() => _StickerWidgetExampleState();
}

class _StickerWidgetExampleState extends State<StickerWidgetExample> {
  LindiController controller = LindiController(
    borderColor: Colors.white,
    icons: [
      // Your LindiStickerIcon configurations
    ],
  );

  @override
  void initState() {
    super.initState();
    // Optional: Listen to position changes for debugging
    controller.onPositionChange((index) {
      debugPrint("Widgets size: ${controller.widgets.length}, current index: $index");
    });
  }

  // Function to move the selected widget to a specific index
  void moveSelectedWidgetToIndex(int newIndex) {
    if (controller.selectedWidget == null) {
      debugPrint("No widget selected");
      return;
    }

    // Find the current index of the selected widget
    int currentIndex = controller.widgets.indexWhere((widget) => widget == controller.selectedWidget);

    if (currentIndex == -1) {
      debugPrint("Selected widget not found in the list");
      return;
    }

    // Ensure the new index is within bounds
    if (newIndex < 0 || newIndex >= controller.widgets.length) {
      debugPrint("Invalid new index: $newIndex");
      return;
    }

    setState(() {
      // Remove the widget from its current position
      var widget = controller.widgets.removeAt(currentIndex);
      // Insert the widget at the new index
      controller.widgets.insert(newIndex, widget);
      // Notify the controller to update the UI

      // controller.();
    });

    debugPrint("Moved widget from index $currentIndex to $newIndex");
  }

  // Example: Bring the selected widget to the front (highest index)
  void bringToFront() {
    moveSelectedWidgetToIndex(controller.widgets.length - 1);
  }

  // Example: Send the selected widget to the back (index 0)
  void sendToBack() {
    moveSelectedWidgetToIndex(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lindi Sticker Widget'),
      ),
      body: Column(
        children: [
          Expanded(
            child: LindiStickerWidget(
              controller: controller,
              child: SizedBox(
                width: double.infinity,
                height: double.infinity,
                child: Image.network(
                  'https://picsum.photos/200/300',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: bringToFront,
                child: const Text('Bring to Front'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: sendToBack,
                child: const Text('Send to Back'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add a new widget for testing
          Widget widget = Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: const Text(
              'This is a Text',
              style: TextStyle(color: Colors.white),
            ),
          );
          controller.add(widget, position: Alignment.center);
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}