import 'package:daymark/core/crypto/security_exception.dart';
import 'package:daymark/core/session/journal_session.dart';
import 'package:daymark/core/session/journal_session_controller.dart';
import 'package:daymark/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class JournalAccessScreen extends ConsumerStatefulWidget {
  const JournalAccessScreen({super.key});

  @override
  ConsumerState<JournalAccessScreen> createState() =>
      _JournalAccessScreenState();
}

class _JournalAccessScreenState extends ConsumerState<JournalAccessScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmationController = TextEditingController();

  String? _errorMessage;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final AsyncValue<JournalAccessState> access = ref.watch(
      journalSessionControllerProvider,
    );

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: access.when(
                data: (state) => switch (state) {
                  JournalNeedsCreation() => _buildCreate(context, l10n),
                  JournalLocked() => _buildUnlock(context, l10n),
                  JournalStorageProblem() => _buildStorageProblem(
                    context,
                    l10n,
                  ),
                  JournalUnlocked() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stackTrace) => _buildLoadFailure(context, l10n),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreate(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.createJournalTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(l10n.createJournalMessage),
        const SizedBox(height: 28),
        _passwordField(
          controller: _passwordController,
          label: l10n.masterPassword,
          newPassword: true,
        ),
        const SizedBox(height: 12),
        _passwordField(
          controller: _confirmationController,
          label: l10n.confirmMasterPassword,
          newPassword: true,
          onSubmitted: (_) => _createJournal(),
        ),
        _buildError(context),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _createJournal,
          child: Text(l10n.createJournal),
        ),
      ],
    );
  }

  Widget _buildUnlock(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.unlockJournalTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(l10n.unlockJournalMessage),
        const SizedBox(height: 28),
        _passwordField(
          controller: _passwordController,
          label: l10n.masterPassword,
          onSubmitted: (_) => _unlockJournal(),
        ),
        _buildError(context),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _unlockJournal,
          child: Text(l10n.unlockJournal),
        ),
      ],
    );
  }

  Widget _buildError(BuildContext context) {
    final String? errorMessage = _errorMessage;
    if (errorMessage == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Text(
        errorMessage,
        style: TextStyle(color: Theme.of(context).colorScheme.error),
      ),
    );
  }

  Widget _buildStorageProblem(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.journalStorageProblemTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 12),
        Text(l10n.journalStorageProblem),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => ref.invalidate(journalSessionControllerProvider),
          child: Text(l10n.tryAgain),
        ),
      ],
    );
  }

  Widget _buildLoadFailure(BuildContext context, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.journalAccessFailed,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => ref.invalidate(journalSessionControllerProvider),
          child: Text(l10n.tryAgain),
        ),
      ],
    );
  }

  Widget _passwordField({
    required TextEditingController controller,
    required String label,
    bool newPassword = false,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: true,
      autocorrect: false,
      enableSuggestions: false,
      autofillHints: <String>[
        newPassword ? AutofillHints.newPassword : AutofillHints.password,
      ],
      textInputAction: onSubmitted == null
          ? TextInputAction.next
          : TextInputAction.done,
      onSubmitted: onSubmitted,
      decoration: InputDecoration(labelText: label),
    );
  }

  Future<void> _createJournal() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String password = _passwordController.text;

    if (password.isEmpty) {
      setState(() => _errorMessage = l10n.masterPasswordRequired);
      return;
    }
    if (password != _confirmationController.text) {
      setState(() => _errorMessage = l10n.passwordsDoNotMatch);
      return;
    }

    setState(() => _errorMessage = null);
    try {
      await ref
          .read(journalSessionControllerProvider.notifier)
          .create(masterPassword: password);
    } catch (error, stackTrace) {
      _reportUnexpectedAccessError(error, stackTrace);
      if (mounted) {
        setState(() => _errorMessage = l10n.journalAccessFailed);
      }
    }
  }

  Future<void> _unlockJournal() async {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final String password = _passwordController.text;

    if (password.isEmpty) {
      setState(() => _errorMessage = l10n.masterPasswordRequired);
      return;
    }

    setState(() => _errorMessage = null);
    try {
      await ref
          .read(journalSessionControllerProvider.notifier)
          .unlock(masterPassword: password);
    } on JournalUnlockException {
      if (mounted) {
        setState(() => _errorMessage = l10n.journalAccessFailed);
      }
    } catch (error, stackTrace) {
      _reportUnexpectedAccessError(error, stackTrace);
      if (mounted) {
        setState(() => _errorMessage = l10n.journalAccessFailed);
      }
    }
  }
}

void _reportUnexpectedAccessError(Object error, StackTrace stackTrace) {
  FlutterError.reportError(
    FlutterErrorDetails(
      exception: FlutterError(
        'Journal access operation failed (${error.runtimeType}).',
      ),
      stack: stackTrace,
      library: 'daymark',
    ),
  );
}
