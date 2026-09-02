sealed class DaymarkSecurityException implements Exception {
  const DaymarkSecurityException(this.message);

  final String message;

  @override
  String toString() => '$runtimeType: $message';
}

final class KeyEnvelopeFormatException extends DaymarkSecurityException {
  const KeyEnvelopeFormatException([super.message = 'Invalid key envelope.']);
}

final class JournalUnlockException extends DaymarkSecurityException {
  const JournalUnlockException() : super('The journal could not be unlocked.');
}

final class EncryptedDatabaseUnavailableException
    extends DaymarkSecurityException {
  const EncryptedDatabaseUnavailableException()
    : super('Encrypted SQLite support is unavailable.');
}

final class JournalDatabaseOpenException extends DaymarkSecurityException {
  const JournalDatabaseOpenException(super.message);
}

final class BackupFormatException extends DaymarkSecurityException {
  const BackupFormatException([super.message = 'Invalid Daymark backup.']);
}

final class BackupAuthenticationException extends DaymarkSecurityException {
  const BackupAuthenticationException()
    : super('The Daymark backup could not be authenticated.');
}

final class BackupCompatibilityException extends DaymarkSecurityException {
  const BackupCompatibilityException(super.message);
}

final class BackupWriteException extends DaymarkSecurityException {
  const BackupWriteException(super.message);
}

final class BackupRestoreException extends DaymarkSecurityException {
  const BackupRestoreException(super.message);
}
