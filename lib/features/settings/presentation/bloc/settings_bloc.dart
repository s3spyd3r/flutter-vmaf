import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart' as di;
import '../../domain/entities/app_settings.dart';
import '../../domain/entities/calculation_method.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';
import '../../data/datasources/ffmpeg_validator.dart';
import '../../data/datasources/vmaf_cli_validator.dart';
import 'settings_event.dart';
import 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final SaveSettings saveSettings;
  AppSettings? _currentSettings;

  SettingsBloc({
    required this.getSettings,
    required this.saveSettings,
  }) : super(const SettingsInitial()) {
    on<LoadSettings>(_onLoadSettings);
    on<UpdateFfmpegPath>(_onUpdateFfmpegPath);
    on<UpdateCalculationMethod>(_onUpdateCalculationMethod);
    on<UpdateVmafCliPath>(_onUpdateVmafCliPath);
    on<UpdateVmafTempPath>(_onUpdateVmafTempPath);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final result = await getSettings();

    result.fold(
      (failure) {
        if (!isClosed) emit(SettingsError(failure.message));
      },
      (settings) {
        _currentSettings = settings;
        if (!isClosed) emit(SettingsLoaded(settings));
      },
    );
  }

  Future<void> _onUpdateFfmpegPath(
    UpdateFfmpegPath event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final existingMethod = _currentSettings?.calculationMethod ?? CalculationMethod.ffmpeg;
    final existingVmafCliPath = _currentSettings?.vmafCliPath;
    final existingVmafTempPath = _currentSettings?.vmafTempPath;

    final validationResult = await FfmpegValidator.validate(event.ffmpegPath);
    final ffmpegStatus = _mapValidationStatus(validationResult);
    final ffmpegVersion = _mapVersion(validationResult);

    final settings = AppSettings(
      ffmpegPath: event.ffmpegPath,
      calculationMethod: existingMethod,
      vmafCliPath: existingVmafCliPath,
      vmafCliVersion: _currentSettings?.vmafCliVersion,
      vmafTempPath: existingVmafTempPath,
      ffmpegStatus: ffmpegStatus,
      ffmpegVersion: ffmpegVersion,
    );

    final result = await saveSettings(settings);

    result.fold(
      (failure) {
        if (!isClosed) emit(SettingsError(failure.message));
      },
      (savedSettings) {
        _currentSettings = settings;
        if (!isClosed) {
          emit(SettingsLoaded(settings));
          di.updateCalculator(settings);
        }
      },
    );
  }

  Future<void> _onUpdateCalculationMethod(
    UpdateCalculationMethod event,
    Emitter<SettingsState> emit,
  ) async {
    if (_currentSettings == null) return;

    final settings = _currentSettings!.copyWith(calculationMethod: event.method);
    final result = await saveSettings(settings);

    result.fold(
      (failure) {
        if (!isClosed) emit(SettingsError(failure.message));
      },
      (savedSettings) {
        _currentSettings = settings;
        if (!isClosed) {
          emit(SettingsLoaded(settings));
          di.updateCalculator(settings);
        }
      },
    );
  }

  Future<void> _onUpdateVmafCliPath(
    UpdateVmafCliPath event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsLoading());

    final existingFfmpegPath = _currentSettings?.ffmpegPath ?? '';
    final existingMethod = _currentSettings?.calculationMethod ?? CalculationMethod.ffmpeg;
    final existingVmafTempPath = _currentSettings?.vmafTempPath;

    final validationResult = await VmafCliValidator.validate(event.vmafCliPath);
    final vmafCliVersion = validationResult.version.isNotEmpty ? validationResult.version : null;

    final settings = AppSettings(
      ffmpegPath: existingFfmpegPath.isNotEmpty ? existingFfmpegPath : null,
      calculationMethod: existingMethod,
      vmafCliPath: event.vmafCliPath,
      vmafCliVersion: vmafCliVersion,
      vmafTempPath: existingVmafTempPath,
    );

    final result = await saveSettings(settings);

    result.fold(
      (failure) {
        if (!isClosed) emit(SettingsError(failure.message));
      },
      (savedSettings) {
        _currentSettings = settings;
        if (!isClosed) {
          emit(SettingsLoaded(settings));
          di.updateCalculator(settings);
        }
      },
    );
  }

  Future<void> _onUpdateVmafTempPath(
    UpdateVmafTempPath event,
    Emitter<SettingsState> emit,
  ) async {
    if (_currentSettings == null) return;

    final settings = _currentSettings!.copyWith(vmafTempPath: event.vmafTempPath);
    final result = await saveSettings(settings);

    result.fold(
      (failure) => emit(SettingsError(failure.message)),
      (savedSettings) {
        _currentSettings = settings;
        emit(SettingsLoaded(settings));
        di.updateCalculator(settings);
      },
    );
  }

  FfmpegStatus _mapValidationStatus(FfmpegValidationResult result) {
    switch (result.status) {
      case FfmpegValidationStatus.valid:
        return FfmpegStatus.valid;
      case FfmpegValidationStatus.invalid:
      case FfmpegValidationStatus.missing:
        return FfmpegStatus.invalid;
    }
  }

  String? _mapVersion(FfmpegValidationResult result) {
    return result.version.isNotEmpty ? result.version : null;
  }
}