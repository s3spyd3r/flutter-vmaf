import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/calculation_method.dart';
import 'ffmpeg_validator.dart';
import 'vmaf_cli_validator.dart';

class SettingsDataSource {
  Future<Either<Failure, AppSettings>> getSettings() async {
    try {
      final settingsFile = await _getSettingsFile();
      if (await settingsFile.exists()) {
        final content = await settingsFile.readAsString();
        final json = jsonDecode(content);
        final path = json['ffmpegPath'] as String? ?? '';
        final calculationMethodStr = json['calculationMethod'] as String? ?? 'ffmpeg';
        final calculationMethod = calculationMethodStr == 'netflixCli'
            ? CalculationMethod.netflixCli
            : CalculationMethod.ffmpeg;
        final vmafCliPath = json['vmafCliPath'] as String?;
        final vmafTempPath = json['vmafTempPath'] as String?;

        final validationResult = await FfmpegValidator.validate(path);
        final vmafCliValidation = vmafCliPath != null
            ? await VmafCliValidator.validate(vmafCliPath)
            : VmafCliValidationResult(status: VmafCliValidationStatus.missing);

        return Right(AppSettings(
          ffmpegPath: path.isNotEmpty ? path : null,
          ffmpegStatus: _mapValidationStatus(validationResult),
          ffmpegVersion: _mapVersion(validationResult),
          calculationMethod: calculationMethod,
          vmafCliPath: vmafCliPath,
          vmafCliVersion:
              vmafCliValidation.version.isNotEmpty ? vmafCliValidation.version : null,
          vmafTempPath: vmafTempPath,
        ));
      }
      return const Right(AppSettings());
    } catch (e) {
      return Left(SettingsFailure(e.toString()));
    }
  }

  Future<Either<Failure, AppSettings>> saveSettings(AppSettings settings) async {
    try {
      final settingsFile = await _getSettingsFile();
      final json = jsonEncode({
        'ffmpegPath': settings.ffmpegPath ?? '',
        'calculationMethod': settings.calculationMethod == CalculationMethod.netflixCli
            ? 'netflixCli'
            : 'ffmpeg',
        'vmafCliPath': settings.vmafCliPath ?? '',
        'vmafTempPath': settings.vmafTempPath ?? '',
      });
      await settingsFile.writeAsString(json);
      return Right(settings);
    } catch (e) {
      return Left(SettingsFailure(e.toString()));
    }
  }

  FfmpegStatus _mapValidationStatus(FfmpegValidationResult result) {
    switch (result.status) {
      case FfmpegValidationStatus.valid:
        return FfmpegStatus.valid;
      case FfmpegValidationStatus.invalid:
        return FfmpegStatus.invalid;
      case FfmpegValidationStatus.missing:
        return FfmpegStatus.invalid;
    }
  }

  String? _mapVersion(FfmpegValidationResult result) {
    return result.version.isNotEmpty ? result.version : null;
  }

  Future<File> _getSettingsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}\\flutter_vmaf_settings.json');
  }
}