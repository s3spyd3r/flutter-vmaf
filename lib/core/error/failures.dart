import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

class FFmpegNotFoundFailure extends Failure {
  const FFmpegNotFoundFailure()
      : super('FFmpeg not found. Please configure the FFmpeg path in settings.');
}

class InvalidVideoPathFailure extends Failure {
  const InvalidVideoPathFailure(String path)
      : super('Invalid video path: $path');
}

class VmafCalculationFailure extends Failure {
  const VmafCalculationFailure(String message) : super(message);
}

class CancelledFailure extends Failure {
  const CancelledFailure() : super('Calculation cancelled');
}

class SettingsFailure extends Failure {
  const SettingsFailure(String message) : super(message);
}