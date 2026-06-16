import 'package:flutter/material.dart';
import 'package:linguasync/ui/pages/languages/explore_languages.dart';
import 'package:linguasync/ui/pages/languages/my_study_page.dart';
import 'package:linguasync/ui/pages/leaderboard/global_leaderboard_page.dart';
import 'package:linguasync/ui/pages/history/user_history_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linguasync/logic/bloc/language/language_bloc.dart';
import 'package:linguasync/logic/bloc/language/language_event.dart';
import 'package:linguasync/logic/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:linguasync/logic/bloc/leaderboard/leaderboard_event.dart';
import 'package:linguasync/logic/bloc/history/history_bloc.dart';
import 'package:linguasync/logic/bloc/history/history_event.dart';
import 'package:linguasync/ui/theme/japandi_theme.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<LanguageBloc>().add(const FetchLanguages(isRefresh: true));
  }

  final List<Widget> _pages = [
    const ExploreLanguagePage(),
    const MyStudyPage(),
    const GlobalLeaderboardPage(),
    const UserHistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);

    if (index == 0) {
      context.read<LanguageBloc>().add(const FetchLanguages(isRefresh: true));
    } else if (index == 1) {
      context.read<LanguageBloc>().add(const FetchMyLanguages(isRefresh: true));
    } else if (index == 2) {
      context.read<LeaderboardBloc>().add(const FetchLeaderboard(isRefresh: true));
    } else if (index == 3) {
      context.read<HistoryBloc>().add(const FetchHistory(isRefresh: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: JC.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.explore_outlined),
              activeIcon: Icon(Icons.explore),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_outlined),
              activeIcon: Icon(Icons.menu_book),
              label: 'Studi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.leaderboard_outlined),
              activeIcon: Icon(Icons.leaderboard),
              label: 'Peringkat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_outlined),
              activeIcon: Icon(Icons.history),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }
}
