import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rasoi_app/firebase_options.dart';
import 'package:rasoi_app/providers/cart_provider.dart';
import 'package:rasoi_app/screens/main_screen.dart';
// import 'package:rasoi_app/services/firestore_service.dart'; // Removed as unused
import 'package:rasoi_app/screens/auth_screen.dart'; // Import AuthScreen
import 'package:rasoi_app/providers/theme_provider.dart'; // Import ThemeProvider

// final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
  // const InitializationSettings initializationSettings = InitializationSettings(
  //   android: initializationSettingsAndroid,
  // );
  // await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget { // Change to StatefulWidget
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // final FirestoreService _firestoreService = FirestoreService(); // Removed as unused
  // String? _lastNotificationId; // Removed as unused

  @override
  void initState() {
    super.initState();
    // _setupNotificationListener(); // This method is no longer needed as local notifications are removed
  }

  // void _setupNotificationListener() { // This method is no longer needed as local notifications are removed
  //   FirebaseAuth.instance.authStateChanges().listen((user) {
  //     if (user != null) {
  //       _firestoreService.getAdminNotifications(user.uid).listen((notifications) {
  //         if (notifications.isNotEmpty) {
  //           final latestNotification = notifications.first; // Notifications are ordered by timestamp descending
  //           if (_lastNotificationId != latestNotification.id) {
  //             _showNotification(latestNotification);
  //             _lastNotificationId = latestNotification.id;
  //           }
  //         }
  //       });
  //     }
  //   });
  // }

  // Future<void> _showNotification(AppNotification notification) async { // This method is no longer needed as local notifications are removed
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics = AndroidNotificationDetails(
  //     'admin_messages', 'Admin Messages', // id and name for the channel
  //     channelDescription: 'Notifications from admin',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );
  //   const NotificationDetails platformChannelSpecifics = NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //     0, // Notification ID
  //     notification.title,
  //     notification.message,
  //     platformChannelSpecifics,
  //     payload: notification.id,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => CartProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>( // Use Consumer to rebuild when theme changes
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'Rasoi Xpress',
            theme: ThemeData(
              primarySwatch: Colors.deepOrange,
              brightness: Brightness.light,
            ),
            darkTheme: ThemeData(
              primarySwatch: Colors.deepOrange,
              brightness: Brightness.dark,
            ),
            themeMode: themeProvider.themeMode, // Use themeMode from ThemeProvider
            home: StreamBuilder(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (ctx, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasData) {
                  return const MainScreen();
                }
                return const AuthScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
