import 'package:equatable/equatable.dart';

class VmafResult extends Equatable {
  final double score;
  final String distortedPath;
  final String referencePath;

  const VmafResult({
    required this.score,
    required this.distortedPath,
    required this.referencePath,
  });

  @override
  List<Object> get props => [score, distortedPath, referencePath];
}