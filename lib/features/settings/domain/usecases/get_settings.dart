import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings {
  final SettingsRepository repository;

  GetSettings(this.repository);

  Future<Either<Failure, AppSettings>> call() {
    return repository.getSettings();
  }
}