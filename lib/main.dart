import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/screens.dart';
import 'constants/constants.dart';
import 'services/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SibehGoodBankApp());
}

class SibehGoodBankApp extends StatefulWidget {
  const SibehGoodBankApp({super.key});

  @override
  State<SibehGoodBankApp> createState() => _SibehGoodBankAppState();
}

class _SibehGoodBankAppState extends State<SibehGoodBankApp> {
  late final NavbarConfigProvider _navbarProvider;

  @override
  void initState() {
    super.initState();
    _navbarProvider = NavbarConfigProvider();
    _navbarProvider.initialize();
  }

  @override
  void dispose() {
    _navbarProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Wrap with NavbarConfigScope to provide navbar configuration to all screens
    return NavbarConfigScope(
      provider: _navbarProvider,
      child: MaterialApp(
      title: 'SiBeh Good Bank',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.accent,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        textTheme: const TextTheme(
          displayLarge: AppTextStyles.displayLarge,
          displayMedium: AppTextStyles.displayMedium,
          displaySmall: AppTextStyles.displaySmall,
          headlineLarge: AppTextStyles.headlineLarge,
          headlineMedium: AppTextStyles.headlineMedium,
          headlineSmall: AppTextStyles.headlineSmall,
          titleLarge: AppTextStyles.titleLarge,
          titleMedium: AppTextStyles.titleMedium,
          titleSmall: AppTextStyles.titleSmall,
          bodyLarge: AppTextStyles.bodyLarge,
          bodyMedium: AppTextStyles.bodyMedium,
          bodySmall: AppTextStyles.bodySmall,
          labelLarge: AppTextStyles.labelLarge,
          labelMedium: AppTextStyles.labelMedium,
          labelSmall: AppTextStyles.labelSmall,
        ),
      ),
      home: const SetupLandingScreen(),
      routes: {
        '/setup': (context) => const SetupLandingScreen(),
        '/onboarding': (context) => const OnboardingScreen(),
        '/home': (context) => const RootShell(),
        '/analytics': (context) => const AnalyticsScreen(),
        '/navbar-customization': (context) => const NavbarCustomizationScreen(),
      },
      ),
    );
  }
}
