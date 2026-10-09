import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../shared/widgets.dart';
import '../auth/auth.dart';

class RouterDemo extends ConsumerWidget {
  const RouterDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).uri.toString();
    final loggedIn = ref.watch(isLoggedInProvider);

    return Column(
      children: [
        DemoCard(
          title: 'Where am I?',
          subtitle: 'GoRouterState.of(context).uri',
          children: [CodeBlock(location)],
        ),
        DemoCard(
          title: '1 · go vs push',
          subtitle:
              'Try both, then press the back arrow. go() rebuilds the stack from '
              'the URL (back → /pets). push() stacks on top (back → here).',
          children: [
            _NavButton(
              code: "context.go('/pets?status=sold')",
              onPressed: () => context.go('/pets?status=sold'),
            ),
            _NavButton(
              code: "context.push('/pets?status=sold')",
              onPressed: () => context.push('/pets?status=sold'),
            ),
          ],
        ),
        DemoCard(
          title: '2 · Path & query parameters, named routes',
          children: [
            _NavButton(
              code: "context.push('/pets/10')   // :id = 10",
              onPressed: () => context.push('/pets/10'),
            ),
            _NavButton(
              code:
                  "context.pushNamed('pets',\n"
                  "    queryParameters: {'status': 'pending'})",
              onPressed: () => context.pushNamed(
                'pets',
                queryParameters: {'status': 'pending'},
              ),
            ),
            _NavButton(
              code:
                  "context.goNamed('lesson',\n"
                  "    pathParameters: {'topic': 'freezed'})",
              onPressed: () => context.goNamed(
                'lesson',
                pathParameters: {'topic': 'freezed'},
              ),
            ),
          ],
        ),
        DemoCard(
          title: '3 · push and wait for a result',
          subtitle:
              'The Add Pet screen calls context.pop(createdPet). '
              'push returns a Future with that value.',
          children: [
            _NavButton(
              code:
                  "final pet = await context.push<Object?>('/pets/new');\n"
                  'showSnackBar(pet)',
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final result = await context.push<Object?>('/pets/new');
                messenger.showSnackBar(
                  SnackBar(content: Text('push() returned: $result')),
                );
              },
            ),
          ],
        ),
        DemoCard(
          title: '4 · Redirect guard',
          subtitle:
              'You are ${loggedIn ? 'LOGGED IN' : 'LOGGED OUT'}. '
              '/secret is protected by `redirect` in app_router.dart.',
          children: [
            _NavButton(
              code: "context.push('/secret')",
              onPressed: () => context.push('/secret'),
            ),
            if (loggedIn)
              TextButton(
                onPressed: () => ref.read(isLoggedInProvider.notifier).logOut(),
                child: const Text('Log out'),
              ),
          ],
        ),
        DemoCard(
          title: '5 · Unknown route',
          children: [
            _NavButton(
              code: "context.go('/this/does/not/exist')",
              onPressed: () => context.go('/this/does/not/exist'),
            ),
          ],
        ),
      ],
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.code, required this.onPressed});

  final String code;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.all(12),
        ),
        onPressed: onPressed,
        child: Row(
          children: [
            Expanded(
              child: Text(
                code,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12.5),
              ),
            ),
            const Icon(Icons.play_arrow),
          ],
        ),
      ),
    );
  }
}
