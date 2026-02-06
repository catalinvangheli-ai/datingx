import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'providers/user_provider.dart';
import 'providers/matching_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/language_provider.dart';
import 'config/app_localizations.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const DatingXApp());
}

class DatingXApp extends StatelessWidget {
  const DatingXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => MatchingProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'DatingX - Compatibilitate Profundă',
            debugShowCheckedModeBanner: false,
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('ro'), // Română
              Locale('en'), // English
              Locale('fr'), // Français
              Locale('de'), // Deutsch
              Locale('es'), // Español
              Locale('it'), // Italiano
              Locale('ru'), // Русский
              Locale('hu'), // Magyar
            ],
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFFE91E63),
                brightness: Brightness.light,
              ),
              textTheme: GoogleFonts.poppinsTextTheme(),
            ),
            home: const SplashScreen(), // Start with splash screen to load auth and profile
          );
        },
      ),
    );
  }
}
