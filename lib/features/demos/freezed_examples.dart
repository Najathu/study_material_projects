import 'package:freezed_annotation/freezed_annotation.dart';

// `part` files are created by: dart run build_runner build
part 'freezed_examples.freezed.dart';
part 'freezed_examples.g.dart';

/// 1) A simple immutable DATA CLASS with JSON support.
@freezed
abstract class Student with _$Student {
  const factory Student({
    required String name,
    required int age,
    @Default(<String>[]) List<String> skills, // default value
    @JsonKey(name: 'is_active') @Default(true) bool isActive, // custom JSON key
  }) = _Student;

  factory Student.fromJson(Map<String, Object?> json) =>
      _$StudentFromJson(json);
}

/// 2) A SEALED UNION: a value that is exactly ONE of several shapes.
/// Perfect for "loading / success / failure" states.
/// Dart's `switch` will warn you if you forget a case.
@freezed
sealed class LoadState with _$LoadState {
  const factory LoadState.idle() = Idle;
  const factory LoadState.loading() = Loading;
  const factory LoadState.success(List<String> items) = Success;
  const factory LoadState.failure(String message) = Failure;
}

/// 3) Adding your own getters/methods needs a private `._()` constructor.
@freezed
abstract class Money with _$Money {
  const Money._();

  const factory Money({required int cents, @Default('USD') String currency}) =
      _Money;

  String get formatted => '${(cents / 100).toStringAsFixed(2)} $currency';

  Money operator +(Money other) => copyWith(cents: cents + other.cents);
}
