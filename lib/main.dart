// lib/main.dart
import 'package:flutter/material.dart';
import 'controllers/range_controller.dart';
import 'core/app.dart';

class RangeProvider extends InheritedNotifier<RangeController> {
  const RangeProvider({super.key, required RangeController controller, required super.child})
      : super(notifier: controller);

  static RangeController of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<RangeProvider>();
    assert(provider != null, 'RangeProvider not found in widget tree');
    return provider!.notifier as RangeController;
  }
}

void main() {
  final controller = App.initializeController();
  runApp(MyApp(controller: controller));
}
