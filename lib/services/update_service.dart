import 'package:flutter/foundation.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdateService {
  static final UpdateService _instance = UpdateService._internal();
  factory UpdateService() => _instance;
  UpdateService._internal();

  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Configuration Remote Config
  Future<void> initialize() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));

      // Valeurs par défaut
      await _remoteConfig.setDefaults({
        'latest_version': '1.0.0',
        'minimum_version': '1.0.0',
        'update_url': 'https://votre-serveur.com/downloads/app-release.apk',
        'force_update': false,
        'update_message': 'Une nouvelle version est disponible !',
        'features': '',
      });

      await _remoteConfig.fetchAndActivate();
      
      if (kDebugMode) {
        debugPrint('✅ Remote Config initialisé');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur Remote Config: $e');
      }
    }
  }

  // Vérifier si une mise à jour est disponible
  Future<UpdateInfo> checkForUpdate() async {
    try {
      // Récupérer la version actuelle de l'app
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Récupérer les infos de mise à jour depuis Remote Config
      await _remoteConfig.fetchAndActivate();
      
      final latestVersion = _remoteConfig.getString('latest_version');
      final minimumVersion = _remoteConfig.getString('minimum_version');
      final updateUrl = _remoteConfig.getString('update_url');
      final forceUpdate = _remoteConfig.getBool('force_update');
      final updateMessage = _remoteConfig.getString('update_message');
      final features = _remoteConfig.getString('features');

      // Comparer les versions
      final isUpdateAvailable = _compareVersions(currentVersion, latestVersion) < 0;
      final isMandatory = _compareVersions(currentVersion, minimumVersion) < 0;

      return UpdateInfo(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        minimumVersion: minimumVersion,
        updateUrl: updateUrl,
        isUpdateAvailable: isUpdateAvailable,
        isMandatory: isMandatory || forceUpdate,
        message: updateMessage,
        features: features.split('\n').where((f) => f.isNotEmpty).toList(),
      );
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur vérification mise à jour: $e');
      }
      return UpdateInfo(
        currentVersion: '1.0.0',
        latestVersion: '1.0.0',
        minimumVersion: '1.0.0',
        updateUrl: '',
        isUpdateAvailable: false,
        isMandatory: false,
        message: '',
        features: [],
      );
    }
  }

  // Comparer deux versions (format: 1.2.3)
  int _compareVersions(String version1, String version2) {
    final v1Parts = version1.split('.').map(int.parse).toList();
    final v2Parts = version2.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      final v1 = i < v1Parts.length ? v1Parts[i] : 0;
      final v2 = i < v2Parts.length ? v2Parts[i] : 0;
      
      if (v1 < v2) return -1;
      if (v1 > v2) return 1;
    }
    
    return 0;
  }

  // Enregistrer la dernière vérification dans Firestore
  Future<void> recordUpdateCheck(String userId) async {
    try {
      await _firestore.collection('update_logs').add({
        'user_id': userId,
        'checked_at': FieldValue.serverTimestamp(),
        'app_version': (await PackageInfo.fromPlatform()).version,
      });
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur enregistrement log: $e');
      }
    }
  }

  // Ouvrir l'URL de téléchargement
  Future<void> openUpdateUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
      } else {
        throw 'Impossible d\'ouvrir l\'URL: $url';
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur ouverture URL: $e');
      }
      rethrow;
    }
  }

  // Envoyer une notification de mise à jour à tous les utilisateurs
  Future<void> notifyAllUsers(String version, String message) async {
    try {
      await _firestore.collection('app_updates').add({
        'version': version,
        'message': message,
        'created_at': FieldValue.serverTimestamp(),
        'notified_users': [],
      });
      
      if (kDebugMode) {
        debugPrint('✅ Notification de mise à jour envoyée');
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('❌ Erreur notification: $e');
      }
    }
  }
}

// Modèle d'information de mise à jour
class UpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String minimumVersion;
  final String updateUrl;
  final bool isUpdateAvailable;
  final bool isMandatory;
  final String message;
  final List<String> features;

  UpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.minimumVersion,
    required this.updateUrl,
    required this.isUpdateAvailable,
    required this.isMandatory,
    required this.message,
    required this.features,
  });

  @override
  String toString() {
    return 'UpdateInfo(current: $currentVersion, latest: $latestVersion, '
           'available: $isUpdateAvailable, mandatory: $isMandatory)';
  }
}
