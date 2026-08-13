import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;
import 'package:my_finance/utils/exceptions/exceptions.dart';

class FirebaseEnvOptions {
  static const String _webApiKey = String.fromEnvironment(
    'FIREBASE_WEB_API_KEY',
  );
  static const String _webAppId = String.fromEnvironment('FIREBASE_WEB_APP_ID');
  static const String _webMessagingSenderId = String.fromEnvironment(
    'FIREBASE_WEB_MESSAGING_SENDER_ID',
  );
  static const String _webProjectId = String.fromEnvironment(
    'FIREBASE_WEB_PROJECT_ID',
  );
  static const String _webAuthDomain = String.fromEnvironment(
    'FIREBASE_WEB_AUTH_DOMAIN',
  );
  static const String _webStorageBucket = String.fromEnvironment(
    'FIREBASE_WEB_STORAGE_BUCKET',
  );
  static const String _webMeasurementId = String.fromEnvironment(
    'FIREBASE_WEB_MEASUREMENT_ID',
  );

  static const String _androidApiKey = String.fromEnvironment(
    'FIREBASE_ANDROID_API_KEY',
  );
  static const String _androidAppId = String.fromEnvironment(
    'FIREBASE_ANDROID_APP_ID',
  );
  static const String _androidMessagingSenderId = String.fromEnvironment(
    'FIREBASE_ANDROID_MESSAGING_SENDER_ID',
  );
  static const String _androidProjectId = String.fromEnvironment(
    'FIREBASE_ANDROID_PROJECT_ID',
  );
  static const String _androidStorageBucket = String.fromEnvironment(
    'FIREBASE_ANDROID_STORAGE_BUCKET',
  );

  static const String _iosApiKey = String.fromEnvironment(
    'FIREBASE_IOS_API_KEY',
  );
  static const String _iosAppId = String.fromEnvironment('FIREBASE_IOS_APP_ID');
  static const String _iosMessagingSenderId = String.fromEnvironment(
    'FIREBASE_IOS_MESSAGING_SENDER_ID',
  );
  static const String _iosProjectId = String.fromEnvironment(
    'FIREBASE_IOS_PROJECT_ID',
  );
  static const String _iosStorageBucket = String.fromEnvironment(
    'FIREBASE_IOS_STORAGE_BUCKET',
  );
  static const String _iosBundleId = String.fromEnvironment(
    'FIREBASE_IOS_BUNDLE_ID',
  );

  static const String _macosApiKey = String.fromEnvironment(
    'FIREBASE_MACOS_API_KEY',
  );
  static const String _macosAppId = String.fromEnvironment(
    'FIREBASE_MACOS_APP_ID',
  );
  static const String _macosMessagingSenderId = String.fromEnvironment(
    'FIREBASE_MACOS_MESSAGING_SENDER_ID',
  );
  static const String _macosProjectId = String.fromEnvironment(
    'FIREBASE_MACOS_PROJECT_ID',
  );
  static const String _macosStorageBucket = String.fromEnvironment(
    'FIREBASE_MACOS_STORAGE_BUCKET',
  );
  static const String _macosBundleId = String.fromEnvironment(
    'FIREBASE_MACOS_BUNDLE_ID',
  );

  static const String _windowsApiKey = String.fromEnvironment(
    'FIREBASE_WINDOWS_API_KEY',
  );
  static const String _windowsAppId = String.fromEnvironment(
    'FIREBASE_WINDOWS_APP_ID',
  );
  static const String _windowsMessagingSenderId = String.fromEnvironment(
    'FIREBASE_WINDOWS_MESSAGING_SENDER_ID',
  );
  static const String _windowsProjectId = String.fromEnvironment(
    'FIREBASE_WINDOWS_PROJECT_ID',
  );
  static const String _windowsAuthDomain = String.fromEnvironment(
    'FIREBASE_WINDOWS_AUTH_DOMAIN',
  );
  static const String _windowsStorageBucket = String.fromEnvironment(
    'FIREBASE_WINDOWS_STORAGE_BUCKET',
  );
  static const String _windowsMeasurementId = String.fromEnvironment(
    'FIREBASE_WINDOWS_MEASUREMENT_ID',
  );

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw InitializationException(
          'Firebase options nao configuradas para Linux por ambiente.',
          origin: 'FirebaseEnvOptions',
        );
      default:
        throw InitializationException(
          'Plataforma nao suportada para Firebase.',
          origin: 'FirebaseEnvOptions',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: _webApiKey,
    appId: _webAppId,
    messagingSenderId: _webMessagingSenderId,
    projectId: _webProjectId,
    authDomain: _webAuthDomain,
    storageBucket: _webStorageBucket,
    measurementId: _webMeasurementId,
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: _androidApiKey,
    appId: _androidAppId,
    messagingSenderId: _androidMessagingSenderId,
    projectId: _androidProjectId,
    storageBucket: _androidStorageBucket,
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: _iosApiKey,
    appId: _iosAppId,
    messagingSenderId: _iosMessagingSenderId,
    projectId: _iosProjectId,
    storageBucket: _iosStorageBucket,
    iosBundleId: _iosBundleId,
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: _macosApiKey,
    appId: _macosAppId,
    messagingSenderId: _macosMessagingSenderId,
    projectId: _macosProjectId,
    storageBucket: _macosStorageBucket,
    iosBundleId: _macosBundleId,
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: _windowsApiKey,
    appId: _windowsAppId,
    messagingSenderId: _windowsMessagingSenderId,
    projectId: _windowsProjectId,
    authDomain: _windowsAuthDomain,
    storageBucket: _windowsStorageBucket,
    measurementId: _windowsMeasurementId,
  );

  static bool get hasRequiredValues {
    return _hasCore(
          _webApiKey,
          _webAppId,
          _webMessagingSenderId,
          _webProjectId,
        ) &&
        _hasCore(
          _androidApiKey,
          _androidAppId,
          _androidMessagingSenderId,
          _androidProjectId,
        ) &&
        _hasCore(_iosApiKey, _iosAppId, _iosMessagingSenderId, _iosProjectId) &&
        _hasCore(
          _macosApiKey,
          _macosAppId,
          _macosMessagingSenderId,
          _macosProjectId,
        ) &&
        _hasCore(
          _windowsApiKey,
          _windowsAppId,
          _windowsMessagingSenderId,
          _windowsProjectId,
        );
  }

  static bool _hasCore(
    String apiKey,
    String appId,
    String messagingSenderId,
    String projectId,
  ) {
    return apiKey.isNotEmpty &&
        appId.isNotEmpty &&
        messagingSenderId.isNotEmpty &&
        projectId.isNotEmpty;
  }

  static void validateOrThrow() {
    if (!hasRequiredValues) {
      throw InitializationException(
        'Firebase nao configurado. Rode com --dart-define-from-file=env.json.',
        origin: 'FirebaseEnvOptions',
      );
    }
  }
}
