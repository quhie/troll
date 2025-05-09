import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'views/enter_view.dart';
import 'viewmodels/theme_viewmodel.dart';
import 'services/permissions_service.dart';
import 'utils/app_theme.dart';
import 'utils/constants.dart';
import 'widgets/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Request permissions
  final permissionsService = PermissionsService();
  await permissionsService.requestAllPermissions();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeViewModel()),
      ],
      child: const TrollApp(),
    );
  }
}

class TrollApp extends StatelessWidget {
  const TrollApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeViewModel = Provider.of<ThemeViewModel>(context);
    
    return MaterialApp(
      title: Constants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: themeViewModel.themeMode,
      builder: (context, child) {
        // Add a global scroll behavior to avoid overflow issues
        return ScrollConfiguration(
          behavior: const ScrollBehavior().copyWith(
            physics: const BouncingScrollPhysics(),
            overscroll: false,
          ),
          child: child!,
        );
      },
      home: const SplashScreen(),
    );
  }
}
