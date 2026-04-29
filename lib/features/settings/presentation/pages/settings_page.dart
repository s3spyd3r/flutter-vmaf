import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/calculation_method.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsBloc, SettingsState>(
      listener: (context, state) {
        if (state is SettingsError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is SettingsLoading;
        String? ffmpegPath;
        String? ffmpegVersion;
        FfmpegStatus ffmpegStatus = FfmpegStatus.unknown;
        CalculationMethod calculationMethod = CalculationMethod.ffmpeg;
        String? vmafCliPath;
        String? vmafCliVersion;
        String? vmafTempPath;

        if (state is SettingsLoaded) {
          ffmpegPath = state.settings.ffmpegPath;
          ffmpegVersion = state.settings.ffmpegVersion;
          ffmpegStatus = state.settings.ffmpegStatus;
          calculationMethod = state.settings.calculationMethod;
          vmafCliPath = state.settings.vmafCliPath;
          vmafCliVersion = state.settings.vmafCliVersion;
          vmafTempPath = state.settings.vmafTempPath;
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'Settings',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),

              // Calculation Method Selector
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Calculation Method',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      _buildCalculationMethodSelector(
                        context,
                        calculationMethod,
                        isLoading,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // FFmpeg Configuration
              if (calculationMethod == CalculationMethod.ffmpeg)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FFmpeg Configuration',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select the folder containing ffmpeg.exe and ffprobe.exe',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                ffmpegPath ?? 'No folder selected',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: ffmpegPath != null
                                          ? null
                                          : Theme.of(context).hintColor,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () => _selectFfmpegFolder(context),
                              icon: isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.folder_open, size: 18),
                              label: const Text('Browse'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildFfmpegStatusMessage(
                          context,
                          ffmpegPath,
                          ffmpegStatus,
                          ffmpegVersion,
                        ),
                      ],
                    ),
                  ),
                ),

              // Netflix VMAF CLI Configuration
              if (calculationMethod == CalculationMethod.netflixCli)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Netflix VMAF CLI Configuration',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select the folder containing vmaf.exe',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).hintColor,
                              ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                vmafCliPath ?? 'No folder selected',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: vmafCliPath != null
                                          ? null
                                          : Theme.of(context).hintColor,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () => _selectVmafCliFolder(context),
                              icon: const Icon(Icons.folder_open, size: 18),
                              label: const Text('Browse'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildVmafCliStatusMessage(
                          context,
                          vmafCliPath,
                          vmafCliVersion,
                        ),
                        const SizedBox(height: 16),
                        _buildTempFolderSelector(
                          context,
                          vmafTempPath,
                          isLoading,
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalculationMethodSelector(
    BuildContext context,
    CalculationMethod currentMethod,
    bool isLoading,
  ) {
    return RadioGroup<CalculationMethod>(
      groupValue: currentMethod,
      onChanged: (value) {
        if (!isLoading && value != null && context.mounted) {
          context.read<SettingsBloc>().add(UpdateCalculationMethod(value));
        }
      },
      child: Column(
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
                        if (context.mounted) {
                          context.read<SettingsBloc>().add(UpdateCalculationMethod(value!));
                        }
                      },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildFfmpegStatusMessage(
    BuildContext context,
    String? ffmpegPath,
    FfmpegStatus status,
    String? version,
  ) {
    if (ffmpegPath == null || ffmpegPath.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (status) {
      case FfmpegStatus.valid:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  version != null && version.isNotEmpty
                      ? 'FFmpeg $version is ready'
                      : 'FFmpeg is ready',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      case FfmpegStatus.invalid:
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'FFmpeg not found. Please check the folder contains ffmpeg.exe and ffprobe.exe',
                  style: TextStyle(
                    color: Colors.red.shade700,
                  ),
                ),
              ),
            ],
          ),
        );
      case FfmpegStatus.unknown:
        return const SizedBox.shrink();
    }
  }

  Widget _buildVmafCliStatusMessage(
    BuildContext context,
    String? vmafCliPath,
    String? version,
  ) {
    if (vmafCliPath == null || vmafCliPath.isEmpty) {
      return const SizedBox.shrink();
    }

    final exists = Directory(vmafCliPath).existsSync() ||
        File('$vmafCliPath\\vmaf.exe').existsSync();

    if (exists) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                version != null && version.isNotEmpty
                    ? 'VMAF CLI $version is ready'
                    : 'VMAF CLI is ready',
                style: TextStyle(
                  color: Colors.green.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'vmaf.exe not found. Please check the folder.',
                style: TextStyle(
                  color: Colors.red.shade700,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildTempFolderSelector(
    BuildContext context,
    String? vmafTempPath,
    bool isLoading,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Temp Folder for Y4M Files',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Temporary folder for Y4M video files during calculation. System temp will be used if not specified.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Text(
                vmafTempPath ?? 'System temp',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: vmafTempPath != null
                          ? null
                          : Theme.of(context).hintColor,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: isLoading
                  ? null
                  : () => _selectVmafTempFolder(context),
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('Browse'),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectFfmpegFolder(BuildContext context) async {
    final result = await FilePicker.getDirectoryPath();
    if (result != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateFfmpegPath(result));
    }
  }

  Future<void> _selectVmafCliFolder(BuildContext context) async {
    final result = await FilePicker.getDirectoryPath();
    if (result != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateVmafCliPath(result));
    }
  }

  Future<void> _selectVmafTempFolder(BuildContext context) async {
    final result = await FilePicker.getDirectoryPath();
    if (result != null && context.mounted) {
      context.read<SettingsBloc>().add(UpdateVmafTempPath(result));
    }
  }
}