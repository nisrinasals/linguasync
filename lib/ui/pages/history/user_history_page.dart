import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/history/history_bloc.dart';
import '../../../../logic/bloc/history/history_event.dart';
import '../../../../logic/bloc/history/history_state.dart';
import '../../widgets/shimmer_loading.dart';
import '../../theme/japandi_theme.dart';
import 'quiz_history_detail_page.dart';

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
    BlocProvider.of<HistoryBloc>(context).add(const FetchHistory(isRefresh: true));
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
        BlocProvider.of<HistoryBloc>(context).add(const FetchHistory(isRefresh: false));
      }
    }
  }

  String _formatDate(String rawDate) {
    try {
      final dt = DateTime.parse(rawDate).toLocal();
      final months = ['Jan','Feb','Mar','Apr','Mei','Jun','Jul','Agu','Sep','Okt','Nov','Des'];
      return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
    } catch (_) {
      return rawDate;
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
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: JC.bgMuted,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(Icons.history, size: 36, color: JC.inkLt),
                    ),
                    const SizedBox(height: 16),
                    const Text('Belum ada riwayat kuis', style: JT.titleMd),
                    const SizedBox(height: 6),
                    Text(
                      'Kerjakan kuis untuk melihat hasilnya di sini.',
                      style: JT.bodySm,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              color: JC.primary,
              backgroundColor: JC.bgCard,
              onRefresh: () async {
                BlocProvider.of<HistoryBloc>(context).add(const FetchHistory(isRefresh: true));
              },
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.only(top: 8, bottom: 20),
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
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizHistoryDetailPage(history: history),
                          ),
                        );
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            // Icon
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isPassed ? JC.successLt : JC.errorLt,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                isPassed ? Icons.check_circle_outline : Icons.cancel_outlined,
                                color: isPassed ? JC.success : JC.error,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    history.languageName ?? '-',
                                    style: JT.titleMd,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    _formatDate(history.createdAt),
                                    style: JT.caption,
                                  ),
                                ],
                              ),
                            ),
                            // Score badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: isPassed ? JC.successLt : JC.errorLt,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isPassed ? JC.success : JC.error,
                                  width: 0.5,
                                ),
                              ),
                              child: Text(
                                '${history.score.toStringAsFixed(0)} pts',
                                style: TextStyle(
                                  color: isPassed ? JC.success : JC.error,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.chevron_right, color: JC.inkLt, size: 18),
                          ],
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
              child: Text(state.error, style: const TextStyle(color: JC.error)),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
