import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/admin_quiz/admin_quiz_bloc.dart';
import '../../../../logic/bloc/admin_quiz/admin_quiz_event.dart';
import '../../../../logic/bloc/admin_quiz/admin_quiz_state.dart';
import 'quiz_form_page.dart';
import '../../widgets/shimmer_loading.dart';
import '../../theme/japandi_theme.dart';

class AdminManageQuizPage extends StatefulWidget {
  final int languageId;
  final String languageName;

  const AdminManageQuizPage({
    super.key,
    required this.languageId,
    required this.languageName,
  });

  @override
  State<AdminManageQuizPage> createState() => _AdminManageQuizPageState();
}

class _AdminManageQuizPageState extends State<AdminManageQuizPage> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<AdminQuizBloc>().add(
      FetchAdminQuizzes(languageId: widget.languageId, isRefresh: true),
    );
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = context.read<AdminQuizBloc>().state;
      if (state is AdminQuizListLoaded && !state.hasReachedMax) {
        context.read<AdminQuizBloc>().add(
          FetchAdminQuizzes(
            languageId: widget.languageId,
            search: _searchController.text.trim(),
            isRefresh: false,
          ),
        );
      }
    }
  }

  void _onSearchChanged(String query) {
    context.read<AdminQuizBloc>().add(
      FetchAdminQuizzes(
        languageId: widget.languageId,
        search: query.trim(),
        isRefresh: true,
      ),
    );
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Hapus Soal', style: JT.titleMd),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pertanyaan kuis ini secara permanen?',
          style: JT.bodySm,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: JC.error),
            onPressed: () {
              context.read<AdminQuizBloc>().add(DeleteQuizQuestionRequested(id: id));
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Kelola Kuis: ${widget.languageName}',
          style: JT.titleLg,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: JC.primary,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => QuizFormPage(languageId: widget.languageId),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: BlocListener<AdminQuizBloc, AdminQuizState>(
        listener: (context, state) {
          if (state is AdminQuizOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            context.read<AdminQuizBloc>().add(
              FetchAdminQuizzes(
                languageId: widget.languageId,
                search: _searchController.text.trim(),
                isRefresh: true,
              ),
            );
          } else if (state is AdminQuizFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: JC.error,
              ),
            );
          }
        },
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(color: JC.ink, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Cari soal kuis...',
                  hintStyle: const TextStyle(color: JC.inkLt, fontSize: 14),
                  prefixIcon: const Icon(Icons.search, color: JC.inkLt, size: 20),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  filled: true,
                  fillColor: JC.bgCard,
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<AdminQuizBloc, AdminQuizState>(
                builder: (context, state) {
                  if (state is AdminQuizLoading) {
                    return ListView.builder(
                      itemCount: 5,
                      itemBuilder: (context, index) => const ShimmerLoading(),
                    );
                  }

                  if (state is AdminQuizListLoaded) {
                    if (state.questions.isEmpty) {
                      return const Center(
                        child: Text(
                          'Tidak ada soal kuis ditemukan.',
                          style: JT.body,
                        ),
                      );
                    }

                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: state.hasReachedMax
                          ? state.questions.length
                          : state.questions.length + 1,
                      itemBuilder: (context, index) {
                        if (index >= state.questions.length) {
                          return const ShimmerLoading();
                        }

                        final quiz = state.questions[index];
                        return Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            title: Text(
                              quiz.question,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: JT.titleMd,
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 6.0),
                              child: Text(
                                'Kunci Jawaban: Opsi ${quiz.answer.toUpperCase()}',
                                style: const TextStyle(
                                  color: JC.success,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => QuizFormPage(
                                          languageId: widget.languageId,
                                          quiz: quiz,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: JC.error,
                                  ),
                                  onPressed: () => _confirmDelete(quiz.id),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
