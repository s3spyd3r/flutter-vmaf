import 'package:equatable/equatable.dart';

class VideoFile extends Equatable {
  final String path;
  final String name;

  const VideoFile({required this.path, required this.name});

  @override
  List<Object> get props => [path, name];
}