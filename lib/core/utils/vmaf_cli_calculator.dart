import 'dart:async';
import 'dart:io';

import 'package:flutter_vmaf/core/utils/logger.dart';
import 'package:flutter_vmaf/core/utils/system_info.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'vmaf_calculator_base.dart';

class VmafCliCalculator implements VmafCalculatorBase {
  final String vmafCliPath;
  final String? vmafTempPath;
  Process? _process;
  final List<Process> _conversionProcesses = [];
  bool _cancelled = false;
  Completer<void>? cancelledCompleter;

  VmafCliCalculator({
    required this.vmafCliPath,
    this.vmafTempPath,
  });

  @override
  Future<VmafCalcResult> calculateVmaf({
    required String distortedPath,
    required String referencePath,
    ProgressCallback? onProgress,
  }) async {
    String refY4mPath = referencePath;
    String distY4mPath = distortedPath;
    _cancelled = false;
    cancelledCompleter = Completer<void>();
    
    final tempDir = await _getTempDirectory();
    final String tempDirPath = tempDir.path;
    final List<String> tempFilesToCleanup = [];
    final String outputJsonPath = p.join(tempDirPath, 'vmaf_result_${DateTime.now().millisecondsSinceEpoch}.json');
    
    _conversionProcesses.clear();

    String? ffmpegPath;
    try {
      final vmafExe = File('$vmafCliPath\\vmaf.exe');
      if (!await vmafExe.exists()) {
        throw Exception('vmaf.exe not found at $vmafCliPath');
      }
      
      ffmpegPath = await _findFfmpegPath();
      if (ffmpegPath == null) {
        throw Exception('FFmpeg not found. Please configure FFmpeg path in settings.');
      }
      
      Logger.log('Temp directory: ${tempDir.path}');

      if (!_isY4mFile(referencePath)) {
        if (_cancelled) throw Exception('Calculation cancelled');
        final refFileName = p.basenameWithoutExtension(referencePath);
        refY4mPath = p.join(tempDirPath, '$refFileName.y4m');
        
        final existingRefY4m = File(refY4mPath);
        if (await existingRefY4m.exists()) {
          Logger.log('Using existing Y4M file: $refY4mPath');
        } else {
          tempFilesToCleanup.add(refY4mPath);
          Logger.log('Task 1/3: Converting reference video to Y4M');
          onProgress?.call('Converting reference video...', 0.0);
          final proc = await _convertToY4m(referencePath, refY4mPath, onProgress, 'original');
          _conversionProcesses.add(proc);
          onProgress?.call('Converting reference video complete', 1.0);
        }
      }

      if (!_isY4mFile(distortedPath)) {
        if (_cancelled) throw Exception('Calculation cancelled');
        final distFileName = p.basenameWithoutExtension(distortedPath);
        distY4mPath = p.join(tempDirPath, '$distFileName.y4m');
        
        final existingDistY4m = File(distY4mPath);
        if (await existingDistY4m.exists()) {
          Logger.log('Using existing Y4M file: $distY4mPath');
        } else {
          tempFilesToCleanup.add(distY4mPath);
          Logger.log('Task 2/3: Converting distorted video to Y4M');
          onProgress?.call('Converting distorted video...', 0.0);
          final proc = await _convertToY4m(distortedPath, distY4mPath, onProgress, 'encoded');
          _conversionProcesses.add(proc);
          onProgress?.call('Converting distorted video complete', 1.0);
        }
      }

      tempFilesToCleanup.add(outputJsonPath);

      Logger.log('Task 3/3: Calculating VMAF score');
      onProgress?.call('Calculating VMAF score...', 0.0);
      Logger.log('VMAF calculation started');

      final args = [
        '--reference', refY4mPath,
        '--distorted', distY4mPath,
        '--threads', '${(getCpuThreadCount() / 2).ceil()}',
        '--json',
        '--output', outputJsonPath,
      ];

      Logger.log('Running: vmaf.exe ${args.join(' ')}');
      _process = await Process.start(
        '$vmafCliPath\\vmaf.exe',
        args,
      );

      try {
        await for (final data in _process!.stderr) {
          if (_process == null || _cancelled) break;
          final line = String.fromCharCodes(data);
          Logger.log('VMAF stderr: $line');
        }
      } catch (e) {
        Logger.log('Error reading vmaf output: $e');
      }

      onProgress?.call('Finalizing VMAF score', 0.995);

      if (_process == null || _cancelled) {
        throw Exception('Calculation cancelled');
      }

      final exitCode = await _process!.exitCode;
      if (exitCode != 0) {
        throw Exception('vmaf.exe exited with code $exitCode');
      }

      double score = 0.0;
      final outputFile = File(outputJsonPath);
      if (await outputFile.exists()) {
        final jsonContent = await outputFile.readAsString();
        score = _parseVmafScore(jsonContent);
        await outputFile.delete();
      } else {
        throw Exception('VMAF output file not found at $outputJsonPath');
      }

      await _cleanupTempFiles(tempFilesToCleanup..add(outputJsonPath));

      onProgress?.call('Complete!', 1.0);
      Logger.log('VMAF CLI complete: score=$score');

      return VmafCalcResult(
        score: score,
        distortedPath: distortedPath,
        referencePath: referencePath,
      );
    } catch (e) {
      await _cleanupTempFiles(tempFilesToCleanup..add(outputJsonPath));
      rethrow;
    }
  }

  @override
  Future<void> cancel() async {
    Logger.log('Cancellation requested');
    _cancelled = true;
    
    if (cancelledCompleter != null && !cancelledCompleter!.isCompleted) {
      cancelledCompleter!.complete();
    }
    
    for (final proc in List.from(_conversionProcesses)) {
      try {
        final pid = proc.pid;
        if (Platform.isWindows) {
          try {
            await Process.run('taskkill', ['/F', '/T', '/PID', '$pid']);
          } catch (_) {}
        }
        try {
          proc.kill(ProcessSignal.sigkill);
        } catch (_) {}
        _conversionProcesses.remove(proc);
      } catch (e) {
        Logger.log('Error killing conversion process: $e');
      }
    }
    _conversionProcesses.clear();
    
    if (Platform.isWindows) {
      try {
        await Process.run('taskkill', ['/F', '/IM', 'ffmpeg.exe']);
      } catch (_) {}
      try {
        await Process.run('taskkill', ['/F', '/IM', 'ffprobe.exe']);
      } catch (_) {}
      try {
        await Process.run('taskkill', ['/F', '/IM', 'vmaf.exe']);
      } catch (_) {}
    }
    
    try {
      if (_process != null) {
        _process!.kill(ProcessSignal.sigkill);
        _process = null;
      }
    } catch (e) {
      Logger.log('Error killing VMAF process: $e');
    }
  }

  Future<Directory> _getTempDirectory() async {
    if (vmafTempPath != null && vmafTempPath!.isNotEmpty) {
      final dir = Directory(vmafTempPath!);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
      return dir;
    }
    return await getTemporaryDirectory();
  }

  bool _isY4mFile(String path) {
    return path.toLowerCase().endsWith('.y4m');
  }

  Future<Process> _convertToY4m(
    String inputPath,
    String outputPath,
    ProgressCallback? onProgress,
    String videoName,
  ) async {
    final ffmpegPath = await _findFfmpegPath();
    if (ffmpegPath == null) {
      throw Exception('FFmpeg not found. Please configure FFmpeg path in settings.');
    }

    Logger.log('Running: ffmpeg -i $inputPath -pix_fmt yuv420p -f yuv4mpegpipe $outputPath');
    final proc = await Process.start(
      '$ffmpegPath\\ffmpeg.exe',
      ['-i', inputPath, '-pix_fmt', 'yuv420p', '-f', 'yuv4mpegpipe', outputPath],
    );

    _conversionProcesses.add(proc);

    int? totalFrames;
    try {
      Logger.log('Running: ffprobe -show_streams $inputPath');
      final probeResult = await Process.run(
        '$ffmpegPath\\ffprobe.exe',
        ['-v', 'quiet', '-print_format', 'json', '-show_streams', inputPath],
      );
      if (probeResult.exitCode == 0) {
        final output = probeResult.stdout.toString();
        final match = RegExp(r'"nb_frames"\s*:\s*"?(\d+)"?').firstMatch(output);
        if (match != null) {
          totalFrames = int.tryParse(match.group(1)!);
        }
        if (totalFrames == null || totalFrames == 0) {
          final durationMatch = RegExp(r'"duration"\s*:\s*"?([\d.]+)"?').firstMatch(output);
          final fpsMatch = RegExp(r'"r_frame_rate"\s*:\s*"?(\d+)/(\d+)"?').firstMatch(output);
          if (durationMatch != null && fpsMatch != null) {
            final duration = double.tryParse(durationMatch.group(1)!);
            final fpsNum = int.tryParse(fpsMatch.group(1)!);
            final fpsDen = int.tryParse(fpsMatch.group(2)!);
            if (duration != null && fpsNum != null && fpsDen != null && fpsDen != 0) {
              totalFrames = (duration * fpsNum / fpsDen).round();
            }
          }
        }
      }
    } catch (e) {
      Logger.log('Error probing video: $e');
    }

    int lastReportedFrame = 0;
    await for (final data in proc.stderr) {
      if (!_conversionProcesses.contains(proc) || _cancelled) break;
      final line = String.fromCharCodes(data);
      final frameMatch = RegExp(r'frame=\s*(\d+)').firstMatch(line);
      if (frameMatch != null) {
        final frame = int.parse(frameMatch.group(1)!);
        if (frame != lastReportedFrame || frame == 1) {
          lastReportedFrame = frame;
          final effectiveTotal = totalFrames ?? 3000;
          final progress = (frame / effectiveTotal.toDouble()).clamp(0.0, 1.0);
          onProgress?.call('Converting $videoName - Frame $frame', progress);
        }
      }
    }

    final exitCode = await proc.exitCode;
    _conversionProcesses.remove(proc);
    if (exitCode != 0) {
      throw Exception('FFmpeg conversion failed for $inputPath');
    }

    return proc;
  }

  Future<String?> _findFfmpegPath() async {
    try {
      final homeDir = Platform.environment['USERPROFILE'] ?? '';
      final commonPaths = [
        'C:\\Program Files\\ffmpeg\\bin',
        'C:\\ffmpeg\\bin',
        p.join(homeDir, 'ffmpeg\\bin'),
      ];

      for (final path in commonPaths) {
        final file = File('$path\\ffmpeg.exe');
        if (await file.exists()) {
          return path;
        }
      }

      final result = await Process.run('where', ['ffmpeg']);
      Logger.log('Running: where ffmpeg');
      if (result.exitCode == 0 && result.stdout.toString().isNotEmpty) {
        final path = result.stdout.toString().trim().split('\n').first;
        return p.dirname(path);
      }
    } catch (e) {
      Logger.log('Error finding FFmpeg: $e');
    }
    return null;
  }

  double _parseVmafScore(String jsonContent) {
    try {
      final vmafMatch = RegExp(r'"vmaf":\s*([\d.]+)').firstMatch(jsonContent);
      if (vmafMatch != null) {
        return double.parse(vmafMatch.group(1)!);
      }

      final meanMatch = RegExp(r'"mean":\s*([\d.]+)').firstMatch(jsonContent);
      if (meanMatch != null) {
        return double.parse(meanMatch.group(1)!);
      }
    } catch (e) {
      Logger.log('Error parsing VMAF score: $e');
    }
    return 0.0;
  }

  Future<void> _cleanupTempFiles(List<String?> paths) async {
    for (final path in paths) {
      if (path != null) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
            Logger.log('Deleted temp file: $path');
          }
        } catch (e) {
          Logger.log('Error deleting temp file: $e');
        }
      }
    }
  }
}
