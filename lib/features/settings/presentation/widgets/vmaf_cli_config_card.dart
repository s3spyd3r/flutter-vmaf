import 'dart:io';
import 'package:flutter/material.dart';

class VmafCliConfigCard extends StatelessWidget {
  final String? vmafCliPath;
  final String? vmafCliVersion;
  final String? vmafTempPath;
  final bool isLoading;
  final VoidCallback onBrowseCliPressed;
  final VoidCallback onBrowseTempPressed;

  const VmafCliConfigCard({
    super.key,
    required this.vmafCliPath,
    required this.vmafCliVersion,
    required this.vmafTempPath,
    required this.isLoading,
    required this.onBrowseCliPressed,
    required this.onBrowseTempPressed,
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
                          color: vmafCliPath != null ? null : Theme.of(context).hintColor,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : onBrowseCliPressed,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('Browse'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _VmafCliStatusMessage(
              vmafCliPath: vmafCliPath,
              version: vmafCliVersion,
            ),
            const SizedBox(height: 16),
            _TempFolderSelector(
              vmafTempPath: vmafTempPath,
              isLoading: isLoading,
              onBrowsePressed: onBrowseTempPressed,
            ),
          ],
        ),
      ),
    );
  }
}

class _VmafCliStatusMessage extends StatelessWidget {
  final String? vmafCliPath;
  final String? version;

  const _VmafCliStatusMessage({
    required this.vmafCliPath,
    this.version,
  });

  @override
  Widget build(BuildContext context) {
    if (vmafCliPath == null || vmafCliPath!.isEmpty) {
      return const SizedBox.shrink();
    }

    final exists = Directory(vmafCliPath!).existsSync() ||
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
                version != null && version!.isNotEmpty
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
}

class _TempFolderSelector extends StatelessWidget {
  final String? vmafTempPath;
  final bool isLoading;
  final VoidCallback onBrowsePressed;

  const _TempFolderSelector({
    required this.vmafTempPath,
    required this.isLoading,
    required this.onBrowsePressed,
  });

  @override
  Widget build(BuildContext context) {
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
                      color: vmafTempPath != null ? null : Theme.of(context).hintColor,
                    ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: isLoading ? null : onBrowsePressed,
              icon: const Icon(Icons.folder_open, size: 18),
              label: const Text('Browse'),
            ),
          ],
        ),
      ],
    );
  }
}
