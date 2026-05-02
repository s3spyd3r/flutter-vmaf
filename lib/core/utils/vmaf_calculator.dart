import 'dart:async';
import 'dart:io';

import 'package:flutter_vmaf/core/utils/logger.dart';
import 'package:flutter_vmaf/core/utils/system_info.dart';

import 'vmaf_calculator_base.dart';

class VmafCalculator implements VmafCalculatorBase {
  final String? ffmpegPath;
  Process? _process;
  bool _loggedComplete = false;

  DateTime? _calcStartTime;
  int _lastEtaFrame = 0;
  String _lastEtaStr = ''; // Persist ETA string between updates
  static const int _kEtaUpdateInterval = 500; // Recalculate ETA every X frames

  VmafCalculator({this.ffmpegPath});

  void _resetState() {
    _loggedComplete = false;
    _process = null;
    _calcStartTime = null;
    _lastEtaFrame = 0;
    _lastEtaStr = '';
  }

  @override
  Future<VmafCalcResult> calculateVmaf({
    required String distortedPath,
    required String referencePath,
    ProgressCallback? onProgress,
  }) async {
    _resetState();
    if (ffmpegPath == null || ffmpegPath!.isEmpty) {
      throw Exception('No FFmpeg path configured');
    }

    final ffmpegFile = File('$ffmpegPath\\ffmpeg.exe');
    if (!await ffmpegFile.exists()) {
      Logger.log('ERROR: ffmpeg.exe not found at $ffmpegPath');
      throw Exception('ffmpeg.exe not found at $ffmpegPath');
    }

    Logger.log('=== PROBING VIDEO ===');
    onProgress?.call('Probing video...', 0.0);

    final videoInfo = await _probeVideo(referencePath);
    final double? totalFrames = videoInfo.$1;
    final double? frameRate = videoInfo.$2;
    final double? videoDuration = videoInfo.$3;

    Logger.log('Video info: frames=$totalFrames, fps=$frameRate, duration=${videoDuration}s');

    double? estimatedFramesToProcess;
    if (totalFrames != null) {
      estimatedFramesToProcess = totalFrames;
    } else if (videoDuration != null && frameRate != null) {
      estimatedFramesToProcess = videoDuration * frameRate;
    }

    final cpuThreads = getCpuThreadCount();
    final vmafThreads = (cpuThreads / 2).ceil();
    Logger.log('Starting VMAF with n_threads=$vmafThreads (half of $cpuThreads)');

    onProgress?.call('Starting VMAF...', 0.0);
    Logger.log('Starting VMAF with n_threads=$vmafThreads');

    final outputJsonFile = toFFmpegPath('vmaf_output.json');
    final lavfiFilter = '[0:v][1:v]libvmaf=n_threads=$vmafThreads:log_path="$outputJsonFile":log_fmt=json';

    final distortedPathFfmpeg = toFFmpegPath(distortedPath);
    final referencePathFfmpeg = toFFmpegPath(referencePath);
    Logger.log('Running: ffmpeg -threads $vmafThreads -i $distortedPathFfmpeg -i $referencePathFfmpeg -lavfi "$lavfiFilter" -f null -');
    try {
      _process = await Process.start(
        '"$ffmpegPath\\ffmpeg.exe"',
        [
          '-threads', '$vmafThreads',
          '-an',
          '-sn',
          '-i', distortedPathFfmpeg,
          '-i', referencePathFfmpeg,
          '-lavfi', lavfiFilter,
          '-f', 'null',
          '-',
        ],
      );
    } catch (e) {
      throw Exception('Failed to start FFmpeg process: $e');
    }
    _calcStartTime = DateTime.now();

    int processedFrames = 0;
    final stderrBuffer = StringBuffer();
    int lastProgressUpdate = 0;

    await for (final data in _process!.stderr) {
      final line = String.fromCharCodes(data);
      stderrBuffer.write(line);

      final frame = _parseProgress(line);
      if (frame != null) {
        processedFrames = frame;

        double progress = 0.0;
        if (estimatedFramesToProcess != null && estimatedFramesToProcess > 0) {
          progress = (processedFrames / estimatedFramesToProcess * 0.95);
          if (progress > 0.95) progress = 0.95;
        }

        final progressStr = (progress * 100).toStringAsFixed(1);
        if (estimatedFramesToProcess != null && 
            processedFrames > 0 && 
            _calcStartTime != null &&
            processedFrames - _lastEtaFrame >= _kEtaUpdateInterval) {
          final elapsed = DateTime.now().difference(_calcStartTime!).inSeconds;
          if (elapsed > 0) {
            final remainingFrames = estimatedFramesToProcess - processedFrames;
            if (remainingFrames > 0) {
              final framesPerSecond = processedFrames / elapsed;
              final remainingSeconds = remainingFrames / framesPerSecond;
              final remainingMinutes = remainingSeconds / 60;
              _lastEtaStr = ' | ETA: ${remainingMinutes.toStringAsFixed(1)} min';
              _lastEtaFrame = processedFrames;
            } else {
              _lastEtaStr = ' | ETA: 0.0 min';
              _lastEtaFrame = processedFrames;
            }
          }
        }
        onProgress?.call('Frame $processedFrames${estimatedFramesToProcess != null ? ' / ${estimatedFramesToProcess.round()}' : ''} ($progressStr%)$_lastEtaStr', progress);

        if (processedFrames > lastProgressUpdate + 1000) {
          lastProgressUpdate = processedFrames;
        }
        if (!_loggedComplete && progress >= 0.95) {
          _loggedComplete = true;
          Logger.log('Processing complete, waiting for score...');
        }
      }
    }

    final exitCode = await _process!.exitCode;
    if (exitCode != 0) {
      throw Exception(stderrBuffer.toString().isNotEmpty
          ? stderrBuffer.toString()
          : 'FFmpeg exited with code $exitCode');
    }

    onProgress?.call('Reading VMAF score...', 0.95);
    double score = 0.0;
    final stderrContent = stderrBuffer.toString();

    try {
      final jsonMatch = RegExp(r'VMAF score:\s*([0-9.]+)').firstMatch(stderrContent);
      if (jsonMatch != null) {
        score = double.parse(jsonMatch.group(1)!);
      } else {
        final outputFile = File(outputJsonFile);
        if (await outputFile.exists()) {
          final jsonContent = await outputFile.readAsString();

          final vmafScoreMatch = RegExp(r'"VMAF_score":\s*([0-9.]+)').firstMatch(jsonContent);
          if (vmafScoreMatch != null) {
            score = double.parse(vmafScoreMatch.group(1)!);
          } else {
            final allVmafScores = RegExp(r'"vmaf":\s*([0-9.]+)').allMatches(jsonContent);
            if (allVmafScores.isNotEmpty) {
              double totalScore = 0;
              for (final match in allVmafScores) {
                totalScore += double.parse(match.group(1)!);
              }
              score = totalScore / allVmafScores.length;
            }
          }
        }
      }
    } finally {
      final outputFile = File(outputJsonFile);
      if (await outputFile.exists()) {
        await outputFile.delete();
      }
    }

    onProgress?.call('Complete!', 1.0);
    Logger.log('VMAF complete: score=$score');

    _process = null;
    return VmafCalcResult(
      score: score,
      distortedPath: distortedPath,
      referencePath: referencePath,
    );
  }

  @override
  Future<void> cancel() async {
    _process?.kill();
  }

  Future<(double?, double?, double?)> _probeVideo(String path) async {
    try {
      double? duration;
      double? frameRate;

      Logger.log('Running: ffprobe -show_format -show_streams $path');
      final pathFfmpeg = toFFmpegPath(path);
      final infoResult = await Process.run(
        '$ffmpegPath\\ffprobe.exe',
        [
          '-v', 'quiet',
          '-print_format', 'json',
          '-show_format',
          '-show_streams',
          pathFfmpeg,
        ],
      );

      if (infoResult.exitCode == 0) {
        final output = infoResult.stdout.toString();
        Logger.log('Probe output length: ${output.length}');

        final durMatch = RegExp(r'"duration"\s*:\s*"([\d.]+)"').firstMatch(output);
        if (durMatch != null) {
          duration = double.tryParse(durMatch.group(1)!);
          Logger.log('Duration: $duration');
        }

        final fpsMatch = RegExp(r'"r_frame_rate"\s*:\s*"(\d+)/(\d+)"').firstMatch(output);
        if (fpsMatch != null) {
          final num = int.parse(fpsMatch.group(1)!);
          final den = int.parse(fpsMatch.group(2)!);
          if (den != 0) {
            frameRate = num / den;
            Logger.log('FPS: $frameRate');
          }
        }
      } else {
        Logger.log('Probe failed: ${infoResult.stderr}');
      }

      double? totalFrames;
      if (duration != null && frameRate != null) {
        totalFrames = duration * frameRate;
        Logger.log('Estimated frames: $totalFrames');
      }

      return (totalFrames, frameRate, duration);
    } catch (e) {
      Logger.log('Probe error: $e');
    }
    return (null, null, null);
  }

  int? _parseProgress(String line) {
    final frameMatch = RegExp(r'frame=\s*(\d+)').firstMatch(line);
    if (frameMatch != null) {
      return int.parse(frameMatch.group(1)!);
    }
    return null;
  }
}
