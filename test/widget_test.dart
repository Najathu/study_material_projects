import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:study_material_projects/api/generated/export.dart';
import 'package:study_material_projects/core/dio_provider.dart';
import 'package:study_material_projects/core/petstore_providers.dart';
import 'package:study_material_projects/features/demos/freezed_examples.dart';
import 'package:study_material_projects/features/learn/lessons.dart';
import 'package:study_material_projects/router/app_router.dart';
import 'package:study_material_projects/main.dart';

/// A Dio adapter that never touches the network: it answers from a map.
/// Shows how overriding `dioProvider` makes the whole stack testable.
class FakeAdapter implements HttpClientAdapter {
  FakeAdapter(this.routes);

  final Map<String, String> routes;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final body = routes[options.uri.path];
    if (body == null) return ResponseBody.fromString('Not found', 404);
    return ResponseBody.fromString(
      body,
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  group('Freezed', () {
    test('copyWith returns a new object and leaves the original alone', () {
      const a = Student(name: 'Ana', age: 20);
      final b = a.copyWith(age: 21);
      expect(a.age, 20);
      expect(b.age, 21);
    });

    test('value equality', () {
      expect(
        const Student(name: 'Ana', age: 20),
        Student(name: 'Ana', age: 20, skills: []),
      );
    });

    test('JSON round trip uses @JsonKey name', () {
      const s = Student(name: 'Ana', age: 20, isActive: false);
      expect(s.toJson()['is_active'], false);
      expect(Student.fromJson(s.toJson()), s);
    });

    test('generated Pet tolerates unknown enum values', () {
      final pet = Pet.fromJson({'name': 'x', 'status': 'on-holiday'});
      expect(pet.status, PetStatus.$unknown);
    });
  });

  group('Riverpod + Dio + generated client', () {
    test('petsByStatusProvider parses and filters pets', () async {
      final dio = Dio(BaseOptions(baseUrl: petstoreBaseUrl))
        ..httpClientAdapter = FakeAdapter({
          '/api/v3/pet/findByStatus':
              '[{"id":1,"name":"Rex","status":"available"},'
              '{"id":1,"name":"Rex dup"},'
              '{"id":-5,"name":"junk"}]',
        });

      final container = ProviderContainer.test(
        overrides: [dioProvider.overrideWithValue(dio)],
      );

      final pets = await container.read(
        petsByStatusProvider(PetStatus.available).future,
      );
      expect(pets.map((p) => p.name), ['Rex']);
    });
  });

  testWidgets('home screen lists all six lessons', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: StudyApp()));
    await tester.pumpAndSettle();

    expect(find.text('Flutter Stack Academy'), findsOneWidget);
    expect(find.text('1. Riverpod'), findsOneWidget);
    expect(find.text('2. Dio'), findsOneWidget);

    await tester.tap(find.text('2. Dio'));
    await tester.pumpAndSettle();
    expect(find.text('Learn'), findsOneWidget);
  });

  testWidgets('every lesson tab and the pet store render without errors', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 860);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final dio = Dio(BaseOptions(baseUrl: petstoreBaseUrl))
      ..httpClientAdapter = FakeAdapter({
        '/api/v3/pet/findByStatus':
            '[{"id":7,"name":"Lion 1","status":"sold"}]',
        '/api/v3/pet/7':
            '{"id":7,"name":"Lion 1","tags":[{"id":1,"name":"t"}]}',
        '/api/v3/store/inventory': '{"available":3}',
      });
    final container = ProviderContainer.test(
      overrides: [dioProvider.overrideWithValue(dio)],
    );
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const StudyApp()),
    );
    final router = container.read(routerProvider);

    for (final topic in Topic.values) {
      router.go('/lesson/${topic.name}');
      await tester.pumpAndSettle();
      expect(find.text(lessonFor(topic).title), findsWidgets);
      await tester.tap(find.text('Try it'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Quiz'));
      await tester.pumpAndSettle();
    }

    router.go('/pets?status=sold');
    await tester.pumpAndSettle();
    expect(find.text('Lion 1'), findsOneWidget);

    await tester.tap(find.text('Lion 1'));
    await tester.pumpAndSettle();
    expect(find.text('Pet #7'), findsOneWidget);

    router.go('/secret');
    await tester.pumpAndSettle();
    expect(find.text('Login (fake)'), findsOneWidget);

    router.go('/lesson/nonsense');
    await tester.pumpAndSettle();
    expect(find.text('Flutter Stack Academy'), findsOneWidget);
  });
}
