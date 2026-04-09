// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';

// /// 웹/윈도우 빌드 테스트를 위해 임시로 주석 처리해 둔 FCM 서비스 뼈대 코드입니다.
// /// (firebase_messaging_web 플러그인 에러 방지)
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();
//   print("Handling a background message: ${message.messageId}");
// }

// class FCMService {
//   static final FCMService _instance = FCMService._internal();
//   factory FCMService() => _instance;
//   FCMService._internal();

//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

//   Future<void> initialize() async {
//     FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
//     NotificationSettings settings = await _firebaseMessaging.requestPermission();
//     print('User granted permission: ${settings.authorizationStatus}');
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {});
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {});
//   }

//   Future<String?> getToken() async {
//     return await _firebaseMessaging.getToken();
//   }
// }
