import 'dart:async';

abstract class VmafCalculatorBase {
  Future<VmafCalcResult> calculateVmaf({
    required String distortedPath,
    required String referencePath,
    ProgressCallback? onProgress,
  });

  Future<void> cancel();
}

typedef ProgressCallback = void Function(String message, double progress);

class VmafCalcResult {
  final double score;
  final String distortedPath;
  final String referencePath;
  final bool cancelled;

  VmafCalcResult({
    required this.score,
    required this.distortedPath,
    required this.referencePath,
    this.cancelled = false,
  });
}
