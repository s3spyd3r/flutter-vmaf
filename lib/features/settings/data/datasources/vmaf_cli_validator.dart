import 'dart:io';

class VmafCliValidationResult {
  final VmafCliValidationStatus status;
  final String version;

  VmafCliValidationResult({
    required this.status,
    this.version = '',
  });
}

enum VmafCliValidationStatus {
  valid,
  invalid,
  missing,
}

class VmafCliValidator {
  static Future<VmafCliValidationResult> validate(String path) async {
    try {
      if (path.isEmpty) {
        return VmafCliValidationResult(status: VmafCliValidationStatus.missing);
      }

      final vmafFile = File('$path\\vmaf.exe');
      if (!await vmafFile.exists()) {
        return VmafCliValidationResult(status: VmafCliValidationStatus.invalid);
      }

      final result = await Process.run('$path\\vmaf.exe', ['--version']);

      if (result.exitCode == 0) {
        final output = result.stdout.toString();
        final versionMatch = RegExp(r'VMAF.*?(\d+\.\d+\.\d+)').firstMatch(output);
        final version = versionMatch?.group(1) ?? '';
        return VmafCliValidationResult(
          status: VmafCliValidationStatus.valid,
          version: version,
        );
      }

      return VmafCliValidationResult(status: VmafCliValidationStatus.valid);
    } catch (e) {
      return VmafCliValidationResult(status: VmafCliValidationStatus.invalid);
    }
  }
}
