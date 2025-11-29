import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:akdeniz_cep/firebase_options.dart';
import 'package:akdeniz_cep/pages/home_page.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

// ✅ EKLENDİ: Onboarding sayfası importu
import 'package:akdeniz_cep/pages/OnBoardingPage.dart';

// ✅ EKLENDİ: shared_preferences importu
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ EKLENDİ: Onboarding daha önce görüldü mü kontrol et
  final prefs = await SharedPreferences.getInstance();
  final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

  // ✅ DEĞİŞTİ: const MainApp() yerine parametreli çağırıyoruz
  runApp(MainApp(hasSeenOnboarding: hasSeenOnboarding));
}

class MainApp extends StatefulWidget {
  const MainApp({
    super.key,

    // ✅ EKLENDİ: onboarding’i görüp görmediği bilgisi
    required this.hasSeenOnboarding,
  });

  // ✅ EKLENDİ: field tanımı
  final bool hasSeenOnboarding;

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Akdeniz Cep',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        splashColor: Colors.transparent,
        hoverColor: Colors.transparent,
      ),
      // Türkçe dil desteği
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr', 'TR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('tr', 'TR'),
      // ✅ DEĞİŞTİ: home artık onboarding flag'ine göre seçiliyor
      home: widget.hasSeenOnboarding
          ? const HomePage() // Onboarding daha önce görüldüyse direkt anasayfa
          : const OnboardingPage(), // İlk defaysa onboarding
    );
  }
}
