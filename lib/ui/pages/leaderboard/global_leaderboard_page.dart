import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/leaderboard/leaderboard_bloc.dart';
import '../../../../logic/bloc/leaderboard/leaderboard_event.dart';
import '../../../../logic/bloc/leaderboard/leaderboard_state.dart';
import '../../widgets/leaderboard_tile.dart';
import '../../widgets/shimmer_loading.dart';
import '../../theme/japandi_theme.dart';

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
    BlocProvider.of<LeaderboardBloc>(context).add(const FetchLeaderboard(isRefresh: true));
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
        BlocProvider.of<LeaderboardBloc>(context).add(const FetchLeaderboard(isRefresh: false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Papan Peringkat')),
      body: Column(
        children: [
          // Current user stats banner
          BlocBuilder<LeaderboardBloc, LeaderboardState>(
            builder: (context, state) {
              if (state is LeaderboardLoaded) {
                return Container(
                  margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: JC.ink,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(
                        label: 'Peringkat Saya',
                        value: state.currentUserRank != null
                            ? '#${state.currentUserRank}'
                            : '—',
                      ),
                      Container(width: 1, height: 36, color: Colors.white12),
                      _buildStat(
                        label: 'Total Skor',
                        value: '${state.currentUserScore.toStringAsFixed(0)} pts',
                      ),
                    ],
                  ),
                );
              }
              return const SizedBox();
            },
          ),

          const SizedBox(height: 12),

          Expanded(
            child: BlocBuilder<LeaderboardBloc, LeaderboardState>(
              builder: (context, state) {
                if (state is LeaderboardLoading) {
                  return ListView.builder(
                    itemCount: 5,
                    itemBuilder: (_, __) => const ShimmerLoading(),
                  );
                }

                if (state is LeaderboardLoaded) {
                  if (state.rankings.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: JC.bgMuted,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.leaderboard_outlined, color: JC.inkLt, size: 32),
                          ),
                          const SizedBox(height: 16),
                          const Text('Belum ada data kompetisi', style: JT.titleMd),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    color: JC.primary,
                    backgroundColor: JC.bgCard,
                    onRefresh: () async {
                      BlocProvider.of<LeaderboardBloc>(context)
                          .add(const FetchLeaderboard(isRefresh: true));
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(bottom: 20),
                      itemCount: state.hasReachedMax
                          ? state.rankings.length
                          : state.rankings.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.rankings.length) {
                          return const ShimmerLoading();
                        }
                        return LeaderboardTile(leaderboard: state.rankings[index]);
                      },
                    ),
                  );
                }

                if (state is LeaderboardFailure) {
                  return Center(
                    child: Text(state.error, style: const TextStyle(color: JC.error)),
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

  Widget _buildStat({required String label, required String value}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 12, letterSpacing: 0.3),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}
