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

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}
class _MainNavigationPageState extends State<MainNavigationPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const ExploreLanguagePage(),
    const MyStudyPage(),
    const GlobalLeaderboardPage(),
    const UserHistoryPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'My Study',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Leaderboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
        ],
      ),
    );
  }
}
