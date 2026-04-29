import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import '../bloc/vmaf_bloc.dart';
import '../bloc/vmaf_event.dart';
import '../bloc/vmaf_state.dart';
import '../../domain/entities/video_file.dart';
import '../widgets/video_selector.dart';
import '../widgets/calculate_button.dart';
import '../widgets/vmaf_result_card.dart';
import '../widgets/vmaf_progress_indicator.dart';

class VmafPage extends StatefulWidget {
  const VmafPage({super.key});

  @override
  State<VmafPage> createState() => _VmafPageState();
}

class _VmafPageState extends State<VmafPage> {
  String? _referencePath;
  String? _distortedPath;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VmafBloc, VmafState>(
      listener: (context, state) {
        if (state is VmafError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
        if (state is VmafCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Calculation cancelled'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Text(
                'VMAF Calculator',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              VideoSelector(
                label: 'Original Video',
                selectedPath: _referencePath,
                onVideoSelected: (path) {
                  setState(() {
                    _referencePath = path;
                  });
                },
              ),
              const SizedBox(height: 16),
              VideoSelector(
                label: 'Encoded Video',
                selectedPath: _distortedPath,
                onVideoSelected: (path) {
                  setState(() {
                    _distortedPath = path;
                  });
                },
              ),
              const SizedBox(height: 24),
              CalculateButton(
                isEnabled: state is! VmafLoading && _referencePath != null && _distortedPath != null,
                onPressed: () => _calculateVmaf(context),
              ),
              if (state is VmafLoading) ...[
                const SizedBox(height: 24),
                VmafProgressIndicator(
                  progress: state.progress,
                  message: state.message,
                  onCancel: () => _cancelVmaf(context),
                ),
              ],
              if (state is VmafSuccess) ...[
                const SizedBox(height: 24),
                VmafResultCard(score: state.result.score),
              ],
            ],
          ),
        );
      },
    );
  }

  void _cancelVmaf(BuildContext context) {
    context.read<VmafBloc>().add(const CancelVmaf());
  }

  void _calculateVmaf(BuildContext context) {
    if (_referencePath == null || _distortedPath == null) return;

    final referenceName = p.basename(_referencePath!);
    final distortedName = p.basename(_distortedPath!);

    context.read<VmafBloc>().add(
          CalculateVmafEvent(
            distortedVideo: VideoFile(path: _distortedPath!, name: distortedName),
            referenceVideo: VideoFile(path: _referencePath!, name: referenceName),
          ),
        );
  }
}
