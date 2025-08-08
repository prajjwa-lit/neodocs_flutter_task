// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import '../controllers/range_controller.dart';
import '../widgets/fallback_states.dart';
import '../widgets/range_display.dart';
import '../widgets/range_input_field.dart';
import '../main.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _textController = TextEditingController();

  RangeController get controller => RangeProvider.of(context);

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Widget _buildContent() {
    if (controller.loading) {
      return const LoadingState(
        message: 'Loading range data...',
      );
    }

    if (controller.error != null) {
      return ErrorState(
        message: controller.error!,
        onRetry: controller.retryWithDelay,
        isRetrying: controller.isRetrying,
      );
    }

    if (controller.sections.isEmpty) {
      return const EmptyState(
        message: 'No ranges available',
        icon: Icons.bar_chart,
      );
    }

    return RangeDisplay(
      sections: controller.sections,
      currentValue: controller.currentValue,
      currentRange: controller.getCurrentRange(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.blueAccent,
            elevation: 2,
            title: const Text(
              'Range Bar Assignment',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            actions: [
              if (controller.loading || controller.error != null)
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: controller.loading ? null : controller.fetchRanges,
                ),
            ],
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth > 700;
              final horizontalPadding = isWide ? constraints.maxWidth * 0.2 : 16.0;

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalPadding,
                    vertical: 24.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      RangeInputField(
                        controller: _textController,
                        errorText: controller.inputError,
                        onSubmitted: controller.setValueFromString,
                        onCheckPressed: () {
                          controller.setValueFromString(_textController.text);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildContent(),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
