import '../utils/logger.dart';

class GlobalErrorHandler {
  static void init() {
    // Handling Flutter errors
    // FlutterError.onError = (FlutterErrorDetails details) {
    //   AppLogger.e('Flutter Error', details.exception, details.stack);
    // };

    // Handling Dart errors
    // PlatformDispatcher.instance.onError = (error, stack) {
    //   AppLogger.e('Dart Error', error, stack);
    //   return true;
    // };
  }

  static void handleError(dynamic error, [StackTrace? stackTrace]) {
    AppLogger.e('Unhandled Application Error', error, stackTrace);
  }
}
