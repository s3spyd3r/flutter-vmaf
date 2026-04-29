import 'package:equatable/equatable.dart';
import '../../domain/entities/video_file.dart';

abstract class VmafEvent extends Equatable {
  const VmafEvent();

  @override
  List<Object?> get props => [];
}

class CalculateVmafEvent extends VmafEvent {
  final VideoFile distortedVideo;
  final VideoFile referenceVideo;

  const CalculateVmafEvent({
    required this.distortedVideo,
    required this.referenceVideo,
  });

  @override
  List<Object?> get props => [distortedVideo, referenceVideo];
}

class CancelVmaf extends VmafEvent {
  const CancelVmaf();
}

class ResetVmaf extends VmafEvent {
  const ResetVmaf();
}