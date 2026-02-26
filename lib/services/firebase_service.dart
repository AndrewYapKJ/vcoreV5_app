import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCLzrJyfmQplWpy8tMcu4VT5fvc_jhDaao',
    appId: '1:430652937649:android:43964176520022105cd990',
    messagingSenderId: '143084427573',
    projectId: 'vcorev5',
    storageBucket: 'vcorev5.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCv8KYB6n28ujNFTHlLjmciSLUpIbYZSkc',
    appId: '1:430652937649:ios:41e17b3a661d95ac5cd990',
    messagingSenderId: '143084427573',
    projectId: 'vcorev5',
    storageBucket: 'vcorev5.firebasestorage.app',
    iosBundleId: 'com.gis.vcorev5',
  );
}
