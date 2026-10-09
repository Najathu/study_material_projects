import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'network_log.freezed.dart';

/// One line in the in-app "network inspector".
///
/// FREEZED: a hand-written Freezed class (no JSON this time, so no `.g.dart`).
/// We get immutability, `copyWith`, `==` and `toString` for free.
@freezed
abstract class NetworkLogEntry with _$NetworkLogEntry {
  const factory NetworkLogEntry({
    required int id,
    required String method,
    required String url,
    required DateTime startedAt,
    int? statusCode,
    int? durationMs,
    String? error,
  }) = _NetworkLogEntry;
}

/// RIVERPOD: a `Notifier` owns a piece of state (here: a list of log entries)
/// and exposes methods to change it. Widgets `ref.watch` it and rebuild when
/// `state` is reassigned.
class NetworkLogNotifier extends Notifier<List<NetworkLogEntry>> {
  int _nextId = 0;

  @override
  List<NetworkLogEntry> build() => const [];

  int started(String method, String url) {
    final id = _nextId++;
    // State must be replaced, never mutated, so Riverpod can notice the change.
    state = [
      NetworkLogEntry(
        id: id,
        method: method,
        url: url,
        startedAt: DateTime.now(),
      ),
      ...state,
    ].take(50).toList();
    return id;
  }

  void finished(int id, {int? statusCode, String? error}) {
    state = [
      for (final e in state)
        if (e.id == id)
          // copyWith comes from Freezed.
          e.copyWith(
            statusCode: statusCode,
            error: error,
            durationMs: DateTime.now().difference(e.startedAt).inMilliseconds,
          )
        else
          e,
    ];
  }

  void clear() => state = const [];
}

final networkLogProvider =
    NotifierProvider<NetworkLogNotifier, List<NetworkLogEntry>>(
      NetworkLogNotifier.new,
    );
