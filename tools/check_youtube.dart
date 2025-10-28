import 'dart:io';
import 'dart:convert';

Future<void> main() async {
  final envFile = File('.env');
  if (!envFile.existsSync()) {
    print('.env not found in workspace root');
    return;
  }
  final lines = envFile.readAsLinesSync();
  final map = <String, String>{};
  for (final l in lines) {
    final line = l.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final idx = line.indexOf('=');
    if (idx <= 0) continue;
    final key = line.substring(0, idx).trim();
    final val = line.substring(idx + 1).trim();
    map[key] = val;
  }

  final apiKey = map['YOUTUBE_API_KEY'];
  if (apiKey == null || apiKey.isEmpty) {
    print('YOUTUBE_API_KEY not found in .env');
    return;
  }

  final uri = Uri.https('www.googleapis.com', '/youtube/v3/videos', {
    'part': 'snippet',
    'chart': 'mostPopular',
    'maxResults': '8',
    'regionCode': 'US',
    'key': apiKey,
  });

  print('Requesting: $uri');

  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    final resp = await req.close();
    final body = await resp.transform(utf8.decoder).join();
    print('Status: ${resp.statusCode}');
    print('Headers:');
    resp.headers.forEach(
      (name, values) => print('  $name: ${values.join(', ')}'),
    );
    print('\nBody:\n$body');
  } catch (e, st) {
    print('Request failed: $e');
    print(st);
  } finally {
    client.close();
  }
}
