import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'field_notes.dart';
import 'lobby.dart';
import 'preferences.dart';
import 'workshop.dart';

class Deck extends StatefulWidget {
  const Deck({super.key});

  @override
  State<Deck> createState() => _DeckState();
}

class _DeckState extends State<Deck> {
  int _tab = 0;

  static const _titles = ['Send Files to TV: Share', 'Tools', 'Guides'];

  void _select(int index) {
    if (index == _tab) return;
    setState(() => _tab = index);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            _titles[_tab],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
          ),
          actions: [
            IconButton(
              tooltip: 'Settings',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const Preferences()),
                );
              },
              icon: const Icon(Icons.tune),
            ),
          ],
        ),
        body: IndexedStack(
          index: _tab,
          children: const [Lobby(), Workshop(), FieldNotes()],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _tab,
          onDestinationSelected: _select,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded),
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
