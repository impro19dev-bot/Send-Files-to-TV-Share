import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app.dart';
import '../util/ads_helper.dart';
import '../theme/app_colors.dart';
import '../widgets/local_network_illustration.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _pages = _OnboardingContent._all;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _complete() async {
    await widget.prefs.setBool(kOnboardingCompleteKey, true);
    if (!mounted) return;
    OpenAdGate.scheduleBeforeHome();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const MainShell()),
    );
  }

  void _next() {
    if (_index >= _pages.length - 1) {
      _complete();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppColors.screenBackground,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _pages.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (context, i) {
                    final p = _pages[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          Text(
                            p.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (p.illustration != null) ...[
                            p.illustration!,
                            const SizedBox(height: 24),
                          ],
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                p.body,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.92),
                                  fontSize: 16,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: Row(
                  children: [
                    TextButton(
                      onPressed: _complete,
                      child: Text(
                        'SKIP',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          final active = i == _index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: active ? 9 : 7,
                            height: active ? 9 : 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: active
                                  ? Colors.white
                                  : Colors.white.withValues(alpha: 0.28),
                            ),
                          );
                        }),
                      ),
                    ),
                    IconButton(
                      onPressed: _next,
                      icon: const Icon(
                        Icons.chevron_right,
                        color: Colors.white,
                      ),
                      iconSize: 36,
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardingContent {
  const _OnboardingContent({
    required this.title,
    required this.body,
    this.illustration,
  });

  final String title;
  final String body;
  final Widget? illustration;

  static const List<_OnboardingContent> _all = [
    _OnboardingContent(
      title: 'Introduction',
      illustration: LocalNetworkIllustration(height: 220),
      body:
          'Send files to TV (SFTTV) works on your home Wi‑Fi. Install the companion '
          'receiver on your TV (many brands use an Android TV–based store) and the '
          'sender app on each phone, tablet, or computer you want to transfer from. '
          'Exact store names depend on your TV platform—use your TV’s app directory '
          'and the publisher’s instructions.',
    ),
    _OnboardingContent(
      title: 'Network tools',
      body:
          'Use the planner to plug in realistic link speeds, then estimate how long '
          'large files will take. For real measurements, use a reputable speed test '
          'or your router’s diagnostics—this app does not replace those tools.',
    ),
    _OnboardingContent(
      title: 'Compatibility',
      body:
          'Skim typical TV notes and format rules, then use the calculator with '
          'speeds you trust (from a real test or your ISP). Treat every result as a '
          'starting point, not a guarantee.',
    ),
    _OnboardingContent(
      title: 'Guides',
      body:
          'Step‑by‑step walkthroughs for AirPlay, Chromecast, and other popular '
          'ways to stream from your iPhone or iPad to the big screen.',
    ),
  ];
}
