import 'package:flutter/material.dart';

class FfmpegLicenseInfo extends StatelessWidget {
  const FfmpegLicenseInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'FFmpeg & libvmaf',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'This app requires FFmpeg to be installed. FFmpeg is free '
          'software licensed under LGPL/GPL. The libvmaf filter used '
          'for VMAF calculation is licensed under the BSD-3-Clause '
          'license (see: https://github.com/Netflix/vmaf).',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 12),
        const Text(
          'When distributing this application, you may need to '
          'consider how FFmpeg is distributed with your app. If you '
          'bundle FFmpeg, check the FFmpeg licensing page for details.',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        const SizedBox(height: 8),
        const Text(
          'FFmpeg Licensing: https://ffmpeg.org/legal.html',
          style: TextStyle(fontSize: 15, color: Colors.blue),
        ),
      ],
    );
  }
}
