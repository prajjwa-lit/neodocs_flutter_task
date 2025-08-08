// lib/main.dart
import 'package:flutter/material.dart';
import 'controllers/range_controller.dart';
import 'services/api_service.dart';
import 'views/home_screen.dart';

/// Simple InheritedNotifier wrapper to provide the controller down the tree.
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
  // Token from assignment PDF (hard-coded here for assignment):
  const token =
      'eb3dae0a10614a7e719277e07e268b12aeb3af6d7a4655472608451b321f5a95';
  const apiUrl = 'https://nd-assignment.azurewebsites.net/api/get-ranges';

  final apiService = ApiService(url: apiUrl, bearerToken: token);
  final controller = RangeController(apiService: apiService);

  // Kick off fetch at startup (controller will notify listeners)
  controller.fetchRanges();

  runApp(MyApp(controller: controller));
}

class MyApp extends StatelessWidget {
  final RangeController controller;
  const MyApp({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return RangeProvider(
      controller: controller,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Range Bar Assignment',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const HomeScreen(),
      ),
    );
  }
}
