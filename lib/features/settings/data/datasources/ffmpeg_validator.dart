import 'dart:io';

class FfmpegValidator {
  static Future<FfmpegValidationResult> validate(String? path) async {
    if (path == null || path.isEmpty) {
      return const FfmpegValidationResult(
        status: FfmpegValidationStatus.missing,
        message: 'No FFmpeg path configured',
      );
    }

    final ffmpegFile = File('$path\\ffmpeg.exe');
    final ffprobeFile = File('$path\\ffprobe.exe');

    if (!await ffmpegFile.exists()) {
      return const FfmpegValidationResult(
        status: FfmpegValidationStatus.missing,
        message: 'ffmpeg.exe not found in the selected folder',
      );
    }

    if (!await ffprobeFile.exists()) {
      return const FfmpegValidationResult(
        status: FfmpegValidationStatus.missing,
        message: 'ffprobe.exe not found in the selected folder',
      );
    }

    try {
      final result = await Process.run('$path\\ffmpeg.exe', ['-version']);

      if (result.exitCode != 0) {
        return FfmpegValidationResult(
          status: FfmpegValidationStatus.invalid,
          message: 'FFmpeg is not working properly',
        );
      }

      final version = _parseVersion(result.stdout.toString());
      return FfmpegValidationResult(
        status: FfmpegValidationStatus.valid,
        message: version.isNotEmpty ? version : 'FFmpeg detected',
        version: version,
      );
    } catch (e) {
      return FfmpegValidationResult(
        status: FfmpegValidationStatus.invalid,
        message: 'Failed to run FFmpeg: ${e.toString()}',
      );
    }
  }

  static String _parseVersion(String output) {
    final match = RegExp(r'ffmpeg version ([^\s]+)').firstMatch(output);
    return match?.group(1) ?? '';
  }
}

class FfmpegValidationResult {
  final FfmpegValidationStatus status;
  final String message;
  final String version;

  const FfmpegValidationResult({
    required this.status,
    required this.message,
    this.version = '',
  });
}

enum FfmpegValidationStatus {
  missing,
  invalid,
  valid,
}