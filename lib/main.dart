import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/app_provider_scope.dart';
import 'core/constants/app_constants.dart';
import 'core/error/global_error_handler.dart';
import 'core/utils/logger.dart';
import 'data/local_storage/local_storage.dart';
import 'data/database/app_database.dart';
import 'features/sales_entry/providers/sales_entry_providers.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    AppLogger.init(AppConstants.currentEnvironment);
    AppLogger.i('Initializing Application...');

    FlutterError.onError = (FlutterErrorDetails details) {
      AppLogger.e('Flutter Error', details.exception, details.stack);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      GlobalErrorHandler.handleError(error, stack);
      return true;
    };
    GlobalErrorHandler.init();

    await LocalStorage.init();
    AppLogger.d('Local Storage Initialized');

    final db = AppDatabase();
    AppLogger.d('Database Initialized');

    runApp(
      AppProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: const EikonApp(),
      ),
    );
  }, GlobalErrorHandler.handleError);
}
