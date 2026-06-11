import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linguasync/data/provider/storage_provider.dart';
import 'package:linguasync/data/repositories/auth_repository.dart';
import 'package:linguasync/data/repositories/language_repository.dart';
import 'package:linguasync/data/repositories/material_repository.dart';
import 'package:linguasync/data/repositories/quiz_repository.dart';
import 'package:linguasync/data/repositories/leaderboard_repository.dart';
import 'package:linguasync/data/repositories/history_repository.dart';
import 'package:linguasync/logic/bloc/auth/auth_bloc.dart';
import 'package:linguasync/logic/bloc/language/language_bloc.dart';
import 'package:linguasync/logic/bloc/material/material_bloc.dart';
import 'package:linguasync/logic/bloc/quiz/quiz_bloc.dart';
import 'package:linguasync/logic/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:linguasync/logic/bloc/history/history_bloc.dart';
import 'package:linguasync/logic/debug/bloc_observer.dart';
import 'package:linguasync/ui/pages/auth/splash_page.dart';
import 'package:linguasync/ui/pages/auth/login_page.dart';
import 'package:linguasync/ui/pages/auth/register_page.dart';
import 'package:linguasync/ui/pages/languages/explore_languages.dart';
import 'package:linguasync/ui/pages/languages/my_study_page.dart';
import 'package:linguasync/ui/pages/languages/admin_manage_language_page.dart';
import 'package:linguasync/ui/pages/leaderboard/global_leaderboard_page.dart';
import 'package:linguasync/ui/pages/history/user_history_page.dart';
import 'package:linguasync/ui/pages/admin/admin_dashboard_page.dart';

void main() {
  Bloc.observer = AppBlocObserver();
  final storageProvider = StorageProvider();

  runApp(LinguaSyncApp(storageProvider: storageProvider));
}

class LinguaSyncApp extends StatelessWidget {
  final StorageProvider storageProvider;

  const LinguaSyncApp({super.key, required this.storageProvider});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>(
          create: (context) => AuthRepository(storageProvider: storageProvider),
        ),
        RepositoryProvider<LanguageRepository>(
          create: (context) => LanguageRepository(storageProvider: storageProvider),
        ),
        RepositoryProvider<MaterialRepository>(
          create: (context) => MaterialRepository(storageProvider: storageProvider),
        ),
        RepositoryProvider<QuizRepository>(
          create: (context) => QuizRepository(storageProvider: storageProvider),
        ),
        RepositoryProvider<LeaderboardRepository>(
          create: (context) => LeaderboardRepository(storageProvider: storageProvider),
        ),
        RepositoryProvider<HistoryRepository>(
          create: (context) => HistoryRepository(storageProvider: storageProvider),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthBloc>(
            create: (context) => AuthBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            ),
          ),
          BlocProvider<LanguageBloc>(
            create: (context) => LanguageBloc(
              languageRepository: RepositoryProvider.of<LanguageRepository>(context),
            ),
          ),
          BlocProvider<MaterialBloc>(
            create: (context) => MaterialBloc(
              materialRepository: RepositoryProvider.of<MaterialRepository>(context),
            ),
          ),
          BlocProvider<QuizBloc>(
            create: (context) => QuizBloc(
              quizRepository: RepositoryProvider.of<QuizRepository>(context),
            ),
          ),
          BlocProvider<LeaderboardBloc>(
            create: (context) => LeaderboardBloc(
              leaderboardRepository: RepositoryProvider.of<LeaderboardRepository>(context),
            ),
          ),
          BlocProvider<HistoryBloc>(
            create: (context) => HistoryBloc(
              historyRepository: RepositoryProvider.of<HistoryRepository>(context),
            ),
          ),
        ],
        child: MaterialApp(
          title: 'LinguaSync',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            primaryColor: const Color(0xFF2C3E50),
            scaffoldBackgroundColor: const Color(0xFFF8F9FA),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: IconThemeData(color: Color(0xFF2C3E50)),
              titleTextStyle: TextStyle(
                color: Color(0xFF2C3E50),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            useMaterial3: true,
          ),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/explore-language': (context) => const ExploreLanguagePage(),
            '/my-study': (context) => const MyStudyPage(),
            '/leaderboard': (context) => const GlobalLeaderboardPage(),
            '/history': (context) => const UserHistoryPage(),
            '/admin-dashboard': (context) => const AdminDashboardPage(),
            '/admin-manage-language': (context) => const AdminManageLanguagePage(),
          },
        ),
      ),
    );
  }
}