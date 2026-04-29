import 'package:equatable/equatable.dart';
import '../../domain/entities/vmaf_result.dart';

abstract class VmafState extends Equatable {
  const VmafState();

  @override
  List<Object?> get props => [];
}

class VmafInitial extends VmafState {
  const VmafInitial();
}

class VmafLoading extends VmafState {
  final String? message;
  final double? progress;

  const VmafLoading({this.message, this.progress});

  @override
  List<Object?> get props => [message, progress];
}

class VmafCancelled extends VmafState {
  const VmafCancelled();
}

class VmafSuccess extends VmafState {
  final VmafResult result;

  const VmafSuccess(this.result);

  @override
  List<Object?> get props => [result];
}

class VmafError extends VmafState {
  final String message;

  const VmafError(this.message);

  @override
  List<Object?> get props => [message];
}