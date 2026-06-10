abstract class AppExceptions implements Exception {
  final String message;
  AppExceptions(this.message);

  @override
  String toString() => message;
}

class ValidationException extends AppExceptions {
  ValidationException(super.message);
}

class DatabaseException extends AppExceptions {
  DatabaseException(super.message);
}

class UnknownException extends AppExceptions {
  UnknownException(super.message);
}

extension AppExceptionMessage on Object? {
  String toUserMessage() {
    final error = this;
    if (error is ValidationException) {
      return error.message;
    }
    if (error is DatabaseException) {
      return 'Unable to complete that action right now. Please try again.';
    }
    return 'Something went wrong. Please try again.';
  }
}
