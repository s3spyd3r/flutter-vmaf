import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/calculation_method.dart';
import '../bloc/settings_bloc.dart';
import '../bloc/settings_event.dart';
import '../bloc/settings_state.dart';
import '../widgets/calculation_method_selector.dart';
import '../widgets/ffmpeg_config_card.dart';
import '../widgets/vmaf_cli_config_card.dart';

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

        Future<void> selectFfmpegFolder() async {
          final result = await FilePicker.getDirectoryPath();
          if (result != null && context.mounted) {
            context.read<SettingsBloc>().add(UpdateFfmpegPath(result));
          }
        }

        Future<void> selectVmafCliFolder() async {
          final result = await FilePicker.getDirectoryPath();
          if (result != null && context.mounted) {
            context.read<SettingsBloc>().add(UpdateVmafCliPath(result));
          }
        }

        Future<void> selectVmafTempFolder() async {
          final result = await FilePicker.getDirectoryPath();
          if (result != null && context.mounted) {
            context.read<SettingsBloc>().add(UpdateVmafTempPath(result));
          }
        }

        void onMethodChanged(CalculationMethod method) {
          if (context.mounted) {
            context.read<SettingsBloc>().add(UpdateCalculationMethod(method));
          }
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
                      CalculationMethodSelector(
                        currentMethod: calculationMethod,
                        isLoading: isLoading,
                        onMethodChanged: onMethodChanged,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (calculationMethod == CalculationMethod.ffmpeg)
                FfmpegConfigCard(
                  ffmpegPath: ffmpegPath,
                  ffmpegStatus: ffmpegStatus,
                  ffmpegVersion: ffmpegVersion,
                  isLoading: isLoading,
                  onBrowsePressed: selectFfmpegFolder,
                ),
              if (calculationMethod == CalculationMethod.netflixCli)
                VmafCliConfigCard(
                  vmafCliPath: vmafCliPath,
                  vmafCliVersion: vmafCliVersion,
                  vmafTempPath: vmafTempPath,
                  isLoading: isLoading,
                  onBrowseCliPressed: selectVmafCliFolder,
                  onBrowseTempPressed: selectVmafTempFolder,
                ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
