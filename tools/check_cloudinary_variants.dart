// ignore_for_file: unused_local_variable

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

  final uri = Uri.https(
    'api.cloudinary.com',
    '/v1_1/$cloudName/resources/video/upload',
    {'prefix': 'flutter/videos', 'max_results': '100'},
  );

  final auth = 'Basic ' + base64Encode(utf8.encode('$apiKey:$apiSecret'));
  print('Requesting: $uri');

  final client = HttpClient();
  try {
    final req = await client.getUrl(uri);
    req.headers.set('Authorization', auth);
    final resp = await req.close();
    final body = await resp.transform(utf8.decoder).join();
    if (resp.statusCode != 200) {
      print('Status: ${resp.statusCode}');
      print(body);
      return;
    }
    final mapResp = json.decode(body) as Map<String, dynamic>;
    final resources = (mapResp['resources'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    // Group by base public id (remove trailing resolution parts like _720p, output_720p)
    final Map<String, List<Map<String, dynamic>>> groups = {};
    for (final r in resources) {
      final publicId = (r['public_id'] as String?) ?? '';
      final displayName = (r['display_name'] as String?) ?? '';
      // heuristic: strip a trailing _{digits}p or output_{digits}p or /{id}
      String base = publicId;
      // if publicId contains '/', take the last segment as id
      if (base.contains('/')) base = base.split('/').last;
      base = base.replaceAll(RegExp(r'(_|-)output_?'), '_');
      base = base.replaceAll(RegExp(r'(_|-)output_?\d+p\b'), '');
      base = base.replaceAll(RegExp(r'\d+p\b'), '');
      base = base.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '');
      base = base.trim();
      groups.putIfAbsent(base, () => []).add(r);
    }

    print(
      'Found ${resources.length} resources and ${groups.length} candidate groups',
    );

    bool anyFullSet = false;
    for (final entry in groups.entries) {
      final base = entry.key;
      final rs = entry.value;
      final have = <int>{};
      for (final r in rs) {
        final h = r['height'];
        if (h is int)
          have.add(h);
        else if (h is String) {
          final parsed = int.tryParse(h);
          if (parsed != null) have.add(parsed);
        } else {
          // fallback: try to parse from display_name
          final dn = (r['display_name'] as String?) ?? '';
          final m = RegExp(r'(\d{3,4})p').firstMatch(dn);
          if (m != null) {
            final p = int.tryParse(m.group(1)!);
            if (p != null) have.add(p);
          }
        }
      }
      final required = {1080, 720, 480, 360};
      final diff = required.difference(have);
      if (diff.isEmpty) {
        anyFullSet = true;
        print('Group $base has all qualities: ${have.toList()}');
        print('  Members:');
        for (final r in rs) {
          print(
            '   - ${r['public_id']} (${r['width']}x${r['height']}) -> ${r['secure_url']}',
          );
        }
        break;
      }
    }

    if (!anyFullSet) {
      print('No group contained all 1080/720/480/360 variants.');
      // show a candidate summary
      for (final entry in groups.entries) {
        final base = entry.key;
        final rs = entry.value;
        final have = rs.map((r) => r['height']).toSet();
        print('Group $base -> heights: $have');
      }
    }
  } catch (e, st) {
    print('Request failed: $e');
    print(st);
  } finally {
    client.close();
  }
}
