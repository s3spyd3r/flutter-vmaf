import 'dart:io';

int getCpuThreadCount() {
  return Platform.numberOfProcessors;
}

String toFFmpegPath(String path) {
  return path.replaceAll('\\', '/');
}
