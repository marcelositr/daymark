import 'package:daymark/app/app_info.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> showDaymarkAboutDialog(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => const DaymarkAboutDialog(),
  );
}

final class DaymarkAboutDialog extends StatefulWidget {
  const DaymarkAboutDialog({super.key});

  @override
  State<DaymarkAboutDialog> createState() => _DaymarkAboutDialogState();
}

final class _DaymarkAboutDialogState extends State<DaymarkAboutDialog> {
  bool _copied = false;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final TextTheme text = Theme.of(context).textTheme;

    return AboutDialog(
      applicationName: l10n.appName,
      applicationVersion: DaymarkAppInfo.version,
      applicationIcon: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          DaymarkAppInfo.iconAsset,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
        ),
      ),
      applicationLegalese:
          '© 2026 ${DaymarkAppInfo.author}\n${DaymarkAppInfo.license}',
      children: [
        const SizedBox(height: 8),
        Text(l10n.aboutDescription),
        const SizedBox(height: 8),
        Text(l10n.aboutPrinciples, style: text.labelLarge),
        const SizedBox(height: 16),
        _AboutValue(
          icon: Icons.language_outlined,
          label: l10n.aboutWebsite,
          value: DaymarkAppInfo.website,
          copyTooltip: l10n.aboutCopy,
          onCopy: () => _copy(DaymarkAppInfo.website),
        ),
        _AboutValue(
          icon: Icons.code,
          label: l10n.aboutSourceCode,
          value: DaymarkAppInfo.sourceCode,
          copyTooltip: l10n.aboutCopy,
          onCopy: () => _copy(DaymarkAppInfo.sourceCode),
        ),
        _AboutValue(
          icon: Icons.bug_report_outlined,
          label: l10n.aboutReportIssue,
          value: DaymarkAppInfo.issues,
          copyTooltip: l10n.aboutCopy,
          onCopy: () => _copy(DaymarkAppInfo.issues),
        ),
        if (_copied) ...[
          const SizedBox(height: 4),
          Text(l10n.aboutCopied, style: text.bodySmall),
        ],
        const Divider(height: 28),
        Text(l10n.aboutCreatedBy, style: text.titleSmall),
        const SizedBox(height: 4),
        const SelectableText(DaymarkAppInfo.author),
        const SelectableText(DaymarkAppInfo.authorWebsite),
        const SizedBox(height: 16),
        Text(l10n.aboutIndependent, style: text.bodySmall),
      ],
    );
  }

  Future<void> _copy(String value) async {
    await Clipboard.setData(ClipboardData(text: value));
    if (mounted) {
      setState(() => _copied = true);
    }
  }
}

final class _AboutValue extends StatelessWidget {
  const _AboutValue({
    required this.icon,
    required this.label,
    required this.value,
    required this.copyTooltip,
    required this.onCopy,
  });

  final IconData icon;
  final String label;
  final String value;
  final String copyTooltip;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(label),
      subtitle: SelectableText(value),
      trailing: IconButton(
        onPressed: onCopy,
        tooltip: copyTooltip,
        icon: const Icon(Icons.copy_outlined),
      ),
    );
  }
}
