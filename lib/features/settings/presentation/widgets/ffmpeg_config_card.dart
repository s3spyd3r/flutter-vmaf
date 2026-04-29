import 'package:flutter/material.dart';
import '../../domain/entities/app_settings.dart';

class FfmpegConfigCard extends StatelessWidget {
  final String? ffmpegPath;
  final FfmpegStatus ffmpegStatus;
  final String? ffmpegVersion;
  final bool isLoading;
  final VoidCallback onBrowsePressed;

  const FfmpegConfigCard({
    super.key,
    required this.ffmpegPath,
    required this.ffmpegStatus,
    required this.ffmpegVersion,
    required this.isLoading,
    required this.onBrowsePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
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
                          color: ffmpegPath != null ? null : Theme.of(context).hintColor,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onBrowsePressed,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.folder_open, size: 18),
                  label: const Text('Browse'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _FfmpegStatusMessage(
              ffmpegPath: ffmpegPath,
              status: ffmpegStatus,
              version: ffmpegVersion,
            ),
          ],
        ),
      ),
    );
  }
}

class _FfmpegStatusMessage extends StatelessWidget {
  final String? ffmpegPath;
  final FfmpegStatus status;
  final String? version;

  const _FfmpegStatusMessage({
    required this.ffmpegPath,
    required this.status,
    this.version,
  });

  @override
  Widget build(BuildContext context) {
    if (ffmpegPath == null || ffmpegPath!.isEmpty) {
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
                  version != null && version!.isNotEmpty
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
}
