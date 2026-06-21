import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:linguasync/data/provider/storage_provider.dart';
import 'package:linguasync/data/repositories/auth_repository.dart';
import 'package:linguasync/data/repositories/language_repository.dart';
import 'package:linguasync/data/repositories/material_repository.dart';
import 'package:linguasync/data/repositories/quiz_repository.dart';
import 'package:linguasync/data/repositories/leaderboard_repository.dart';
import 'package:linguasync/data/repositories/history_repository.dart';
import 'package:linguasync/data/repositories/user_repository.dart';
import 'package:linguasync/logic/bloc/auth/auth_bloc.dart';
import 'package:linguasync/logic/bloc/auth/auth_state.dart';
import 'package:linguasync/logic/bloc/language/language_bloc.dart';
import 'package:linguasync/logic/bloc/language/language_event.dart';
import 'package:linguasync/logic/bloc/material/material_bloc.dart';
import 'package:linguasync/logic/bloc/quiz/quiz_bloc.dart';
import 'package:linguasync/logic/bloc/quiz/quiz_event.dart';
import 'package:linguasync/logic/bloc/leaderboard/leaderboard_bloc.dart';
import 'package:linguasync/logic/bloc/leaderboard/leaderboard_event.dart';
import 'package:linguasync/logic/bloc/history/history_bloc.dart';
import 'package:linguasync/logic/bloc/history/history_event.dart';
import 'package:linguasync/logic/bloc/profile/profile_bloc.dart';
import 'package:linguasync/logic/bloc/admin_user/admin_user_bloc.dart';
import 'package:linguasync/logic/bloc/admin_history/admin_history_bloc.dart';
import 'package:linguasync/logic/bloc/admin_language/admin_language_bloc.dart';
import 'package:linguasync/logic/bloc/admin_material/admin_material_bloc.dart';
import 'package:linguasync/logic/bloc/admin_quiz/admin_quiz_bloc.dart';
import 'package:linguasync/logic/debug/bloc_observer.dart';
import 'package:linguasync/ui/pages/auth/splash_page.dart';
import 'package:linguasync/ui/pages/auth/login_page.dart';
import 'package:linguasync/ui/pages/auth/register_page.dart';
import 'package:linguasync/ui/pages/languages/explore_languages.dart';
import 'package:linguasync/ui/pages/languages/my_study_page.dart';
import 'package:linguasync/ui/pages/main_navigation_page.dart';
import 'package:linguasync/ui/pages/admin/admin_manage_language_page.dart';
import 'package:linguasync/ui/pages/leaderboard/global_leaderboard_page.dart';
import 'package:linguasync/ui/pages/history/user_history_page.dart';
import 'package:linguasync/ui/pages/admin/admin_dashboard_page.dart';
import 'package:linguasync/ui/theme/japandi_theme.dart';

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
        RepositoryProvider<UserRepository>(
          create: (context) => UserRepository(storageProvider: storageProvider),
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
          BlocProvider<ProfileBloc>(
            create: (context) => ProfileBloc(
              authRepository: RepositoryProvider.of<AuthRepository>(context),
            ),
          ),
          BlocProvider<AdminUserBloc>(
            create: (context) => AdminUserBloc(
              userRepository: RepositoryProvider.of<UserRepository>(context),
            ),
          ),
          BlocProvider<AdminHistoryBloc>(
            create: (context) => AdminHistoryBloc(
              historyRepository: RepositoryProvider.of<HistoryRepository>(context),
            ),
          ),
          BlocProvider<AdminLanguageBloc>(
            create: (context) => AdminLanguageBloc(
              languageRepository: RepositoryProvider.of<LanguageRepository>(context),
            ),
          ),
          BlocProvider<AdminMaterialBloc>(
            create: (context) => AdminMaterialBloc(
              materialRepository: RepositoryProvider.of<MaterialRepository>(context),
            ),
          ),
          BlocProvider<AdminQuizBloc>(
            create: (context) => AdminQuizBloc(
              quizRepository: RepositoryProvider.of<QuizRepository>(context),
            ),
          ),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is Unauthenticated) {
              context.read<LanguageBloc>().add(ResetLanguageData());
              context.read<QuizBloc>().add(ResetQuizData());
              context.read<LeaderboardBloc>().add(ResetLeaderboardData());
              context.read<HistoryBloc>().add(ResetHistoryData());
            }
          },
          child: MaterialApp(
            title: 'LinguaSync',
            debugShowCheckedModeBanner: false,
            theme: buildJapandiTheme(),
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashPage(),
            '/login': (context) => const LoginPage(),
            '/register': (context) => const RegisterPage(),
            '/main': (context) => const MainNavigationPage(),
            '/explore-language': (context) => const ExploreLanguagePage(),
            '/my-study': (context) => const MyStudyPage(),
            '/leaderboard': (context) => const GlobalLeaderboardPage(),
            '/history': (context) => const UserHistoryPage(),
            '/admin-dashboard': (context) => const AdminDashboardPage(),
            '/admin-manage-language': (context) => const AdminManageLanguagePage(),
          },
        ),
      ),
      ),
    );
  }
}