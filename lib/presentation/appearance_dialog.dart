import 'package:daymark/app/appearance_controller.dart';
import 'package:daymark/core/settings/appearance_preferences.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> showAppearanceDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => const AppearanceDialog(),
  );
}

final class AppearanceDialog extends ConsumerStatefulWidget {
  const AppearanceDialog({super.key});

  @override
  ConsumerState<AppearanceDialog> createState() => _AppearanceDialogState();
}

final class _AppearanceDialogState extends ConsumerState<AppearanceDialog> {
  bool _saving = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<AppearancePreference> appearance = ref.watch(
      appearanceControllerProvider,
    );
    final AppearancePreference current =
        appearance.value ?? AppearancePreference.system;
    final bool enabled = appearance.hasValue && !_saving;

    return AlertDialog(
      title: Text(l10n.appearanceTitle),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.appearanceMessage),
            const SizedBox(height: 12),
            _AppearanceChoice(
              icon: Icons.brightness_auto_outlined,
              label: l10n.appearanceSystem,
              selected: current == AppearancePreference.system,
              onTap: enabled
                  ? () => _select(AppearancePreference.system)
                  : null,
            ),
            _AppearanceChoice(
              icon: Icons.light_mode_outlined,
              label: l10n.appearanceLight,
              selected: current == AppearancePreference.light,
              onTap: enabled ? () => _select(AppearancePreference.light) : null,
            ),
            _AppearanceChoice(
              icon: Icons.dark_mode_outlined,
              label: l10n.appearanceDark,
              selected: current == AppearancePreference.dark,
              onTap: enabled ? () => _select(AppearancePreference.dark) : null,
            ),
            if (!appearance.hasValue) ...[
              const SizedBox(height: 8),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).closeButtonLabel),
        ),
      ],
    );
  }

  Future<void> _select(AppearancePreference preference) async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    setState(() {
      _saving = true;
      _errorMessage = null;
    });

    try {
      await ref
          .read(appearanceControllerProvider.notifier)
          .setPreference(preference);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _errorMessage = l10n.appearanceSaveFailed;
        });
      }
    }
  }
}

final class _AppearanceChoice extends StatelessWidget {
  const _AppearanceChoice({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      trailing: selected ? const Icon(Icons.check) : null,
      onTap: onTap,
    );
  }
}
