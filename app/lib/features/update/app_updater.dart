import 'dart:async';

import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// Information about a newer build published by the team.
class AppUpdate {
  const AppUpdate({
    required this.latestBuild,
    required this.latestName,
    required this.apkUrl,
    required this.notesBn,
    required this.notesEn,
    required this.mandatory,
  });

  final int latestBuild;
  final String latestName;
  final String apkUrl;
  final String notesBn;
  final String notesEn;

  /// The installed build is older than `min_build_code`, so the update can't be skipped
  /// (used for a security fix or a breaking backend change).
  final bool mandatory;

  String notes(String languageCode) => languageCode == 'bn' && notesBn.isNotEmpty ? notesBn : notesEn;
}

/// Checks for a newer APK and opens its download link.
///
/// How "automatic update" works for an APK shared outside the Play Store:
/// 1. `scripts/release.ps1` builds a new APK, uploads it to GitHub Releases,
///    and publishes the new build number to **Firebase Remote Config**.
/// 2. Every installed copy reads Remote Config when it opens (and live, via
///    Remote Config's real-time updates, while it is open).
/// 3. If a newer build exists, Bolo shows an "Update available" card. Tapping
///    Update downloads the new APK, and Android asks the user to install it.
///
/// Android never lets an app replace itself silently, so that last tap
/// ("Install") always stays with the user. Data is kept: it lives in Firebase.
abstract class AppUpdater {
  Future<AppUpdate?> check();

  /// Fires when the team publishes a new build while the app is open.
  Stream<AppUpdate?> get liveUpdates;

  Future<bool> openDownload(AppUpdate update);
}

class RemoteConfigAppUpdater implements AppUpdater {
  RemoteConfigAppUpdater({FirebaseRemoteConfig? config}) : _configOverride = config;

  final FirebaseRemoteConfig? _configOverride;
  FirebaseRemoteConfig get _config => _configOverride ?? FirebaseRemoteConfig.instance;
  bool _ready = false;

  static const defaultApkUrl = 'https://github.com/Ashfaq1306/bolo/releases/latest/download/bolo.apk';

  Future<void> _init() async {
    if (_ready) return;
    await _config.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      // Remote Config caches values; one hour keeps us well inside its free quota.
      minimumFetchInterval: kDebugMode ? Duration.zero : const Duration(hours: 1),
    ));
    await _config.setDefaults(const {
      'latest_build_code': 0,
      'latest_version_name': '',
      'min_build_code': 0,
      'apk_url': defaultApkUrl,
      'update_notes_bn': '',
      'update_notes_en': '',
    });
    _ready = true;
  }

  Future<AppUpdate?> _evaluate() async {
    final info = await PackageInfo.fromPlatform();
    final installed = int.tryParse(info.buildNumber) ?? 0;
    final latest = _config.getInt('latest_build_code');
    if (latest <= installed) return null;
    final url = _config.getString('apk_url');
    final uri = Uri.tryParse(url);
    // Only ever open an https link (never a link that could run something else).
    if (uri == null || uri.scheme != 'https') return null;
    return AppUpdate(
      latestBuild: latest,
      latestName: _config.getString('latest_version_name'),
      apkUrl: url,
      notesBn: _config.getString('update_notes_bn'),
      notesEn: _config.getString('update_notes_en'),
      mandatory: installed < _config.getInt('min_build_code'),
    );
  }

  @override
  Future<AppUpdate?> check() async {
    try {
      await _init();
      await _config.fetchAndActivate();
      return await _evaluate();
    } catch (e) {
      // Offline or Remote Config unavailable: just check again next launch.
      debugPrint('Update check skipped: $e');
      return null;
    }
  }

  @override
  Stream<AppUpdate?> get liveUpdates async* {
    try {
      await _init();
    } catch (_) {
      return;
    }
    await for (final _ in _config.onConfigUpdated.handleError((Object e) => debugPrint('Live config: $e'))) {
      try {
        await _config.activate();
        yield await _evaluate();
      } catch (e) {
        debugPrint('Live update check failed: $e');
      }
    }
  }

  @override
  Future<bool> openDownload(AppUpdate update) =>
      launchUrl(Uri.parse(update.apkUrl), mode: LaunchMode.externalApplication);
}

/// For tests and builds without Firebase.
class NoopAppUpdater implements AppUpdater {
  const NoopAppUpdater();
  @override
  Future<AppUpdate?> check() async => null;
  @override
  Stream<AppUpdate?> get liveUpdates => const Stream.empty();
  @override
  Future<bool> openDownload(AppUpdate update) async => false;
}
