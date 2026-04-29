import 'package:dartz/dartz.dart';
import 'package:flutter_vmaf/core/error/failures.dart';
import 'package:flutter_vmaf/core/utils/vmaf_calculator_base.dart';
import '../entities/video_file.dart';
import '../entities/vmaf_result.dart';

class CalculateVmaf {
  final VmafCalculatorBase _calculator;

  CalculateVmaf(this._calculator);

  Future<Either<Failure, VmafResult>> call({
    required VideoFile distortedVideo,
    required VideoFile referenceVideo,
    void Function(String message, double progress)? onProgress,
  }) async {
    try {
      final result = await _calculator.calculateVmaf(
        distortedPath: distortedVideo.path,
        referencePath: referenceVideo.path,
        onProgress: onProgress,
      );

      if (result.cancelled) {
        return const Left(CancelledFailure());
      }

      return Right(VmafResult(
        score: result.score,
        distortedPath: result.distortedPath,
        referencePath: result.referencePath,
      ));
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(VmafCalculationFailure(e.toString()));
    }
  }

  Future<void> cancel() async => _calculator.cancel();
}
