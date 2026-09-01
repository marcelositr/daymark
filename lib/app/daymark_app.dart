import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

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

class DaymarkApp extends StatelessWidget {
  const DaymarkApp({super.key});

  @override
  Widget build(BuildContext context) {
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
      themeMode: ThemeMode.system,
      routerConfig: daymarkRouter,
    );
  }
}
