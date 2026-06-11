import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/models/language_model.dart';
import '../../../../logic/bloc/language/language_bloc.dart';
import '../../../../logic/bloc/language/language_event.dart';
import '../../../../logic/bloc/language/language_state.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class LanguageFormPage extends StatefulWidget {
  final LanguageModel? language;

  const LanguageFormPage({super.key, this.language});

  @override
  State<LanguageFormPage> createState() => _LanguageFormPageState();
}

class _LanguageFormPageState extends State<LanguageFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.language?.name ?? '');
    _descController = TextEditingController(
      text: widget.language?.description ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      if (widget.language == null) {
        BlocProvider.of<LanguageBloc>(context).add(
          CreateLanguageRequested(
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
          ),
        );
      } else {
        BlocProvider.of<LanguageBloc>(context).add(
          UpdateLanguageRequested(
            id: widget.language!.id,
            name: _nameController.text.trim(),
            description: _descController.text.trim(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.language == null ? 'Tambah Bahasa' : 'Edit Bahasa'),
      ),
      body: BlocListener<LanguageBloc, LanguageState>(
        listener: (context, state) {
          if (state is LanguageOperationSuccess) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
            BlocProvider.of<LanguageBloc>(
              context,
            ).add(const FetchLanguages(isRefresh: true));
            Navigator.pop(context);
          } else if (state is LanguageFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error)));
          }
        },
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              CustomTextField(
                controller: _nameController,
                label: 'Nama Bahasa',
                validator: (val) => val == null || val.isEmpty
                    ? 'Nama bahasa wajib diisi'
                    : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _descController,
                label: 'Deskripsi',
                maxLines: 4,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Deskripsi wajib diisi' : null,
              ),
              const SizedBox(height: 32),
              BlocBuilder<LanguageBloc, LanguageState>(
                builder: (context, state) {
                  return CustomButton(
                    onPressed: _submit,
                    text: widget.language == null
                        ? 'Simpan Data'
                        : 'Perbarui Data',
                    isLoading: state is LanguageLoading,
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
