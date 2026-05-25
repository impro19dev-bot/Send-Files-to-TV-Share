import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'util/ads_helper.dart';
import 'screens/main_shell.dart';
import 'screens/onboarding_screen.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

void bootstrapApp(SharedPreferences prefs) {
  runApp(SendFilesToTvApp(prefs: prefs));
}

class SendFilesToTvApp extends StatelessWidget {
  const SendFilesToTvApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return AppOpenLifecycleObserver(
      child: MaterialApp(
        title: 'Send files to TV',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: SplashScreen(
          onFinished: (context) {
            final completed = prefs.getBool(kOnboardingCompleteKey) ?? false;
            final Widget next = completed
                ? const MainShell()
                : OnboardingScreen(prefs: prefs);
            if (next is MainShell) {
              OpenAdGate.scheduleBeforeHome();
            }
            Navigator.of(context).pushReplacement(
              PageRouteBuilder<void>(
                pageBuilder: (context, animation, secondaryAnimation) => next,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                transitionDuration: const Duration(milliseconds: 450),
              ),
            );
          },
        ),
      ),
    );
  }
}

const String kOnboardingCompleteKey = 'onboarding_complete_v1';
