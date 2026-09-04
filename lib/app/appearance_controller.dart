import 'package:daymark/core/settings/appearance_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final FutureProvider<AppearancePreferenceStore>
appearancePreferenceStoreProvider = FutureProvider<AppearancePreferenceStore>(
  (ref) => AppearancePreferenceStore.forApplication(),
);

final AsyncNotifierProvider<AppearanceController, AppearancePreference>
appearanceControllerProvider =
    AsyncNotifierProvider<AppearanceController, AppearancePreference>(
      AppearanceController.new,
    );

final class AppearanceController extends AsyncNotifier<AppearancePreference> {
  @override
  Future<AppearancePreference> build() async {
    final AppearancePreferenceStore store = await ref.watch(
      appearancePreferenceStoreProvider.future,
    );
    return store.load();
  }

  Future<void> setPreference(AppearancePreference preference) async {
    final AppearancePreference previous =
        state.value ?? AppearancePreference.system;
    final AppearancePreferenceStore store = await ref.read(
      appearancePreferenceStoreProvider.future,
    );

    state = AsyncData<AppearancePreference>(preference);

    try {
      await store.save(preference);
    } catch (error, stackTrace) {
      state = AsyncData<AppearancePreference>(previous);
      Error.throwWithStackTrace(error, stackTrace);
    }
  }
}
