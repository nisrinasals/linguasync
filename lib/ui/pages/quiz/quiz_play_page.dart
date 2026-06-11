import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/quiz/quiz_bloc.dart';
import '../../../../logic/bloc/quiz/quiz_event.dart';
import '../../../../logic/bloc/quiz/quiz_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/quiz_option_button.dart';

class QuizPlayPage extends StatefulWidget {
  final int languageId;
  final String languageName;

  const QuizPlayPage({super.key, required this.languageId, required this.languageName});

  @override
  State<QuizPlayPage> createState() => _QuizPlayPageState();
}

class _QuizPlayPageState extends State<QuizPlayPage> {
  String? _selectedOption;

  @override
  void initState() {
    super.initState();
    BlocProvider.of<QuizBloc>(context).add(StartQuiz(languageId: widget.languageId));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Kuis ${widget.languageName}'),
          automaticallyImplyLeading: false,
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizQuestionActive) {
              setState(() {
                _selectedOption = null;
              });
            }
            if (state is QuizOperationSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)),
              );
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF2C3E50)),
              );
            }

            if (state is QuizQuestionActive) {
              final question = state.questions[state.currentIndex];
              return Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Pertanyaan ${state.currentIndex + 1}/${state.questions.length}',
                          style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2C3E50),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${state.remainingSeconds}s',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: state.remainingSeconds / 5,
                      color: const Color(0xFF2C3E50),
                      backgroundColor: Colors.grey[300],
                    ),
                    const SizedBox(height: 32),
                    Text(
                      question.question,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                    ),
                    const SizedBox(height: 32),
                    QuizOptionButton(
                      label: 'A',
                      text: question.optA,
                      isSelected: _selectedOption == 'A',
                      onPressed: () {
                        setState(() => _selectedOption = 'A');
                        BlocProvider.of<QuizBloc>(context).add(const AnswerSelected(selectedOption: 'A'));
                      },
                    ),
                    QuizOptionButton(
                      label: 'B',
                      text: question.optB,
                      isSelected: _selectedOption == 'B',
                      onPressed: () {
                        setState(() => _selectedOption = 'B');
                        BlocProvider.of<QuizBloc>(context).add(const AnswerSelected(selectedOption: 'B'));
                      },
                    ),
                    QuizOptionButton(
                      label: 'C',
                      text: question.optC,
                      isSelected: _selectedOption == 'C',
                      onPressed: () {
                        setState(() => _selectedOption = 'C');
                        BlocProvider.of<QuizBloc>(context).add(const AnswerSelected(selectedOption: 'C'));
                      },
                    ),
                    QuizOptionButton(
                      label: 'D',
                      text: question.optD,
                      isSelected: _selectedOption == 'D',
                      onPressed: () {
                        setState(() => _selectedOption = 'D');
                        BlocProvider.of<QuizBloc>(context).add(const AnswerSelected(selectedOption: 'D'));
                      },
                    ),
                  ],
                ),
              );
            }

            if (state is QuizFinished) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.emoji_events, size: 80, color: Color(0xFFFFD700)),
                      const SizedBox(height: 24),
                      const Text(
                        'Kuis Selesai!',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Skor Anda: ${state.score.toStringAsFixed(1)}',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Benar ${state.correctAnswers} dari ${state.totalQuestions} soal',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(height: 40),
                      CustomButton(
                        text: 'Simpan & Selesai',
                        onPressed: () {
                          BlocProvider.of<QuizBloc>(context).add(
                            SubmitQuizResultRequested(languageId: widget.languageId, score: state.score),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is QuizFailure) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.error, style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Kembali'),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }
}