import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_data_source.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDataSource dataSource;

  SettingsRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, AppSettings>> getSettings() {
    return dataSource.getSettings();
  }

  @override
  Future<Either<Failure, AppSettings>> saveSettings(AppSettings settings) {
    return dataSource.saveSettings(settings);
  }
}