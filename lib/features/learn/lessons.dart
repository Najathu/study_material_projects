import 'package:flutter/material.dart';

/// The six things this app teaches, in the recommended learning order.
enum Topic { riverpod, dio, freezed, goRouter, openapi, swagger }

class LessonSection {
  const LessonSection(this.heading, this.body, {this.code});

  final String heading;
  final String body;
  final String? code;
}

class QuizQuestion {
  const QuizQuestion(this.question, this.options, this.answerIndex, this.why);

  final String question;
  final List<String> options;
  final int answerIndex;
  final String why;
}

class Lesson {
  const Lesson({
    required this.topic,
    required this.title,
    required this.icon,
    required this.color,
    required this.oneLiner,
    required this.analogy,
    required this.sections,
    required this.mistakes,
    required this.filesInThisApp,
    required this.quiz,
  });

  final Topic topic;
  final String title;
  final IconData icon;
  final Color color;
  final String oneLiner;
  final String analogy;
  final List<LessonSection> sections;
  final List<String> mistakes;
  final List<String> filesInThisApp;
  final List<QuizQuestion> quiz;
}

Lesson lessonFor(Topic topic) => lessons.firstWhere((l) => l.topic == topic);

const lessons = <Lesson>[
  // ───────────────────────────────────────────────────────────── RIVERPOD ──
  Lesson(
    topic: Topic.riverpod,
    title: 'Riverpod',
    icon: Icons.water_drop_outlined,
    color: Colors.teal,
    oneLiner:
        'State management + dependency injection. You declare "providers" '
        '(global, typed recipes for a value) and widgets watch them.',
    analogy:
        'Think of a provider as a labelled box in a warehouse (ProviderScope). '
        'A widget asks for a box by its label. If the box contents change, '
        'everyone holding that label is told to update. Boxes are only filled '
        'when someone first asks for them (lazy).',
    sections: [
      LessonSection(
        'Why do we need it?',
        'setState only works inside one widget. As soon as two screens need the '
            'same data (logged-in user, cart, a list loaded from an API) you need '
            'somewhere outside the widget tree to keep it. Riverpod gives you that '
            'place, and it also handles loading/error states for async data, '
            'caching, and disposing things nobody uses anymore.',
      ),
      LessonSection(
        'Step 1 – wrap the app',
        'All provider state lives inside a ProviderScope at the root.',
        code: '''void main() {
  runApp(const ProviderScope(child: MyApp()));
}''',
      ),
      LessonSection(
        'Step 2 – declare providers',
        'Providers are global final variables. That is safe: the variable is only '
            'the recipe; the actual state lives in ProviderScope.\n\n'
            '• Provider – a value that never changes on its own (e.g. a Dio instance).\n'
            '• NotifierProvider – state + methods to change it.\n'
            '• FutureProvider – the result of an async call (gives you AsyncValue).\n'
            '• StreamProvider – the latest value from a Stream.',
        code: '''// 1. Plain value / dependency
final dioProvider = Provider<Dio>((ref) => Dio());

// 2. State you can change
class Counter extends Notifier<int> {
  @override
  int build() => 0;            // initial state
  void increment() => state++; // assigning `state` notifies listeners
}
final counterProvider = NotifierProvider<Counter, int>(Counter.new);

// 3. Async data
final petsProvider = FutureProvider<List<Pet>>((ref) async {
  final dio = ref.watch(dioProvider);  // providers can use other providers
  final res = await dio.get('/pets');
  return (res.data as List).map((j) => Pet.fromJson(j)).toList();
});''',
      ),
      LessonSection(
        'Step 3 – use them in widgets',
        'Use ConsumerWidget instead of StatelessWidget. You get a `ref`.\n\n'
            '• ref.watch(p) → read AND rebuild when it changes. Use inside build().\n'
            '• ref.read(p) → read once, no rebuild. Use inside onPressed etc.\n'
            '• ref.listen(p, cb) → run a side effect (snackbar, navigation) on change.',
        code: '''class CounterText extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);
    return TextButton(
      onPressed: () => ref.read(counterProvider.notifier).increment(),
      child: Text('\$count'),
    );
  }
}''',
      ),
      LessonSection(
        'AsyncValue – loading / data / error in one object',
        'A FutureProvider gives you AsyncValue<T>. It is a sealed class, so you '
            'can switch on it and the compiler makes sure you handle every case.',
        code: '''final pets = ref.watch(petsProvider);
return switch (pets) {
  AsyncData(:final value) => PetList(value),
  AsyncError(:final error) => Text('Oops: \$error'),
  _ => const CircularProgressIndicator(),
};

// Pull-to-refresh / retry:
ref.invalidate(petsProvider);''',
      ),
      LessonSection(
        'Modifiers: family & autoDispose',
        '• .family lets a provider take a parameter: petByIdProvider(42). Each '
            'argument gets its own cached state.\n'
            '• .autoDispose throws the state away when no widget is watching it '
            'anymore (e.g. you left the detail screen), so memory is freed and '
            'the next visit fetches fresh data.',
        code: '''final petByIdProvider =
    FutureProvider.autoDispose.family<Pet, int>((ref, id) {
  return ref.watch(apiProvider).getPetById(petId: id);
});

ref.watch(petByIdProvider(42));''',
      ),
      LessonSection(
        'Bonus: code generation',
        'Riverpod also has an optional generator (riverpod_annotation + '
            'riverpod_generator) where you write `@riverpod` functions and the '
            'provider variables are generated. This app uses the manual syntax so '
            'you can see exactly what a provider is. Both styles are fine.',
        code: '''@riverpod
Future<Pet> petById(Ref ref, int id) =>
    ref.watch(apiProvider).getPetById(petId: id);
// generates: petByIdProvider''',
      ),
    ],
    mistakes: [
      'Using ref.read inside build() → the widget won\'t update. Use ref.watch.',
      'Using ref.watch inside onPressed → use ref.read in callbacks.',
      'Mutating state (state.add(x)) instead of replacing it (state = [...state, x]). '
          'Riverpod compares by identity, so mutation is invisible.',
      'Forgetting ProviderScope at the root → "No ProviderScope found" error.',
    ],
    filesInThisApp: [
      'lib/main.dart – ProviderScope',
      'lib/core/petstore_providers.dart – Provider, Notifier, FutureProvider, family, autoDispose',
      'lib/core/network_log.dart – a Notifier holding a list',
      'lib/features/pets/pet_list_screen.dart – ref.watch + AsyncValue switch',
    ],
    quiz: [
      QuizQuestion(
        'Inside a button\'s onPressed you want to call increment(). Which do you use?',
        [
          'ref.watch(counterProvider)',
          'ref.read(counterProvider.notifier)',
          'ref.listen(counterProvider)',
        ],
        1,
        'Callbacks run once; you don\'t want to subscribe. `.notifier` gives the '
            'Notifier object that has the methods.',
      ),
      QuizQuestion(
        'What does .autoDispose do?',
        [
          'Deletes the provider variable',
          'Frees the provider\'s state when nobody watches it',
          'Disposes the whole ProviderScope',
        ],
        1,
        'The recipe stays; only the cached value is thrown away.',
      ),
      QuizQuestion(
        'How do you give a provider a parameter like a pet id?',
        ['.family', '.select', 'A global variable'],
        0,
        'FutureProvider.family<Pet, int> → petByIdProvider(42).',
      ),
    ],
  ),

  // ────────────────────────────────────────────────────────────────── DIO ──
  Lesson(
    topic: Topic.dio,
    title: 'Dio',
    icon: Icons.cloud_sync_outlined,
    color: Colors.orange,
    oneLiner:
        'A powerful HTTP client for Dart. Like the `http` package, plus base '
        'URLs, interceptors, timeouts, cancellation, file upload & typed errors.',
    analogy:
        'Dio is a post office. BaseOptions are the default stamp/return address '
        'on every letter. Interceptors are the clerks every letter passes '
        'through – one adds your ID (auth token), one writes it in the log book, '
        'one re-sends it if it got lost.',
    sections: [
      LessonSection(
        'Create one configured instance',
        'Make one Dio for the whole app (we expose it with a Riverpod provider) '
            'so configuration lives in one place.',
        code: '''final dio = Dio(BaseOptions(
  baseUrl: 'https://petstore3.swagger.io/api/v3',
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 15),
  headers: {'Accept': 'application/json'},
));''',
      ),
      LessonSection(
        'Making requests',
        'Dio decodes JSON for you: response.data is already a Map or List.',
        code: '''// GET /pet/findByStatus?status=available
final res = await dio.get(
  '/pet/findByStatus',
  queryParameters: {'status': 'available'},
);
print(res.statusCode); // 200
print(res.data);       // List<dynamic>

// POST with a JSON body
await dio.post('/pet', data: {'name': 'Rex', 'status': 'available'});

// Other verbs: dio.put, dio.patch, dio.delete, dio.download''',
      ),
      LessonSection(
        'Interceptors',
        'Code that runs around every request. Call handler.next() to continue, '
            'handler.resolve() to answer yourself (e.g. from cache), or '
            'handler.reject() to fail. Common uses: add auth token, refresh an '
            'expired token on 401 and retry, logging, analytics.',
        code: '''class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    o.headers['Authorization'] = 'Bearer \$token';
    h.next(o);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) {
    if (e.response?.statusCode == 401) { /* refresh & retry */ }
    h.next(e);
  }
}

dio.interceptors.add(AuthInterceptor());''',
      ),
      LessonSection(
        'Errors: DioException',
        'Any failure throws a DioException. Its `type` tells you what happened, '
            'so you can show a good message. A 404/500 is type badResponse and '
            'you can still read e.response!.data.',
        code: '''try {
  await dio.get('/pet/999999999');
} on DioException catch (e) {
  switch (e.type) {
    case DioExceptionType.badResponse:
      print('Server said \${e.response?.statusCode}');
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
      print('Too slow');
    case DioExceptionType.connectionError:
      print('Offline?');
    default:
      print(e.message);
  }
}''',
      ),
      LessonSection(
        'Cancelling a request',
        'Pass a CancelToken. Calling cancel() makes the future throw a '
            'DioException of type cancel. Useful when the user leaves a screen '
            'or types a new search query.',
        code: '''final token = CancelToken();
dio.get('/slow', cancelToken: token);
token.cancel('user left');''',
      ),
    ],
    mistakes: [
      'Creating a new Dio() in every function → interceptors/config get lost.',
      'Using full URLs everywhere instead of baseUrl.',
      'Forgetting handler.next() in an interceptor → the request hangs forever.',
      'Catching Exception instead of DioException and losing the status code.',
    ],
    filesInThisApp: [
      'lib/core/dio_provider.dart – BaseOptions + 3 interceptors + error messages',
      'lib/features/demos/dio_demo.dart – raw dio.get, 404, timeout, cancel',
    ],
    quiz: [
      QuizQuestion(
        'The server returns 404. What DioExceptionType is it?',
        ['unknown', 'badResponse', 'connectionError'],
        1,
        'Any non-2xx status code from the server is badResponse.',
      ),
      QuizQuestion(
        'Where should you add an Authorization header for every request?',
        [
          'In every dio.get call',
          'In an interceptor\'s onRequest',
          'In main()',
        ],
        1,
        'One place, applied to all requests automatically.',
      ),
      QuizQuestion(
        'What happens if an interceptor never calls handler.next()?',
        ['Nothing', 'The request never continues', 'Dio retries'],
        1,
        'The chain stops there, the Future never completes.',
      ),
    ],
  ),

  // ────────────────────────────────────────────────────────────── FREEZED ──
  Lesson(
    topic: Topic.freezed,
    title: 'Freezed',
    icon: Icons.ac_unit,
    color: Colors.lightBlue,
    oneLiner:
        'A code generator for immutable data classes and sealed unions: you write '
        'the fields, it writes copyWith, ==, hashCode, toString and fromJson/toJson.',
    analogy:
        'A Freezed object is a printed photo: you can\'t edit it, but you can '
        'make a copy with one thing changed (copyWith). Two photos of the same '
        'thing are "equal" even if they are different pieces of paper.',
    sections: [
      LessonSection(
        'The problem',
        'A normal Dart class compares by identity: User("a") == User("a") is '
            'false. Writing ==, hashCode, copyWith and JSON by hand for every '
            'model is ~80 lines of boring, bug-prone code. Freezed generates it.',
      ),
      LessonSection(
        'Writing a model',
        'Three parts: the annotation, the mixin `with _\$Name`, and a factory '
            'constructor that redirects to the generated `_Name`. Add `part` '
            'lines for the generated files.',
        code: '''import 'package:freezed_annotation/freezed_annotation.dart';

part 'student.freezed.dart'; // copyWith, ==, toString
part 'student.g.dart';       // JSON (json_serializable)

@freezed
abstract class Student with _\$Student {
  const factory Student({
    required String name,
    required int age,
    @Default([]) List<String> skills,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
  }) = _Student;

  factory Student.fromJson(Map<String, Object?> json) =>
      _\$StudentFromJson(json);
}''',
      ),
      LessonSection(
        'Generate the code',
        'Run build_runner. Use `watch` while developing so it regenerates on save.',
        code: '''dart run build_runner build   # once
dart run build_runner watch   # keep running''',
      ),
      LessonSection(
        'What you get',
        '',
        code: '''final a = Student(name: 'Ana', age: 20);
final b = a.copyWith(age: 21);   // new object, a is unchanged
a == Student(name: 'Ana', age: 20); // true – value equality
print(a); // Student(name: Ana, age: 20, skills: [], isActive: true)
a.toJson(); // {name: Ana, age: 20, skills: [], is_active: true}
Student.fromJson({'name': 'Bo', 'age': 3});''',
      ),
      LessonSection(
        'Sealed unions – "one of these shapes"',
        'Use `sealed class` with several named factories. Each becomes a '
            'subclass and Dart\'s switch checks you handled all of them. Great '
            'for UI states and API results.',
        code: '''@freezed
sealed class LoadState with _\$LoadState {
  const factory LoadState.loading() = Loading;
  const factory LoadState.success(List<String> items) = Success;
  const factory LoadState.failure(String message) = Failure;
}

Widget build(LoadState s) => switch (s) {
  Loading() => const Spinner(),
  Success(:final items) => ListView(...),
  Failure(:final message) => Text(message),
};''',
      ),
      LessonSection(
        'Adding methods',
        'If you want custom getters/methods, add a private empty constructor `._()`.',
        code: '''@freezed
abstract class Money with _\$Money {
  const Money._();
  const factory Money({required int cents}) = _Money;
  String get formatted => '\\\$\${cents / 100}';
}''',
      ),
    ],
    mistakes: [
      'Forgetting `part \'x.freezed.dart\';` or using a different file name.',
      'Forgetting to run build_runner after changing a model (red errors everywhere).',
      'Missing `abstract` or `sealed` before class (required since Freezed 3).',
      'Adding a method without the `const X._();` constructor.',
      'Editing *.freezed.dart / *.g.dart by hand – they get overwritten.',
    ],
    filesInThisApp: [
      'lib/features/demos/freezed_examples.dart – Student, LoadState union, Money',
      'lib/core/network_log.dart – Freezed without JSON',
      'lib/api/generated/models/pet.dart – Freezed models GENERATED from OpenAPI',
    ],
    quiz: [
      QuizQuestion(
        'a = Student(name:"x", age:1); b = a.copyWith(age: 2). What is a.age?',
        ['1', '2', 'Error'],
        0,
        'Freezed objects are immutable; copyWith returns a NEW object.',
      ),
      QuizQuestion(
        'Which command generates the .freezed.dart files?',
        [
          'flutter pub get',
          'dart run build_runner build',
          'flutter run --freezed',
        ],
        1,
        'Freezed is a build_runner generator.',
      ),
      QuizQuestion(
        'Which keyword makes Dart force you to handle every union case in switch?',
        ['abstract', 'sealed', 'final'],
        1,
        'sealed classes enable exhaustiveness checking.',
      ),
    ],
  ),

  // ──────────────────────────────────────────────────────────── GO ROUTER ──
  Lesson(
    topic: Topic.goRouter,
    title: 'GoRouter',
    icon: Icons.alt_route,
    color: Colors.deepPurple,
    oneLiner:
        'URL-based navigation for Flutter. Every screen has a path like '
        '/pets/42, which makes deep links, web URLs and login guards easy.',
    analogy:
        'GoRouter is a website\'s address bar for your app. Instead of '
        '"push this widget", you say "go to /pets/42" and the router figures '
        'out which screens should be on the stack.',
    sections: [
      LessonSection(
        'Declare routes',
        'A tree of GoRoute objects. Child paths are relative to their parent. '
            '`:id` is a path parameter.',
        code: '''final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/pets',
      builder: (context, state) => const PetListScreen(),
      routes: [
        GoRoute(
          path: ':id',             // -> /pets/42
          builder: (context, state) =>
              PetDetailScreen(id: int.parse(state.pathParameters['id']!)),
        ),
      ],
    ),
  ],
);

MaterialApp.router(routerConfig: router);''',
      ),
      LessonSection(
        'go vs push vs pop',
        '• context.go(\'/pets/42\') → jump to that URL. The stack is REBUILT from '
            'the route tree (Home → Pets → Pet 42). Back goes to /pets.\n'
            '• context.push(\'/pets/42\') → put it ON TOP of whatever is shown now. '
            'Back returns to where you were. push can also return a result.\n'
            '• context.pop() → close the top screen (optionally with a result).',
        code: '''context.go('/pets/42');
final result = await context.push<bool>('/pets/new');
context.pop(true);''',
      ),
      LessonSection(
        'Parameters',
        'Path params are part of the route (/pets/42). Query params are optional '
            'extras (?status=sold). Use `extra` to pass a whole object (but it is '
            'lost on web refresh / deep link, so prefer ids).',
        code: '''state.pathParameters['id'];          // '42'
state.uri.queryParameters['status']; // 'sold'
state.extra as Pet?;                 // object passed via go(..., extra: pet)

// Named routes avoid typos in paths:
context.goNamed('petDetail', pathParameters: {'id': '42'});''',
      ),
      LessonSection(
        'Redirect = route guards',
        'redirect runs before every navigation. Return a path to send the user '
            'elsewhere, or null to allow it. refreshListenable makes GoRouter '
            're-check when e.g. the login state changes.',
        code: '''GoRouter(
  refreshListenable: authNotifier,
  redirect: (context, state) {
    final loggedIn = auth.isLoggedIn;
    if (!loggedIn && state.matchedLocation == '/secret') {
      return '/login?from=/secret';
    }
    return null; // allow
  },
  ...
);''',
      ),
      LessonSection(
        'Also good to know',
        '• errorBuilder – page for unknown URLs.\n'
            '• ShellRoute / StatefulShellRoute – keep a bottom navigation bar '
            'around child routes, each tab with its own stack.\n'
            '• go_router_builder – optional type-safe routes via code generation.',
      ),
    ],
    mistakes: [
      'Using Navigator.push for some screens and GoRouter for others – pick one.',
      'Using go() when you wanted to come back with a result → use push().',
      'Declaring /pets/:id before /pets/new – "new" gets treated as an id.',
      'Creating the GoRouter inside build() – it gets recreated on every rebuild.',
    ],
    filesInThisApp: [
      'lib/router/app_router.dart – all routes, redirect guard, errorBuilder',
      'lib/main.dart – MaterialApp.router',
      'lib/features/demos/router_demo.dart – try every kind of navigation',
    ],
    quiz: [
      QuizQuestion(
        'You open "Add pet" and want it to return true when saved. Which call?',
        ['context.go', 'context.push', 'context.replace'],
        1,
        'push returns a Future that completes with the value given to pop().',
      ),
      QuizQuestion(
        'In /pets?status=sold, how do you read "sold"?',
        [
          'state.pathParameters[\'status\']',
          'state.uri.queryParameters[\'status\']',
          'state.extra',
        ],
        1,
        'Things after ? are query parameters.',
      ),
      QuizQuestion(
        'What should redirect return to ALLOW the navigation?',
        ['true', 'null', 'The same path'],
        1,
        'null means "no redirect".',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────── OPENAPI ──
  Lesson(
    topic: Topic.openapi,
    title: 'OpenAPI',
    icon: Icons.description_outlined,
    color: Colors.green,
    oneLiner:
        'A standard file format (YAML/JSON) that describes a REST API: every '
        'URL, parameter, request body, response and data model.',
    analogy:
        'OpenAPI is the restaurant menu. It lists every dish (endpoint), what '
        'you must tell the waiter (parameters), and exactly what arrives on '
        'the plate (response schema). Backend and frontend both read the same '
        'menu, so nobody has to guess.',
    sections: [
      LessonSection(
        'Why it matters for a Flutter dev',
        'Without a spec you read backend code or ask on Slack "what does '
            '/pets return?". With a spec you have exact, machine-readable '
            'documentation, and you can GENERATE your Dart models and API '
            'client from it instead of typing them by hand.',
      ),
      LessonSection(
        'Anatomy of a spec',
        'Top-level keys you will see in every OpenAPI 3 file:',
        code: '''openapi: 3.0.3                 # spec version
info:                          # title, version, description
  title: Petstore
  version: 1.0.0
servers:                       # base URL(s)  -> Dio baseUrl
  - url: https://petstore3.swagger.io/api/v3
paths:                         # the endpoints
  /pet/{petId}:
    get: ...
components:
  schemas:                     # data models  -> Freezed classes
    Pet: ...''',
      ),
      LessonSection(
        'An endpoint (path + operation)',
        '`parameters` say where each input goes: in: path, query, header or '
            'cookie. `requestBody` is the JSON you send. `responses` are keyed '
            'by status code. `operationId` becomes the method name in generated '
            'code; `tags` group endpoints into clients.',
        code: '''paths:
  /pet/{petId}:
    get:
      tags: [pet]
      operationId: getPetById
      parameters:
        - name: petId
          in: path
          required: true
          schema: { type: integer, format: int64 }
      responses:
        '200':
          description: The pet
          content:
            application/json:
              schema:
                \$ref: '#/components/schemas/Pet'
        '404':
          description: Pet not found''',
      ),
      LessonSection(
        'Schemas (data models)',
        'Schemas use JSON Schema. `\$ref` points to a reusable schema. Fields in '
            '`required` become non-nullable in Dart; the rest become nullable (?).',
        code: '''components:
  schemas:
    Pet:
      type: object
      required: [name]
      properties:
        id:       { type: integer, format: int64 }   # int?
        name:     { type: string }                   # String
        status:   { \$ref: '#/components/schemas/PetStatus' }
        photoUrls:
          type: array
          items: { type: string }                    # List<String>?
    PetStatus:
      type: string
      enum: [available, pending, sold]               # enum PetStatus''',
      ),
      LessonSection(
        'Type mapping cheat-sheet',
        'string → String\n'
            'integer → int\n'
            'number → double / num\n'
            'boolean → bool\n'
            'array + items → List<T>\n'
            'object + properties → a class\n'
            'object + additionalProperties → Map<String, T>\n'
            'string + enum → enum\n'
            'string + format: date-time → DateTime',
      ),
    ],
    mistakes: [
      'Confusing OpenAPI (the format) with Swagger (the tools). See next lesson.',
      'Hand-editing generated code instead of fixing the spec and regenerating.',
      'Specs that mark everything required while the server sends nulls → '
          'JSON parse crashes. (That\'s why our spec only requires `name`.)',
    ],
    filesInThisApp: [
      'openapi/petstore.yaml – the spec, heavily commented. READ THIS FILE.',
    ],
    quiz: [
      QuizQuestion(
        'In a spec, where are reusable data models defined?',
        ['paths', 'components/schemas', 'servers'],
        1,
        'Schemas are referenced elsewhere with \$ref.',
      ),
      QuizQuestion(
        'A parameter with `in: query` named status ends up as…',
        ['/pet/status', '?status=value', 'a JSON body'],
        1,
        'Query parameters go after the ? in the URL.',
      ),
      QuizQuestion(
        'A property NOT listed under `required` becomes in Dart…',
        ['non-nullable', 'nullable (Type?)', 'it is skipped'],
        1,
        'Not required = may be missing = nullable.',
      ),
    ],
  ),

  // ───────────────────────────────────────────────────────────── SWAGGER ──
  Lesson(
    topic: Topic.swagger,
    title: 'Swagger & codegen',
    icon: Icons.auto_awesome,
    color: Colors.pink,
    oneLiner:
        'Swagger is the family of tools around OpenAPI: Swagger UI (interactive '
        'docs), Swagger Editor, and code generators. In Flutter we use a '
        'generator to turn the spec into Dio + Freezed code.',
    analogy:
        'If OpenAPI is the menu, Swagger UI is the menu printed nicely with a '
        '"try it" button next to every dish, and the code generator is a robot '
        'that reads the menu and writes your ordering app for you.',
    sections: [
      LessonSection(
        'OpenAPI vs Swagger – the history',
        'The spec was originally called "Swagger" (Swagger 2.0, 2014). In 2016 '
            'it was donated to the Linux Foundation and renamed OpenAPI (3.0, '
            '3.1). SmartBear kept the "Swagger" brand for its tools. So today:\n\n'
            '• OpenAPI = the specification (the file).\n'
            '• Swagger = tools that read/write that file.\n\n'
            'People still say "the swagger" or "swagger.json" when they mean the spec.',
      ),
      LessonSection(
        'Swagger UI',
        'Most backends (Spring, NestJS, FastAPI, .NET…) host an auto-generated '
            'Swagger UI page, usually at /swagger, /docs or /swagger-ui. You can '
            'read every endpoint and press "Try it out" to call it. Ask your '
            'backend team for this link – it is your best friend.\n\n'
            'Open the real one: https://petstore3.swagger.io\n'
            'Paste our openapi/petstore.yaml into https://editor.swagger.io',
      ),
      LessonSection(
        'Code generation pipeline (what this app does)',
        'Step 1: swagger_parser reads the spec and writes Retrofit-style client '
            'interfaces + Freezed models.\n'
            'Step 2: build_runner runs retrofit_generator, freezed and '
            'json_serializable to fill in the implementations.',
        code: '''# swagger_parser.yaml
swagger_parser:
  schema_path: openapi/petstore.yaml   # or schema_url: https://.../openapi.json
  output_directory: lib/api/generated
  json_serializer: freezed
  use_freezed3: true
  root_client_name: PetstoreApi

# then
dart run swagger_parser
dart run build_runner build''',
      ),
      LessonSection(
        'What gets generated',
        'A client per tag, using Retrofit annotations on top of Dio:',
        code: '''@RestApi()
abstract class PetClient {
  factory PetClient(Dio dio, {String? baseUrl}) = _PetClient;

  @GET('/pet/{petId}')
  Future<Pet> getPetById({@Path('petId') required int petId});

  @GET('/pet/findByStatus')
  Future<List<Pet>> findPetsByStatus({
    @Query('status') required PetStatus status,
  });
}

// Using it:
final api = PetstoreApi(dio);
final pet = await api.pet.getPetById(petId: 42); // typed Pet!''',
      ),
      LessonSection(
        'Retrofit in one sentence',
        'Retrofit (package `retrofit`) turns an abstract class with @GET/@POST '
            'annotations into real Dio calls, including JSON → model conversion. '
            'swagger_parser writes those annotated classes for you.',
      ),
      LessonSection(
        'Other generators',
        '• openapi_generator (Dart wrapper around the official Java OpenAPI '
            'Generator; needs Java).\n'
            '• swagger_dart_code_generator (uses chopper or dio).\n'
            '• swagger_parser (used here: pure Dart, supports Freezed).\n'
            'They all follow the same idea: spec in → Dart code out.',
      ),
      LessonSection(
        'The full picture',
        'This is how all six topics connect in a real app:',
        code: '''openapi/petstore.yaml          (OpenAPI spec, viewable in Swagger UI)
        │  dart run swagger_parser
        ▼
lib/api/generated/             (Retrofit clients + Freezed models)
        │  dart run build_runner build
        ▼
PetstoreApi(dio)               (Dio does the HTTP, interceptors add auth/logs)
        │  wrapped in
        ▼
petsByStatusProvider           (Riverpod: caching, loading/error)
        │  ref.watch
        ▼
PetListScreen at /pets         (GoRouter: URL navigation)''',
      ),
    ],
    mistakes: [
      'Editing generated files – changes are lost on the next generation.',
      'Generating from a stale spec – re-download the spec when the backend changes.',
      'Committing a spec URL that needs VPN/auth – CI can\'t fetch it. Commit the file.',
    ],
    filesInThisApp: [
      'swagger_parser.yaml – generator config',
      'lib/api/generated/ – generated output (do not edit)',
      'lib/core/petstore_providers.dart – where generated client meets Riverpod',
    ],
    quiz: [
      QuizQuestion(
        'Which is the SPECIFICATION and which are the TOOLS?',
        [
          'Swagger = spec, OpenAPI = tools',
          'OpenAPI = spec, Swagger = tools',
          'They are unrelated',
        ],
        1,
        'Swagger 2.0 was renamed OpenAPI 3; "Swagger" lives on as tool names.',
      ),
      QuizQuestion(
        'You changed the spec. What do you run?',
        [
          'Only flutter pub get',
          'swagger_parser, then build_runner',
          'Nothing, it updates automatically',
        ],
        1,
        'First regenerate the clients/models, then their .g/.freezed parts.',
      ),
      QuizQuestion(
        'The generated client uses which HTTP library underneath?',
        ['http', 'Dio', 'HttpClient'],
        1,
        'Retrofit for Dart is built on Dio – so your interceptors still apply.',
      ),
    ],
  ),
];
