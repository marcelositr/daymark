import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/features/journal/presentation/journal_access_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
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

class DaymarkApp extends ConsumerWidget {
  const DaymarkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<JournalAccessState> access = ref.watch(
      journalSessionControllerProvider,
    );
    final bool unlocked = access.when(
      data: (state) => state is JournalUnlocked,
      error: (error, stackTrace) => false,
      loading: () => false,
    );

    if (unlocked) {
      return MaterialApp.router(
        debugShowCheckedModeBanner: false,
        onGenerateTitle: (context) => AppLocalizations.of(context).appName,
        localizationsDelegates: _localizationDelegates,
        supportedLocales: daymarkSupportedLocales,
        localeListResolutionCallback: (locales, supportedLocales) {
          return resolveDaymarkLocale(locales);
        },
        theme: DaymarkTheme.light(),
        darkTheme: DaymarkTheme.dark(),
        themeMode: ThemeMode.system,
        routerConfig: daymarkRouter,
      );
    }

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context).appName,
      localizationsDelegates: _localizationDelegates,
      supportedLocales: daymarkSupportedLocales,
      localeListResolutionCallback: (locales, supportedLocales) {
        return resolveDaymarkLocale(locales);
      },
      theme: DaymarkTheme.light(),
      darkTheme: DaymarkTheme.dark(),
      themeMode: ThemeMode.system,
      home: const JournalAccessScreen(),
    );
  }
}

const List<LocalizationsDelegate<dynamic>> _localizationDelegates = [
  AppLocalizations.delegate,
  GlobalMaterialLocalizations.delegate,
  GlobalWidgetsLocalizations.delegate,
  GlobalCupertinoLocalizations.delegate,
];
