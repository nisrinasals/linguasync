import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/leaderboard/leaderboard_bloc.dart';
import '../../../../logic/bloc/leaderboard/leaderboard_event.dart';
import '../../../../logic/bloc/leaderboard/leaderboard_state.dart';
import '../../widgets/leaderboard_tile.dart';
import '../../widgets/shimmer_loading.dart';

class GlobalLeaderboardPage extends StatefulWidget {
  const GlobalLeaderboardPage({super.key});

  @override
  State<GlobalLeaderboardPage> createState() => _GlobalLeaderboardPageState();
}

class _GlobalLeaderboardPageState extends State<GlobalLeaderboardPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    BlocProvider.of<LeaderboardBloc>(
      context,
    ).add(const FetchLeaderboard(isRefresh: true));
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = BlocProvider.of<LeaderboardBloc>(context).state;
      if (state is LeaderboardLoaded && !state.hasReachedMax) {
        BlocProvider.of<LeaderboardBloc>(
          context,
        ).add(const FetchLeaderboard(isRefresh: false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Papan Peringkat Global')),
      body: Column(
        children: [
          BlocBuilder<LeaderboardBloc, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoaded) {
                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C3E50),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Column(
                        children: [
                          const Text(
                            'Peringkat Anda',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            state.currentUserRank != null
                                ? '#${state.currentUserRank}'
                                : '-',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(width: 1, height: 40, color: Colors.white24),
                      Column(
                        children: [
                          const Text(
                            'Total Skor Kuis',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${state.currentUserScore.toStringAsFixed(0)} Pts',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),
          Expanded(
            child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
              builder: (context, state) {
                if (state is LeaderboardLoading) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => const ShimmerLoading(),
                  );
                }

                if (state is LeaderboardLoaded) {
                  if (state.rankings.isEmpty) {
                    return const Center(
                      child: Text('Belum ada data kompetisi kuis tersedia.'),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      BlocProvider.of<LeaderboardBloc>(
                        context,
                      ).add(const FetchLeaderboard(isRefresh: true));
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: state.hasReachedMax
                          ? state.rankings.length
                          : state.rankings.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.rankings.length) {
                          return const ShimmerLoading();
                        }

                        final rankData = state.rankings[index];
                        return LeaderboardTile(leaderboard: rankData);
                      },
                    ),
                  );
                }

                if (state is LeaderboardFailure) {
                  return Center(
                    child: Text(
                      state.error,
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}
