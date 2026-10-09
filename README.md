# Flutter Stack Academy

A study app that teaches **Riverpod, Dio, Freezed, GoRouter, OpenAPI and Swagger**.
It is itself built with all six tools, so the code is the second textbook.

Every lesson in the app has three tabs:

- **Learn** – explanation, analogy, code, common mistakes, files to read
- **Try it** – a live, interactive demo
- **Quiz** – 3 questions; pass all to tick the lesson off on the home screen

The final project, **Pet Store**, uses everything together against the real
public API at https://petstore3.swagger.io.

## Run it

```bash
flutter pub get
flutter run            # pick macOS, iOS simulator, Android or Chrome*
flutter test
```

\* On Chrome the Petstore API may be blocked by CORS; use macOS or a phone/simulator.

Generated files are committed, so it runs right away. After changing a model
or the spec, regenerate:

```bash
dart run swagger_parser      # openapi/petstore.yaml  ->  lib/api/generated/*.dart
dart run build_runner build  # Freezed / json_serializable / Retrofit parts
```

## Suggested study path

| Day | Do this in the app | Then read this code |
|-----|--------------------|---------------------|
| 1 | Lesson 1 Riverpod | `lib/main.dart`, `lib/features/demos/riverpod_demo.dart`, `lib/core/petstore_providers.dart` |
| 2 | Lesson 2 Dio (watch the network inspector) | `lib/core/dio_provider.dart`, `lib/features/demos/dio_demo.dart` |
| 3 | Lesson 3 Freezed | `lib/features/demos/freezed_examples.dart` and its generated `.freezed.dart` |
| 4 | Lesson 4 GoRouter | `lib/router/app_router.dart`, `lib/features/demos/router_demo.dart` |
| 5 | Lessons 5 + 6 OpenAPI & Swagger | `openapi/petstore.yaml`, `swagger_parser.yaml`, `lib/api/generated/` |
| 6 | Pet Store | `lib/features/pets/` and follow one request all the way down |

## How the pieces connect

```
openapi/petstore.yaml          OpenAPI spec (view it in Swagger UI / editor.swagger.io)
        │  dart run swagger_parser
        ▼
lib/api/generated/             Retrofit clients + Freezed models (do not edit)
        │  dart run build_runner build
        ▼
PetstoreApi(dio)               Dio sends HTTP; interceptors add api_key + log requests
        │  wrapped in
        ▼
petsByStatusProvider           Riverpod: caching, AsyncValue loading/error/data
        │  ref.watch
        ▼
PetListScreen  /pets?status=   GoRouter: URL-based navigation & guards
```

## Project layout

```
openapi/petstore.yaml          the API spec (heavily commented)
swagger_parser.yaml            code generator config
lib/
  main.dart                    ProviderScope + MaterialApp.router
  router/app_router.dart       every route, redirect guard, 404 page
  core/
    dio_provider.dart          Dio instance, interceptors, error messages
    network_log.dart           Freezed model + Notifier for the network inspector
    petstore_providers.dart    generated client exposed through Riverpod
  api/generated/               output of swagger_parser + build_runner
  features/
    learn/                     home, lesson screen, lesson content, quiz state
    demos/                     one interactive demo per topic
    pets/                      final project: list, detail, add
    auth/                      fake login used by the GoRouter guard
test/widget_test.dart          unit + widget tests (incl. faking Dio via provider override)
```

## Exercises once you are done

1. Add a `nickname` field to `Pet` in `openapi/petstore.yaml`, regenerate, and show it on the detail screen.
2. Add the `DELETE /pet/{petId}` endpoint to the spec, regenerate, and add a delete button.
3. Write a Dio interceptor that retries a request once on `connectionError`.
4. Turn the pet list into a `StatefulShellRoute` with a bottom bar: *Pets* and *Inventory*.
5. Rewrite `petByIdProvider` using `riverpod_generator` (`@riverpod`).
