import 'dart:async';
import 'dart:io';

class Logger {
  static final _streamController = StreamController<String>.broadcast();
  static Stream<String> get stream => _streamController.stream;
  static final List<String> _logs = [];
  static List<String> get logs => List.unmodifiable(_logs);
  static File? _logFile;

  static Future<void> init() async {
    try {
      final exePath = Platform.resolvedExecutable;
      final exeDir = Directory(exePath).parent.path;
      _logFile = File('$exeDir\\log.txt');
      await _logFile!.writeAsString('');
      await log('Logger initialized at ${_logFile!.path}');
    } catch (e) {
      _logs.add('Logger init error: $e');
    }
  }

  static Future<void> log(String message) async {
    final timestamp = DateTime.now().toIso8601String();
    final logEntry = '[$timestamp] $message';
    _logs.add(logEntry);
    _streamController.add(logEntry);
    await _writeToFile(logEntry);
  }

  static Future<void> logError(String context, Object error, [StackTrace? stackTrace]) async {
    final message = StringBuffer();
    message.writeln('ERROR: $context');
    message.writeln('Error: $error');
    if (stackTrace != null) {
      message.writeln('StackTrace: $stackTrace');
    }
    await log(message.toString());
  }

  static Future<String?> readLog() async {
    return _logs.join('\n');
  }

  static Future<void> clearLog() async {
    _logs.clear();
    try {
      if (_logFile != null && await _logFile!.exists()) {
        await _logFile!.delete();
        await _logFile!.create();
      }
    } catch (e) {
      _logs.add('Logger clear error: $e');
    }
  }

  static Future<void> _writeToFile(String entry) async {
    try {
      if (_logFile != null) {
        await _logFile!.writeAsString('$entry\n', mode: FileMode.append);
      }
    } catch (e) {
      _logs.add('Logger write error: $e');
    }
  }
}
