import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/sales_entry.dart';
import '../providers/sales_entry_providers.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/utils/logger.dart';

class SalesEntryController extends Notifier<AsyncValue<void>> {
  Timer? _debounceTimer;
  Completer<List<String>>? _pendingSuggestionCompleter;

  @override
  AsyncValue<void> build() {
    ref.onDispose(() {
      _debounceTimer?.cancel();
      if (!(_pendingSuggestionCompleter?.isCompleted ?? true)) {
        _pendingSuggestionCompleter?.complete(const []);
      }
    });
    return const AsyncValue.data(null);
  }

  AppExceptions _mapException(Object error) {
    if (error is ValidationException || error is DatabaseException) {
      return error as AppExceptions;
    }
    return UnknownException(error.toString());
  }

  Future<void> createEntry({
    required DateTime date,
    required String salesmanName,
    required String area,
    required double value,
    required int shopCount,
    required double cashCollection,
    required double checkCollection,
  }) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncValue.loading();
    try {
      final entry = SalesEntry(
        date: date,
        salesmanName: salesmanName,
        area: area,
        value: value,
        shopCount: shopCount,
        cashCollection: cashCollection,
        checkCollection: checkCollection,
      );
      await ref.read(createSalesEntryProvider).call(entry);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      AppLogger.e('SalesEntryController Create Error', e, stack);
      state = AsyncValue.error(_mapException(e), stack);
    }
  }

  Future<void> updateEntry(SalesEntry entry) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncValue.loading();
    try {
      await ref.read(updateSalesEntryProvider).call(entry);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      AppLogger.e('SalesEntryController Update Error', e, stack);
      state = AsyncValue.error(_mapException(e), stack);
    }
  }

  Future<void> deleteEntry(int id) async {
    if (state.isLoading) {
      return;
    }
    state = const AsyncValue.loading();
    try {
      await ref.read(deleteSalesEntryProvider).call(id);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      AppLogger.e('SalesEntryController Delete Error', e, stack);
      state = AsyncValue.error(_mapException(e), stack);
    }
  }

  Future<List<String>> fetchSuggestions(String type, String query) async {
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      return const [];
    }

    _debounceTimer?.cancel();
    if (!(_pendingSuggestionCompleter?.isCompleted ?? true)) {
      _pendingSuggestionCompleter?.complete(const []);
    }

    final completer = Completer<List<String>>();
    _pendingSuggestionCompleter = completer;

    _debounceTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final results = await ref
            .read(fetchSuggestionsProvider)
            .call(type, normalizedQuery);
        if (!completer.isCompleted) {
          completer.complete(results);
        }
      } catch (e, stack) {
        AppLogger.e('SalesEntryController Suggestion Error', e, stack);
        if (!completer.isCompleted) {
          completer.complete(const []);
        }
      }
    });

    return completer.future;
  }
}

final salesEntryControllerProvider =
    NotifierProvider<SalesEntryController, AsyncValue<void>>(
      SalesEntryController.new,
    );
