import 'package:flutter/material.dart';
import '../../domain/entities/calculation_method.dart';

class CalculationMethodSelector extends StatelessWidget {
  final CalculationMethod currentMethod;
  final bool isLoading;
  final ValueChanged<CalculationMethod> onMethodChanged;

  const CalculationMethodSelector({
    super.key,
    required this.currentMethod,
    required this.isLoading,
    required this.onMethodChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: CalculationMethod.values.map((method) {
        final isSelected = method == currentMethod;
        final title = method == CalculationMethod.ffmpeg
            ? 'FFmpeg libvmaf'
            : 'Netflix VMAF CLI';
        final subtitle = method == CalculationMethod.ffmpeg
            ? 'Use FFmpeg with libvmaf filter'
            : 'Use standalone vmaf.exe CLI tool';

        return Card(
          elevation: isSelected ? 2 : 0,
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.3)
              : null,
          child: ListTile(
            title: Text(title),
            subtitle: Text(subtitle),
            leading: Radio<CalculationMethod>(
              value: method,
              groupValue: currentMethod,
              onChanged: isLoading
                  ? null
                  : (value) {
                      if (value != null) onMethodChanged(value);
                    },
            ),
          ),
        );
      }).toList(),
    );
  }
}
