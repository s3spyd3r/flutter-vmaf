import 'package:equatable/equatable.dart';
import 'calculation_method.dart';

class AppSettings extends Equatable {
  final String? ffmpegPath;
  final FfmpegStatus ffmpegStatus;
  final String? ffmpegVersion;
  final CalculationMethod calculationMethod;
  final String? vmafCliPath;
  final String? vmafCliVersion;
  final String? vmafTempPath;

  const AppSettings({
    this.ffmpegPath,
    this.ffmpegStatus = FfmpegStatus.unknown,
    this.ffmpegVersion,
    this.calculationMethod = CalculationMethod.ffmpeg,
    this.vmafCliPath,
    this.vmafCliVersion,
    this.vmafTempPath,
  });

  bool get isFfmpegConfigured => ffmpegPath != null && ffmpegPath!.isNotEmpty;

  AppSettings copyWith({
    String? ffmpegPath,
    FfmpegStatus? ffmpegStatus,
    String? ffmpegVersion,
    CalculationMethod? calculationMethod,
    String? vmafCliPath,
    String? vmafCliVersion,
    String? vmafTempPath,
  }) {
    return AppSettings(
      ffmpegPath: ffmpegPath ?? this.ffmpegPath,
      ffmpegStatus: ffmpegStatus ?? this.ffmpegStatus,
      ffmpegVersion: ffmpegVersion ?? this.ffmpegVersion,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      vmafCliPath: vmafCliPath ?? this.vmafCliPath,
      vmafCliVersion: vmafCliVersion ?? this.vmafCliVersion,
      vmafTempPath: vmafTempPath ?? this.vmafTempPath,
    );
  }

  @override
  List<Object?> get props => [
        ffmpegPath,
        ffmpegStatus,
        ffmpegVersion,
        calculationMethod,
        vmafCliPath,
        vmafCliVersion,
        vmafTempPath,
      ];
}

enum FfmpegStatus {
  unknown,
  valid,
  invalid,
}