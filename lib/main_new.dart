import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart';

// Services
import 'services/auth_service.dart';
import 'services/firestore_service.dart';
import 'services/storage_service.dart';
import 'services/notification_service.dart';

// Controllers
import 'controllers/auth_bloc.dart';

// Config
import 'config/app_theme.dart';
import 'config/app_router.dart';

// Views
import 'views/splash_screen.dart';

// Firebase Options (you need to add this file after setting up Firebase)
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    // options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  runApp(MyApp(notificationService: notificationService));
}

class MyApp extends StatelessWidget {
  final NotificationService notificationService;

  const MyApp({
    super.key,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthService>(
          create: (context) => AuthService(),
        ),
        RepositoryProvider<FirestoreService>(
          create: (context) => FirestoreService(),
        ),
        RepositoryProvider<StorageService>(
          create: (context) => StorageService(),
        ),
        RepositoryProvider<NotificationService>(
          create: (context) => notificationService,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authService: context.read<AuthService>(),
            )..add(AuthStarted()),
          ),
        ],
        child: MaterialApp.router(
          title: 'HR Mobile App',
          debugShowCheckedModeBanner: false,
          
          // Theme
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          
          // Localization
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', 'US'), // English
            Locale('si', 'LK'), // Sinhala
            Locale('ta', 'LK'), // Tamil
          ],
          
          // Routing
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
