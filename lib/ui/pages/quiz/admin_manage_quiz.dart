import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/quiz/quiz_bloc.dart';
import '../../../../logic/bloc/quiz/quiz_event.dart';
import '../../../../logic/bloc/quiz/quiz_state.dart';
import '../../pages/quiz/quiz_form_page.dart';
import '../../widgets/shimmer_loading.dart';

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

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    BlocProvider.of<QuizBloc>(
      context,
    ).add(FetchAdminQuizzes(languageId: widget.languageId, isRefresh: true));
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
      final state = BlocProvider.of<QuizBloc>(context).state;
      if (state is QuizAdminListLoaded && !state.hasReachedMax) {
        BlocProvider.of<QuizBloc>(context).add(
          FetchAdminQuizzes(languageId: widget.languageId, isRefresh: false),
        );
      }
    }
  }

  void _confirmDelete(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Soal'),
        content: const Text(
          'Apakah Anda yakin ingin menghapus pertanyaan kuis ini secara permanen?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              BlocProvider.of<QuizBloc>(
                context,
              ).add(DeleteQuizQuestionRequested(id: id));
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kelola Kuis: ${widget.languageName}')),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2C3E50),
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
      body: BlocListener<QuizBloc, QuizState>(
        listener: (context, state) {
          if (state is QuizOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            BlocProvider.of<QuizBloc>(context).add(
              FetchAdminQuizzes(languageId: widget.languageId, isRefresh: true),
            );
          } else if (state is QuizFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: BlocBuilder<QuizBloc, QuizState>(
          builder: (context, state) {
            if (state is QuizLoading) {
              return ListView.builder(
                itemCount: 5,
                itemBuilder: (context, index) => const ShimmerLoading(),
              );
            }

            if (state is QuizAdminListLoaded) {
              if (state.questions.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada soal kuis terdaftar untuk bahasa ini.',
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
                    margin: const EdgeInsets.symmetric(
                      vertical: 6,
                      horizontal: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      title: Text(
                        quiz.question,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6.0),
                        child: Text(
                          'Kunci Jawaban: Opsi ${quiz.answer.toUpperCase()}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.orange),
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
                            icon: const Icon(Icons.delete, color: Colors.red),
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
    );
  }
}
