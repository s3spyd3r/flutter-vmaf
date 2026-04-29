import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class VideoSelector extends StatefulWidget {
  final String label;
  final String? selectedPath;
  final ValueChanged<String> onVideoSelected;

  const VideoSelector({
    super.key,
    required this.label,
    this.selectedPath,
    required this.onVideoSelected,
  });

  @override
  State<VideoSelector> createState() => _VideoSelectorState();
}

class _VideoSelectorState extends State<VideoSelector> {
  String? _selectedPath;

  @override
  void initState() {
    super.initState();
    _selectedPath = widget.selectedPath;
  }

  @override
  void didUpdateWidget(VideoSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedPath != oldWidget.selectedPath) {
      _selectedPath = widget.selectedPath;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.label,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedPath ?? 'No video selected',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _selectedPath != null
                              ? null
                              : Theme.of(context).hintColor,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () => _pickVideo(context),
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('Browse'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );

    if (result != null && result.files.isNotEmpty) {
      final path = result.files.first.path;
      if (path != null) {
        setState(() {
          _selectedPath = path;
        });
        widget.onVideoSelected(path);
      }
    }
  }
}