// Manually generated Firebase Options (Workaround for missing Firebase CLI)
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can add them by running flutterfire configure',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can add them by running flutterfire configure',
        );
      case TargetPlatform.windows:
        // Windows Desktop can usually work with Web config for Firebase JS bridge or specific plugins
        return web; 
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for linux.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // 🌐 WEB / CHROME / WINDOWS CONFIG
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCm0NVoEKaocpQCv4fdHnHhODC800yUnMo',
    appId: '1:513829091101:web:84941266f97e8b823993f4',
    messagingSenderId: '513829091101',
    projectId: 'sorbi-56227',
    authDomain: 'sorbi-56227.firebaseapp.com',
    storageBucket: 'sorbi-56227.firebasestorage.app',
    measurementId: 'G-PN97TGEVYL',
  );

  // 🤖 ANDROID CONFIG
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCTt7cp7PF2WNwP52VezuP8asI2QHhaqnA',
    appId: '1:513829091101:android:c31722e4c153a6723993f4',
    messagingSenderId: '513829091101',
    projectId: 'sorbi-56227',
    storageBucket: 'sorbi-56227.firebasestorage.app',
  );
}
