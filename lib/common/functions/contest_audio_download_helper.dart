import 'dart:io';

import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shortzz/common/extensions/string_extension.dart';

class ContestAudioDownloadHelper {
  ContestAudioDownloadHelper._();

  static Future<String?> downloadAndSave({
    required String audioUrl,
    required String fileBaseName,
    String? localSourcePath,
  }) async {
    final sourceFile = await _resolveSourceFile(
      audioUrl: audioUrl,
      localSourcePath: localSourcePath,
    );
    final fileName = _buildFileName(
      baseName: fileBaseName,
      sourcePath: sourceFile.path,
      audioUrl: audioUrl,
    );
    return _saveToBestLocation(sourceFile, fileName);
  }

  static Future<File> _resolveSourceFile({
    required String audioUrl,
    String? localSourcePath,
  }) async {
    final local = localSourcePath?.trim() ?? '';
    if (local.isNotEmpty) {
      final file = File(local);
      if (await file.exists()) return file;
    }

    final url = audioUrl.trim();
    if (url.isEmpty) {
      throw Exception('Contest audio not available');
    }

    // Already a local file path
    if (!url.startsWith('http') && await File(url).exists()) {
      return File(url);
    }

    final fullUrl = url.startsWith('http') ? url : url.addBaseURL();
    return DefaultCacheManager().getSingleFile(fullUrl);
  }

  static String _buildFileName({
    required String baseName,
    required String sourcePath,
    required String audioUrl,
  }) {
    var safeName = baseName
        .trim()
        .replaceAll(RegExp(r'[^\w\s\-.]'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_');
    if (safeName.isEmpty || safeName == '_' || safeName == '.') {
      safeName = 'contest_song';
    }
    if (safeName.length > 60) {
      safeName = safeName.substring(0, 60);
    }
    return '$safeName${_audioExtension(audioUrl, sourcePath)}';
  }

  static String _audioExtension(String url, String localPath) {
    final fromPath = localPath.contains('.')
        ? '.${localPath.split('.').last.split('?').first}'
        : '';
    if (fromPath.length <= 5 &&
        RegExp(r'^\.(mp3|m4a|aac|wav|ogg)$', caseSensitive: false)
            .hasMatch(fromPath)) {
      return fromPath.toLowerCase();
    }
    final uriPath = Uri.tryParse(url)?.path ?? '';
    if (uriPath.contains('.')) {
      final ext = '.${uriPath.split('.').last}';
      if (RegExp(r'^\.(mp3|m4a|aac|wav|ogg)$', caseSensitive: false)
          .hasMatch(ext)) {
        return ext.toLowerCase();
      }
    }
    return '.mp3';
  }

  static Future<void> _requestStorageIfNeeded() async {
    if (!Platform.isAndroid) return;
    try {
      final status = await Permission.storage.status;
      if (status.isDenied || status.isRestricted) {
        await Permission.storage.request();
      }
    } catch (_) {}
  }

  /// Tries public Downloads first, then always-writable app folders.
  static Future<String?> _saveToBestLocation(
      File source, String fileName) async {
    await _requestStorageIfNeeded();

    final candidates = <Directory?>[];

    if (Platform.isAndroid) {
      candidates.add(Directory('/storage/emulated/0/Download'));
      candidates.add(Directory('/storage/emulated/0/Music'));

      final external = await getExternalStorageDirectory();
      if (external != null) {
        candidates.add(Directory('${external.path}/Download'));
        candidates.add(Directory('${external.path}/Music'));
        candidates.add(external);
      }
    } else {
      final downloads = await getDownloadsDirectory();
      if (downloads != null) candidates.add(downloads);
    }

    candidates.add(await getApplicationDocumentsDirectory());
    candidates.add(await getTemporaryDirectory());

    for (final directory in candidates) {
      if (directory == null) continue;
      try {
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
        final destination =
            File('${directory.path}${Platform.pathSeparator}$fileName');
        if (await destination.exists()) {
          await destination.delete();
        }
        await source.copy(destination.path);
        if (await destination.exists() && await destination.length() > 0) {
          return destination.path;
        }
      } catch (_) {
        continue;
      }
    }
    return null;
  }
}
