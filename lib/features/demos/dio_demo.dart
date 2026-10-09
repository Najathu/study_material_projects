import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/dio_provider.dart';
import '../../shared/widgets.dart';

/// Calls the Petstore with RAW Dio (no generated client) so you can see
/// exactly what Dio gives you: status codes, headers, decoded JSON, errors.
class DioDemo extends ConsumerStatefulWidget {
  const DioDemo({super.key});

  @override
  ConsumerState<DioDemo> createState() => _DioDemoState();
}

class _DioDemoState extends ConsumerState<DioDemo> {
  String _code = '// Press a button';
  String _result = '';
  bool _busy = false;

  Future<void> _run(
    String code,
    Future<Response<dynamic>> Function(Dio) call,
  ) async {
    setState(() {
      _code = code;
      _busy = true;
      _result = '';
    });
    final dio = ref.read(dioProvider);
    final sw = Stopwatch()..start();
    try {
      final res = await call(dio);
      final body = const JsonEncoder.withIndent('  ').convert(res.data);
      _result =
          '✅ ${res.statusCode} ${res.statusMessage} in ${sw.elapsedMilliseconds} ms\n'
          'content-type: ${res.headers.value('content-type')}\n'
          'request headers sent: ${res.requestOptions.headers}\n\n'
          'response.data (${res.data.runtimeType}):\n'
          '${body.length > 1500 ? '${body.substring(0, 1500)}\n…' : body}';
    } on DioException catch (e) {
      _result =
          '❌ DioException after ${sw.elapsedMilliseconds} ms\n'
          'type: ${e.type}\n'
          'status: ${e.response?.statusCode}\n'
          'body: ${e.response?.data}\n\n'
          'friendly message: ${describeDioError(e)}';
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DemoCard(
          title: 'Send requests',
          subtitle:
              'Every button uses the shared dioProvider, so all requests pass '
              'through our interceptors (api_key header + network log).',
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          "await dio.get('/store/inventory');",
                          (dio) => dio.get('/store/inventory'),
                        ),
                  child: const Text('GET inventory'),
                ),
                FilledButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          "await dio.get('/pet/findByStatus',\n"
                          "    queryParameters: {'status': 'sold'});",
                          (dio) => dio.get(
                            '/pet/findByStatus',
                            queryParameters: {'status': 'sold'},
                          ),
                        ),
                  child: const Text('GET with query'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          "await dio.get('/pet/987654321'); // doesn't exist",
                          (dio) => dio.get('/pet/987654321'),
                        ),
                  child: const Text('404 error'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          "await dio.get('/store/inventory',\n"
                          "    options: Options(receiveTimeout: Duration(milliseconds: 1)));",
                          (dio) => dio.get(
                            '/store/inventory',
                            options: Options(
                              receiveTimeout: const Duration(milliseconds: 1),
                            ),
                          ),
                        ),
                  child: const Text('Timeout'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () {
                          final token = CancelToken();
                          Future.delayed(
                            const Duration(milliseconds: 50),
                            () => token.cancel('user pressed cancel'),
                          );
                          _run(
                            'final token = CancelToken();\n'
                            "dio.get('/store/inventory', cancelToken: token);\n"
                            'token.cancel(); // 50 ms later',
                            (dio) =>
                                dio.get('/store/inventory', cancelToken: token),
                          );
                        },
                  child: const Text('Cancel'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () => _run(
                          "await dio.post('/pet', data: {\n"
                          "  'id': 424242, 'name': 'Study Buddy',\n"
                          "  'status': 'available', 'photoUrls': [],\n"
                          '});',
                          (dio) => dio.post(
                            '/pet',
                            data: {
                              'id': 424242,
                              'name': 'Study Buddy',
                              'status': 'available',
                              'photoUrls': <String>[],
                            },
                          ),
                        ),
                  child: const Text('POST JSON'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CodeBlock(_code),
            if (_busy) const LinearProgressIndicator(),
            if (_result.isNotEmpty) CodeBlock(_result),
          ],
        ),
        const DemoCard(
          title: 'Network inspector (live)',
          subtitle:
              'Written by NetworkLogInterceptor (lib/core/dio_provider.dart) '
              'into a Riverpod Notifier; this widget just watches it.',
          children: [NetworkLogView()],
        ),
      ],
    );
  }
}
