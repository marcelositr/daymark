import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

enum DaymarkSection { today, monthly, future, collections, search }

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    required this.section,
    this.isFoundationHome = false,
    super.key,
  });

  final bool isFoundationHome;
  final DaymarkSection section;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _title(l10n),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  isFoundationHome
                      ? l10n.foundationMessage
                      : l10n.placeholderMessage,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n) {
    return switch (section) {
      DaymarkSection.today => l10n.today,
      DaymarkSection.monthly => l10n.monthly,
      DaymarkSection.future => l10n.future,
      DaymarkSection.collections => l10n.collections,
      DaymarkSection.search => l10n.search,
    };
  }
}
