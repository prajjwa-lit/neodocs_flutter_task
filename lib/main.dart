// lib/main.dart
import 'package:flutter/material.dart';
import 'controllers/range_controller.dart';
import 'services/api_service.dart';
import 'widgets/range_bar.dart';
import 'models/range_section.dart';

/// Simple InheritedNotifier wrapper to provide the controller down the tree.
class RangeProvider extends InheritedNotifier<RangeController> {
  RangeProvider({Key? key, required RangeController controller, required Widget child})
      : super(key: key, notifier: controller, child: child);

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
  const MyApp({Key? key, required this.controller}) : super(key: key);

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

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// Note: we are not using setState to update the bar; the widget uses AnimatedBuilder
// and the controller's ChangeNotifier to update. We only hold the TextEditingController here.
class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();

  RangeController get controller => RangeProvider.of(context);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _legend(List<RangeSection> sections) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: sections.map((s) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 18, height: 12, color: s.color),
            const SizedBox(width: 6),
            Text('${s.meaning} (${s.start.toInt()}-${s.end.toInt()})'),
          ],
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // AnimatedBuilder listens to controller and rebuilds only this subtree when controller notifies.
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(title: const Text('Range Bar Assignment')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(children: [
              TextField(
                controller: _textController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Enter numeric value',
                  hintText: 'e.g. 45',
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: () {
                      controller.setValueFromString(_textController.text);
                    },
                  ),
                ),
                onSubmitted: (v) => controller.setValueFromString(v),
              ),
              const SizedBox(height: 16),
              // content area
              Expanded(
                child: Center(
                  child: Builder(builder: (context) {
                    if (controller.loading) {
                      return const CircularProgressIndicator();
                    } else if (controller.error != null) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Error: ${controller.error}'),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: controller.fetchRanges,
                            child: const Text('Retry'),
                          ),
                        ],
                      );
                    } else if (controller.sections.isEmpty) {
                      return const Text('No ranges returned by API');
                    }

                    // Normal state: show the RangeBar and legend
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 600, // allow nice width on wider screens; constrained by parent in smaller screens
                          child: RangeBar(
                            sections: controller.sections,
                            value: controller.currentValue,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _legend(controller.sections),
                      ],
                    );
                  }),
                ),
              ),
            ]),
          ),
        );
      },
    );
  }
}
