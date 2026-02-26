import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'env_service.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;

      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions get android {
    return FirebaseOptions(
      apiKey: EnvService.firebaseApiKey,
      appId: EnvService.firebaseAppId,
      messagingSenderId: EnvService.firebaseMessagingSenderId,
      projectId: EnvService.firebaseProjectId,
      storageBucket: EnvService.firebaseStorageBucket,
    );
  }

  static FirebaseOptions get ios {
    return FirebaseOptions(
      apiKey: EnvService.firebaseApiKey,
      appId: EnvService.firebaseAppId,
      messagingSenderId: EnvService.firebaseMessagingSenderId,
      projectId: EnvService.firebaseProjectId,
      storageBucket: EnvService.firebaseStorageBucket,
      iosBundleId: EnvService.firebaseIosBundleId,
    );
  }
}
