import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import '../bloc/vmaf_bloc.dart';
import '../bloc/vmaf_event.dart';
import '../bloc/vmaf_state.dart';
import '../../domain/entities/video_file.dart';
import '../widgets/video_selector.dart';

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
              _buildCalculateButton(context, state),
              if (state is VmafLoading) ...[
                const SizedBox(height: 24),
                _buildProgressIndicator(context, state),
              ],
              if (state is VmafSuccess) ...[
                const SizedBox(height: 24),
                _buildResultCard(context, state),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildCalculateButton(BuildContext context, VmafState state) {
    final isEnabled = state is! VmafLoading && _referencePath != null && _distortedPath != null;
    return ElevatedButton.icon(
      onPressed: isEnabled ? () => _calculateVmaf(context) : null,
      icon: const Icon(Icons.play_arrow),
      label: const Text('Calculate VMAF'),
    );
  }

  Widget _buildResultCard(BuildContext context, VmafSuccess state) {
    final score = state.result.score;
    final color = _getScoreColor(score);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              'VMAF Score',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              score.toStringAsFixed(2),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: score / 100,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(color),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildProgressIndicator(BuildContext context, VmafLoading state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text(
              state.message ?? 'Analyzing videos...',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: state.progress,
              backgroundColor: Colors.grey[300],
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a while depending on video duration',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).hintColor,
                  ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => _cancelVmaf(context),
              icon: const Icon(Icons.stop),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
              ),
            ),
          ],
        ),
      ),
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