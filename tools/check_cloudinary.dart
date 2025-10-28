import 'dart:convert';
import 'dart:io';

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

  final apiKey = map['CLOUDINARY_API_KEY'];
  final apiSecret = map['CLOUDINARY_API_SECRET'];
  final cloudName = map['CLOUDINARY_CLOUD_NAME'] ?? 'djipdnpai';
  if (apiKey == null || apiSecret == null) {
    print('CLOUDINARY_API_KEY/SECRET not found in .env');
    return;
  }

  // Include the required 'type' path segment ('upload') to list uploaded resources
  final uri = Uri.https(
    'api.cloudinary.com',
    '/v1_1/$cloudName/resources/video/upload',
    {'prefix': 'flutter/videos', 'max_results': '100'},
  );

  final auth = 'Basic ' + base64Encode(utf8.encode('$apiKey:$apiSecret'));
  print('Requesting: $uri');
  print(
    'Using CLOUDINARY_API_KEY: ${apiKey.substring(0, 4)}...${apiKey.substring(apiKey.length - 4)}',
  );

  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    req.headers.set('Authorization', auth);
    final resp = await req.close();
    final body = await resp.transform(utf8.decoder).join();
    print('Status: ${resp.statusCode}');
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
