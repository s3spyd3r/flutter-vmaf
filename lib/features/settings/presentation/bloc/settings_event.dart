import 'package:equatable/equatable.dart';

import '../../domain/entities/calculation_method.dart';

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadSettings extends SettingsEvent {
  const LoadSettings();
}

class UpdateFfmpegPath extends SettingsEvent {
  final String ffmpegPath;

  const UpdateFfmpegPath(this.ffmpegPath);

  @override
  List<Object?> get props => [ffmpegPath];
}

class UpdateCalculationMethod extends SettingsEvent {
  final CalculationMethod method;

  const UpdateCalculationMethod(this.method);

  @override
  List<Object?> get props => [method];
}

class UpdateVmafCliPath extends SettingsEvent {
  final String vmafCliPath;

  const UpdateVmafCliPath(this.vmafCliPath);

  @override
  List<Object?> get props => [vmafCliPath];
}

class UpdateVmafTempPath extends SettingsEvent {
  final String? vmafTempPath;

  const UpdateVmafTempPath(this.vmafTempPath);

  @override
  List<Object?> get props => [vmafTempPath];
}