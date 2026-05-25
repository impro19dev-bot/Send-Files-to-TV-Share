import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../util/ads_helper.dart';
import '../widgets/main_banner_ad.dart';
import '../widgets/sfttv_logo.dart';
import 'home_dashboard.dart';
import 'guides_screen.dart';
import 'settings_screen.dart';
import 'tools_hub_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      OpenAdGate.showBeforeHomeOnce();
    });
  }

  void _selectTab(int i) {
    if (i == _index) return;
    setState(() => _index = i);
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
        appBar: AppBar(
          centerTitle: true,
          actions: [
            IconButton(
              tooltip: 'Settings',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () async {
                await showInterstitialThen(() {
                  if (!context.mounted) return;
                  pushWithInterstitialBack<void>(
                    context,
                    const SettingsScreen(),
                  );
                });
              },
            ),
          ],
          title: _index == 0
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    SfttvLogo(size: 36),
                    SizedBox(width: 10),
                    Text(
                      'Send files to TV',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                )
              : Text(
                  _index == 1 ? 'Tools' : 'Guides',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
        ),
        body: Column(
          children: [
            Expanded(
              child: IndexedStack(
                index: _index,
                children: const [
                  HomeDashboard(),
                  ToolsHubScreen(),
                  GuidesScreen(),
                ],
              ),
            ),
            const MainBannerAd(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _index,
          onDestinationSelected: (i) {
            if (i == _index) return;
            switch (i) {
              case 0: // Home
                showRewardedThen(() => _selectTab(0));
              case 2: // Guides
                showRewardedThen(() => _selectTab(2));
              case 1: // Tools
                showInterstitialThen(() => _selectTab(1));
              default:
                _selectTab(i);
            }
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.build_outlined),
              selectedIcon: Icon(Icons.build),
              label: 'Tools',
            ),
            NavigationDestination(
              icon: Icon(Icons.menu_book_outlined),
              selectedIcon: Icon(Icons.menu_book),
              label: 'Guides',
            ),
          ],
        ),
      ),
    );
  }
}
