import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/quiz_model.dart';
import '../../../../logic/bloc/admin_quiz/admin_quiz_bloc.dart';
import '../../../../logic/bloc/admin_quiz/admin_quiz_event.dart';
import '../../../../logic/bloc/admin_quiz/admin_quiz_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../theme/japandi_theme.dart';

class QuizFormPage extends StatefulWidget {
  final int languageId;
  final QuizModel? quiz;

  const QuizFormPage({super.key, required this.languageId, this.quiz});

  @override
  State<QuizFormPage> createState() => _QuizFormPageState();
}

class _QuizFormPageState extends State<QuizFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _optAController;
  late TextEditingController _optBController;
  late TextEditingController _optCController;
  late TextEditingController _optDController;
  String _selectedAnswer = 'A';

  @override
  void initState() {
    super.initState();
    _questionController = TextEditingController(text: widget.quiz?.question ?? '');
    _optAController = TextEditingController(text: widget.quiz?.optA ?? '');
    _optBController = TextEditingController(text: widget.quiz?.optB ?? '');
    _optCController = TextEditingController(text: widget.quiz?.optC ?? '');
    _optDController = TextEditingController(text: widget.quiz?.optD ?? '');
    _selectedAnswer = widget.quiz?.answer.toUpperCase() ?? 'A';
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optAController.dispose();
    _optBController.dispose();
    _optCController.dispose();
    _optDController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.quiz == null) {
        context.read<AdminQuizBloc>().add(
          CreateQuizQuestionRequested(
            languageId: widget.languageId,
            question: _questionController.text.trim(),
            optA: _optAController.text.trim(),
            optB: _optBController.text.trim(),
            optC: _optCController.text.trim(),
            optD: _optDController.text.trim(),
            answer: _selectedAnswer,
          ),
        );
      } else {
        context.read<AdminQuizBloc>().add(
          UpdateQuizQuestionRequested(
            id: widget.quiz!.id,
            question: _questionController.text.trim(),
            optA: _optAController.text.trim(),
            optB: _optBController.text.trim(),
            optC: _optCController.text.trim(),
            optD: _optDController.text.trim(),
            answer: _selectedAnswer,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.quiz == null ? 'Tambah Soal Kuis' : 'Edit Soal Kuis',
          style: JT.titleLg,
        ),
      ),
      body: BlocListener<AdminQuizBloc, AdminQuizState>(
        listener: (context, state) {
          if (state is AdminQuizOperationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
            // Refresh list in AdminQuizBloc
            context.read<AdminQuizBloc>().add(
              FetchAdminQuizzes(
                languageId: widget.languageId,
                isRefresh: true,
              ),
            );
            Navigator.pop(context);
          } else if (state is AdminQuizFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: JC.error,
              ),
            );
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              CustomTextField(
                controller: _questionController,
                label: 'Pertanyaan Kuis',
                maxLines: 3,
                validator: (val) => val == null || val.isEmpty ? 'Pertanyaan kuis wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _optAController,
                label: 'Pilihan Opsi A',
                validator: (val) => val == null || val.isEmpty ? 'Opsi A wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _optBController,
                label: 'Pilihan Opsi B',
                validator: (val) => val == null || val.isEmpty ? 'Opsi B wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _optCController,
                label: 'Pilihan Opsi C',
                validator: (val) => val == null || val.isEmpty ? 'Opsi C wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              CustomTextField(
                controller: _optDController,
                label: 'Pilihan Opsi D',
                validator: (val) => val == null || val.isEmpty ? 'Opsi D wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAnswer,
                dropdownColor: JC.bgCard,
                style: JT.body.copyWith(fontWeight: FontWeight.w600),
                decoration: const InputDecoration(
                  labelText: 'Kunci Jawaban yang Benar',
                ),
                items: ['A', 'B', 'C', 'D'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text('Opsi $value'),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedAnswer = newValue!;
                  });
                },
              ),
              const SizedBox(height: 32),
              BlocBuilder<AdminQuizBloc, AdminQuizState>(
                builder: (context, state) {
                  return CustomButton(
                    onPressed: _submit,
                    text: widget.quiz == null ? 'Simpan Pertanyaan' : 'Perbarui Pertanyaan',
                    isLoading: state is AdminQuizLoading,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
