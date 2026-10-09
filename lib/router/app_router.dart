import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/auth.dart';
import '../features/learn/home_screen.dart';
import '../features/learn/lesson_screen.dart';
import '../features/learn/lessons.dart';
import '../features/pets/add_pet_screen.dart';
import '../features/pets/pet_detail_screen.dart';
import '../features/pets/pet_list_screen.dart';

/// GO_ROUTER: all screens are declared here, as a tree of URL paths.
///
///   /                     HomeScreen
///   /lesson/:topic        LessonScreen         (path parameter)
///   /pets?status=sold     PetListScreen        (query parameter)
///   /pets/new             AddPetScreen
///   /pets/:id             PetDetailScreen      (nested + path parameter)
///   /secret               SecretScreen         (protected by `redirect`)
///   /login?from=/secret   LoginScreen
///
/// The router lives in a Riverpod provider so its `redirect` can read
/// other providers (here: the login state).
final routerProvider = Provider<GoRouter>((ref) {
  // GoRouter re-runs `redirect` whenever this Listenable fires.
  // We bridge Riverpod -> Listenable: when login state changes, notify.
  final authChanged = ValueNotifier(0);
  ref.listen(isLoggedInProvider, (_, _) => authChanged.value++);
  ref.onDispose(authChanged.dispose);

  final router = GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true, // prints route changes to the console
    refreshListenable: authChanged,

    // Runs before EVERY navigation. Return a new location to redirect,
    // or null to let the navigation through.
    redirect: (context, state) {
      final loggedIn = ref.read(isLoggedInProvider);
      final goingToSecret = state.matchedLocation == '/secret';
      if (goingToSecret && !loggedIn) {
        return Uri(
          path: '/login',
          queryParameters: {'from': state.matchedLocation},
        ).toString();
      }
      return null;
    },

    routes: [
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
        routes: [
          // Child routes are relative: this is "/lesson/:topic".
          GoRoute(
            path: 'lesson/:topic',
            name: 'lesson',
            // Route-level redirect: unknown topics go back home.
            redirect: (context, state) =>
                Topic.values.asNameMap()[state.pathParameters['topic']] == null
                ? '/'
                : null,
            builder: (context, state) {
              final topic = Topic.values.byName(state.pathParameters['topic']!);
              return LessonScreen(topic: topic);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/pets',
        name: 'pets',
        builder: (context, state) =>
            PetListScreen(initialStatus: state.uri.queryParameters['status']),
        routes: [
          // Declared BEFORE ':id' so "new" isn't parsed as an id.
          GoRoute(
            path: 'new',
            name: 'addPet',
            builder: (context, state) => const AddPetScreen(),
          ),
          GoRoute(
            path: ':id',
            name: 'petDetail',
            builder: (context, state) {
              final id = int.tryParse(state.pathParameters['id']!) ?? -1;
              return PetDetailScreen(petId: id);
            },
          ),
        ],
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) =>
            LoginScreen(from: state.uri.queryParameters['from']),
      ),
      GoRoute(
        path: '/secret',
        builder: (context, state) => const SecretScreen(),
      ),
    ],

    // Shown for unknown URLs, e.g. context.go('/does-not-exist').
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('404')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('No route for "${state.uri}"'),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.go('/'),
              child: const Text('Go home'),
            ),
          ],
        ),
      ),
    ),
  );

  ref.onDispose(router.dispose);
  return router;
});
