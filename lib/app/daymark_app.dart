import 'package:daymark/core/settings/appearance_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import 'appearance_controller.dart';
import 'router.dart';
import 'theme.dart';

const List<Locale> daymarkSupportedLocales = <Locale>[
  Locale('en'),
  Locale('pt', 'BR'),
];

Locale resolveDaymarkLocale(List<Locale>? preferredLocales) {
  if (preferredLocales != null) {
    for (final Locale locale in preferredLocales) {
      if (locale.languageCode == 'pt' && locale.countryCode == 'BR') {
        return const Locale('pt', 'BR');
      }

      if (locale.languageCode == 'en') {
        return const Locale('en');
      }
    }
  }

  return const Locale('en');
}

ThemeMode themeModeForAppearance(AppearancePreference preference) {
  return switch (preference) {
    AppearancePreference.system => ThemeMode.system,
    AppearancePreference.light => ThemeMode.light,
    AppearancePreference.dark => ThemeMode.dark,
  };
}

class DaymarkApp extends ConsumerWidget {
  const DaymarkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<AppearancePreference> appearance = ref.watch(
      appearanceControllerProvider,
    );
    final ThemeMode themeMode = appearance.when(
      data: themeModeForAppearance,
      error: (error, stackTrace) => ThemeMode.system,
      loading: () => ThemeMode.system,
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: daymarkSupportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        return resolveDaymarkLocale(locales);
      },
      theme: DaymarkTheme.light(),
      darkTheme: DaymarkTheme.dark(),
      themeMode: themeMode,
      routerConfig: daymarkRouter,
    );
  }
}
