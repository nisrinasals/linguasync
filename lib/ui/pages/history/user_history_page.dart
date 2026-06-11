import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/history/history_bloc.dart';
import '../../../../logic/bloc/history/history_event.dart';
import '../../../../logic/bloc/history/history_state.dart';
import '../../widgets/shimmer_loading.dart';

class UserHistoryPage extends StatefulWidget {
  const UserHistoryPage({super.key});

  @override
  State<UserHistoryPage> createState() => _UserHistoryPageState();
}

class _UserHistoryPageState extends State<UserHistoryPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    BlocProvider.of<HistoryBloc>(
      context,
    ).add(const FetchHistory(isRefresh: true));
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
      final state = BlocProvider.of<HistoryBloc>(context).state;
      if (state is HistoryLoaded && !state.hasReachedMax) {
        BlocProvider.of<HistoryBloc>(
          context,
        ).add(const FetchHistory(isRefresh: false));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Kuis')),
      body: BlocBuilder<HistoryBloc, HistoryState>(
        builder: (context, state) {
          if (state is HistoryLoading) {
            return ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) => const ShimmerLoading(),
            );
          }

          if (state is HistoryLoaded) {
            if (state.histories.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.history, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Belum ada riwayat pengerjaan kuis.',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                BlocProvider.of<HistoryBloc>(
                  context,
                ).add(const FetchHistory(isRefresh: true));
              },
              child: ListView.builder(
                controller: _scrollController,
                itemCount: state.hasReachedMax
                    ? state.histories.length
                    : state.histories.length + 1,
                itemBuilder: (context, index) {
                  if (index >= state.histories.length) {
                    return const ShimmerLoading();
                  }

                  final history = state.histories[index];
                  final isPassed = history.score >= 60;

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(16),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF2C3E50),
                        child: Icon(Icons.assignment, color: Colors.white),
                      ),
                      title: Text(
                        history.languageName ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          history.createdAt,
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: isPassed ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${history.score.toStringAsFixed(0)} Pts',
                          style: TextStyle(
                            color: isPassed
                                ? Colors.green[700]
                                : Colors.red[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }

          if (state is HistoryFailure) {
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
    );
  }
}
