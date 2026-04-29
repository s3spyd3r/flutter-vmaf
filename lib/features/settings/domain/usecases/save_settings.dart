import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class SaveSettings {
  final SettingsRepository repository;

  SaveSettings(this.repository);

  Future<Either<Failure, AppSettings>> call(AppSettings settings) {
    return repository.saveSettings(settings);
  }
}