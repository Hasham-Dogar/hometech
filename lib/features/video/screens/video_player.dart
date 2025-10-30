import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:ffmpeg_kit_flutter_new/ffmpeg_kit.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:crypto/crypto.dart';

class YouTubeStyleUploader extends StatefulWidget {
  const YouTubeStyleUploader({super.key});

  @override
  State<YouTubeStyleUploader> createState() => _YouTubeStyleUploaderState();
}

class _YouTubeStyleUploaderState extends State<YouTubeStyleUploader> {
  File? _originalVideo;
  bool _isProcessing = false;
  String? _status;
  Map<String, String> _videoUrls = {}; // e.g., {'360p': url, '480p': url}
  String? _selectedQuality;

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  // Cloudinary config — defaults and dotenv override
  static String cloudName = 'djipdnpai';
  static String uploadPreset = 'videos';

  // runtime override from .env (optional)
  void _loadEnv() {
    try {
      final envCloud = dotenv.env['CLOUDINARY_CLOUD_NAME'];
      final envPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'];
      if (envCloud != null && envCloud.isNotEmpty) cloudName = envCloud;
      if (envPreset != null && envPreset.isNotEmpty) uploadPreset = envPreset;
    } catch (_) {}
  }

  // Track playback_url (HLS) when available per quality
  final Map<String, String> _playbackUrls = {};
  bool _include1080 = false;
  // Track thumbnails and per-quality status
  final Map<String, String> _thumbnailUrls = {};
  final Map<String, String> _statusByQuality =
      {}; // 'queued','encoding','uploading','done','failed'

  @override
  void initState() {
    super.initState();
    _loadEnv();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getBool('include1080') ?? false;
      setState(() => _include1080 = val);
    } catch (_) {}
  }

  // Fetch uploaded videos from Cloudinary (requires API key/secret in .env)
  Future<void> fetchUploadedVideos() async {
    final apiKeyRaw = dotenv.env['CLOUDINARY_API_KEY'];
    final apiSecretRaw = dotenv.env['CLOUDINARY_API_SECRET'];
    final apiKey = apiKeyRaw?.trim();
    final apiSecret = apiSecretRaw?.trim();
    if (apiKey == null || apiSecret == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'CLOUDINARY_API_KEY/SECRET not set in .env. Cannot list assets.',
          ),
        ),
      );
      return;
    }

    setState(() => _status = 'Fetching uploaded videos...');
    // Cloudinary Admin API requires the 'type' path segment (e.g. 'upload')
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/resources/video/upload?prefix=flutter/videos&max_results=100',
    );
    final auth = 'Basic ' + base64Encode(utf8.encode('$apiKey:$apiSecret'));
    debugPrint('[VideoUploader] fetchUploadedVideos uri=$uri');
    // show masked key for debugging (don't log full secret)
    String mask(String k) {
      if (k.length <= 8) return k;
      return '${k.substring(0, 4)}...${k.substring(k.length - 4)}';
    }

    debugPrint('[VideoUploader] using CLOUDINARY_API_KEY=${mask(apiKey)}');
    try {
      final resp = await http.get(uri, headers: {'Authorization': auth});
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body) as Map<String, dynamic>;
        final resources = data['resources'] as List<dynamic>? ?? [];
        final Map<String, String> found = {};
        final Map<String, String> foundPlayback = {};
        for (final r in resources) {
          final Map<String, dynamic> res = r as Map<String, dynamic>;
          final publicId = res['public_id'] as String?;
          final secure = res['secure_url'] as String?;
          final playback = res['playback_url'] as String?;
          // Use public_id as key so all videos are shown
          final label =
              publicId ??
              res['asset_id']?.toString() ??
              res['created_at']?.toString() ??
              'video';
          if (secure != null) found[label] = secure;
          if (playback != null) foundPlayback[label] = playback;
        }
        if (found.isNotEmpty) {
          setState(() {
            _videoUrls = found;
            _playbackUrls.clear();
            _playbackUrls.addAll(foundPlayback);
            _selectedQuality = _videoUrls.keys.first;
            _status = 'Fetched ${_videoUrls.length} videos from Cloudinary';
          });
          final preferred =
              _playbackUrls[_selectedQuality] ?? _videoUrls[_selectedQuality]!;
          await _initializePlayer(preferred);
        } else {
          setState(() => _status = 'No videos found in Cloudinary folder');
        }
      } else {
        debugPrint(
          '[VideoUploader] list assets failed: ${resp.statusCode} body=${resp.body}',
        );
        // Try to parse cloudinary error message if present
        String msg = 'Failed to list assets: ${resp.statusCode}';
        try {
          final m = json.decode(resp.body) as Map<String, dynamic>?;
          if (m != null) {
            if (m['error'] is Map && m['error']['message'] != null) {
              msg = 'Cloudinary error: ${m['error']['message']}';
            } else if (m['message'] != null) {
              msg = 'Cloudinary: ${m['message']}';
            } else {
              msg = 'Cloudinary response: ${resp.body}';
            }
          }
        } catch (_) {
          msg = 'Failed to list assets: ${resp.statusCode}';
        }
        setState(() => _status = msg);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e, st) {
      debugPrint('[VideoUploader] fetchUploadedVideos error: $e\n$st');
      setState(() => _status = 'Error fetching videos: ${e.toString()}');
    }
  }

  // Step 1: Pick local video
  Future<void> _pickVideo() async {
    final picker = ImagePicker();
    final picked = await picker.pickVideo(source: ImageSource.gallery);
    if (picked != null) {
      try {
        // Some gallery pickers return content:// URIs which aren't regular files.
        // Copy bytes to a temp file so FFmpeg can access it reliably.
        final bytes = await picked.readAsBytes();
        final dir = await Directory.systemTemp.createTemp('picked_video');
        final tempPath =
            '${dir.path}/picked_${DateTime.now().millisecondsSinceEpoch}.mp4';
        final tempFile = await File(tempPath).writeAsBytes(bytes);
        setState(() {
          _originalVideo = tempFile;
          _status = 'Video selected. Ready to encode.';
        });
      } catch (e, st) {
        debugPrint('[VideoUploader] Failed to copy picked video: $e\n$st');
        setState(() => _status = 'Failed to prepare video: ${e.toString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to prepare video: ${e.toString()}')),
        );
      }
    }
  }

  // Step 2: Encode video using FFmpeg
  Future<File?> _encodeVideo(File input, String label, int height) async {
    final dir = await Directory.systemTemp.createTemp();
    final output = '${dir.path}/output_$label.mp4';
    setState(() => _status = 'Encoding $label...');
    final command =
        '-y -i "${input.path}" -vf scale=-2:$height -c:v libx264 -preset medium -crf 23 -c:a aac "$output"';
    try {
      final session = await FFmpegKit.execute(command);
      // Log return code for debugging
      try {
        final returnCode = await session.getReturnCode();
        debugPrint('[FFmpeg] returnCode for $label: $returnCode');
      } catch (e) {
        debugPrint('[FFmpeg] could not read return code: $e');
      }
    } catch (e, st) {
      debugPrint('[FFmpeg] execute error: $e\n$st');
    }

    final file = File(output);
    if (await file.exists()) return file;
    debugPrint('[VideoUploader] Encoded file not found: $output');
    return null;
  }

  // Step 3: Upload to Cloudinary
  // Upload file to Cloudinary. If `publicId` is provided, try to set it so
  // multiple variants can be uploaded under a predictable id (e.g.
  // flutter/videos/<base>_720p). If Cloudinary rejects the public_id (unsigned
  // preset restrictions), fall back to an unsigned upload without public_id.
  Future<Map<String, String>?> _uploadToCloudinary(
    File file, {
    String? publicId,
    String? displayName,
  }) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/video/upload',
    );

    // Check for API key/secret for signed upload
    final apiKeyRaw = dotenv.env['CLOUDINARY_API_KEY'];
    final apiSecretRaw = dotenv.env['CLOUDINARY_API_SECRET'];
    final apiKey = apiKeyRaw?.trim();
    final apiSecret = apiSecretRaw?.trim();

    // Helper: Generate SHA-1 signature for signed upload
    String? _generateSignature(Map<String, String> params, String apiSecret) {
      final sortedKeys = params.keys.toList()..sort();
      final paramString = sortedKeys.map((k) => '$k=${params[k]}').join('&');
      final toSign = '$paramString$apiSecret';
      // Use Dart's crypto package for SHA-1
      // import 'package:crypto/crypto.dart'; at top of file
      try {
        final bytes = utf8.encode(toSign);
        final digest = sha1.convert(bytes);
        return digest.toString();
      } catch (e) {
        debugPrint('[VideoUploader] Signature generation error: $e');
        return null;
      }
    }

    setState(() => _status = 'Uploading ${file.path.split('/').last}...');

    http.StreamedResponse response;
    try {
      // If API key/secret present, use signed upload
      if (apiKey != null &&
          apiKey.isNotEmpty &&
          apiSecret != null &&
          apiSecret.isNotEmpty) {
        final timestamp = (DateTime.now().millisecondsSinceEpoch ~/ 1000)
            .toString();
        // Params to sign: public_id, timestamp, display_name (if present)
        final paramsToSign = <String, String>{
          'timestamp': timestamp,
          if (publicId != null && publicId.isNotEmpty) 'public_id': publicId,
          if (displayName != null && displayName.isNotEmpty)
            'display_name': displayName,
        };
        final signature = _generateSignature(paramsToSign, apiSecret);
        final request = http.MultipartRequest('POST', url)
          ..fields['api_key'] = apiKey
          ..fields['timestamp'] = timestamp
          ..fields['signature'] = signature ?? ''
          ..files.add(await http.MultipartFile.fromPath('file', file.path));
        if (publicId != null && publicId.isNotEmpty) {
          request.fields['public_id'] = publicId;
        } else {
          request.fields['folder'] = 'flutter/videos';
        }
        if (displayName != null && displayName.isNotEmpty) {
          request.fields['display_name'] = displayName;
        }
        response = await request.send();
        final body = await http.Response.fromStream(response);
        debugPrint(
          '[VideoUploader] signed upload status=${response.statusCode} body=${body.body}',
        );
        if (response.statusCode == 200) {
          final data = json.decode(body.body);
          return {
            if (data['secure_url'] != null)
              'secure_url': data['secure_url'] as String,
            if (data['playback_url'] != null)
              'playback_url': data['playback_url'] as String,
            if (data['public_id'] != null)
              'public_id': data['public_id'] as String,
          };
        } else {
          // Show Cloudinary error message if present
          String msg = 'Upload failed: ${response.statusCode}';
          try {
            final m = json.decode(body.body) as Map<String, dynamic>?;
            if (m != null) {
              if (m['error'] is Map && m['error']['message'] != null) {
                msg = 'Cloudinary error: ${m['error']['message']}';
              } else if (m['message'] != null) {
                msg = 'Cloudinary: ${m['message']}';
              } else {
                msg = 'Cloudinary response: ${body.body}';
              }
            }
          } catch (_) {}
          setState(() => _status = msg);
          debugPrint('[VideoUploader] $msg');
        }
        // If signed upload fails, fall back to unsigned
        debugPrint('[VideoUploader] signed upload failed, will retry unsigned');
      }

      // Unsigned upload (upload_preset only)
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..fields['folder'] = 'flutter/videos'
        ..files.add(await http.MultipartFile.fromPath('file', file.path));
      // DO NOT set public_id or display_name for unsigned upload
      response = await request.send();
      final body = await http.Response.fromStream(response);
      debugPrint(
        '[VideoUploader] unsigned upload status=${response.statusCode} body=${body.body}',
      );
      if (response.statusCode == 200) {
        final data = json.decode(body.body);
        return {
          if (data['secure_url'] != null)
            'secure_url': data['secure_url'] as String,
          if (data['playback_url'] != null)
            'playback_url': data['playback_url'] as String,
          if (data['public_id'] != null)
            'public_id': data['public_id'] as String,
        };
      } else {
        // Show Cloudinary error message if present
        String msg = 'Upload failed: ${response.statusCode}';
        try {
          final m = json.decode(body.body) as Map<String, dynamic>?;
          if (m != null) {
            if (m['error'] is Map && m['error']['message'] != null) {
              msg = 'Cloudinary error: ${m['error']['message']}';
            } else if (m['message'] != null) {
              msg = 'Cloudinary: ${m['message']}';
            } else {
              msg = 'Cloudinary response: ${body.body}';
            }
          }
        } catch (_) {}
        setState(() => _status = msg);
        debugPrint('[VideoUploader] $msg');
      }
      return null;
    } catch (e, st) {
      debugPrint('[VideoUploader] upload error: $e\n$st');
      setState(() => _status = 'Upload failed: ${e.toString()}');
      return null;
    }
  }

  // Step 4: Encode all resolutions
  Future<void> _processAndUpload() async {
    if (_originalVideo == null) return;
    // Quick guard: ensure Cloudinary config is set
    if (cloudName == 'YOUR_CLOUD_NAME' ||
        uploadPreset == 'YOUR_UNSIGNED_UPLOAD_PRESET') {
      setState(() {
        _status = 'Cloudinary not configured. Set cloudName and uploadPreset.';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cloudinary not configured. Please update config.'),
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
      _status = 'Starting processing...';
    });

    final qualities = {'360p': 360, '480p': 480, '720p': 720, '1080p': 1080};
    final Map<String, String> uploaded = {};

    try {
      // Extract original filename (without extension)
      final originalPath = _originalVideo!.path;
      final originalName = originalPath
          .split(Platform.pathSeparator)
          .last
          .split('.')
          .first;

      for (final entry in qualities.entries) {
        final label = entry.key; // e.g. '720p'
        final height = entry.value;
        setState(() => _status = 'Encoding $label');
        debugPrint('[VideoUploader] Encoding $label at ${height}p');
        _statusByQuality[label] = 'encoding';
        final encoded = await _encodeVideo(_originalVideo!, label, height);
        if (encoded == null) {
          debugPrint('[VideoUploader] Encoding failed for $label');
          setState(() => _status = 'Encoding failed for $label');
          _statusByQuality[label] = 'failed';
          continue;
        }

        setState(() => _status = 'Uploading $label');
        _statusByQuality[label] = 'uploading';
        debugPrint('[VideoUploader] Uploading $label: ${encoded.path}');

        // public_id: flutter/videos/{originalName}_{label}
        final publicId =
            'flutter/videos/${originalName}_${label.replaceAll(RegExp(r"[^0-9a-zA-Z]"), '')}';
        final displayName = '${originalName}_${label}';
        final result = await _uploadToCloudinary(
          encoded,
          publicId: publicId,
          displayName: displayName,
        );

        if (result != null) {
          final secure = result['secure_url'];
          final playback = result['playback_url'];
          final publicIdReturned = result['public_id'];
          if (publicIdReturned != null) {
            // construct a simple thumbnail URL (jpg, 320x180)
            _thumbnailUrls[label] =
                'https://res.cloudinary.com/$cloudName/video/upload/w_320,h_180,c_fill/$publicIdReturned.jpg';
          }
          if (secure != null) uploaded[label] = secure;
          if (playback != null) _playbackUrls[label] = playback;
          _statusByQuality[label] = 'done';
          debugPrint(
            '[VideoUploader] Uploaded $label => $secure (playback: $playback)',
          );
        } else {
          debugPrint('[VideoUploader] Upload failed for $label');
          _statusByQuality[label] = 'failed';
        }
      }

      if (uploaded.isNotEmpty) {
        setState(() {
          _videoUrls = uploaded;
          _selectedQuality = uploaded.keys.first;
          _status = 'All versions uploaded successfully!';
        });
        await _initializePlayer(_videoUrls[_selectedQuality]!);
      } else {
        setState(() => _status = 'No videos uploaded.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload failed. Check logs and configuration.'),
          ),
        );
      }
    } catch (e, st) {
      debugPrint('[VideoUploader] Error: $e\n$st');
      setState(() => _status = 'Error: ${e.toString()}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during processing: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  // Step 5: Initialize Chewie video player
  Future<void> _initializePlayer(String url) async {
    _videoController = VideoPlayerController.networkUrl(Uri.parse(url));
    await _videoController!.initialize();
    _chewieController?.dispose();
    _chewieController = ChewieController(
      videoPlayerController: _videoController!,
      autoPlay: true,
      looping: false,
      deviceOrientationsAfterFullScreen: [
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
      deviceOrientationsOnEnterFullScreen: [
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ],
    );
    setState(() {});
  }

  // Step 6: Switch resolution
  Future<void> _switchQuality(String quality) async {
    final url = _videoUrls[quality];
    if (url == null) return;
    setState(() => _selectedQuality = quality);
    await _initializePlayer(url);
  }

  @override
  void dispose() {
    _chewieController?.dispose();
    _videoController?.dispose();
    // Reset orientation to portrait when leaving the page
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Icon(Icons.ondemand_video, color: Colors.redAccent),
            const SizedBox(width: 8),
            const Text('YouTube Player', style: TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final val = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Video Settings'),
                  content: StatefulBuilder(
                    builder: (c, setS) {
                      return Row(
                        children: [
                          const Text('Include 1080p'),
                          const SizedBox(width: 12),
                          Switch(
                            value: _include1080,
                            onChanged: (v) => setS(() => _include1080 = v),
                          ),
                        ],
                      );
                    },
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () async {
                        // persist setting
                        try {
                          final prefs = await SharedPreferences.getInstance();
                          await prefs.setBool('include1080', _include1080);
                        } catch (_) {}
                        Navigator.pop(ctx, true);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
              );
              if (val == true) setState(() {});
            },
          ),
        ],
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (_videoUrls.isNotEmpty && _chewieController != null)
                    Builder(
                      builder: (context) {
                        final screenHeight = MediaQuery.of(context).size.height;
                        final maxHeight = screenHeight * 0.4;
                        final constrainedHeight = maxHeight.clamp(220.0, 400.0);
                        return ConstrainedBox(
                          constraints: BoxConstraints(
                            maxHeight: constrainedHeight,
                          ),
                          child: AspectRatio(
                            aspectRatio:
                                _videoController?.value.aspectRatio ?? 16 / 9,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Chewie(controller: _chewieController!),
                            ),
                          ),
                        );
                      },
                    ),
                  if (_videoUrls.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 400),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _videoUrls.length,
                          itemBuilder: (context, index) {
                            final e = _videoUrls.entries.elementAt(index);
                            final q = e.key;
                            final url = e.value;
                            final playback = _playbackUrls[q];
                            // final thumb = _thumbnailUrls[q]; // reserved for future thumbnail previews
                            final st = _statusByQuality[q] ?? 'idle';
                            // Show error if status is failed
                            final error = st == 'failed'
                                ? 'Error: Upload or encoding failed for $q'
                                : null;
                            return ListTile(
                              leading: const Icon(
                                Icons.videocam,
                                color: Colors.white54,
                                size: 24,
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Quality: $q',
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Chip(
                                    label: Text(
                                      st,
                                      style: const TextStyle(
                                        color: Colors.white,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    backgroundColor: st == 'failed'
                                        ? Colors.red[800]
                                        : Colors.grey[800],
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    constraints: const BoxConstraints(
                                      maxWidth: 180,
                                    ),
                                    child: Text(
                                      url,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                  if (error != null)
                                    Text(
                                      error,
                                      style: const TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (playback != null)
                                    TextButton(
                                      onPressed: () async {
                                        await _initializePlayer(playback);
                                        setState(() => _selectedQuality = q);
                                      },
                                      child: const Text('Play HLS'),
                                    ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.open_in_new,
                                      color: Colors.white70,
                                    ),
                                    onPressed: () async {
                                      await _initializePlayer(url);
                                      setState(() => _selectedQuality = q);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  if (_videoUrls.isNotEmpty && _chewieController != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.hd, color: Colors.white70),
                          const SizedBox(width: 8),
                          Flexible(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                dropdownColor: Colors.grey[900],
                                value: _selectedQuality,
                                style: const TextStyle(color: Colors.white),
                                items: _videoUrls.keys
                                    .map(
                                      (q) => DropdownMenuItem(
                                        value: q,
                                        child: Text('Quality: $q'),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => _switchQuality(v!),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_status != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _status!,
                        style: const TextStyle(
                          color: Colors.blueAccent,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  if (_originalVideo == null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(200, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.video_library),
                        label: const Text('Pick Video from Gallery'),
                        onPressed: _pickVideo,
                      ),
                    ),
                  if (!_isProcessing)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: fetchUploadedVideos,
                            icon: const Icon(Icons.cloud),
                            label: const Text('Fetch uploaded videos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[850],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (_originalVideo != null && !_isProcessing)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(200, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.cloud_upload),
                        label: const Text('Encode & Upload'),
                        onPressed: _processAndUpload,
                      ),
                    ),
                  if (_isProcessing)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: CircularProgressIndicator(color: Colors.redAccent),
                    ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
