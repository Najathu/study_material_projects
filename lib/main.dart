import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router/app_router.dart';

void main() {
  runApp(
    // RIVERPOD: ProviderScope stores the state of every provider.
    // It must wrap the whole app.
    ProviderScope(
      // Riverpod 3 retries failed providers automatically. We turn that off
      // so errors (like a 404 in the Dio demo) show up immediately.
      retry: (retryCount, error) => null,
      child: const StudyApp(),
    ),
  );
}

class StudyApp extends ConsumerWidget {
  const StudyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // GO_ROUTER: MaterialApp.router hands navigation over to GoRouter.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Flutter Stack Academy',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
    );
  }
}
