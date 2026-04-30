import 'package:get_it/get_it.dart';
import 'package:flutter_vmaf/core/utils/vmaf_calculator_base.dart';
import 'package:flutter_vmaf/core/utils/vmaf_calculator.dart';
import 'package:flutter_vmaf/core/utils/vmaf_cli_calculator.dart';
import 'package:flutter_vmaf/features/settings/data/datasources/settings_data_source.dart';
import 'package:flutter_vmaf/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:flutter_vmaf/features/settings/domain/entities/app_settings.dart';
import 'package:flutter_vmaf/features/settings/domain/entities/calculation_method.dart';
import 'package:flutter_vmaf/features/settings/domain/repositories/settings_repository.dart';
import 'package:flutter_vmaf/features/settings/domain/usecases/get_settings.dart';
import 'package:flutter_vmaf/features/settings/domain/usecases/save_settings.dart';
import 'package:flutter_vmaf/features/settings/presentation/bloc/settings_bloc.dart';
import 'package:flutter_vmaf/features/vmaf_calculation/domain/usecases/calculate_vmaf.dart';
import 'package:flutter_vmaf/features/vmaf_calculation/presentation/bloc/vmaf_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final settingsDataSource = SettingsDataSource();
  final settingsResult = await settingsDataSource.getSettings();

  String? ffmpegPath;
  CalculationMethod calculationMethod = CalculationMethod.ffmpeg;
  String? vmafCliPath;
  String? vmafTempPath;

  settingsResult.fold(
    (_) {},
    (settings) {
      ffmpegPath = settings.ffmpegPath;
      calculationMethod = settings.calculationMethod;
      vmafCliPath = settings.vmafCliPath;
      vmafTempPath = settings.vmafTempPath;
    },
  );

  sl.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(SettingsDataSource()),
  );

  sl.registerLazySingleton<VmafCalculatorBase>(
    () => _createCalculator(
      calculationMethod,
      ffmpegPath,
      vmafCliPath,
      vmafTempPath,
    ),
  );

  sl.registerLazySingleton<CalculateVmaf>(
    () => CalculateVmaf(sl<VmafCalculatorBase>()),
  );

  sl.registerLazySingleton(() => GetSettings(sl()));
  sl.registerLazySingleton(() => SaveSettings(sl()));

  sl.registerFactory(
    () => SettingsBloc(
      getSettings: sl(),
      saveSettings: sl(),
    ),
  );

  sl.registerFactory(
    () => VmafBloc(),
  );
}

VmafCalculatorBase _createCalculator(
  CalculationMethod method,
  String? ffmpegPath,
  String? vmafCliPath,
  String? vmafTempPath,
) {
  switch (method) {
    case CalculationMethod.ffmpeg:
      return VmafCalculator(
        ffmpegPath: ffmpegPath,
      );
    case CalculationMethod.netflixCli:
      return VmafCliCalculator(
        vmafCliPath: vmafCliPath ?? '',
        vmafTempPath: vmafTempPath,
        ffmpegPath: ffmpegPath,
      );
  }
}

void updateCalculator(AppSettings settings) {
  if (sl.isRegistered<VmafCalculatorBase>()) {
    sl.unregister<VmafCalculatorBase>();
  }
  if (sl.isRegistered<CalculateVmaf>()) {
    sl.unregister<CalculateVmaf>();
  }
  sl.registerSingleton<VmafCalculatorBase>(
    _createCalculator(
      settings.calculationMethod,
      settings.ffmpegPath,
      settings.vmafCliPath,
      settings.vmafTempPath,
    ),
  );
  sl.registerSingleton<CalculateVmaf>(
    CalculateVmaf(sl<VmafCalculatorBase>()),
  );
}