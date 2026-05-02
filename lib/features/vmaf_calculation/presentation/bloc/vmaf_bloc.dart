import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vmaf/core/utils/logger.dart';
import 'package:flutter_vmaf/features/vmaf_calculation/domain/usecases/calculate_vmaf.dart';
import 'package:flutter_vmaf/core/di/injection.dart' as di;
import 'vmaf_event.dart';
import 'vmaf_state.dart';

class VmafBloc extends Bloc<VmafEvent, VmafState> {
  bool _isCancelled = false;

  VmafBloc() : super(const VmafInitial()) {
    on<CalculateVmafEvent>(_onCalculateVmaf);
    on<CancelVmaf>(_onCancelVmaf);
    on<ResetVmaf>(_onResetVmaf);
  }

  CalculateVmaf get _calculateVmaf => di.sl<CalculateVmaf>();

  Future<void> _onCalculateVmaf(
    CalculateVmafEvent event,
    Emitter<VmafState> emit,
  ) async {
    _isCancelled = false;
    Logger.log('Starting VMAF...');
    emit(const VmafLoading(message: 'Starting VMAF calculation...'));

    final result = await _calculateVmaf(
      distortedVideo: event.distortedVideo,
      referenceVideo: event.referenceVideo,
      onProgress: (message, progress) {
        if (!isClosed && !_isCancelled) {
          emit(VmafLoading(message: message, progress: progress));
        }
      },
    );

    if (_isCancelled) {
      Logger.log('VMAF cancelled by user');
      if (!isClosed) emit(const VmafCancelled());
      return;
    }

    if (!isClosed) {
      result.fold(
        (failure) {
          Logger.logError('VMAF failed', failure.message);
          emit(VmafError(failure.message));
        },
        (vmafResult) {
          Logger.log('VMAF completed: ${vmafResult.score}');
          emit(VmafSuccess(vmafResult));
        },
      );
    }
  }

  Future<void> _onCancelVmaf(
    CancelVmaf event,
    Emitter<VmafState> emit,
  ) async {
    Logger.log('Cancellation requested');
    _isCancelled = true;
    await _calculateVmaf.cancel();
  }

  void _onResetVmaf(
    ResetVmaf event,
    Emitter<VmafState> emit,
  ) {
    _isCancelled = false;
    emit(const VmafInitial());
  }
}