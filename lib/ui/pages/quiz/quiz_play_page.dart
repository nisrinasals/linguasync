import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../logic/bloc/quiz/quiz_bloc.dart';
import '../../../../logic/bloc/quiz/quiz_event.dart';
import '../../../../logic/bloc/quiz/quiz_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/quiz_option_button.dart';
import '../../theme/japandi_theme.dart';

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
          title: Text('Kuis — ${widget.languageName}'),
          automaticallyImplyLeading: false,
        ),
        body: BlocConsumer<QuizBloc, QuizState>(
          listener: (context, state) {
            if (state is QuizQuestionActive) {
              setState(() => _selectedOption = null);
            }
            if (state is QuizOperationSuccess) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.message)));
              Navigator.pop(context);
            }
          },
          builder: (context, state) {
            if (state is QuizLoading) {
              return const Center(
                child: CircularProgressIndicator(color: JC.primary, strokeWidth: 2),
              );
            }

            if (state is QuizQuestionActive) {
              final question = state.questions[state.currentIndex];
              final progress = (state.currentIndex + 1) / state.questions.length;

              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Soal ${state.currentIndex + 1} dari ${state.questions.length}',
                            style: JT.bodySm,
                          ),
                          // Timer chip
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: state.remainingSeconds <= 2
                                  ? JC.errorLt
                                  : JC.primarySfc,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: state.remainingSeconds <= 2
                                    ? JC.error
                                    : JC.primaryLt,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.timer_outlined,
                                  size: 14,
                                  color: state.remainingSeconds <= 2 ? JC.error : JC.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${state.remainingSeconds}s',
                                  style: TextStyle(
                                    color: state.remainingSeconds <= 2 ? JC.error : JC.primary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Progress bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 5,
                          color: JC.primary,
                          backgroundColor: JC.bgMuted,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Question text
                      Text(
                        question.question,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: JC.ink,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 28),
                      // Options
                      QuizOptionButton(
                        label: 'A', text: question.optA,
                        isSelected: _selectedOption == 'A',
                        onPressed: () {
                          setState(() => _selectedOption = 'A');
                          BlocProvider.of<QuizBloc>(context)
                              .add(const AnswerSelected(selectedOption: 'A'));
                        },
                      ),
                      QuizOptionButton(
                        label: 'B', text: question.optB,
                        isSelected: _selectedOption == 'B',
                        onPressed: () {
                          setState(() => _selectedOption = 'B');
                          BlocProvider.of<QuizBloc>(context)
                              .add(const AnswerSelected(selectedOption: 'B'));
                        },
                      ),
                      QuizOptionButton(
                        label: 'C', text: question.optC,
                        isSelected: _selectedOption == 'C',
                        onPressed: () {
                          setState(() => _selectedOption = 'C');
                          BlocProvider.of<QuizBloc>(context)
                              .add(const AnswerSelected(selectedOption: 'C'));
                        },
                      ),
                      QuizOptionButton(
                        label: 'D', text: question.optD,
                        isSelected: _selectedOption == 'D',
                        onPressed: () {
                          setState(() => _selectedOption = 'D');
                          BlocProvider.of<QuizBloc>(context)
                              .add(const AnswerSelected(selectedOption: 'D'));
                        },
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is QuizFinished) {
              final isPassed = state.score >= 60;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: isPassed ? JC.successLt : JC.errorLt,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isPassed ? Icons.emoji_events_outlined : Icons.refresh_rounded,
                          size: 50,
                          color: isPassed ? JC.success : JC.error,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isPassed ? 'Kuis Selesai!' : 'Belum Lulus',
                        style: JT.displaySm,
                      ),
                      const SizedBox(height: 12),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: JT.body.copyWith(color: JC.inkMd),
                          children: [
                            const TextSpan(text: 'Skor Anda: '),
                            TextSpan(
                              text: state.score.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: isPassed ? JC.success : JC.error,
                                height: 1.2,
                              ),
                            ),
                            const TextSpan(text: ' pts'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Benar ${state.correctAnswers} dari ${state.totalQuestions} soal',
                        style: JT.bodySm,
                      ),
                      const SizedBox(height: 40),
                      CustomButton(
                        text: 'Simpan & Selesai',
                        onPressed: () {
                          BlocProvider.of<QuizBloc>(context).add(
                            SubmitQuizResultRequested(
                              languageId: widget.languageId,
                              score: state.score,
                            ),
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
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.error, style: const TextStyle(color: JC.error)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Kembali'),
                      ),
                    ],
                  ),
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