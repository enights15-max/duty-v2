import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can retrace this section from the documentation.',
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
    apiKey: 'AIzaSyBtVxUQrIwkhmJsCx1rNuNXdLttgsdIb4I',
    appId: '1:406735731787:android:fbfc7b57d8641fd99221ce',
    messagingSenderId: '406735731787',
    projectId: 'duty-2756b',
    storageBucket: 'duty-2756b.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD5vMNlU7DZM4NgJi_gf9qad1dTn__RLDc',
    appId: '1:406735731787:ios:1bc42d48899a01c09221ce',
    messagingSenderId: '406735731787',
    projectId: 'duty-2756b',
    storageBucket: 'duty-2756b.firebasestorage.app',
    iosBundleId: 'com.duty.monkey',
  );
}
