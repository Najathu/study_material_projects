import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// A fake login state used to demonstrate GoRouter's `redirect` guard.
class AuthNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void logIn() => state = true;
  void logOut() => state = false;
}

final isLoggedInProvider = NotifierProvider<AuthNotifier, bool>(
  AuthNotifier.new,
);

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key, this.from});

  /// Where the user was trying to go before the guard sent them here.
  final String? from;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login (fake)')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 64),
              const SizedBox(height: 16),
              Text(
                from == null
                    ? 'You are logged out.'
                    : 'GoRouter redirected you here because "$from" '
                          'requires login.\nThe original path was passed as '
                          'the query parameter ?from=$from',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.login),
                label: const Text('Log in'),
                onPressed: () {
                  ref.read(isLoggedInProvider.notifier).logIn();
                  // The router's redirect also re-runs when login changes,
                  // but navigating explicitly makes the flow obvious.
                  context.go(from ?? '/');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SecretScreen extends ConsumerWidget {
  const SecretScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Secret area')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.verified_user, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            const Text('You passed the redirect guard 🎉'),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => ref.read(isLoggedInProvider.notifier).logOut(),
              child: const Text('Log out (watch the guard kick you out)'),
            ),
          ],
        ),
      ),
    );
  }
}
