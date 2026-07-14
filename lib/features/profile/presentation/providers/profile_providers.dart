import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../onboarding/presentation/providers/onboarding_providers.dart'
    show sharedPreferencesProvider;
import '../../data/datasources/profile_local_data_source.dart';
import '../../domain/entities/user_profile.dart';

final profileLocalDataSourceProvider = Provider(
  (ref) => ProfileLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

final userProfileProvider =
    NotifierProvider<UserProfileController, UserProfile>(
  UserProfileController.new,
);

class UserProfileController extends Notifier<UserProfile> {
  @override
  UserProfile build() =>
      ref.watch(profileLocalDataSourceProvider).getProfile();

  Future<void> update({String? name, String? avatarEmoji}) async {
    final updated = state.copyWith(name: name, avatarEmoji: avatarEmoji);
    await ref.read(profileLocalDataSourceProvider).saveProfile(updated);
    state = updated;
  }
}