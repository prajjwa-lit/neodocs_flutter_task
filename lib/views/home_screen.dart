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

  Widget _buildInputField() {
    return TextField(
      controller: _textController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: 'Enter numeric value',
        hintText: 'e.g. 45',
        errorText: controller.inputError,
        suffixIcon: IconButton(
          icon: const Icon(Icons.check),
          onPressed: () {
            controller.setValueFromString(_textController.text);
          },
        ),
      ),
      onSubmitted: (v) => controller.setValueFromString(v),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (currentRange != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              'Current Range: $currentRange',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        SizedBox(
          width: 600,
          child: RangeBar(
            sections: controller.sections,
            value: controller.currentValue,
          ),
        ),
        const SizedBox(height: 12),
        _legend(controller.sections),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Range Bar Assignment'),
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
                    vertical: 16.0,
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