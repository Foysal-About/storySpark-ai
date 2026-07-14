import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../onboarding/presentation/providers/onboarding_providers.dart'
    show sharedPreferencesProvider;
import '../../data/datasources/settings_local_data_source.dart';
import '../../domain/entities/app_settings.dart';

final settingsLocalDataSourceProvider = Provider(
  (ref) => SettingsLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

final appSettingsProvider =
    NotifierProvider<AppSettingsController, AppSettings>(
  AppSettingsController.new,
);

class AppSettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() =>
      ref.watch(settingsLocalDataSourceProvider).getSettings();

  Future<void> update({
    bool? soundsEnabled,
    bool? notificationsEnabled,
    String? narrationVoice,
    String? appearance,
    String? language,
  }) async {
    final updated = state.copyWith(
      soundsEnabled: soundsEnabled,
      notificationsEnabled: notificationsEnabled,
      narrationVoice: narrationVoice,
      appearance: appearance,
      language: language,
    );
    await ref.read(settingsLocalDataSourceProvider).saveSettings(updated);
    state = updated;
  }
}
