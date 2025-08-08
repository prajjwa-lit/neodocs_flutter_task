// lib/views/home_screen.dart
import 'package:flutter/material.dart';
import '../controllers/range_controller.dart';
import '../models/range_section.dart';
import '../widgets/range_bar.dart';
import '../widgets/fallback_states.dart';
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

  Widget _legend(List<RangeSection> sections) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          children: sections.map((s) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 20,
                  height: 14,
                  decoration: BoxDecoration(
                    color: s.color,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: Colors.black12,
                      width: 0.5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${s.meaning} (${s.start.toInt()}-${s.end.toInt()})',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: TextField(
          controller: _textController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Enter numeric value',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            hintText: 'e.g. 45',
            errorText: controller.inputError,
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.arrow_forward_ios_rounded),
              onPressed: () {
                controller.setValueFromString(_textController.text);
              },
            ),
          ),
          onSubmitted: (v) => controller.setValueFromString(v),
        ),
      ),
    );
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

    final currentRange = controller.getCurrentRange();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (currentRange != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Current Range: $currentRange',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(
              width: 600,
              child: RangeBar(
                sections: controller.sections,
                value: controller.currentValue,
              ),
            ),
            const SizedBox(height: 16),
            _legend(controller.sections),
          ],
        ),
      ),
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
                      _buildInputField(),
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
