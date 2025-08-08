// lib/widgets/range_input_field.dart
import 'package:flutter/material.dart';

class RangeInputField extends StatelessWidget {
  final TextEditingController controller;
  final String? errorText;
  final ValueChanged<String> onSubmitted;
  final VoidCallback onCheckPressed;

  const RangeInputField({
    Key? key,
    required this.controller,
    required this.onSubmitted,
    required this.onCheckPressed,
    this.errorText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
        child: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            labelText: 'Enter numeric value',
            labelStyle: const TextStyle(fontWeight: FontWeight.w500),
            hintText: 'e.g. 45',
            errorText: errorText,
            border: InputBorder.none,
            suffixIcon: IconButton(
              icon: const Icon(Icons.check_circle_outline),
              onPressed: onCheckPressed,
            ),
          ),
          onSubmitted: onSubmitted,
        ),
      ),
    );
  }
}
